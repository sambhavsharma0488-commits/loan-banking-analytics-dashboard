# Loan & Banking Analytics Dashboard

An end-to-end analytics project: raw banking CSVs are cleaned with Python, loaded into PostgreSQL, modelled with SQL views, and visualised in a five-page Power BI dashboard.

## Business Question

How is revenue performing over time, where does it come from, and which customers and loans need attention?

## Tech Stack

- **Python** (pandas, SQLAlchemy, pg8000): data cleaning and loading
- **PostgreSQL 18**: storage and analysis layer
- **SQL**: 13 views holding all analysis logic (CTEs, window functions, joins)
- **Power BI**: interactive dashboard

## Workflow

```
CSV  ->  Python (clean)  ->  PostgreSQL  ->  SQL views  ->  Power BI
```

1. **Cleaning (pandas):** removed duplicate IDs, filled missing values (median for numeric columns, "UNKNOWN" / "Unavailable" for categories), fixed negative values, standardised text, and parsed dates.
2. **Loading:** cleaned data is loaded into three related tables (`customers`, `loans`, `transactions`) with primary and foreign keys.
3. **SQL views:** all business logic lives in the database. Revenue views count only transactions with `status = 'Success'`.
4. **Dashboard:** Power BI reads the views, not the raw tables.

## Dashboard

| Page | Contents |
|------|----------|
| Home | Navigation to every page |
| Overview | KPI cards, monthly revenue trend, month-over-month growth |
| Sales Breakdown | Revenue by product and by channel |
| Customers | Revenue by city, occupation and account type; top 10 customers |
| Loans | Loan status share by loan type; customers by risk level |
| RFM Segment | Segment slicer, customers per segment, revenue per segment, average RFM profile |

### Screenshots

![Home](screenshots/home.png)
![Overview](screenshots/overview.png)
![Sales Breakdown](screenshots/sales_breakdown.png)
![Customers](screenshots/customers.png)
![Loans](screenshots/loans.png)
![RFM Segment](screenshots/rfm_segment.png)

## SQL Views

| # | View | Purpose |
|---|------|---------|
| 1 | `kpi_summary` | Total transactions, total revenue, average transaction amount |
| 2 | `monthly_revenue` | Revenue and transaction count per month |
| 3 | `sales_by_product` | Revenue by product |
| 4 | `sales_by_channel` | Revenue by channel |
| 5 | `revenue_by_customer_occupation` | Revenue by occupation |
| 6 | `revenue_by_city` | Revenue by city |
| 7 | `revenue_by_account_type` | Revenue by account type |
| 8 | `loan_summary` | Loan count and amount by type and status |
| 9 | `loan_risk` | Customers and loan amount by risk level (low / medium / high) |
| 10 | `top_customer_by_revenue` | Top 10 customers by revenue |
| 11 | `monthly_growth` | Month-over-month revenue change using `LAG()` |
| 12 | `rfm` | Recency, frequency and monetary value per customer |
| 13 | `rfm_customer_segment` | RFM segments: Champion, Loyal, At Risk, Lost |

**Loan risk levels:** low = 0-1 missed payments, medium = 2-4, high = 5 or more.

**RFM segments:**

| Segment | Recency (days) | Frequency | Monetary |
|---------|----------------|-----------|----------|
| Champion | <= 60 | >= 15 | >= 1,500,000 |
| Loyal | <= 120 | >= 12 | >= 1,000,000 |
| At Risk | > 120 | >= 10 | >= 1,000,000 |
| Lost | everything else | | |

## Key Insights

- **Revenue:** 1.34bn from about 13K successful transactions, averaging roughly 100K each.
- **Trend:** monthly revenue moves between about 19M and 25.5M across 2020-2024, and month-over-month change swings from about -19% to +31%. The trend is volatile rather than steadily growing.
- **Products and channels:** revenue is spread almost evenly across the four products (330M-336M) and the four channels (324M-340M). Mobile is the lowest channel.
- **Geography and occupation:** Lucknow is the top city (131M) and Mumbai the lowest (84M). Salaried customers generate the most revenue among occupations.
- **Loans:** active loans are the largest share for every loan type, and defaults are a small share. By customer, 448 are low risk, 49 medium and 3 high.
- **RFM:** At Risk customers (287) generate about 412M, close to Loyal (452M), yet their average recency is 243 days. They are high-value customers who have gone quiet, which makes them the main retention target. Only 117 customers qualify as Champions.

## Data Notes

- 8 loans have an invalid disbursed date and 20 transactions have a missing date. Views that depend on dates (`monthly_revenue`, `monthly_growth`, `rfm`, `rfm_customer_segment`) exclude the missing-date transactions.
- In `loan_risk`, a customer with loans in several risk bands is counted once in each band, so the customer counts should not be added together.

## Project Structure

```
Loan_project/
├── DATA/
│   ├── Raw_data/          loans.csv, customers.csv, transactions.csv
│   └── Cleaned_data/      customers_clean.csv, loans_clean.csv, transactions_clean.csv
├── PYTHON_SRC/            customer_clean.py, loans_clean.py, transaction_clean.py
├── sql/                   loan_analysis_queries.sql
├── dashboard/             Power BI (.pbix) file
├── screenshots/           dashboard page images
├── requirements.txt
└── README.md
```

## Setup

1. Install the dependencies: `pip install -r requirements.txt`
2. Create a PostgreSQL database named `loan_analysis` with the `customers`, `loans` and `transactions` tables.
3. Create a `.env` file in the project root containing `DB_PASSWORD=your_password`.
4. Run the three scripts in `PYTHON_SRC/` to clean the data and load it into PostgreSQL.
5. Run `sql/loan_analysis_queries.sql` to create the views.
6. Open the `.pbix` file in Power BI Desktop and refresh the data.
