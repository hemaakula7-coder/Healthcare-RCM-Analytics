USE healthcare_rcm;

-- ============================================
-- QUERY 1: Basic Overview KPIs
-- ============================================
SELECT
    COUNT(*)                                          AS Total_Claims,
    ROUND(SUM(ClaimAmount), 2)                        AS Total_Billed,
    COUNT(CASE WHEN ClaimStatus = 'Approved' 
          THEN 1 END)                                 AS Approved_Claims,
    COUNT(CASE WHEN ClaimStatus = 'Denied' 
          THEN 1 END)                                 AS Denied_Claims,
    COUNT(CASE WHEN ClaimStatus = 'Pending' 
          THEN 1 END)                                 AS Pending_Claims,
    ROUND(COUNT(CASE WHEN ClaimStatus = 'Denied' 
          THEN 1 END) * 100.0 / COUNT(*), 2)          AS Denial_Rate_Pct,
    ROUND(COUNT(CASE WHEN ClaimStatus = 'Approved' 
          THEN 1 END) * 100.0 / COUNT(*), 2)          AS Approval_Rate_Pct
FROM claims;

-- ============================================
-- QUERY 2: Revenue Leakage Analysis
-- ============================================
WITH leakage AS (
    SELECT
        ClaimStatus,
        COUNT(*)                    AS Claim_Count,
        ROUND(SUM(ClaimAmount), 2)  AS Leakage_Amount
    FROM claims
    WHERE ClaimStatus IN ('Denied', 'Pending')
    GROUP BY ClaimStatus
)
SELECT
    ClaimStatus,
    Claim_Count,
    Leakage_Amount,
    ROUND(Leakage_Amount * 100.0 /
        (SELECT SUM(ClaimAmount) FROM claims), 2) AS Leakage_Pct
FROM leakage
UNION ALL
SELECT
    'TOTAL LEAKAGE'     AS ClaimStatus,
    SUM(Claim_Count)    AS Claim_Count,
    SUM(Leakage_Amount) AS Leakage_Amount,
    ROUND(SUM(Leakage_Amount) * 100.0 /
        (SELECT SUM(ClaimAmount) FROM claims), 2) AS Leakage_Pct
FROM leakage;

-- ============================================
-- QUERY 3: Denial Rate by Specialty
-- ============================================
SELECT
    ProviderSpecialty,
    COUNT(*)                                        AS Total_Claims,
    COUNT(CASE WHEN ClaimStatus = 'Denied' 
          THEN 1 END)                               AS Denied_Claims,
    ROUND(COUNT(CASE WHEN ClaimStatus = 'Denied'
          THEN 1 END) * 100.0 / COUNT(*), 2)        AS Denial_Rate_Pct,
    ROUND(SUM(ClaimAmount), 2)                      AS Total_Billed,
    ROUND(SUM(CASE WHEN ClaimStatus = 'Denied'
          THEN ClaimAmount ELSE 0 END), 2)          AS Specialty_Leakage,
    RANK() OVER (
        ORDER BY COUNT(CASE WHEN ClaimStatus = 'Denied'
        THEN 1 END) * 100.0 / COUNT(*) DESC
    )                                               AS Denial_Rank
FROM claims
GROUP BY ProviderSpecialty
ORDER BY Denial_Rate_Pct DESC;

-- ============================================
-- QUERY 4: A/B Test — Submission Method
-- ============================================
SELECT
    ClaimSubmissionMethod,
    COUNT(*)                                         AS Total_Claims,
    COUNT(CASE WHEN ClaimStatus = 'Denied' 
          THEN 1 END)                                AS Denied_Claims,
    COUNT(CASE WHEN ClaimStatus = 'Approved' 
          THEN 1 END)                                AS Approved_Claims,
    ROUND(COUNT(CASE WHEN ClaimStatus = 'Approved'
          THEN 1 END) * 100.0 / COUNT(*), 2)         AS Approval_Rate_Pct,
    ROUND(COUNT(CASE WHEN ClaimStatus = 'Denied'
          THEN 1 END) * 100.0 / COUNT(*), 2)         AS Denial_Rate_Pct,
    ROUND(SUM(ClaimAmount), 2)                       AS Total_Billed,
    ROUND(AVG(ClaimAmount), 2)                       AS Avg_Claim_Amount,
    RANK() OVER (
        ORDER BY COUNT(CASE WHEN ClaimStatus = 'Approved'
        THEN 1 END) * 100.0 / COUNT(*) DESC
    )                                                AS Performance_Rank
FROM claims
GROUP BY ClaimSubmissionMethod
ORDER BY Approval_Rate_Pct DESC;

-- ============================================
-- QUERY 5: Monthly Revenue Trend
-- ============================================
SELECT
    DATE_FORMAT(ClaimDate, '%Y-%m')          AS Claim_Month,
    COUNT(*)                                 AS Total_Claims,
    ROUND(SUM(ClaimAmount), 2)               AS Monthly_Billed,
    COUNT(CASE WHEN ClaimStatus = 'Denied'
          THEN 1 END)                        AS Denied_Claims,
    ROUND(SUM(CASE WHEN ClaimStatus = 'Denied'
          THEN ClaimAmount ELSE 0 END), 2)   AS Monthly_Leakage,
    ROUND(SUM(SUM(ClaimAmount)) OVER (
        ORDER BY DATE_FORMAT(ClaimDate, '%Y-%m')
    ), 2)                                    AS Running_Total_Billed,
    ROUND(SUM(SUM(CASE WHEN ClaimStatus = 'Denied'
        THEN ClaimAmount ELSE 0 END)) OVER (
        ORDER BY DATE_FORMAT(ClaimDate, '%Y-%m')
    ), 2)                                    AS Running_Leakage,
    ROUND(SUM(ClaimAmount) - LAG(SUM(ClaimAmount))
        OVER (ORDER BY DATE_FORMAT(ClaimDate, '%Y-%m')),
    2)                                       AS MoM_Change
