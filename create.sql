-- Student Number(s): 10728833	
-- Student Name(s):	Koushik Roy	

/*	Database Creation & Population Script (6 marks)
	Write a script to create the database you designed in Task 1 (incorporating any changes you have made since then).  
	Give your columns the same data types, properties and constraints specified in your data dictionary, and name your tables and columns consistently.  
	Include any suitable default values and any necessary/appropriate CHECK or UNIQUE constraints.

	Make sure this script can be run multiple times without resulting in any errors (hint: drop the database if it exists before trying to create it).
	Adapt the code at the start of the “company.sql” file (Module 5) to implement this.  

	See the brief for further information. 
*/


-- Write your creation script here

/*  Note:  Due to the reciprocal relationships between the consultant and office tables, I recommend using an ALTER TABLE
    statement to create the FK constraint on the director consultant column *after* you have inserted data into both tables.
*/







/*	Database Population Statements
	Following the SQL statements to create your database and its tables, you must include statements to populate the database with sufficient test data.
	You are only required to populate the database with enough data to make sure that all views and queries return meaningful results.
	
	You can start working on your views and queries and write INSERT statements as needed for testing as you go.
	The final create.sql should be able to create your database and populate it with enough data to make sure that all views and queries return meaningful results.

	I have provided data for some of the tables below.
	Adapt the INSERT statements as needed, and write your own INSERT statements for the remaining tables at the end of the file.
*/

/*  The following statement inserts the details of 5 offices into a table named "office".
    It specifies values for a office name, address, and salary, as per the brief.
	If your table has an auto-incrementing PK column, the rows will be given ID numbers of 1, 2, 3 and 4.
	Change the table name if needed, but ensure that your columns can contain the specified data.
*/
USE master
GO

IF DB_ID('primeConsulting') IS NOT NULL
BEGIN
    ALTER DATABASE primeConsulting SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE primeConsulting;
END
GO

CREATE DATABASE primeConsulting;
GO

USE primeConsulting;
GO

-- CREATING SERVICE TABLE

CREATE TABLE ServiceType (
    ServiceID          TINYINT IDENTITY(1,1) NOT NULL,
    ServiceTypeName    VARCHAR(50)           NOT NULL,
    CostPer15Min       SMALLMONEY            NOT NULL,

    CONSTRAINT PKServiceType PRIMARY KEY (ServiceID),

    CONSTRAINT UQServiceTypeName UNIQUE (ServiceTypeName),

    CONSTRAINT CHKCostPer15Min CHECK (CostPer15Min >= 0)
);
GO

-- CREATING CERTIFICATION TABLE 

CREATE TABLE Certification (
    CertificationID      TINYINT IDENTITY(1,1) NOT NULL,
    CertificationName    VARCHAR(50)           NOT NULL,
    IssuingOrganization  VARCHAR(50)           NOT NULL,

    CONSTRAINT PKCertification PRIMARY KEY (CertificationID),

    CONSTRAINT UQCertificationName UNIQUE (CertificationName)
);
GO

-- Grade Table
CREATE TABLE Grade (
    GradeID            TINYINT IDENTITY(1,1) NOT NULL,
    GradeName          VARCHAR(50)           NOT NULL,
    AnnualSalary       MONEY            NOT NULL,
    MinimumExperience  TINYINT               NOT NULL,

    CONSTRAINT PKGrade PRIMARY KEY (GradeID),

    CONSTRAINT UQGradeName UNIQUE (GradeName),

    CONSTRAINT CHKAnnualSalary CHECK (AnnualSalary >= 0),
    CONSTRAINT CHKMinimumExperience CHECK (MinimumExperience >= 0)
);
GO

-- CREATING Office Table 

CREATE TABLE Office (
    OfficeID              TINYINT IDENTITY(1,1) NOT NULL,
    DirectorConsultantID  TINYINT               NULL,
    OfficeName            VARCHAR(50)           NOT NULL,
    OfficeAddress         VARCHAR(200)          NOT NULL,
    OfficePhone           VARCHAR(50)           NOT NULL,

    CONSTRAINT PKOffice PRIMARY KEY (OfficeID),

    CONSTRAINT UQOfficeName UNIQUE (OfficeName)
);
GO

