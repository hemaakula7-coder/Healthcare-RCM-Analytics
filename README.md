# 🏥 Healthcare RCM Analytics
## Claims Analysis | Revenue Leakage | A/B Testing

## 📌 Overview
End-to-end Healthcare Revenue Cycle Management 
analytics project analyzing 4,500 insurance claims 
to identify denial patterns, revenue leakage, 
and optimize claim submission processes.

## 🛠️ Tools Used
![MySQL](https://img.shields.io/badge/MySQL-Database-blue)
![PowerBI](https://img.shields.io/badge/PowerBI-Dashboard-yellow)
![SQL](https://img.shields.io/badge/Advanced-SQL-orange)

## 📂 Dataset
- **Source:** Enhanced Health Insurance Claims (Kaggle)
- **Size:** 4,500 claims | 17 columns
- **Period:** July 2022 — July 2024

## 🔍 Key Findings
- 💸 **$14.77M Revenue Leakage** (65.44% of total billed)
- 🔴 **33.60% Denial Rate** — 3x industry benchmark
- 📞 **Phone submissions** best approval rate 34.65%
- 💻 **Online submissions** worst denial rate 35.93%
- 🏥 **General Practice** highest denial rate 35.45%
- 👶 **Pediatrics** highest revenue leakage $2.7M

## 📊 Dashboard Pages
| Page | Description |
|---|---|
| **Executive Summary** | KPIs, trends, claim status |
| **Denial Analytics** | Denial by specialty, age, type |
| **Revenue Leakage** | Leakage analysis & trends |
| **A/B Test Analysis** | Submission method comparison |

## 🔢 Advanced SQL Concepts Used
- CTEs (Common Table Expressions)
- Window Functions (RANK, LAG, Running Total)
- CASE WHEN statements
- Stored Procedures
- A/B Testing queries
- Revenue Leakage calculations

## 💡 Business Recommendations
1. Fix online portal validation — reduce 35.93% denial
2. Focus on Pediatrics billing — $2.7M leakage
3. Encourage phone submissions for better approval
4. Review General Practice coding — 35.45% denial rate
5. Implement monthly stored procedure reports

## 🚀 How to Use
1. Import CSV to MySQL using provided schema
2. Run `healthcare_rcm_queries.sql`
3. Open `Healthcare_RCM_Analytics.pbix` in Power BI

## 👤 Author
**Atchuta Hema Naga Santhoshi**
Data Analyst | US Healthcare Domain | 2.5 Years
[LinkedIn](https://www.linkedin.com/in/hema-akula-a920a8241) | 
[GitHub](https://github.com/hemaakula7-coder)
