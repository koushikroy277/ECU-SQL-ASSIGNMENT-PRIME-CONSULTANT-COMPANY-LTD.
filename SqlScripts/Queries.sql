-- Student Number(s): 10728833	
-- Student Name(s):	Koushik Roy		

USE primeConsulting;

/*	Query 1 – Project Search (2 marks)
	Write a query that selects all details of any projects that are high priority, have not been completed (NULL completion date),
	and have amount paid greater than 0. Order the results by the start date in descending order. 
*/

-- Write Query 1 here
SELECT *

FROM Project

WHERE Project.IsHighPriority = 'Y'
AND Project.CompletedTime IS NULL
AND Project.AmountPaid > 0

ORDER BY RequestedTime DESC;




/*	Query 2 – Over graded Consultants  (2 marks)
	Write a query that selects the full name, hire date, grade name, and minimum years of experience of any consultants
	who have been working at Prime Consulting for less than the minimum number of years required for their grade.
	Using the Consultant View in this query is recommended.
*/

-- Write Query 2 here

SELECT 
	ConsultantView.FullName,
	ConsultantView.HireDate,
	ConsultantView.GradeName,
	ConsultantView.MinimumExperience


FROM ConsultantView

/* 
	CALCULATING THE TIME BETWEEN HIREDATE AND CURRENT DATE TO IDENTIFY THE CONSULTANTS WHO MIGHT HAVE LESS
	EXPERIENCE THAN THE MINIMUM EXPERIENCE CRITERIA OF THE GRADE
*/

WHERE DATEDIFF(year, ConsultantView.HireDate, GETDATE()) < ConsultantView.MinimumExperience 



/*	Query 3 – Most Popular Consultants (2 marks)
	Write a query that selects the consultant ID, full name, and the number of customers who have selected them as their preferred consultant.
	Display the three most popular consultants, based on the number of customer preferences.
	Order the results by:
	1.	Number of preferences (descending) 
	2.	Consultant ID (ascending)
	Using the Consultant View in this query is recommended.
*/

-- Write Query 3 here
SELECT TOP 3
	ConsultantView.ConsultantID,
	ConsultantView.FullName,

	--COUNTING THE TOTAL PREFERENCES OF A CONSULTANT BY THE CUSTOMER
	COUNT(Customer.CustomerID) AS TotalPreferences

FROM ConsultantView
JOIN Customer ON Customer.PreferredConsultantID = ConsultantView.ConsultantID

GROUP BY 
ConsultantView.ConsultantID,
ConsultantView.FullName

ORDER BY 
TotalPreferences DESC,
ConsultantView.ConsultantID ASC;

GO



/*	Query 4 – Certifications of Consultants at Office 2 (3 marks)
	Write a query that selects the full name of all consultants who work at the office with an ID of 2, 
	as well as the office name and a comma-separated list of their certifications.  
	Order the results alphabetically by the consultant's full name. Using the Consultants View in this query is recommended
*/

-- Write Query 4 here

SELECT
	ConsultantView.FullName,
	ConsultantView.OfficeName,

	-- ONE PERSON MAY HAVE SEVERAL QUALIFICATIONS SO IT COMBINES ALL THE CERTIFICATION OF A SINGLE CONSULTANT INTO ONE ROW
	STRING_AGG(Certification.CertificationName, ', ') 
	WITHIN GROUP (ORDER BY Certification.CertificationName ASC) AS Certifications

FROM ConsultantView
JOIN ConsultantCertification ON ConsultantView.ConsultantID = ConsultantCertification.ConsultantID
JOIN Certification ON ConsultantCertification.CertificationID = Certification.CertificationID

WHERE ConsultantView.OfficeID = 2

GROUP BY 
ConsultantView.FullName,
ConsultantView.OfficeName

ORDER BY
ConsultantView.FullName ASC

GO

/*	Query 5 – Project Efficiency (3 marks)
	Write a query that selects the following details about all completed projects (i.e. projects with a NOT NULL completion date):
	•	The project ID, the full name of the lead consultant and the service type name. 
	•	The total number of minutes worked on the project, or 0 if no work has been recorded. 
	•	The number of minutes between the project start date and completion date. 
	•	The efficiency of the project; that is, the percentage of the elapsed time between the project start date and completion date that was spent working on the project, rounded to 2 decimal places. 
			“For example, a project completed exactly 3 hours after it was started with a total working time of 165 minutes has an efficiency of 91.67%.”
	Order the results by project efficiency in descending order. Using the project view in this query is recommended.

*/

-- Write Query 5 here

SELECT 
	ProjectView.ProjectID,
	ProjectView.ConsultantName,
	ProjectView.ServiceTypeName,
	ProjectView.TotalMinutes AS TotalMinutesWorked,

	--Calculating the total time in minutes spent to complete the project
	DATEDIFF(minute, ProjectView.RequestedTime, ProjectView.CompletedTime) AS TotalProjectMinutes,

	--Calculating the efficiency
	ROUND((ProjectView.TotalMinutes * 100 / DATEDIFF(minute, ProjectView.RequestedTime, ProjectView.CompletedTime)), 2) AS Efficiency