-- CREATING Consultant Table

CREATE TABLE Consultant (
    ConsultantID   TINYINT IDENTITY(1,1) NOT NULL,
    OfficeID       TINYINT               NOT NULL,
    GradeID        TINYINT               NOT NULL,
    MentorID       TINYINT               NULL,
    FirstName      VARCHAR(40)           NOT NULL,
    LastName       VARCHAR(40)           NOT NULL,
    HireDate       DATE                  NOT NULL DEFAULT GETDATE(),

    CONSTRAINT PKConsultant PRIMARY KEY (ConsultantID),

    CONSTRAINT FKConsultant_Office FOREIGN KEY (OfficeID) REFERENCES Office(OfficeID),
    CONSTRAINT FKConsultant_Grade FOREIGN KEY (GradeID) REFERENCES Grade(GradeID),
    CONSTRAINT FKConsultant_Mentor FOREIGN KEY (MentorID) REFERENCES Consultant(ConsultantID),

    CONSTRAINT CHKMentorNotSelf CHECK (MentorID <> ConsultantID)
);
GO

-- Creating Circular 1:1 relationship between Office and Director

ALTER TABLE Office
ADD CONSTRAINT FKOfficeDirector FOREIGN KEY (DirectorConsultantID) REFERENCES Consultant(ConsultantID);


CREATE UNIQUE NONCLUSTERED INDEX UQOfficeDirectorConsultantID
ON Office(DirectorConsultantID)
WHERE DirectorConsultantID IS NOT NULL;
GO

-- Creating Customer Table

CREATE TABLE Customer (
    CustomerID             SMALLINT IDENTITY(1,1) NOT NULL,
    PreferredConsultantID  TINYINT               NULL,
    CustomerFirstName      VARCHAR(50)           NOT NULL,
    CustomerLastName       VARCHAR(50)           NOT NULL,
    CustomerPhone          VARCHAR(50)           NOT NULL,
    CustomerEmail          VARCHAR(200)          NOT NULL,

    CONSTRAINT PKCustomer PRIMARY KEY (CustomerID),

    CONSTRAINT UQCustomerEmail UNIQUE (CustomerEmail),

    CONSTRAINT FKCustomerPreferredConsultant FOREIGN KEY (PreferredConsultantID) REFERENCES Consultant(ConsultantID)
);
GO

-- Creating ConsultantCertification Table 

CREATE TABLE ConsultantCertification (
    ConsultantID      TINYINT NOT NULL,
    CertificationID   TINYINT NOT NULL,

    CONSTRAINT PKConsultantCertification PRIMARY KEY (ConsultantID, CertificationID),

    CONSTRAINT FKConsultantCertificationConsultant FOREIGN KEY (ConsultantID) REFERENCES Consultant(ConsultantID),
    CONSTRAINT FKConsultantCertificationCertification FOREIGN KEY (CertificationID) REFERENCES Certification(CertificationID)
);
GO

-- Creating Project Table

CREATE TABLE Project (
    ProjectID        SMALLINT IDENTITY(1,1) NOT NULL,
    LeaderID         TINYINT               NOT NULL,
    CustomerID       SMALLINT               NOT NULL,
    ServiceID        TINYINT               NOT NULL,
    RequestedTime    SMALLDATETIME         NOT NULL DEFAULT GETDATE(),
    CompletedTime    SMALLDATETIME         NULL,
    AmountPaid       MONEY            NOT NULL DEFAULT 0,
    IsHighPriority   CHAR(1)               NOT NULL DEFAULT 'N',

    CONSTRAINT PKProject PRIMARY KEY (ProjectID),

    CONSTRAINT FKProject_Leader FOREIGN KEY (LeaderID) REFERENCES Consultant(ConsultantID),
    CONSTRAINT FKProject_Customer FOREIGN KEY (CustomerID) REFERENCES Customer(CustomerID),
    CONSTRAINT FKProject_ServiceType FOREIGN KEY (ServiceID) REFERENCES ServiceType(ServiceID),

    CONSTRAINT CHKProjectPriority CHECK (IsHighPriority IN ('Y', 'N')),
    CONSTRAINT CHKProjectDates CHECK (CompletedTime IS NULL OR CompletedTime > RequestedTime),
    CONSTRAINT CHKAmountPaid CHECK (AmountPaid >= 0)
);
GO

