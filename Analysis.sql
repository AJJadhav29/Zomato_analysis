-- Analysis

SELECT * FROM customers;

SELECT * FROM restaurants;

SELECT * FROM deliveries;

SELECT * FROM orders;

SELECT * FROM riders;


/*Q1 Write a query to find the top 5 most frequently ordered dishes by the customer "Arjun Mehta" 
in the last 2.5 year.*/

SELECT * 
FROM (SELECT 
	c.customer_id,
	c.customer_name,
	o.order_item AS dishes,
	COUNT(*) as total_orders,
	DENSE_RANK() OVER(ORDER BY COUNT(*) DESC) AS rank
FROM customers AS c
JOIN orders AS o
ON o.customer_id = c.customer_id
WHERE o.order_date >= (CURRENT_DATE - INTERVAL '2.5 Year') AND c.customer_name = 'Arjun Mehta'  
GROUP BY 1,2,3) as t1
WHERE rank BETWEEN 1 AND 5;

-- Q2 Identify the time slots during which the most orders are placed, based on 2-hour intervals.


-- need to create 2 hour slot

SELECT
		CASE
			WHEN  EXTRACT(HOUR FROM order_time) BETWEEN 0 AND 1 THEN '00:00 - 02:00'
			WHEN  EXTRACT(HOUR FROM order_time) BETWEEN 2 AND 3 THEN '02:00 - 04:00'
			WHEN  EXTRACT(HOUR FROM order_time) BETWEEN 4 AND 5 THEN '04:00 - 06:00'
			WHEN  EXTRACT(HOUR FROM order_time) BETWEEN 6 AND 7 THEN '06:00 - 08:00'
			WHEN  EXTRACT(HOUR FROM order_time) BETWEEN 8 AND 9 THEN '08:00 - 10:00'
			WHEN  EXTRACT(HOUR FROM order_time) BETWEEN 10 AND 11 THEN '10:00 - 12:00'
			WHEN  EXTRACT(HOUR FROM order_time) BETWEEN 12 AND 13 THEN '12:00 - 14:00'
			WHEN  EXTRACT(HOUR FROM order_time) BETWEEN 14 AND 15 THEN '14:00 - 16:00'
			WHEN  EXTRACT(HOUR FROM order_time) BETWEEN 16 AND 17 THEN '16:00 - 18:00'
			WHEN  EXTRACT(HOUR FROM order_time) BETWEEN 18 AND 19 THEN '18:00 - 20:00'
			WHEN  EXTRACT(HOUR FROM order_time) BETWEEN 20 AND 21 THEN '20:00 - 22:00'
			WHEN  EXTRACT(HOUR FROM order_time) BETWEEN 21 AND 22 THEN '22:00 - 00:00'
		END as start_slot,
		COUNT(order_id) as total_order
FROM orders
GROUP BY 1
ORDER BY 2 DESC;

-- Approach 2

SELECT CONCAT(start_time,'  :  ',end_time) AS time_slot,
		total_orders
FROM(
SELECT 
	FLOOR(EXTRACT(HOUR FROM order_time)/2)*2 AS start_time,
	FLOOR(EXTRACT(HOUR FROM order_time)/2)*2+2 AS end_time,
	COUNT(*) AS total_orders
FROM orders
GROUP BY 1,2
ORDER BY 3 DESC) as t1;



/*Q3 Find the average order value (AOV) per customer who has placed more than 750 orders.
Return: customer_name, aov (average order value).*/

SELECT *
FROM(SELECT c.customer_name,
	COUNT(*) as total_orders,
	AVG(o.total_amount) AS average_order_value
FROM customers AS c
JOIN orders AS o
ON o.customer_id = c.customer_id
GROUP BY 1
ORDER BY 2 DESC) AS t1
WHERE total_orders > 750;


--- 2

SELECT c.customer_name,
	AVG(o.total_amount) AS average_order_value
FROM customers AS c
JOIN orders AS o
ON o.customer_id = c.customer_id
GROUP BY 1
HAVING COUNT(*)>750;


-- Q4 List the customers who have spent more than 100K in total on food orders. Return: customer_name, customer_id.
SELECT c.customer_name,
		c.customer_id
FROM customers AS c
JOIN orders AS o
ON o.customer_id = c.customer_id
GROUP BY 1,2
HAVING SUM(o.total_amount)> 100000;

