-- Schema created in MySQL Workbench
create schema dannys_diner;
use dannys_diner;

-- All 3 Tables created 
CREATE TABLE members (
    customer_id CHAR(2) NOT NULL PRIMARY KEY,
    join_date DATE );
    
CREATE TABLE menu (
    product_id INT NOT NULL PRIMARY KEY,
    product_name VARCHAR(20) NOT NULL,
    price INT NOT NULL );
    
CREATE TABLE sales (
    customer_id CHAR(2) NOT NULL,
    order_date DATE,
    product_id INT NOT NULL,
    FOREIGN KEY (customer_id)
        REFERENCES members (customer_id),
    FOREIGN KEY (product_id)
        REFERENCES menu (product_id) );

-- Data inserted into all tables
INSERT INTO members (customer_id, join_date) VALUES ('A', '2021-01-07'), ('B', '2021-01-09'), ('C', '2021-01-11');

INSERT INTO menu (product_id, product_name, price) VALUES ('1', 'sushi', '10'), ('2', 'curry', '15'), ('3', 'ramen', '12');

INSERT INTO sales (customer_id, order_date, product_id) VALUES ('A', '2021-01-01', '1'), ('A', '2021-01-01', '2'), 
('A', '2021-01-07', '2'), ('A', '2021-01-10', '3'), ('A', '2021-01-11', '3'), ('A', '2021-01-11', '3'), ('B', '2021-01-01', '2'), 
('B', '2021-01-02', '2'), ('B', '2021-01-04', '1'), ('B', '2021-01-11', '1'), ('B', '2021-01-16', '3'), ('B', '2021-02-01', '3'),
('C', '2021-01-01', '3'), ('C', '2021-01-01', '3'),  ('C', '2021-01-07', '3');

-- Select statements to check whether data is correctly inserted or not !! It is always necessary to check before start 
    writing the queries.
    
SELECT * FROM members;
SELECT * FROM menu;
SELECT * FROM sales;


-- Q1: 
SELECT customer_id, SUM(price) AS 'Total_Amount_Spent' FROM sales
JOIN menu ON sales.product_id = menu.product_id GROUP BY customer_id;
-- Q2 c
SELECT customer_id, COUNT(order_date) AS 'Total_Days_Visited' FROM sales GROUP BY customer_id;
-- q3 c
SELECT customer_id, product_name FROM sales JOIN menu ON sales.product_id = menu.product_id
WHERE order_date IN (SELECT MIN(order_date) FROM sales GROUP BY customer_id);
-- q4 c
SELECT product_name, COUNT(*) AS 'Total_purchases' FROM sales JOIN menu ON sales.product_id = menu.product_id
GROUP BY sales.product_id ORDER BY Total_Purchases DESC LIMIT 1;
-- q5 c
select customer_id, product_name, item_bought_count from( select customer_id, product_name, count(sales.product_id) as 'item_bought_count', 
dense_rank() over(partition by customer_id order by count(sales.product_id) desc) as cte from sales join menu 
on sales.product_id = menu.product_id group by customer_id, sales.product_id ) as subquery where cte =1;
-- q6 c
select customer_id, product_name from ( select row_number() over(partition by sales.customer_id order by order_date) as cte, sales.customer_id, 
order_date, join_date, product_name from sales join menu on sales.product_id = menu.product_id join members 
on members.customer_id = sales.customer_id where order_date >= join_date)as subquery where cte =1 ;
-- q7 c
select customer_id, product_name from( select row_number() over(partition by sales.customer_id order by order_date) as cte, 
sales.customer_id, order_date, join_date, product_name from sales join menu on sales.product_id = menu.product_id join members 
on members.customer_id = sales.customer_id where order_date <= join_date) as subquery where cte = 1 ;
-- q8 c
SELECT members.customer_id, COUNT(DISTINCT menu.product_id) AS 'Items_ordered', SUM(price) AS 'Money_spent' FROM members
JOIN sales ON members.customer_id = sales.customer_id JOIN menu ON menu.product_id = sales.product_id
WHERE order_date < join_date GROUP BY customer_id;
-- q9 c
SELECT customer_id, SUM(CASE WHEN product_name = 'sushi' THEN 20 * price ELSE 10 * price END) AS money_spent
FROM sales JOIN menu ON sales.product_id = menu.product_id GROUP BY customer_id ORDER BY customer_id;
-- q10 c
WITH dates AS( SELECT *, adddate(join_date, interval 7 day) as valid_date, '2021-01-31' AS last_date FROM members)
Select S.Customer_id, SUM( Case When m.product_ID = 1 THEN m.price*20 When S.order_date between D.join_date and D.valid_date Then m.price*20
Else m.price*10 END ) as Points From Dates D join Sales S On D.customer_id = S.customer_id
Join Menu M On M.product_id = S.product_id Where S.order_date < d.last_date Group by S.customer_id;
-- Bonus_Table_1
SELECT s.customer_id, order_date, product_name, price, 
CASE WHEN order_Date < join_date THEN 'N' ELSE 'Y' END AS member FROM sales s
JOIN menu m ON s.product_id = m.product_id JOIN members ms ON ms.customer_id = s.customer_id ORDER BY s.customer_id , order_date;
-- Bonus_Table_2
 with cte as (select s.customer_id, order_date, product_name, price, case when order_Date < join_date then 'N' else 'Y' end  as member
 from sales s join menu m on s.product_id = m.product_id join members ms on ms.customer_id= s.customer_id order by s.customer_id, order_date)
 select *, case when member = 'N' then null else rank() over(partition by s.customer_id, member order by order_date) end as ranking from cte;
