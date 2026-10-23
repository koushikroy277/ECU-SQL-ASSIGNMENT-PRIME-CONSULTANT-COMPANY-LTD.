-- Student Number(s): 10728833, 10729655	
-- Student Name(s):	Koushik Roy, Isha Modi	
--done

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

-- All IDs and FKs are now SMALLINT from TINYINT in DD
-- CREATING SERVICE TABLE

CREATE TABLE ServiceType (
    ServiceID          SMALLINT IDENTITY     NOT NULL   PRIMARY KEY,
    ServiceTypeName    VARCHAR(50)           NOT NULL   UNIQUE,
    --CHECK (CostPer15Min >= 0) moved from Project to ServiceType – CostPer15Min is a ServiceType column
    CostPer15Min       SMALLMONEY            NOT NULL   CHECK (CostPer15Min >= 0)

);
GO

-- CREATING CERTIFICATION TABLE 

CREATE TABLE Certification (
    CertificationID      SMALLINT IDENTITY    NOT NULL  PRIMARY KEY,
    CertificationName    VARCHAR(50)          NOT NULL  UNIQUE,
    IssuingOrganization  VARCHAR(50)          NOT NULL

);
GO

-- Grade Table
CREATE TABLE Grade (
    GradeID            SMALLINT IDENTITY     NOT NULL   PRIMARY KEY,
    GradeName          VARCHAR(50)           NOT NULL   UNIQUE,
    --Annual salary is MONEY from SMALLMONEY in DD
    AnnualSalary       MONEY                 NOT NULL,   
    MinimumExperience  SMALLINT              NOT NULL,  
    
    CHECK (AnnualSalary >= 0), 
    CHECK (MinimumExperience >= 0)
);
GO

-- CREATING Office Table 

CREATE TABLE Office (
    OfficeID              SMALLINT IDENTITY     NOT NULL    PRIMARY KEY,
    DirectorConsultantID  SMALLINT              NOT NULL    UNIQUE,   
    OfficeName            VARCHAR(50)           NOT NULL    UNIQUE,
    OfficeAddress         VARCHAR(200)          NOT NULL,
    OfficePhone           VARCHAR(50)           NOT NULL

);
GO

-- CREATING Consultant Table

CREATE TABLE Consultant (   
    ConsultantID   SMALLINT IDENTITY      NOT NULL    PRIMARY KEY,
    OfficeID       SMALLINT               NOT NULL    FOREIGN KEY REFERENCES Office(OfficeID),
    GradeID        SMALLINT               NOT NULL    FOREIGN KEY REFERENCES Grade(GradeID),
    MentorID       SMALLINT               NULL        FOREIGN KEY REFERENCES Consultant(ConsultantID),
    FirstName      VARCHAR(40)            NOT NULL,
    LastName       VARCHAR(40)            NOT NULL,
    HireDate       DATE                   NOT NULL    DEFAULT CURRENT_TIMESTAMP,

    CHECK (MentorID <> ConsultantID)
);
GO

-- Creating Customer Table

CREATE TABLE Customer (
    CustomerID             SMALLINT IDENTITY     NOT NULL   PRIMARY KEY,
    PreferredConsultantID  SMALLINT              NULL       FOREIGN KEY REFERENCES Consultant(ConsultantID),
    CustomerFirstName      VARCHAR(50)           NOT NULL,
    CustomerLastName       VARCHAR(50)           NOT NULL,
    CustomerPhone          VARCHAR(50)           NOT NULL,
    CustomerEmail          VARCHAR(200)          NOT NULL   UNIQUE

);
GO

-- Creating ConsultantCertification Table 

CREATE TABLE ConsultantCertification (
    --IDENTITY removed from the FK columns
    ConsultantID      SMALLINT   NOT NULL    FOREIGN KEY REFERENCES Consultant(ConsultantID),
    CertificationID   SMALLINT   NOT NULL    FOREIGN KEY REFERENCES Certification(CertificationID),

    PRIMARY KEY (ConsultantID, CertificationID)
);
GO

-- Creating Project Table

