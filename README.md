# SQL Data Analysis for The delivery Food Service Zomato

## Overview
This project is an end-to-end SQL analytics case study on a Zomato-style food delivery platform, built on five core tables: customers, restaurants, orders, deliveries, and riders. 
Using PostgreSQL, it explores customer behavior, restaurant performance, delivery efficiency, and seasonal demand patterns through 20 business-driven queries.

The analysis covers a wide range of questions: top dishes for a specific customer over the last 2.5 years, peak ordering time slots, high-value and high-frequency customers, and customers at risk of churn. 
It evaluates restaurant revenue by city, not-delivered orders and cancellation rates by year, most popular dishes per city, and city-level revenue rankings.

Operational performance is examined through rider-focused queries such as average delivery time, derived star ratings based on delivery speed, and monthly rider earnings (assuming an 8% commission on order value). 
Time-series and growth queries analyze monthly sales trends, restaurant growth ratios based on delivered orders, and seasonal demand spikes for menu items using a Spring/Summer/Fall/Winter breakdown.

Overall, the project demonstrates strong use of joins, window functions, CTEs, date/time logic, and conditional aggregation to answer realistic business questions for a food-delivery marketplace.

## Project Structure

**Database Setup:-** Creating the database for zomato and then creating required tables and adding the relationship into these tables

```sql
-- CREATING TABLE

DROP TABLE IF EXISTS customers;

CREATE TABLE customers (
		customer_id INT PRIMARY KEY,
		customer_name VARCHAR(50),
		reg_date DATE
);

DROP TABLE IF EXISTS restaurants;

CREATE TABLE restaurants (
			restaurant_id INT PRIMARY KEY,
			restaurant_name VARCHAR(35),
			city VARCHAR(25),
			opening_hours VARCHAR(55)

);

DROP TABLE IF EXISTS orders;
CREATE TABLE orders (
					order_id INT PRIMARY KEY,
					customer_id INT,
					restaurant_id INT,
					order_item VARCHAR(55),
					order_date DATE,
					order_time TIME,
					order_status VARCHAR(30),
					total_amount FLOAT
);

DROP TABLE IF EXISTS riders;

CREATE TABLE riders (
				rider_id INT PRIMARY KEY,	
				rider_name VARCHAR(30),
				sign_up DATE
);

DROP TABLE IF EXISTS deliveries;

CREATE TABLE deliveries (
					delivery_id INT  PRIMARY KEY,
					order_id INT,
					delivery_status VARCHAR(50),
					delivery_time TIME,
					rider_id INT
);


-- CREATING FK RELATIONSHIP

ALTER TABLE deliveries
ADD CONSTRAINT fk_order_id
FOREIGN KEY (order_id)
REFERENCES orders(order_id);

ALTER TABLE deliveries
ADD CONSTRAINT fk_rider_id
FOREIGN KEY (rider_id)
REFERENCES riders(rider_id);

ALTER TABLE orders
ADD CONSTRAINT fk_customer_id
FOREIGN KEY (customer_id)
REFERENCES customers(customer_id);

ALTER TABLE orders
ADD CONSTRAINT fk_resturant_id
FOREIGN KEY (restaurant_id)
REFERENCES restaurants(restaurant_id);
```
![ERD](https://github.com/AJJadhav29/Zomato_analysis/blob/main/ERD_of_zomato.png)

** Data Import & Cleaning:-** Inserting the csv file data into the tables and then handling null values and ensuring data integrity.

**Business Problems and Key analyses:-** 

This project answers 20 business-focused questions that cover customers, restaurants, riders, and overall platform performance.
​
Customer and restaurant insights
- Top dishes for a specific customer: Identify the top 5 most frequently ordered dishes for a given customer (e.g., “Arjun Mehta”) over the last 2.5 years.​
- Peak ordering times: Find the 2‑hour time slots during which the platform receives the most orders.​
- High-frequency, high-value customers: Compute average order value (AOV) for customers who have placed more than 750 orders, and list customers who have spent more than 100K in total.​
- Undelivered orders by restaurant: Find orders that were placed but not delivered, aggregated by restaurant and city.​
- Restaurant revenue ranking: Rank restaurants by total revenue in the last 2.5 years, within each city​
- Most popular dish by city: Identify the most frequently ordered dish in each city.
- Inactive customers: Find customers who ordered in 2023 but did not place any order in 2024.

Cancellations and growth
- Yearly cancellation rates: Calculate and compare order cancellation rates for each restaurant between the current year and the previous year.
- Restaurant growth ratio: Compute each restaurant’s month‑over‑month growth in delivered orders using window functions.

Rider performance and earnings
- Average delivery time per rider: Calculate average delivery time for each rider, accounting for overnight deliveries.
- Monthly rider earnings: Estimate each rider’s total monthly earnings assuming an 8% commission on order amounts.
- Rider star ratings: Derive 5‑star, 4‑star, and 3‑star counts per rider based on delivery time thresholds (under 15 minutes, 15–20, over 20).
- Rider efficiency extremes: Identify riders with the lowest and highest average delivery times.

Time-series, demand, and segmentation
- Weekly peaks per restaurant: Find the peak day of the week for orders for each restaurant.
- Customer lifetime value: Compute total revenue generated by each customer across all their orders.
- Monthly sales trends: Compare each month’s total sales to the previous month to identify trends.
- Seasonal item demand: Track the popularity of dishes across seasons (Spring, Summer, Fall, Winter) and identify the top season for each item.
- City revenue ranking: Rank cities by total revenue for the year 2023.
- Customer segmentation: Segment customers into “Gold” and “Silver” based on their total spending relative to average order value, and summarize total orders and revenue per segment.

#### Q1 Write a query to find the top 5 most frequently ordered dishes by the customer "Arjun Mehta" in the last 2.5 year.