-- Creating ProjectConsultant Table

CREATE TABLE ProjectConsultant (
    ConsultantID     TINYINT  NOT NULL,
    ProjectID        SMALLINT  NOT NULL,
    MinutesWorked    INT NOT NULL,

    CONSTRAINT PKProjectConsultant PRIMARY KEY (ConsultantID, ProjectID),

    CONSTRAINT FKProjectConsultantConsultant FOREIGN KEY (ConsultantID) REFERENCES Consultant(ConsultantID),
    CONSTRAINT FKProjectConsultantProject FOREIGN KEY (ProjectID) REFERENCES Project(ProjectID),

    CONSTRAINT CHKProjectConsultantMinutesWorked CHECK (MinutesWorked > 0)
);
GO

-- -----------------------------------------------------------------------------
-- 10. Meeting Table
-- -----------------------------------------------------------------------------
CREATE TABLE Meeting (
    MeetingID           SMALLINT IDENTITY(1,1) NOT NULL,
    ProjectID           SMALLINT               NOT NULL,
    MeetingDateAndTime  DATETIME              NOT NULL,
    MeetingLocation     VARCHAR(50)           NOT NULL,
    MeetingNotes        VARCHAR(200)          NULL,

    CONSTRAINT PKMeeting PRIMARY KEY (MeetingID),
    CONSTRAINT FKMeetingProject FOREIGN KEY (ProjectID) REFERENCES Project(ProjectID)
);
GO


INSERT INTO office (OfficeName, OfficeAddress, OfficePhone, DirectorConsultantID) 
VALUES ('Maylands',  '22 Non Av.',     '9568 2545', NULL), 
	   ('Subiaco',   '19 Eget, St.',   '9652 5624', NULL), 
	   ('Joondalup', '286 Magna. St.', '9547 1546', NULL), 
	   ('Gosnells',  '51 Dui. St.',    '9875 2546', NULL), 
	   ('Perth CBD','123 None. St.',  '9888 1234', NULL);


--/*  The following statement inserts the details of 4 employement grades into a table named "grade".
--    It specifies values for a grade name, annual salary, and minimum experience, as per the brief.
--	If your table has an auto-incrementing PK column, the rows will be given ID numbers of 1, 2, 3 and 4.
--	Change the table name if needed, but ensure that your columns can contain the specified data.
--*/


INSERT INTO Grade (GradeName, AnnualSalary, MinimumExperience) 
VALUES	('Graduate Consultant', 60000, 0), 
		('Associate Consultant', 72000, 2),
		('Consultant', 90000, 5),
		('Senior Consultant', 115000, 8);

--/*  The following statement inserts the details of 4 service types into a table named "service_type".
--    It specifies values for a service type name and cost per 15 minutes, as per the brief.
--    If your table has an auto-incrementing PK column, the rows will be given ID numbers of 1, 2, 3 and 4.
--	Change the table name if needed, but ensure that your columns can contain the specified data.
--*/


INSERT INTO ServiceType (ServiceTypeName, CostPer15Min) 
VALUES	('Tax Return', 25.0), 
		('Financial Planning', 30.0),
		('Litigation Support', 50.0),
		('Miscellaneous', 30.0);

INSERT INTO Certification (CertificationName, IssuingOrganization) 
VALUES
    ('Chartered Accountant (CA)',        'CA ANZ'),
    ('Certified Practising Accountant',  'CPA Australia'),
    ('Certified Financial Planner (CFP)','Financial Advice Association'),
    ('Certified Information Systems Aud','ISACA');
GO