CREATE TABLE Project (
    ProjectID        SMALLINT IDENTITY      NOT NULL    PRIMARY KEY,
    --LeaderID  NOT NULL instead of NULL – every project must have a lead consultant
    LeaderID         SMALLINT               NOT NULL    FOREIGN KEY REFERENCES Consultant(ConsultantID),
    CustomerID       SMALLINT               NOT NULL    FOREIGN KEY REFERENCES Customer(CustomerID),
    ServiceID        SMALLINT               NOT NULL    FOREIGN KEY REFERENCES ServiceType(ServiceID),
    RequestedTime    SMALLDATETIME          NOT NULL    DEFAULT GETDATE(),
    CompletedTime    SMALLDATETIME          NULL,              
    --AmountPaid is MONEY from SMALLMONEY in DD
    AmountPaid       MONEY                  NOT NULL    DEFAULT 0,    
    IsHighPriority   CHAR(1)                NOT NULL    DEFAULT 'N',
    
    /*
        CHECK (CompletedTime > RequestedTime) written as "CompletedTime IS NULL OR ..." to make it
	    clear that unfinished projects (NULL completion time) are allowed.
    */
    CHECK (CompletedTime IS NULL OR CompletedTime > RequestedTime),
    CHECK (AmountPaid >= 0),
    --CHECK (Priority IN ('Y','N')) uses the correct column name, IsHighPriority
    CHECK (IsHighPriority IN ('Y', 'N'))
);
GO

-- Creating ProjectConsultant Table

CREATE TABLE ProjectConsultant (
    --IDENTITY removed from the FK columns
    ConsultantID     SMALLINT   NOT NULL    FOREIGN KEY REFERENCES Consultant(ConsultantID),
    ProjectID        SMALLINT  NOT NULL     FOREIGN KEY REFERENCES Project(ProjectID),
    --MinutesWorked	is INT from TINYINT in DD,
    MinutesWorked    INT       NOT NULL     CHECK (MinutesWorked > 0),

    PRIMARY KEY (ConsultantID, ProjectID)
    
);
GO

-- -----------------------------------------------------------------------------
-- 10. Meeting Table
-- -----------------------------------------------------------------------------
CREATE TABLE Meeting (
    MeetingID           SMALLINT IDENTITY      NOT NULL     PRIMARY KEY,
    ProjectID           SMALLINT               NOT NULL     FOREIGN KEY REFERENCES Project(ProjectID),
    MeetingDateAndTime  DATETIME               NOT NULL,
    MeetingLocation     VARCHAR(50)            NOT NULL,
    MeetingNotes        VARCHAR(200)           NOT NULL
);
GO


INSERT INTO office (OfficeName, OfficeAddress, OfficePhone, DirectorConsultantID) 
VALUES ('Maylands',  '22 Non Av.',     '9568 2545', 3), 
	   ('Subiaco',   '19 Eget, St.',   '9652 5624', 2), 
	   ('Joondalup', '286 Magna. St.', '9547 1546', 4), 
	   ('Gosnells',  '51 Dui. St.',    '9875 2546', 10), 
	   ('Perth CBD','123 None. St.',  '9888 1234', 1);


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
--/*  Inserting additional professional certifications.
--*/
INSERT INTO Certification (CertificationName, IssuingOrganization) VALUES
    ('Certified Internal Auditor (CIA)', 'Institute of Internal Auditors'),
    ('Financial Risk Manager (FRM)',     'Global Association of Risk Prof.');
GO

--/*  Inserting additional consultants across various offices and grades.
--    ConsultantID will auto-increment from 9 to 14.
--*/
INSERT INTO Consultant (OfficeID, GradeID, MentorID, FirstName, LastName, HireDate) VALUES
    (3, 4, NULL, 'Jonathan', 'Reid',     '2016-04-12'),    -- ID 9:  Senior Consultant, Joondalup
    (4, 4, NULL, 'Rachel',   'Green',    '2017-09-20'),    -- ID 10: Senior Consultant, Gosnells
    (2, 3, 10,   'Timothy',  'Drake',    '2021-11-05'),    -- ID 11: Consultant, Subiaco (Mentored from Office 4)
    (5, 3, 6,    'Simon',    'Bauer',    '2022-03-15'),    -- ID 12: Consultant, Perth CBD (Mentored by Junior Priya Patel)
    (3, 2, 9,    'Hannah',   'Abbott',   '2023-10-01'),    -- ID 13: Associate Consultant, Joondalup
    (1, 1, 3,    'Lucas',    'Vance',    '2025-01-10');    -- ID 14: Graduate Consultant, Maylands (0 certs)
