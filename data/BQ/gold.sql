--1. Create Claims in Gold Level
CREATE TABLE IF NOT EXISTS `gcp-health-partners-473103.gold_dataset.claims` (
    Provider_Name STRING,
    Dept_Name STRING,
    Amount FLOAT64
);

# truncate table
TRUNCATE TABLE `avd-databricks-demo.gold_dataset.provider_charge_summary`;

# insert data
INSERT INTO `avd-databricks-demo.gold_dataset.provider_charge_summary`
SELECT 
    CONCAT(p.firstname, ' ', p.LastName) AS Provider_Name,
    d.Name AS Dept_Name,
    SUM(t.Amount) AS Amount
FROM `avd-databricks-demo.silver_dataset.transactions` t
LEFT JOIN `avd-databricks-demo.silver_dataset.providers` p 
    ON SPLIT(p.ProviderID, "-")[SAFE_OFFSET(1)] = t.ProviderID
LEFT JOIN `avd-databricks-demo.silver_dataset.departments` d 
    ON SPLIT(d.Dept_Id, "-")[SAFE_OFFSET(0)] = p.DeptID
WHERE t.is_quarantined = FALSE AND d.Name IS NOT NULL
GROUP BY Provider_Name, Dept_Name;


--------------------------------------------------------------------------------------------------
--2. Patient History (Gold) : This table provides a complete history of a patient’s visits, diagnoses, and financial interactions.

# CREATE TABLE
CREATE TABLE IF NOT EXISTS `avd-databricks-demo.gold_dataset.patient_history` (
    Patient_Key STRING,
    FirstName STRING,
    LastName STRING,
    Gender STRING,
    DOB INT64,
    Address STRING,
    EncounterDate INT64,
    EncounterType STRING,
    Transaction_Key STRING,
    VisitDate INT64,
    ServiceDate INT64,
    BilledAmount FLOAT64,
    PaidAmount FLOAT64,
    ClaimStatus STRING,
    ClaimAmount STRING,
    ClaimPaidAmount STRING,
    PayorType STRING
);


# TRUNCATE TABLE
TRUNCATE TABLE `avd-databricks-demo.gold_dataset.patient_history`;

# INSERT DATA
INSERT INTO `avd-databricks-demo.gold_dataset.patient_history`
SELECT 
    p.Patient_Key,
    p.FirstName,
    p.LastName,
    p.Gender,
    p.DOB,
    p.Address,
    e.EncounterDate,
    e.EncounterType,
    t.Transaction_Key,
    t.VisitDate,
    t.ServiceDate,
    t.Amount AS BilledAmount,
    t.PaidAmount,
    c.ClaimStatus,
    c.ClaimAmount,
    c.PaidAmount AS ClaimPaidAmount,
    c.PayorType
FROM `avd-databricks-demo.silver_dataset.patients` p
LEFT JOIN `avd-databricks-demo.silver_dataset.encounters` e 
    ON SPLIT(p.Patient_Key, '-')[OFFSET(0)] || '-' || SPLIT(p.Patient_Key, '-')[OFFSET(1)] = e.PatientID
LEFT JOIN `avd-databricks-demo.silver_dataset.transactions` t 
    ON SPLIT(p.Patient_Key, '-')[OFFSET(0)] || '-' || SPLIT(p.Patient_Key, '-')[OFFSET(1)] = t.PatientID
LEFT JOIN `avd-databricks-demo.silver_dataset.claims` c 
    ON t.SRC_TransactionID = c.TransactionID
WHERE p.is_current = TRUE;


--------------------------------------------------------------------------------------------------
-- 3. Provider Performance Summary (Gold) : This table summarizes provider activity, including the number of encounters, total billed amount, and claim success rate.

# CREATE TABLE
CREATE TABLE IF NOT EXISTS `avd-databricks-demo.gold_dataset.provider_performance` (
    ProviderID STRING,
    FirstName STRING,
    LastName STRING,
    Specialization STRING,
    TotalEncounters INT64,
    TotalTransactions INT64,
    TotalBilledAmount FLOAT64,
    TotalPaidAmount FLOAT64,
    ApprovedClaims INT64,
    TotalClaims INT64,
    ClaimApprovalRate FLOAT64
);

