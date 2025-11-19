# 💳 Credit Card Risk, Revenue & Fraud Analytics  
**SQL | Finance Domain | MySQL | Power BI**

## 📌 Overview
This project analyzes **1 million credit card transactions** to identify:
- High-risk customers (credit risk analysis)
- Portfolio revenue from merchant fees & interest
- Fraud and suspicious transaction patterns
- Delinquency exposure using **DPD buckets**

This is the same type of analytics used at **American Express, JPMorgan, Mastercard, Citi**.

---

## 🗄️ Data Model
| Table | Rows | Purpose |
|------|------|---------|
| customers | 100K | Credit score, income, demographics |
| cards | 200K | Exposure, APR, product type |
| transactions | 1 Million | Revenue + Fraud analytics |
| statements | 200K | Delinquency (DPD) |
| payments | 200K | Repayment behavior |

📌 Database: **MySQL**  
📌 Currency: **USD ($)**  
📌 Date Format: **MM-DD-YYYY**

---

## 🔍 Key Finance KPIs
- Portfolio Utilization Rate
- CLTV – Customer Lifetime Value
- Merchant Fee Revenue
- Delinquency (DPD) Exposure
- Fraud High-Risk Alerts

---

## 🧠 SQL Analysis Highlights
✔ Revenue Trend Analysis  
✔ Fraud Detection using timestamp comparison  
✔ Credit Risk Segmentation (70%+ utilization)  
✔ DPD Buckets: Current, 1–30, 31–60, 61–90, 90+  
✔ High-Value Merchant Category Profitability  

All queries included in `/sql/queries_finance.sql`

---

## 📊 Power BI Dashboard (Coming)
Amex Royal Blue Theme includes:
1. **Portfolio Summary**
2. **Risk & Delinquency Exposure**
3. **Fraud Monitoring View**

Screenshots and `.pbix` file will be attached soon.

---

## 🧩 Folder Structure
