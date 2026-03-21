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

** Data Import & Cleaning:-** Inserting the csv file data into the tables and then handling null values and ensuring data integrity.

![ERD](https://github.com/AJJadhav29/Zomato_analysis/blob/main/ERD_of_zomato.png)