# TRUNCATE TABLE
TRUNCATE TABLE `avd-databricks-demo.gold_dataset.provider_performance`;

# INSERT DATA
INSERT INTO `avd-databricks-demo.gold_dataset.provider_performance`
SELECT 
    pr.ProviderID,
    pr.FirstName,
    pr.LastName,
    pr.Specialization,
    COUNT(DISTINCT e.Encounter_Key) AS TotalEncounters,
    COUNT(DISTINCT t.Transaction_Key) AS TotalTransactions,
    SUM(t.Amount) AS TotalBilledAmount,
    SUM(t.PaidAmount) AS TotalPaidAmount,
    COUNT(DISTINCT CASE WHEN c.ClaimStatus = 'Approved' THEN c.Claim_Key END) AS ApprovedClaims,
    COUNT(DISTINCT c.Claim_Key) AS TotalClaims,
    ROUND((COUNT(DISTINCT CASE WHEN c.ClaimStatus = 'Approved' THEN c.Claim_Key END) / NULLIF(COUNT(DISTINCT c.Claim_Key), 0)) * 100, 2) AS ClaimApprovalRate
FROM `avd-databricks-demo.silver_dataset.providers` pr
LEFT JOIN `avd-databricks-demo.silver_dataset.encounters` e 
    ON SPLIT(pr.ProviderID, "-")[SAFE_OFFSET(1)] = e.ProviderID
LEFT JOIN `avd-databricks-demo.silver_dataset.transactions` t 
    ON SPLIT(pr.ProviderID, "-")[SAFE_OFFSET(1)] = t.ProviderID
LEFT JOIN `avd-databricks-demo.silver_dataset.claims` c 
    ON t.SRC_TransactionID = c.TransactionID
GROUP BY pr.ProviderID, pr.FirstName, pr.LastName, pr.Specialization;

--------------------------------------------------------------------------------------------------
-- 4. Department Performance Analytics (Gold): Provides insights into department-level efficiency, revenue, and patient volume.

# CREATE TABLE
CREATE TABLE IF NOT EXISTS `avd-databricks-demo.gold_dataset.department_performance` (
    Dept_Id STRING,
    DepartmentName STRING,
    TotalEncounters INT64,
    TotalTransactions INT64,
    TotalBilledAmount FLOAT64,
    TotalPaidAmount FLOAT64,
    AvgPaymentPerTransaction FLOAT64
);

# TRUNCATE TABLE
TRUNCATE TABLE `avd-databricks-demo.gold_dataset.department_performance`;

# INSERT DATA
INSERT INTO `avd-databricks-demo.gold_dataset.department_performance`
SELECT 
    d.Dept_Id,
    d.Name AS DepartmentName,
    COUNT(DISTINCT e.Encounter_Key) AS TotalEncounters,
    COUNT(DISTINCT t.Transaction_Key) AS TotalTransactions,
    SUM(t.Amount) AS TotalBilledAmount,
    SUM(t.PaidAmount) AS TotalPaidAmount,
    AVG(t.PaidAmount) AS AvgPaymentPerTransaction
FROM `avd-databricks-demo.silver_dataset.departments` d
LEFT JOIN `avd-databricks-demo.silver_dataset.encounters` e 
    ON SPLIT(d.Dept_Id, "-")[SAFE_OFFSET(0)] = e.DepartmentID
LEFT JOIN `avd-databricks-demo.silver_dataset.transactions` t 
    ON SPLIT(d.Dept_Id, "-")[SAFE_OFFSET(0)] = t.DeptID
WHERE d.is_quarantined = FALSE
GROUP BY d.Dept_Id, d.Name;

--------------------------------------------------------------------------------------------------

-- 5. Financial Metrics (Gold) : Aggregates financial KPIs, such as total revenue, claim success rate, and outstanding balances.
-- 6. Payor Performance & Claims Summary (Gold): This table tracks the performance of insurance payors, focusing on claim approval rates, payout amounts, and processing efficiency.