-- Q5 Write a query to find orders that were placed but not delivered. Return: restaurant_name, city, and the number of not delivered orders.

-- below query will work for this dataset as the data is clean
SELECT r.restaurant_name,
r.city,
COUNT(o.order_id) AS not_delivered
FROM orders AS o
LEFT JOIN restaurants AS r
ON r.restaurant_id = o.restaurant_id
LEFT JOIN deliveries AS d
ON d.order_id = o.order_id
WHERE d.delivery_status IN ('Not Delivered', 'Order') OR o.order_status <> 'Completed' OR d.order_id IS NULL
GROUP BY 1,2;


-- this will work for all for duplicates
SELECT r.restaurant_name,
r.city,
COUNT( DISTINCT CASE 
					WHEN d.delivery_status IN ('Not Delivered', 'Order') 
					OR 
					o.order_status <> 'Completed' 
					OR 
					d.order_id IS NULL 
					THEN 
					o.order_id
				END) AS not_delivered
FROM orders AS o
LEFT JOIN restaurants AS r
	ON r.restaurant_id = o.restaurant_id
LEFT JOIN deliveries AS d
	ON d.order_id = o.order_id
GROUP BY 1,2;

-- Q6 Rank restaurants by their total revenue from the last 2.5 year. Return: restaurant_name, total_revenue, and their rank within their city.
WITH ranking_table
AS
(
SELECT r.city,
		r.restaurant_name,
		SUM(o.total_amount) AS revenue,
		RANK() OVER(PARTITION BY r.city ORDER BY SUM(o.total_amount) DESC) AS rank
FROM orders AS o
JOIN restaurants AS r
ON r.restaurant_id = o.restaurant_id
WHERE o.order_date >= CURRENT_DATE - INTERVAL '2.5 year'
GROUP BY 1,2
)

SELECT *
FROM ranking_table;

-- Q7 Identify the most popular dish in each city based on the number of orders.
WITH dish_table
AS
(SELECT o.order_item,
		r.city,
		COUNT(o.order_item) as no_of_ordered_dish,
		RANK() OVER(PARTITION BY r.city ORDER BY COUNT(o.order_item) DESC) as rank
FROM orders AS o
JOIN restaurants AS r
ON r.restaurant_id = o.restaurant_id
GROUP BY 1,2
)

SELECT *
FROM dish_table
WHERE rank = 1;


-- Q8 Find customers who haven’t placed an order in 2024 but did in 2023. Need customer_name, customer id

SELECT DISTINCT c.customer_id, c.customer_name
FROM orders AS o
JOIN customers AS c
ON c.customer_id = o.customer_id
WHERE EXTRACT(YEAR FROM o.order_date) = 2023 AND c.customer_id NOT IN (
																SELECT DISTINCT customer_id
																FROM orders
																WHERE EXTRACT(YEAR FROM order_date) = 2024
																);

-- Q9 Calculate and compare the order cancellation rate for each restaurant between the current year and the previous year.


WITH cancel_ratio_23
AS
(
	SELECT o.restaurant_id,
		COUNT(o.order_id) AS total_orders,
		COUNT(
				CASE WHEN d.delivery_status IN ('Not Delivered', 'Order') 
					OR 
					o.order_status <> 'Completed' 
					OR 
					d.order_id IS NULL THEN 1 END
		) as not_delivered
	FROM orders AS o
	FULL OUTER JOIN deliveries AS d
	ON d.order_id = o.order_id
	WHERE EXTRACT(YEAR FROM o.order_date) = 2023
	GROUP BY 1
),
cancel_ratio_24
AS
(
	SELECT o.restaurant_id,
		COUNT(o.order_id) AS total_orders,
		COUNT(
				CASE WHEN d.delivery_status IN ('Not Delivered', 'Order') 
					OR 
					o.order_status <> 'Completed' 
					OR 
					d.order_id IS NULL THEN 1 END
		) as not_delivered
	FROM orders AS o
	FULL OUTER JOIN deliveries AS d
	ON d.order_id = o.order_id
	WHERE EXTRACT(YEAR FROM o.order_date) = 2024
	GROUP BY 1
),
last_year_data
AS
(
	SELECT restaurant_id,
		total_orders,
		not_delivered,
		ROUND(not_delivered::numeric/total_orders::numeric * 100,2) AS cancel_ratio_23
	FROM cancel_ratio_23
),
current_year_data
AS
(
	SELECT restaurant_id,
		total_orders,
		not_delivered,
		ROUND(not_delivered::numeric/total_orders::numeric * 100,2) AS cancel_ratio_24
	FROM cancel_ratio_24
)

