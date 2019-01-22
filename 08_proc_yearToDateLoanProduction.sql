USE [SelfHelp]
GO

/********************************************************************************************************************************************************************************************
*                                                                                                                                                                                           *
*                                                                                                                                                                                           *
*  Script Definition: This procedure shows year-to-date loan production (amount and count) by bank branch and month of close	                 									        *
*  Notes: This is the total loan amount disbursed by a bank branch and total number of loans disbursed at the closing of each month                                                         *
*                                                                                                                                                                                           *
*  Author: Batra, Divyesh                                                                                                                                                                   *   
*  Date: 03/31/2018                                                                                                                                                                         *
*                                                                                                                                                                                           *
*  [Change Log]                                                                                                                                                                             *
*  Version: 1.0.0.1                                                                                                                                                                         *
*  Change Date:                                                                                                                                                                             *
*  Changed By:                                                                                                                                                                              *
*  Change Implemented:                                                                                                                                                                      *
*                                                                                                                                                                                           *
* Usage: exec selfhelp.dbo.yearToDateLoanProduction '19950101', '19961231'                                                                                                                  *
*********************************************************************************************************************************************************************************************/
CREATE PROCEDURE dbo.yearToDateLoanProduction (
	@fromDate DATE
	,@toDate DATE
	)
AS
BEGIN
	--Parameter Sniffing
	DECLARE @localFromDate DATE
	DECLARE @localtoDate DATE

	SET @localFromDate = @fromDate
	SET @localtoDate = @toDate

	-- Move all the relevant data into a temporary table for querying
	SELECT *
	INTO #tempYearToDateLoanProduction
	FROM selfhelp.dbo.loanOriginationInformation
	WHERE loandate >= @localFromDate
		AND loandate <= @localtoDate
	ORDER BY loandate DESC

	--Add a new column for month-of-close in temporary table
	ALTER TABLE #tempYearToDateLoanProduction ADD monthOfClose DATE

	-- add month-end date to every loandate: example 1995-01-01 has a month of close date as 1995-01-31
	UPDATE #tempYearToDateLoanProduction
	SET monthOfClose = DATEADD(d, - 1, DATEADD(m, DATEDIFF(m, 0, loanDate) + 1, 0))
	FROM #tempYearToDateLoanProduction

	-- Selecting Result Set
	SELECT sum(y.loanAmount) AS 'Total Sum Lent'
		,bdef.BranchName AS 'Bank Branch'
		,y.monthOfClose AS 'Month of Close'
		,count(y.loanAmount) AS 'Count of loan amount disbursed'
	FROM #tempYearToDateLoanProduction y
	INNER JOIN dbo.BankBranchDefinition bdef ON bdef.BranchId = y.bankBranchID
	WHERE loanDate >= @localFromDate
		AND loandate <= @localtoDate
	GROUP BY bdef.BranchName
		,y.monthOfClose

	-- Deleting temporary table
	DROP TABLE #tempYearToDateLoanProduction
END