USE [SelfHelp]
GO

/********************************************************************************************************************************************************************************************
*                                                                                                                                                                                           *
*                                                                                                                                                                                           *
*  Script Definition: This procedure shows the top 5 loan products in each state, in terms of loan production, by amount lent.                     									        *
*                                                                                                                                                                                           *
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
* Usage1: exec selfhelp.dbo.topLoanProductsByState 'AK'                                                                                                                                     *
* Usage2: exec selfhelp.dbo.topLoanProductsByState 'All'                                                                                                                                    *
*********************************************************************************************************************************************************************************************/
CREATE PROCEDURE dbo.topLoanProductsByState (@state NVARCHAR(10))
AS
BEGIN
	--Parameter Sniffing
	DECLARE @localState NVARCHAR(10)

	SET @localState = @state

	-- Storing data in a temporary result set and ranking all the products by partitioning state-wise and ranking acording to loanAmount
	SELECT borrowerState AS 'State'
		,sum(loanAmount) AS 'Total Amount Lent for Product'
		,pd.LoanProductName AS 'Loan Product'
		,ROW_NUMBER() OVER (
			PARTITION BY borrowerState ORDER BY sum(loanAmount) DESC
			) AS Rank
	INTO #tempTopLoanProductsByState
	FROM SelfHelp.dbo.loanOriginationInformation oi
	INNER JOIN SelfHelp.dbo.LoanBorrowerInformation bi ON oi.borrowerID = bi.borrowerId
	INNER JOIN SelfHelp.dbo.LoanProductDefinition pd ON pd.LoanProductId = oi.loanProductID
	GROUP BY borrowerState
		,pd.LoanProductName
	ORDER BY borrowerstate ASC
		,sum(loanAmount) DESC

	-- Selecting Results for top 5 products
	IF (@localState = 'All')
	BEGIN
		SELECT *
		FROM #tempTopLoanProductsByState
		WHERE rank <= 5
		ORDER BY STATE ASC
	END
	ELSE
	BEGIN
		SELECT *
		FROM #tempTopLoanProductsByState
		WHERE [State] = @localState
			AND rank <= 5
	END

	-- cleaning up space
	DROP TABLE #tempTopLoanProductsByState
END