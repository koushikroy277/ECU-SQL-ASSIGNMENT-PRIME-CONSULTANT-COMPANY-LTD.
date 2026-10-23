-- Student Number(s): 10728833, 10729655	
-- Student Name(s):	Koushik Roy, Isha Modi	
--done
USE primeConsulting;
GO

/*	Consultant View (2 marks)

	Create a view that selects the following details of all consultants (create appropriate column aliases):
	•	All the columns in the consultant table, including the full name of the consultant.
			Concatenate the first name and last name into one column (e.g. "Joe Bloggs").
	•	The name, annual salary and minimum experience of their grade. 
	•	The name of the office they work at. 
	•	The total number of certifications each consultant holds. 
			Consultants with no certifications should still appear in the results.
	This requires multiple joins.
*/

-- Write your Consultant View here
CREATE VIEW ConsultantView AS
SELECT 
	Consultant.ConsultantID, 
	Consultant.OfficeID, 
	Consultant.GradeID, 
	Consultant.MentorID,
	Consultant.HireDate,

--Full name of the consultant
	CONCAT(Consultant.FirstName, ' ', Consultant.LastName) AS FullName, 
	Grade.GradeName, 
	Grade.AnnualSalary, 
	Grade.MinimumExperience,
	Office.OfficeName, 

--Counts the total number of certification achieved by a consultant
	COUNT(ConsultantCertification.CertificationID) AS TotalCertifications
	
FROM Consultant
JOIN Office ON Consultant.OfficeID = Office.OfficeID
JOIN Grade ON Consultant.GradeID = Grade.GradeID
LEFT JOIN  ConsultantCertification ON Consultant.ConsultantID = ConsultantCertification.ConsultantID 

GROUP BY
	Consultant.ConsultantID,
	Consultant.OfficeID,
	Consultant.GradeID,
	Consultant.MentorID,
	Consultant.FirstName,
	Consultant.LastName,
	Consultant.HireDate,
	Grade.GradeName,
	Grade.AnnualSalary,
	Grade.MinimumExperience,
	Office.OfficeName;

GO

/*	Project View (3 marks)

	Create a view that selects the following details of all projects (create appropriate column aliases):
•	All the columns in the project table. 
•	The full name of the customer and the full name of the lead consultant. 
		Concatenate the first name and last name into one column (e.g. "Joe Bloggs"). 
•	The name of the service type. 
•	The total number of minutes worked on the project, or 0 if no work has been recorded. 
•	A column containing the calculated cost of the project, or 0 if no work has been recorded. 
		This will involve joining with the work table and grouping by all the other columns selected. 
		Sum the minutes worked and divide by 15.0. 
		The CEILING(), ISNULL(), and cost_per_15_mins column of the service_type table will be useful. 
		If the project is high priority, add 25% to the calculated project cost (multiply by 1.25). 
This requires multiple joins, and an outer join will be needed to ensure that all projects are included.

*/


-- Write your Project View here
CREATE VIEW ProjectView AS
SELECT
	Project.ProjectID,       
    Project.LeaderID,       
    Project.CustomerID,      
    Project.ServiceID,        
    Project.RequestedTime,    
    Project.CompletedTime,   
    Project.AmountPaid,       
    Project.IsHighPriority,
	ServiceType.ServiceTypeName,

--Full name of customer and consultant 
	CONCAT(Customer.CustomerFirstName, ' ', Customer.CustomerLastName) AS CustomerName,
	CONCAT(Consultant.FirstName, ' ', Consultant.LastName) AS ConsultantName,

--Returns 0 if the sum of minutes worked is 0
	ISNULL(SUM(ProjectConsultant.MinutesWorked), 0) AS TotalMinutes,

/* 
	Got it from W3Schools as I was going through all the SQL contents and used it as it seemed more convenient to use than the normal IF statement 
	and as the IF statement was mentioned less frequently in the lecture
	source: https://www.w3schools.com/sql/sql_case.asp
*/

--If the project is High Priority, then 1.25 will be multiplied and then the total cost will be rounded up
	CASE 
		WHEN Project.IsHighPriority = 'Y'

		/*
			CEILING rounds a numeric value up to the nearest integer.
			source: https://learn.microsoft.com/en-us/sql/t-sql/functions/ceiling-transact-sql?view=sql-server-ver17
		*/
		THEN CEILING((ISNULL(SUM(ProjectConsultant.MinutesWorked), 0) / 15.0) * 1.25 * ServiceType.CostPer15Min)
		ELSE CEILING((ISNULL(SUM(ProjectConsultant.MinutesWorked), 0) / 15.0) * ServiceType.CostPer15Min)
	END AS ProjectCost

FROM Project

JOIN Customer ON Project.CustomerID = Customer.CustomerID
JOIN Consultant ON Consultant.ConsultantID = Project.LeaderID
JOIN ServiceType ON Project.ServiceID = ServiceType.ServiceID
LEFT JOIN ProjectConsultant ON Project.ProjectID = ProjectConsultant.ProjectID

GROUP BY
    Project.ProjectID,
    Project.LeaderID,
    Project.CustomerID,
    Project.ServiceID,
    Project.RequestedTime,
    Project.CompletedTime,
    Project.IsHighPriority,
    Customer.CustomerFirstName,
    Customer.CustomerLastName,
    Consultant.FirstName,
    Consultant.LastName,
    ServiceType.ServiceTypeName,
    ServiceType.CostPer15Min,
    Project.AmountPaid;
GO

--	If you wish to create additional views to use in the queries which follow, include them in this file.
