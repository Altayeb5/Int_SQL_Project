WITH customer_ltv AS(
SELECT 
customerkey,
cleaned_name,
SUM(total_net_revenue) AS total_ltv
FROM cohort_analysis
GROUP BY customerkey,cleaned_name
), customer_segments AS(
SELECT
PERCENTILE_CONT(0.25) WITHIN GROUP(ORDER BY total_ltv) AS ltv_25th_percentile,
PERCENTILE_CONT(0.75) WITHIN GROUP(ORDER BY total_ltv) AS ltv_75th_percentile 
FROM customer_ltv
), segment_values AS(
SELECT 
cl.*,
CASE
	WHEN cl.total_ltv < ltv_25th_percentile THEN '1_ low_value'
	WHEN cl.total_ltv <= ltv_75th_percentile THEN '2_ mid_value'
	ELSE '3_  high_value' 
END AS customer_segment 

FROM customer_ltv cl,customer_segments cs 
)

SELECT 
customer_segment,
SUM(total_ltv) AS total_ltv

FROM segment_values
GROUP BY customer_segment