SELECT
	cy.restaurant_id,
	ly.total_orders As total_orders_23,
	cy.total_orders AS total_orders_24,
	ly.not_delivered AS not_delivered_in_23,
	cy.not_delivered AS not_delivered_in_24,
ly.cancel_ratio_23,
	cy.cancel_ratio_24
FROM current_year_data as cy
JOIN last_year_data as ly
ON cy.restaurant_id=ly.restaurant_id;

-- Q10 Determine each rider's average delivery time.

SELECT 
	d.rider_id,
	r.rider_name,
	ROUND(AVG(EXTRACT(EPOCH FROM ((d.delivery_time - o.order_time) + 
			CASE WHEN d.delivery_time < o.order_time THEN INTERVAL '1 day'
			ELSE INTERVAL '0 day' END))/60.0),2)  as time_difference
FROM orders AS o
JOIN  deliveries AS d
ON d.order_id = o.order_id
JOIN riders as r
ON r.rider_id = d.rider_id
WHERE d.delivery_status = 'Delivered'
GROUP BY 1,2;


-- Q11 Calculate each restaurant's growth ratio based on the total number of delivered orders since its joining.

WITH growth_ratio
AS
(
SELECT 
	o.restaurant_id,
	DATE_TRUNC('month',o.order_date) as month,
	COUNT(o.order_id) as current_month_orders,
	LAG(COUNT(o.order_id),1) OVER(PARTITION BY o.restaurant_id ORDER BY DATE_TRUNC('month',o.order_date)) as last_month_orders 
FROM orders AS o
JOIN deliveries as d
ON d.order_id = o.order_id
WHERE d.delivery_status = 'Delivered'
GROUP BY 1,2
)
SELECT 
	restaurant_id,
	month,
	current_month_orders,
	last_month_orders,
	ROUND((current_month_orders::numeric - last_month_orders::numeric)/last_month_orders::numeric * 100,2) as each_rest_ratio
FROM growth_ratio;

/*Q12 Segment customers into 'Gold' or 'Silver' groups based on their total spending compared to the
average order value (AOV). If a customer's total spending exceeds the AOV, label them as
'Gold'; otherwise, label them as 'Silver'.
Return: The total number of orders and total revenue for each segment.*/

WITH segment
AS(SELECT 
	customer_id,
	SUM(total_amount) AS total_spend,
	COUNT(order_id) AS total_orders,
	CASE 
		WHEN SUM(total_amount)>(SELECT AVG(total_amount) FROM orders) THEN 'Gold Member'
		ELSE 'Silver Member'
	END AS customer_category
FROM orders
GROUP BY 1)

SELECT 
	SUM(total_spend) AS total_revenue,
	SUM(total_orders) AS total_orders,
	customer_category
FROM segment
GROUP BY 3



-- Q13 Calculate each rider's total monthly earnings, assuming they earn 8% of the order amount.

SELECT 
	d.rider_id,
	EXTRACT(MONTH FROM o.order_date) AS month,
	EXTRACT(YEAR FROM o.order_date) AS YEAR,
	COUNT(o.order_id) AS total_orders,
	ROUND(SUM(o.total_amount)::numeric * 0.08, 2) AS total_earning
FROM orders as o
JOIN deliveries as d
ON d.order_id = o.order_id
GROUP BY 1,2,3
ORDER BY 1,3,2

/* Q14 Find the number of 5-star, 4-star, and 3-star ratings each rider has.
Riders receive ratings based on delivery time:
● 5-star: Delivered in less than 15 minutes
● 4-star: Delivered between 15 and 20 minutes
● 3-star: Delivered after 20 minutes */

SELECT 
	rider_id,
	rating,
	COUNT(*) AS total_stars
FROM
	(SELECT 
		rider_id,
		delivery_process_time,
		CASE WHEN delivery_process_time<15 THEN '5_star' 
			 WHEN delivery_process_time BETWEEN 15 AND 20 THEN '4-star'
			 ELSE '3-star'
		END AS rating
	FROM 
		(SELECT 
			d.rider_id,
			r.rider_name,
			EXTRACT(EPOCH FROM(d.delivery_time-o.order_time) + CASE WHEN d.delivery_time < o.order_time THEN INTERVAL '1 day'
					ELSE INTERVAL '0 day' END)/60 as delivery_process_time
		FROM orders AS o
		JOIN  deliveries AS d
		ON d.order_id = o.order_id
		JOIN riders as r
		ON r.rider_id = d.rider_id
		WHERE d.delivery_status = 'Delivered'
	)as t1) as t2
