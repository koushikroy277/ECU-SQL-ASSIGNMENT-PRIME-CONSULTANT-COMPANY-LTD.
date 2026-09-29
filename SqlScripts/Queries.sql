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
	COUNT(Customer.CustomerID) AS TotalPreferences

FROM ConsultantView
JOIN Customer ON Customer.PreferredConsultantID = ConsultantView.ConsultantID

GROUP BY 
ConsultantView.ConsultantID,
ConsultantView.FullName

ORDER BY 
TotalPreferences DESC,
ConsultantView.ConsultantID ASC;