FROM ProjectView
WHERE ProjectView.CompletedTime IS NOT NULL
ORDER BY Efficiency



/*	Query 6 – Service Type Statistics (3 marks)
	Write a query that selects the service type name, as well as:
	•	the number of projects, 
	•	the average project cost, and 
	•	the total cost 
	for each service type.
	Round the average project cost and total cost to the nearest whole number. Give all calculated columns appropriate aliases. 
	Order the results by the total project cost from highest to lowest. Using the project view in this query is recommended.

*/

-- Write Query 6 here

SELECT 
	ProjectView.ServiceTypeName,

	--Calculating the total number of projects done in that service category
	COUNT(ProjectView.ProjectID) AS TotalProjects,

	
	--Calculating the total cost of projects done in that service category
	SUM(ProjectView.ProjectCost) AS TotalProjectCost,

	--Calculating the average cost of the project
	(SUM(ProjectView.ProjectCost) / COUNT(ProjectView.ServiceID)) AS AverageCost

FROM ProjectView

GROUP BY ProjectView.ServiceTypeName

ORDER BY TotalProjectCost

GO

/*	Query 7 – Unusual Mentoring (4 marks)
	Write a query that selects the consultant's full name, grade name, and office name, along with their mentor's full name, grade name, and office name, formatted in single columns as shown below. The consultants selected should:
	•	have a grade with a higher annual salary than their mentor, or 
	•	work in a different office from their mentor.
	Using the Consultant View in this query is recommended

*/

-- Write Query 7 here

SELECT
	CONCAT(Consultant.FullName,'(',Consultant.GradeName,')', ', ', Consultant.OfficeName) AS Consultant,
	CONCAT(Mentor.FullName,'(',Mentor.GradeName,')', ', ', Mentor.OfficeName) AS Mentor

FROM ConsultantView AS Consultant
JOIN ConsultantView AS Mentor 
	ON Consultant.MentorID = Mentor.ConsultantID

WHERE Consultant.AnnualSalary < Mentor.AnnualSalary
	  AND Consultant.OfficeID <> Mentor.OfficeID

GO


/*	Query 8 – Office Summaries (4 marks)
	Write a query that selects the following information about all offices, concatenated into this format:
	  “[office name] is managed by [director name], has [number of consultants] consultant(s), and has managed [number of projects] project(s).”
	where
	•	[director name] is the full name of the office director. 
	•	[number of consultants] is the number of consultants who work at that office.
	•	[number of projects] is	the number of projects led by consultants or have not managed any projects.
	Include all offices in the results, even if they have no consultants or have not managed any projects.  
	Order the results by office name.
*/

-- Write Query 8 here
SELECT
	CONCAT(
		Office.OfficeName, ' is directed by ', 
		CONCAT(Director.FirstName, ' ', Director.LastName),
		' has ',

		--Total number of consultants in the office branch
		COUNT(DISTINCT Staff.ConsultantID),
		' consultants ',
		' has managed ',
		
		--Total number of projects done by the office branch
		COUNT(DISTINCT Project.ProjectID),
		' projects '
	
	) AS OfficeSummary

FROM Office

JOIN Consultant as Director 
	ON Office.DirectorConsultantID = Director.ConsultantID
LEFT JOIN Consultant AS Staff 
    ON Office.OfficeID = Staff.OfficeID
LEFT JOIN Project 
	ON Project.LeaderID = Staff.ConsultantID

GROUP BY 
Director.FirstName,
Director.LastName,
Office.OfficeName

ORDER BY
Office.OfficeName ASC

GO

/*	Query 9 – Consultant Meeting Statistics (4 marks)
	Write a query that selects the following details for all consultants:
	⦁	The consultant's full name. 
	⦁	The total number of projects for which they are the lead consultant. 
	⦁	The total number of meetings held for those projects. 
	⦁	The average number of meetings per project, rounded to 2 decimal places. 
	⦁	Consultants who are not the lead consultant on any projects should display 0 as the average number of meetings per project. 
	Include all consultants in the results, even if they have not led any projects or their projects have had no meetings. 
	Order the results by the total number of meetings (highest to lowest), and then by the consultant's full name.
*/

-- Write Query 9 here

SELECT
	CONCAT(Consultant.FirstName, ' ', Consultant.LastName) AS FullName,
	COUNT(Project.ProjectID) AS TotalProjects,
	COUNT(Meeting.MeetingID) AS TotalMeetings,
	ROUND(COUNT(Project.ProjectID) / COUNT(Meeting.MeetingID), 2) AS AverageMeeting

FROM Consultant
JOIN Project ON Project.LeaderID = Consultant.ConsultantID
JOIN Meeting ON Project.ProjectID = Meeting.ProjectID

GROUP BY 
	Meeting.ProjectID,
	Consultant.ConsultantID,
	Consultant.FirstName,
	Consultant.LastName

ORDER BY TotalMeetings DESC

GO
