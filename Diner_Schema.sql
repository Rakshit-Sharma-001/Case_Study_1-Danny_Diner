-- Whole work done in MYSQL Workbench

-- Schema Created

create schema dannys_diner;
use dannys_diner;

-- Tables created

CREATE TABLE members (
    customer_id CHAR(2) NOT NULL PRIMARY KEY,
    join_date DATE
);
CREATE TABLE menu (
    product_id INT NOT NULL PRIMARY KEY,
    product_name VARCHAR(20) NOT NULL,
    price INT NOT NULL
);
CREATE TABLE sales (
    customer_id CHAR(2) NOT NULL,
    order_date DATE,
    product_id INT NOT NULL,
    FOREIGN KEY (customer_id)
        REFERENCES members (customer_id),
    FOREIGN KEY (product_id)
        REFERENCES menu (product_id)
);

-- Data inserted in Tables

INSERT INTO members (customer_id, join_date) 
    VALUES ('A', '2021-01-07'), ('B', '2021-01-09'), ('C', '2021-01-11');
INSERT INTO menu (product_id, product_name, price) 
    VALUES ('1', 'sushi', '10'), ('2', 'curry', '15'), ('3', 'ramen', '12');
INSERT INTO sales (customer_id, order_date, product_id) 
    VALUES ('A', '2021-01-01', '1'), ('A', '2021-01-01', '2'), ('A', '2021-01-07', '2'), ('A', '2021-01-10', '3'), ('A', '2021-01-11', '3'), 
    ('A', '2021-01-11', '3'), ('B', '2021-01-01', '2'), ('B', '2021-01-02', '2'), ('B', '2021-01-04', '1'), ('B', '2021-01-11', '1'), 
    ('B', '2021-01-16', '3'), ('B', '2021-02-01', '3'), ('C', '2021-01-01', '3'), ('C', '2021-01-01', '3'),  ('C', '2021-01-07', '3');

-- Select Statement to confirm data insertion and table format

SELECT * FROM members;
SELECT * FROM menu;
SELECT * FROM sales;