GO

--/*  Updating the "Office" table to assign a director to Office 4 (Gosnells).
--*/
UPDATE Office SET DirectorConsultantID = 10 WHERE OfficeID = 4;
GO

--/*  Inserting additional customers with varying consultant preferences.
--    CustomerID will auto-increment from 6 to 12.
--*/
INSERT INTO Customer (PreferredConsultantID, CustomerFirstName, CustomerLastName, CustomerPhone, CustomerEmail) VALUES
    (2,    'Lucas',    'Grey',      '0467 890 123', 'lgrey@apexgroup.com.au'),
    (2,    'Olivia',   'Taylor',    '0478 901 234', 'olivia.t@summitadvisory.net'),
    (2,    'Benjamin', 'Scott',     '0489 012 345', 'bscott@westcoastmining.com'),
    (1,    'Sophia',   'Martinez',  '0490 123 456', 'smartinez@nexuslogistics.com'),
    (3,    'William',  'Wright',    '0401 234 567', 'wwright@vanguardcapital.com.au'),
    (4,    'Zoe',      'Campbell',  '0413 579 246', 'zcampbell@beaconmedia.org'),
    (NULL, 'Ethan',    'Hunt',      '0424 680 135', 'ehunt@missionenterprises.net');
GO


-- Creating Circular 1:1 relationship between Office and Director

ALTER TABLE Office
ADD FOREIGN KEY (DirectorConsultantID) 
REFERENCES Consultant(ConsultantID);

--/*  Linking additional certifications to consultants.
--    Consultant 14 is intentionally excluded so they retain 0 certifications.
--*/
INSERT INTO ConsultantCertification (ConsultantID, CertificationID) VALUES
    (2,  1),
    (7,  3),
    (9,  1),
    (9,  2),
    (9,  6),
    (10, 1),
    (10, 4),
    (11, 2),
    (11, 5),
    (12, 5);
GO

--/*  Inserting additional projects covering completed, active, and priority cases.
--    ProjectID will auto-increment from 6 to 12.
--*/
INSERT INTO Project (LeaderID, CustomerID, ServiceID, RequestedTime, CompletedTime, AmountPaid, IsHighPriority) VALUES
    (10, 6,  2, '2026-08-10 09:30', '2026-08-12 16:30', 2400.00, 'N'),
    (2,  7,  4, '2026-08-15 10:00', '2026-08-18 12:00', 1500.00, 'Y'),
    (9,  8,  1, '2026-08-20 13:00', '2026-08-21 17:00', 800.00,  'N'),
    (3,  9,  1, '2026-09-05 08:30', NULL,                750.00,  'Y'),
    (11, 10, 2, '2026-09-10 11:00', '2026-09-20 15:00', 3000.00, 'N'),
    (10, 11, 3, '2026-09-18 09:00', NULL,                0.00,    'Y'),
    (4,  1,  4, '2026-09-22 14:00', NULL,                1200.00, 'N');
GO

--/*  Recording work performed on the new projects.
--*/
INSERT INTO ProjectConsultant (ConsultantID, ProjectID, MinutesWorked) VALUES
    (10, 6,  960),
    (2,  7,  480),
    (7,  7,  360),
    (9,  8,  300),
    (3,  9,  450),
    (8,  9,  300),
    (11, 10, 1200),
    (10, 11, 600),
    (4,  12, 450);
GO

