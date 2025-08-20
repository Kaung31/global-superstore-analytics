# 📊 Global Superstore Analytics

This project showcases an end-to-end data analytics workflow using the well-known **Global Superstore dataset** (51k orders, 2011–2014).  
I built a SQL star schema, validated key business metrics, and designed an **interactive Power BI dashboard** to highlight sales, profit, and customer insights.

---

## 🚀 Project Workflow
1. **Data Setup**  
   - Imported raw CSV into SQLite via DBeaver.  
   - Cleaned and standardized fields (dates, sales, profit).  

2. **Data Modeling**  
   - Designed a **star schema**:  
     - Fact table: `fact_orders`  
     - Dimensions: Customer, Product, Geography, Date, Shipping  
   - Verified metrics matched the raw dataset ($12.6M sales, $1.47M profit, 11.6% margin).  

3. **Data Enrichment**  
   - Joined fact + dimensions into a clean dataset.  
   - Exported as `orders_enriched_fact.csv` for analysis.  

4. **Power BI Dashboard**  
   - Built DAX measures:  
     - Total Sales  
     - Total Profit  
     - Profit Margin %  
     - Average Order Value  
     - Unique Customers  
   - Visuals: KPI cards, sales trend, bar charts, map, and product/customer breakdowns.  

---

## 📈 Key Insights
- 🌍 **APAC & US drive the majority of revenue**, while **Europe delivers the highest profit margins**.  
- 🖇️ **Office Supplies sell the most units**, but **Technology generates the highest profit**.  
- 👥 **Corporate customers are highly profitable**, despite fewer orders than Consumer segment.  
- 🚚 Shipping mode influences cost and margin — **Second Class has lower margins compared to Standard Class**.  

---

## 📂 Repository Structure

"""
global-superstore-analytics/
├─ data/
│  └─ orders_enriched_fact.csv
├─ sql/
│  ├─ A_00_inspect_schema.sql
│  ├─ A_01_create_dimensions.sql
│  ├─ A_02_create_fact.sql
│  ├─ A_03_quality_checks.sql
│  └─ A_04_view_and_indexes.sql
├─ powerbi/
│  └─ Global_Superstore_Dashboard.pbix
└─ README.md
"""
---

## 🛠️ Tools Used
- **SQLite + DBeaver** → data cleaning & star schema modeling  
- **SQL** → ETL, dimension/fact creation, validation checks  
- **Power BI** → DAX, dashboard design, storytelling  

---

## 🎯 Why This Project Matters
Recruiters want to see not just tools, but **business storytelling**:  
- Can you take messy data and structure it? ✅  
- Can you deliver reliable KPIs and trends? ✅  
- Can you tell a story with insights? ✅  

This project proves all three.  

---

## 🔗 How to Explore
- Open `orders_enriched_fact.csv` → clean dataset for analysis  
- Open `sql/` → schema creation and validation scripts  
- Open `Global_Superstore_Dashboard.pbix` in Power BI Desktop → interactive dashboard  
