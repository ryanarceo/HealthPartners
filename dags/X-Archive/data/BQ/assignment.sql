-- 4. Financial Metrics (Gold) : Aggregates financial KPIs, such as total revenue, claim success rate, and outstanding balances.

CREATE TABLE IF NOT EXISTS `gcp-health-partners-473103.gold_dataset.financial_metrics` AS
SELECT 
    COUNT(DISTINCT t.Transaction_Key) AS TotalTransactions,
    SUM(t.Amount) AS TotalBilledAmount,
    SUM(t.PaidAmount) AS TotalPaidAmount,
    SUM(t.Amount) - SUM(t.PaidAmount) AS OutstandingBalance,
    COUNT(DISTINCT CASE WHEN c.ClaimStatus = 'Approved' THEN c.Claim_Key END) AS ApprovedClaims,
    COUNT(DISTINCT c.Claim_Key) AS TotalClaims,
    ROUND((COUNT(DISTINCT CASE WHEN c.ClaimStatus = 'Approved' THEN c.Claim_Key END) / NULLIF(COUNT(DISTINCT c.Claim_Key), 0)) * 100, 2) AS ClaimApprovalRate
FROM `gcp-health-partners-473103.silver_dataset.transactions` t
LEFT JOIN `gcp-health-partners-473103ß.silver_dataset.claims` c 
    ON t.SRC_TransactionID = c.TransactionID
WHERE t.is_current = TRUE;

-- --------------------------------------------------------------------------------------------------

--5. Payor Performance & Claims Summary (Gold): This table tracks the performance of insurance payors, focusing on claim approval rates, payout amounts, and processing efficiency.

CREATE TABLE IF NOT EXISTS `gcp-health-partners-473103.gold_dataset.payor_performance` AS
SELECT 
    COUNT(DISTINCT c.Claim_Key) AS TotalClaims,
    COUNT(DISTINCT CASE WHEN c.ClaimStatus = 'Approved' THEN c.Claim_Key END) AS ApprovedClaims,
    COUNT(DISTINCT CASE WHEN c.ClaimStatus = 'Denied' THEN c.Claim_Key END) AS DeniedClaims,
    COUNT(DISTINCT CASE WHEN c.ClaimStatus = 'Pending' THEN c.Claim_Key END) AS PendingClaims,
    ROUND((COUNT(DISTINCT CASE WHEN c.ClaimStatus = 'Approved' THEN c.Claim_Key END) / NULLIF(COUNT(DISTINCT c.Claim_Key), 0)) * 100, 2) AS ClaimApprovalRate,
    SUM(CAST(c.ClaimAmount AS FLOAT64)) AS TotalClaimAmount,
    SUM(CAST(c.PaidAmount AS FLOAT64)) AS TotalPaidAmount,
    SUM(CAST(c.ClaimAmount AS FLOAT64)) - SUM(CAST(c.PaidAmount AS FLOAT64)) AS OutstandingAmount
FROM `gcp-health-partners-473103.silver_dataset.claims` c
WHERE c.is_current = TRUE
