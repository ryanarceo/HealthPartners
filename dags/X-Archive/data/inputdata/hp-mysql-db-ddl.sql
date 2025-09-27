-- For database hd-mysql-db:

-- 1. Elig Table:

CREATE TABLE elig (	
	PatientID nvarchar(10) NOT NULL
	,FirstName nvarchar(20)
	,LastName nvarchar(20)
	,MiddleName nvarchar(1)
	,Gender nvarchar(10)
	,DOB DATE
	,ModifiedDate DATE
	,Subgroup	nvarchar(10)	
	,CONSTRAINT PK_elig PRIMARY KEY (PatientID)		
);

-- 2. Medc Table:

CREATE TABLE claimmedc (
    PatientID nvarchar(10) NOT NULL
		,TransactionID nvarchar(20)
		,VisitDate DATE
		,ServiceDate DATE
		,PaidDate DATE
		,VisitType nvarchar(2)
		,Amount INT
		,PaidAmount INT
		,ClaimID nvarchar(10)	
		,LineOfBusiness	nvarchar(10)	
		,InsertDate DATE
		,ModifiedDate DATE
		,CONSTRAINT PK_claimmedc PRIMARY KEY (PatientID)		
);

-- 3. Pharmacy Table:

CREATE TABLE claimrx (
    PatientID nvarchar(10) NOT NULL
		,TransactionID nvarchar(20)
		,VisitDate DATE
		,VisitType nvarchar(2)
		,ServiceDate DATE
		,PaidDate DATE
		,Amount INT
		,PaidAmount INT	
		,InsertDate DATE
		,ModifiedDate DATE
		,CONSTRAINT PK_claimmedc PRIMARY KEY (PatientID)		
);

-- 4. Account Structure Table:

CREATE TABLE acctstruct (
    Subgroup nvarchar(10) NOT NULL
    ,CompanyName nvarchar(20)
		,PlanName nvarchar(20)
    ,BegDt DATE
    ,EndDt DATE
    ,CONSTRAINT PK_acctstruct PRIMARY KEY (Subgroup)
);
-- 5. Transactions Table:

CREATE TABLE transactions (
    TransactionID nvarchar(20) NOT NULL
    ,PatientID nvarchar(20) NOT NULL
    ,PaidDate date NOT NULL
    ,VisitType nvarchar(2) NOT NULL
    ,Amount float NOT NULL
    ,PaidAmount float NOT NULL
    ,LineOfBusiness nvarchar(50) NOT NULL
    ,InsertDate date NOT NULL
    ,ModifiedDate date NOT NULL
    CONSTRAINT PK_transactions PRIMARY KEY (TransactionID)
);