--/*  Inserting project meetings.
--    Projects 8 and 11 have no meetings to test zero-meeting counts.
--*/
INSERT INTO Meeting (ProjectID, MeetingDateAndTime, MeetingLocation, MeetingNotes) VALUES
    (6,  '2026-08-11 10:00:00', 'Gosnells Office - Room 1',         'Retirement fund restructuring strategy.'),
    (7,  '2026-08-16 11:00:00', 'Subiaco Office - Conference Room', 'Corporate compliance kickoff discussion.'),
    (7,  '2026-08-17 15:30:00', 'Subiaco Office - Conference Room', 'Review of policy documentation.'),
    (9,  '2026-09-06 09:00:00', 'Maylands Office - Meeting Room 1', 'Client tax deduction evidence gathering.'),
    (10, '2026-09-12 14:00:00', 'Subiaco Office - Boardroom',       'Investment risk tolerance assessment.'),
    (10, '2026-09-18 10:30:00', 'Subiaco Office - Boardroom',       'Final wealth management roadmap signoff.');
GO
INSERT INTO Consultant (OfficeID, GradeID, MentorID, FirstName, LastName, HireDate) VALUES
    (2, 2, 11, 'Amelia', 'Brooks', '2022-06-06');    -- ID 15: Associate Consultant, Subiaco
GO
 
INSERT INTO ConsultantCertification (ConsultantID, CertificationID) VALUES
    (15, 2),
    (15, 3),
    (13, 5);
GO
 
--/*  Customers 13-15 for the new projects.
--*/
INSERT INTO Customer (PreferredConsultantID, CustomerFirstName, CustomerLastName, CustomerPhone, CustomerEmail) VALUES
    (11,   'Grace',   'Holloway', '0435 246 801', 'gholloway@coastalbuild.com.au'),
    (15,   'Noah',    'Fischer',  '0446 357 912', 'nfischer@brightpath.net'),
    (9,    'Mia',     'Romano',   '0457 468 023', 'mromano@harbourfoods.com.au');
GO

INSERT INTO Project (LeaderID, CustomerID, ServiceID, RequestedTime, CompletedTime, AmountPaid, IsHighPriority) VALUES
    (12, 12, 2, '2026-10-01 09:00', '2026-10-02 09:00', 0.00, 'N');
GO
 
--/*  Projects 14-18: more high-priority unfinished projects that have been paid (Query 1),
--    plus extra completed projects for Queries 5 and 6.
--*/
INSERT INTO Project (LeaderID, CustomerID, ServiceID, RequestedTime, CompletedTime, AmountPaid, IsHighPriority) VALUES
    (13, 13, 4, '2026-10-05 09:00', NULL,               1800.00, 'Y'),   -- 14: high priority, unfinished, paid
    (15, 14, 2, '2026-10-12 13:30', NULL,                500.00, 'Y'),   -- 15: high priority, unfinished, paid
    (11, 15, 3, '2026-08-25 08:00', '2026-08-27 18:00', 5200.00, 'Y'),   -- 16: completed, high priority
    (9,  2,  1, '2026-09-28 10:00', '2026-09-28 16:00',  300.00, 'N'),   -- 17: completed same day (high efficiency)
    (15, 7,  4, '2026-10-08 09:00', '2026-10-09 12:00',  750.00, 'N');   -- 18: completed
GO
 
INSERT INTO ProjectConsultant (ConsultantID, ProjectID, MinutesWorked) VALUES
    (13, 14, 420),
    (9,  14, 240),
    (15, 15, 180),
    (11, 16, 1500),
    (15, 16, 900),
    (9,  17, 315),
    (15, 18, 540),
    (7,  18, 300);
GO
 
INSERT INTO Meeting (ProjectID, MeetingDateAndTime, MeetingLocation, MeetingNotes) VALUES
    (14, '2026-10-06 10:00:00', 'Joondalup Office - Meeting Room 2', 'Scoping session for urgent compliance review.'),
    (15, '2026-10-13 09:30:00', 'Subiaco Office - Conference Room', 'Initial financial goals discussion.'),
    (16, '2026-08-25 14:00:00', 'Subiaco Office - Boardroom',       'Evidence review for upcoming hearing.'),
    (16, '2026-08-26 14:00:00', 'Subiaco Office - Boardroom',       'Expert witness preparation.'),
    (16, '2026-08-27 11:00:00', 'Subiaco Office - Boardroom',       'Final report handover to legal team.'),
    (18, '2026-10-08 15:00:00', 'Subiaco Office - Meeting Room 1',  'Process review and recommendations.');
GO

SELECT * FROM Consultant 
SELECT * FROM Project
SELECT * FROM Office