GROUP BY 1, 2
ORDER BY 1,3 DESC;

-- Q15 Analyze order frequency per day of the week and identify the peak day for each restaurant.


SELECT 
	*
FROM (
SELECT 
	r.restaurant_name,
	TO_CHAR(o.order_date, 'Day') as day,
	COUNT(o.order_id) as order_count,
	RANK() OVER(PARTITION BY r.restaurant_name ORDER BY COUNT(o.order_id) DESC) AS rank
FROM orders AS o
JOIN restaurants AS r
ON r.restaurant_id = o.restaurant_id
GROUP BY 1,2 
) AS t1
WHERE rank = 1;

-- Q16 Calculate the total revenue generated by each customer over all their orders.

SELECT 
	c.customer_name,
	o.customer_id,
	SUM(o.total_amount) AS customer_lifetime_value
FROM orders AS o
JOIN customers AS c
ON c.customer_id = o.customer_id
GROUP BY 1,2;


-- Q17 Identify sales trends by comparing each month's total sales to the previous month.
SELECT 
	year,
	month,
	total_sale_month,
	LAG(month,1) OVER(ORDER BY year, month), 
	LAG(total_sale_month,1) OVER(ORDER BY year, month) as previous_month_total_sale
FROM (
	SELECT 
		EXTRACT(YEAR FROM order_date) as year,
		EXTRACT(MONTH FROM order_date) as month,
		SUM(total_amount) as total_sale_month
	FROM orders
	GROUP BY 1,2) t1;


-- Q18 Evaluate rider efficiency by determining average delivery times and identifying those with the lowest and highest averages.
SELECT
	MAX(avg_time) AS highest_avg_time,
	MIN(avg_time) AS lowest_avg_time
FROM
(
	WITH avg_delivery_time
	AS 
		(SELECT 
			d.rider_id,
			r.rider_name,
			ROUND(AVG(EXTRACT(EPOCH FROM ((d.delivery_time - o.order_time) + 
					CASE WHEN d.delivery_time < o.order_time THEN INTERVAL '1 day'
					ELSE INTERVAL '0 day' END))/60.0),2)  as time_difference
		FROM orders AS o
		JOIN  deliveries AS d
		ON d.order_id = o.order_id
		JOIN riders as r
		ON r.rider_id = d.rider_id
		WHERE d.delivery_status = 'Delivered'
		GROUP BY 1,2)
		
	SELECT 
		rider_id,
		rider_name,
		AVG(time_difference) AS avg_time
	FROM avg_delivery_time
	GROUP BY 1,2) as t1;


-- Q19 Track the popularity of specific order items over time and identify seasonal demand spikes.
SELECT *
FROM (SELECT 
	order_item,
	seasons,
	COUNT(order_id) as total_orders,
	RANK() OVER(PARTITION BY order_item ORDER BY COUNT(order_id) DESC) AS rank
FROM (
	SELECT
		order_item,
		order_id,
		EXTRACT(MONTH FROM order_date),
		CASE 
			WHEN EXTRACT(MONTH FROM order_date) BETWEEN 3 AND 5 THEN ' Spring'
			WHEN EXTRACT(MONTH FROM order_date) BETWEEN 6 AND 8 THEN ' Summer'
			WHEN EXTRACT(MONTH FROM order_date) BETWEEN 9 AND 11 THEN ' Fall'
			ELSE 'Winter'
		END as seasons
	FROM orders
		) as t1
GROUP BY 1,2) AS t2
WHERE rank = 1
				

-- Q20 Rank each city based on the total revenue for the last year (2023).

WITH year_table
AS 
(
	SELECT 
		*,
		EXTRACT(YEAR FROM o.order_date) as year
	FROM orders as o
	JOIN restaurants as r
	ON o.restaurant_id = r.restaurant_id
)

SELECT 	
	city,
	SUM(total_amount) as total_revenue,
	RANK() OVER(ORDER BY SUM(total_amount) DESC) as city_rank
FROM year_table
WHERE year = 2023
GROUP BY 1;