INSERT INTO Consultant (OfficeID, GradeID, MentorID, FirstName, LastName, HireDate) 
VALUES
    (5, 4, NULL, 'Marcus',  'Vance',    '2019-02-15'), 
    (2, 4, NULL, 'Elena',   'Rostova',  '2020-05-10'), 
    (1, 3, 1,    'David',   'Chen',     '2021-08-01'), 
    (3, 3, 2,    'Sarah',   'Jenkins',  '2022-01-20'), 
    (4, 2, 1,    'Liam',    'O''Connor','2023-03-14'), 
    (5, 1, 3,    'Priya',   'Patel',    '2024-02-01'), 
    (2, 1, 2,    'Jack',    'Wilson',   '2024-06-15'), 
    (1, 2, 3,    'Chloe',   'Martin',   '2024-07-01'); 
GO

--/*  Updating the "Office" table to assign a director to each office.
--*/

UPDATE Office SET DirectorConsultantID = 3 WHERE OfficeID = 1; 
UPDATE Office SET DirectorConsultantID = 2 WHERE OfficeID = 2; 
UPDATE Office SET DirectorConsultantID = 4 WHERE OfficeID = 3; 
UPDATE Office SET DirectorConsultantID = 1 WHERE OfficeID = 5; 

GO

INSERT INTO Customer (PreferredConsultantID, CustomerFirstName, CustomerLastName, CustomerPhone, CustomerEmail) 
VALUES
    (1,    'Arthur',  'Pendelton', '0412 345 678', 'arthur.p@techcorp.com.au'),
    (3,    'Nadia',   'Kovac',     '0423 456 789', 'nkovac@innovatestudio.com'),
    (NULL, 'Julian',  'Sterling',  '0434 567 890', 'jsterling@apexventures.net'),
    (2,    'Emma',    'Watson',    '0445 678 901', 'e.watson@horizonlogistics.com'),
    (4,    'Robert',  'Langdon',   '0456 789 012', 'rlangdon@symboldesign.org');
GO

INSERT INTO ConsultantCertification (ConsultantID, CertificationID) 
VALUES
    (1, 1), 
    (1, 2), 
    (2, 2), 
    (2, 4), 
    (3, 1), 
    (3, 3), 
    (4, 3), 
    (5, 1); 
GO

INSERT INTO Project (LeaderID, CustomerID, ServiceID, RequestedTime, CompletedTime, AmountPaid, IsHighPriority) 
VALUES
    (1, 1, 3, '2026-07-01 09:00', '2026-07-15 17:00', 4500.00, 'Y'),
    (3, 2, 1, '2026-07-10 10:30', '2026-07-20 16:00', 1250.00, 'N'),
    (2, 4, 2, '2026-08-01 08:30', '2026-08-25 15:30', 3600.00, 'Y'),
    (4, 5, 4, '2026-09-01 11:00', NULL,                900.00,  'N'),
    (1, 3, 3, '2026-09-15 14:00', NULL,                2000.00, 'Y'); 
GO

INSERT INTO ProjectConsultant (ConsultantID, ProjectID, MinutesWorked) 
VALUES
    (1, 1, 1800), 
    (6, 1, 2400), 
    (3, 2, 750),  
    (8, 2, 1200), 
    (2, 3, 1500), 
    (7, 3, 1800), 
    (4, 4, 600),  
    (1, 5, 900),  
    (5, 5, 1200); 
GO

INSERT INTO Meeting (ProjectID, MeetingDateAndTime, MeetingLocation, MeetingNotes) 
VALUES
    (1, '2026-07-02 10:00:00', 'Perth CBD - Level 4 Boardroom', 'Initial briefing and scoping session with client.'),
    (1, '2026-07-14 14:00:00', 'Perth CBD - Level 4 Boardroom', 'Final presentation of litigation support findings.'),
    (2, '2026-07-11 11:00:00', 'Maylands Office - Meeting Room 1', 'Tax return documentation handoff and review.'),
    (3, '2026-08-03 09:30:00', 'Subiaco Office - Conference Room', 'Kickoff meeting for comprehensive financial plan.'),
    (4, '2026-09-02 13:00:00', 'Joondalup Office - Meeting Room 2', 'Advisory consult regarding business restructure.'),
    (5, '2026-09-16 10:00:00', 'Perth CBD - Level 4 Boardroom', 'Discovery workshop for commercial court filing.');
GO
