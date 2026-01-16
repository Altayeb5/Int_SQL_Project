WITH customer_last_purchase AS(
SELECT 
customerkey,
cleaned_name,
orderdate,
first_purchase_date,
row_number() OVER(PARTITION BY customerkey ORDER BY orderdate DESC) AS rn,
cohort_year
FROM cohort_analysis
), 
last_orderdate AS(
SELECT max(orderdate) AS last_orderdate FROM sales 
),customer_status AS(
SELECT 
cl.customerkey,
cl.cleaned_name,
cl.orderdate AS last_purchase_date,
CASE 
	WHEN cl.orderdate < ld.last_orderdate - INTERVAL '6 months' THEN 'Churned'
	ELSE 'Active'
END AS customer_status,
cl.cohort_year
FROM customer_last_purchase cl ,last_orderdate ld
WHERE rn = 1 AND 
cl.first_purchase_date < ld.last_orderdate - INTERVAL '6 months'
)


SELECT 
cohort_year,
customer_status,
COUNT(customerkey) AS num_customers,
SUM(COUNT(customerkey)) OVER(PARTITION BY cohort_year) AS total_customers,
ROUND(COUNT(customerkey) / SUM(COUNT(customerkey)) OVER(PARTITION BY cohort_year),2)  AS status_percentage
FROM customer_status
GROUP BY cohort_year,customer_status
