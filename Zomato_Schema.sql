
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

