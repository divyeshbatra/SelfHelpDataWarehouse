USE [SelfHelp]
GO

/********************************************************************************************************************************************************************************************
*                                                                                                                                                                                           *
*                                                                                                                                                                                           *
*  Script Definition: This script is used to create various tables in the self help database.                                                                                               *
*																																                                                            *
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
*********************************************************************************************************************************************************************************************/
-- This table stores the loan borrower's information
CREATE TABLE dbo.LoanBorrowerInformation (
	borrowerId INT PRIMARY KEY
	,borrowerFirstName VARCHAR(50)
	,borrowerMiddleName VARCHAR(50)
	,borrowerLastName VARCHAR(50)
	,borrowerStreet NVARCHAR(150)
	,borrowerCity NVARCHAR(130)
	,borrowerState NVARCHAR(50)
	,borrowerZip NVARCHAR(20)
	,borroweDateOfBirth DATE
	,borrowerRace NVARCHAR(70)
	,borrowerEthnicity NVARCHAR(70)
	,borroweGender NVARCHAR(20)
	,borrowerAnnualIncomeinUSD MONEY
	)

-- This table stores the information about various loan products offered
CREATE TABLE dbo.LoanProductDefinition (
	LoanProductId INT PRIMARY KEY
	,LoanProductName NVARCHAR(100)
	,LoanProductComments NVARCHAR(500)
	)

-- This table stores the information about various branches that offer loan
CREATE TABLE dbo.BankBranchDefinition (
	BranchId INT PRIMARY KEY
	,BranchName NVARCHAR(70)
	,BranchStreet NVARCHAR(150)
	,BranchCity NVARCHAR(130)
	,BranchState NVARCHAR(50)
	,BranchZip NVARCHAR(20)
	,BranchContact NVARCHAR(100)
	)

-- This table stores the information about employees that work in the organization.
CREATE TABLE dbo.EmployeeInformation (
	EmployeeID INT PRIMARY KEY
	,BranchID INT FOREIGN KEY REFERENCES selfhelp.dbo.BankBranchDefinition(BranchId)
	,EmployeeFirstName NVARCHAR(50)
	,EmployeeLastName NVARCHAR(50)
	,EmployeeContact NVARCHAR(12)
	,EmployeeStreet NVARCHAR(150)
	,EmployeeCity NVARCHAR(130)
	,EmployeeCounty NVARCHAR(50)
	,EmployeeState NVARCHAR(50)
	,EmployeeZip NVARCHAR(20)
	,EmployeeCountry NVARCHAR(50)
	,EmployeeEmail NVARCHAR(100)
	,EmployeeJoiningDate DATE
	,EmployeeDOB DATE
	)

-- This table stores the transcation records of loan lent by the organization to different borrowers
CREATE TABLE dbo.loanOriginationInformation (
	transactionID INT PRIMARY KEY
	,borrowerID INT FOREIGN KEY REFERENCES selfhelp.dbo.LoanBorrowerInformation(borrowerID)
	,loanProductID INT FOREIGN KEY REFERENCES selfhelp.dbo.LoanProductDefinition(LoanProductId)
	,bankBranchID INT FOREIGN KEY REFERENCES selfhelp.dbo.BankBranchDefinition(BranchID)
	,loanOfficerID INT FOREIGN KEY REFERENCES selfhelp.dbo.EmployeeInformation(EmployeeID)
	,loanAmount FLOAT
	,loanDate DATE
	,loanMaturityDate DATE
	,[interestRat(%)] FLOAT
	)