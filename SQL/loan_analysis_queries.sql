-- loan_analysis: all views used by the Power BI dashboard


-- 1. KPI summary
create or replace view kpi_summary as
select count(txn_id) as Total_transactions,
sum(txn_amount) as Total_revenue,
round(avg(txn_amount),0) as Avg_transaction_amount
from transactions
where status = 'Success';


-- 2. Monthly revenue
create or replace view monthly_revenue as
select date_trunc('month',txn_date)::date as Date_column,
extract(month from txn_date) as month,
round(sum(txn_amount),0) as total_revenue,
count(txn_id) as total_transaction
from transactions
where status = 'Success' and txn_date is not null
group by date_column, month
order by date_column asc;


-- 3. Sales by product
create or replace view sales_by_product as
select product,
count(txn_id) as total_transaction,
round(sum(txn_amount),0) as total_revenue
from transactions
where status = 'Success' and product != 'Unavailable'
group by product
order by total_revenue desc;


-- 4. Sales by channel
create or replace view sales_by_channel as
select channel,
count(txn_id) as total_transaction,
round(sum(txn_amount),0) as total_revenue
from transactions
where status = 'Success'
group by channel
order by total_revenue desc;


-- 5. Revenue by customer occupation
create or replace view revenue_by_customer_occupation as
select c.occupation as occupation,
round(sum(t.txn_amount),0) as revenue,
count(t.txn_id) as total_transaction
from transactions as t
left join customers as c
on t.customer_id = c.customer_id
where status = 'Success'
group by occupation
order by revenue desc;


-- 6. Revenue by city
create or replace view revenue_by_city as
select c.city as city,
round(sum(t.txn_amount),0) as revenue,
count(t.txn_id) as total_transaction
from transactions as t
left join customers as c
on t.customer_id = c.customer_id
where status = 'Success' and city != 'UNKNOWN'
group by city
order by revenue desc;


-- 7. Revenue by account type
create or replace view revenue_by_account_type as
select c.account_type as account_type,
round(sum(t.txn_amount),0) as revenue,
count(t.txn_id) as total_transaction
from transactions as t
left join customers as c
on t.customer_id = c.customer_id
where status = 'Success'
group by account_type
order by revenue desc;


-- 8. Loan summary
create or replace view loan_summary as
select loan_type,
loan_status,
count(loan_id) as total_loans,
sum(loan_amount) as total_amount
from loans
group by loan_type, loan_status
order by total_amount desc;


-- 9. Loan risk
create or replace view loan_risk as
select case
when missed_payments <= 1 then 'low_risk'
when missed_payments between 2 and 4 then 'medium_risk'
else 'high_risk'
end as risk_level,
count(distinct customer_id) as number_of_customer,
sum(loan_amount) as total_loan_amt
from loans
group by risk_level
order by total_loan_amt;


-- 10. Top 10 customers by revenue
create or replace view top_customer_by_revenue as
select c.customer_id as id,
c.name as name,
sum(txn_amount) as revenue
from transactions as t
left join customers as c
on t.customer_id = c.customer_id
where status = 'Success'
group by id, name
order by revenue desc
limit 10;


-- 11. Month-over-month revenue growth
create or replace view monthly_growth as
with c_m_r as (
select date_trunc('month',txn_date)::date as date,
round(sum(txn_amount),0) as current_month_rev
from transactions
where status = 'Success' and txn_date is not null
group by date
),

p_m_r as (
select *,
lag(current_month_rev,1) over(order by date) as previous_month_rev
from c_m_r
)

select *,
cast(((current_month_rev - previous_month_rev) / previous_month_rev) * 100 as int) as percentage_change
from p_m_r;


-- 12. RFM (recency, frequency, monetary per customer)
create or replace view rfm as
with _recency_ as (
select customer_id,
max(txn_date) as recent_transaction,
(select max(txn_date)
from transactions
where status = 'Success' and txn_date is not null)::date - max(txn_date) as recency
from transactions
where status = 'Success' and txn_date is not null
group by customer_id
),

_frequency_ as (
select customer_id,
count(txn_id) as frequency
from transactions
where status = 'Success' and txn_date is not null
group by customer_id
),

_monetary_ as (
select customer_id,
sum(txn_amount) as monetary
from transactions
where status = 'Success' and txn_date is not null
group by customer_id
)

select r.customer_id, r.recency, f.frequency, m.monetary
from _recency_ as r
inner join _frequency_ as f
on r.customer_id = f.customer_id
inner join _monetary_ as m
on r.customer_id = m.customer_id;


-- 13. RFM customer segments
create or replace view rfm_customer_segment as
with _recency_ as (
select customer_id,
max(txn_date) as recent_transaction,
(select max(txn_date)
from transactions
where status = 'Success' and txn_date is not null)::date - max(txn_date) as recency
from transactions
where status = 'Success' and txn_date is not null
group by customer_id
),

_frequency_ as (
select customer_id,
count(txn_id) as frequency
from transactions
where status = 'Success' and txn_date is not null
group by customer_id
),

_monetary_ as (
select customer_id,
sum(txn_amount) as monetary
from transactions
where status = 'Success' and txn_date is not null
group by customer_id
),

rfm as (
select r.customer_id, r.recency, f.frequency, m.monetary
from _recency_ as r
inner join _frequency_ as f
on r.customer_id = f.customer_id
inner join _monetary_ as m
on r.customer_id = m.customer_id
)

select *,
case
when recency <= 60  and frequency >= 15 and monetary >= 1500000 then 'Champion'
when recency <= 120 and frequency >= 12 and monetary >= 1000000 then 'Loyal'
when recency > 120  and frequency >= 10 and monetary >= 1000000 then 'At Risk'
else 'Lost'
end as segment
from rfm
order by customer_id;