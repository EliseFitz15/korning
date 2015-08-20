-- DEFINE YOUR DATABASE SCHEMA HERE
DROP TABLE IF EXISTS sales, employee, frequency, product, customer;

CREATE TABLE employee(
  id SERIAL PRIMARY KEY,
 email VARCHAR(255),
 name VARCHAR(255)
);

CREATE TABLE frequency(
  id SERIAL PRIMARY KEY,
 invoice_frequency VARCHAR(255)
);

CREATE TABLE product(
  id SERIAL PRIMARY KEY,
 name VARCHAR(1000)
);

CREATE TABLE customer(
  id SERIAL PRIMARY KEY,
 act_no VARCHAR(255),
 company_name VARCHAR(1000)
);

CREATE TABLE sales(
  id SERIAL PRIMARY KEY,
 invoice_no INT,
 sale_date DATE,
 sale_amount MONEY,
 units_sold INT,
 frequency_id INT REFERENCES frequency(id),
 employee_id INT REFERENCES employee(id),
 product_id INT REFERENCES product(id),
 customer_id INT REFERENCES customer(id)
);
