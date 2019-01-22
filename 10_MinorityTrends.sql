USE [selfhelp]
GO

/********************************************************************************************************************************************************************************************
*                                                                                                                                                                                           *
*                                                                                                                                                                                           *
*  Script Definition: This script shows whether the organization is consistently making loans to low-income or minority borrowers across geographies								        *
*                                                                                                                                                                                           * 
*  Notes: This script is developed based on following assumptions:                                                                                                                          *
*  1. Low-Income or Minority Borrowers are identified as people who have an annual income >=$15000 and annual income<=$50000                                                                *
*  2. Percentage Rate of Minority lending is defined as (count of total loans disbursed to minorities in a geography * 100/count of total loans disbursed in a geography) in a year         *
*  3. Consistency is defined as: if 50% (including variance) of minorities are served during years, then a state is considered consistent while lending loans to minorities                 *
*                                                                                                                                                                                           *
*  Important: To support the result generated by this query, a supporting document can be found at: SelfHelp\Files\MinorityTrends.pdf                                                       *
*  Author: Batra, Divyesh                                                                                                                                                                   *   
*  Date: 03/31/2018                                                                                                                                                                         *
*                                                                                                                                                                                           *
*  [Change Log]                                                                                                                                                                             *
*  Version: 1.0.0.1                                                                                                                                                                         *
*  Change Date:                                                                                                                                                                             *
*  Changed By:                                                                                                                                                                              *
*  Change Implemented:                                                                                                                                                                      *
*                                                                                                                                                                                           *
*                                                                                                                                                                                           *
*********************************************************************************************************************************************************************************************/
--Determine Low income group from loan borrowers
SELECT *
INTO #minoritylenders
FROM selfhelp.dbo.LoanBorrowerInformation
WHERE borrowerAnnualIncomeinUSD >= '15000'
	AND borrowerAnnualIncomeinUSD <= '50000'

-- Create temporary tables
CREATE TABLE #Minoritytrends (
	[NumberofLoansLent] INT
	,borrowerState VARCHAR(10)
	,StartYear DATE
	,EndYear DATE
	)

CREATE TABLE #Overalltrends (
	[NumberofLoansLent] INT
	,borrowerState VARCHAR(10)
	,StartYear DATE
	,EndYear DATE
	)

-- Extract min and max loan date from the given data
DECLARE @minLoanDate DATE
DECLARE @maxloanDate DATE
DECLARE @counterDate DATE

-- Set @minLoanDate as the first day of the month for min loan date. Example, if min loandate is 1995-03-03 (yyyy-mm-dd), make it 1995-03-01
SET @minLoanDate = (
		SELECT DATEADD(yy, DATEDIFF(yy, 0, min(loandate)), 0)
		FROM SelfHelp.dbo.loanOriginationInformation
		)
-- Set @maxLoanDate as the last day of the month for max loan date. Example, if min loandate is 2010-12-15 (yyyy-mm-dd), make it 2010-12-31
SET @maxloanDate = (
		SELECT DATEADD(yy, DATEDIFF(yy, 0, max(loandate)) + 1, - 1)
		FROM SelfHelp.dbo.loanOriginationInformation
		)
SET @counterdate = @minLoanDate

WHILE (@counterDate <= @maxloanDate)
BEGIN
	-- insert data according to how many minority groups were served in a state according to year range: 1995-01-01 to 1995-12-31
	INSERT INTO #Minoritytrends
	SELECT count(transactionid)
		,m.borrowerState
		,@counterDate
		,DATEADD(yy, DATEDIFF(yy, 0, @counterDate) + 1, - 1)
	FROM SelfHelp.dbo.loanOriginationInformation oi
	INNER JOIN #minoritylenders m ON oi.borrowerID = m.borrowerId
		AND oi.loanDate >= @counterDate
		AND oi.loanDate <= DATEADD(yy, DATEDIFF(yy, 0, @counterDate) + 1, - 1)
	GROUP BY m.borrowerState

	-- insert data according to how many overall loans were disbursed in a state according to year range: 1995-01-01 to 1995-12-31
	INSERT INTO #Overalltrends
	SELECT count(transactionID)
		,bi.borrowerState
		,@counterDate
		,DATEADD(yy, DATEDIFF(yy, 0, @counterDate) + 1, - 1)
	FROM SelfHelp.dbo.loanOriginationInformation oi
	INNER JOIN selfhelp.dbo.LoanBorrowerInformation bi ON oi.borrowerID = bi.borrowerId
	WHERE oi.loanDate >= @counterDate
		AND oi.loanDate <= DATEADD(yy, DATEDIFF(yy, 0, @counterDate) + 1, - 1)
	GROUP BY bi.borrowerState

	SET @counterdate = dateadd(DD, 1, DATEADD(yy, DATEDIFF(yy, 0, @counterDate) + 1, - 1))
END

/* --Debug Space
select * from #Minoritytrends order by borrowerState, StartYear asc 
select * from #Overalltrends order by borrowerState, StartYear asc 
*/
--This query gives us what percentage of minorities were served in a state in a given year. For example, in AL, in 1997, 14 loans were disbursed overall and 7 loans were disbursed to minorites, so 50% minorites were served in AL in 1997 
-- minority trends charts was developed using the data fetched from below query. It is assumed if 50% of loans were disbursed to minorities over the period of time, then the state is consistent in offering loans to minorities. (See file:SelfHelp\Files\MinorityTrends.pdf )
SELECT Isnull((m.NumberofLoansLent * 100 / o.NumberofLoansLent), 0) AS 'MinorityRate%'
	,o.borrowerState
	,o.StartYear
	,o.EndYear
FROM #Overalltrends o
LEFT JOIN #Minoritytrends m ON o.borrowerState = m.borrowerState
	AND o.StartYear = m.StartYear
	AND o.EndYear = m.EndYear
ORDER BY borrowerState
	,StartYear ASC

--Cleaning space:
DROP TABLE #minoritylenders

DROP TABLE #Minoritytrends

DROP TABLE #Overalltrends