FROM claims
GROUP BY DATE_FORMAT(ClaimDate, '%Y-%m')
ORDER BY Claim_Month;

-- ============================================
-- QUERY 6: Age Group Analysis
-- ============================================
SELECT
    CASE
        WHEN PatientAge < 18  THEN 'Under 18'
        WHEN PatientAge < 30  THEN '18-29'
        WHEN PatientAge < 45  THEN '30-44'
        WHEN PatientAge < 60  THEN '45-59'
        ELSE '60+'
    END                                             AS Age_Group,
    COUNT(*)                                        AS Total_Claims,
    ROUND(SUM(ClaimAmount), 2)                      AS Total_Billed,
    ROUND(AVG(ClaimAmount), 2)                      AS Avg_Claim_Amount,
    COUNT(CASE WHEN ClaimStatus = 'Denied'
          THEN 1 END)                               AS Denied_Claims,
    ROUND(COUNT(CASE WHEN ClaimStatus = 'Denied'
          THEN 1 END) * 100.0 / COUNT(*), 2)        AS Denial_Rate_Pct,
    ROUND(SUM(CASE WHEN ClaimStatus = 'Denied'
          THEN ClaimAmount ELSE 0 END), 2)          AS Revenue_Leakage
FROM claims
GROUP BY Age_Group
ORDER BY Total_Claims DESC;

-- ============================================
-- QUERY 7: Provider Performance Scorecard
-- ============================================
WITH provider_stats AS (
    SELECT
        ProviderID,
        ProviderSpecialty,
        COUNT(*)                                    AS Total_Claims,
        ROUND(SUM(ClaimAmount), 2)                  AS Total_Billed,
        COUNT(CASE WHEN ClaimStatus = 'Approved'
              THEN 1 END)                           AS Approved_Claims,
        COUNT(CASE WHEN ClaimStatus = 'Denied'
              THEN 1 END)                           AS Denied_Claims,
        ROUND(COUNT(CASE WHEN ClaimStatus = 'Denied'
              THEN 1 END) * 100.0 / COUNT(*), 2)    AS Denial_Rate_Pct,
        ROUND(SUM(CASE WHEN ClaimStatus = 'Denied'
              THEN ClaimAmount ELSE 0 END), 2)      AS Revenue_Leakage
    FROM claims
    GROUP BY ProviderID, ProviderSpecialty
)
SELECT
    ProviderID,
    ProviderSpecialty,
    Total_Claims,
    Total_Billed,
    Approved_Claims,
    Denied_Claims,
    Denial_Rate_Pct,
    Revenue_Leakage,
    RANK() OVER (
        PARTITION BY ProviderSpecialty
        ORDER BY Denial_Rate_Pct ASC
    )                                               AS Rank_In_Specialty,
    CASE
        WHEN Denial_Rate_Pct < 20 THEN 'Excellent'
        WHEN Denial_Rate_Pct < 35 THEN 'Good'
        WHEN Denial_Rate_Pct < 45 THEN 'Needs Improvement'
        ELSE 'Critical'
    END                                             AS Performance_Score
FROM provider_stats
ORDER BY Denial_Rate_Pct ASC;

-- ============================================
-- QUERY 8: Stored Procedure
-- ============================================
DROP PROCEDURE IF EXISTS GetMonthlyReport;

DELIMITER //
CREATE PROCEDURE GetMonthlyReport(
    IN report_year INT,
    IN report_month INT
)
BEGIN
    SELECT
        DATE_FORMAT(ClaimDate, '%M %Y')      AS Report_Month,
        COUNT(*)                             AS Total_Claims,
        ROUND(SUM(ClaimAmount), 2)           AS Total_Billed,
        COUNT(CASE WHEN ClaimStatus = 'Approved'
              THEN 1 END)                    AS Approved_Claims,
        COUNT(CASE WHEN ClaimStatus = 'Denied'
              THEN 1 END)                    AS Denied_Claims,
        ROUND(COUNT(CASE WHEN ClaimStatus = 'Denied'
              THEN 1 END) * 100.0
              / COUNT(*), 2)                 AS Denial_Rate_Pct,
        ROUND(SUM(CASE WHEN ClaimStatus = 'Denied'
              THEN ClaimAmount ELSE 0 END),
              2)                             AS Revenue_Leakage,
        ClaimType,
        ClaimSubmissionMethod
    FROM claims
    WHERE YEAR(ClaimDate)  = report_year
    AND   MONTH(ClaimDate) = report_month
    GROUP BY
        DATE_FORMAT(ClaimDate, '%M %Y'),
        ClaimType,
        ClaimSubmissionMethod;
END //
DELIMITER ;

-- Call for different months!
CALL GetMonthlyReport(2024, 1);
CALL GetMonthlyReport(2024, 2);
CALL GetMonthlyReport(2023, 6);