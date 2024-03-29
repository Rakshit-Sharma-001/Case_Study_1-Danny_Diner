-- Q1: What is the total amount each customer spent at the restaurant?

SELECT customer_id, SUM(price) AS 'Total_Amount_Spent'
FROM sales JOIN menu ON sales.product_id = menu.product_id
GROUP BY customer_id;

-- Q2: How many days has each customer visited the restaurant?

SELECT customer_id, COUNT(order_date) AS 'Total_Days_Visited'
FROM sales GROUP BY customer_id;

-- Q3: What was the first item from the menu purchased by each customer? 

SELECT customer_id, product_name
FROM sales JOIN menu ON sales.product_id = menu.product_id
WHERE order_date IN 
(SELECT MIN(order_date) FROM sales GROUP BY customer_id);

-- Q4: What is the most purchased item on the menu and how many times was it purchased by all customers? 

SELECT product_name, COUNT(*) AS 'Total_purchases'
FROM sales JOIN menu ON sales.product_id = menu.product_id
GROUP BY sales.product_id ORDER BY Total_Purchases DESC LIMIT 1;

-- Q5: Which item was the most popular for each customer? 

SELECT customer_id, product_name, item_bought_count FROM
(SELECT customer_id, product_name, count(sales.product_id) AS 'item_bought_count', 
dense_rank() over(partition by customer_id order by count(sales.product_id) desc) 
as cte from sales join menu on sales.product_id = menu.product_id 
group by customer_id, sales.product_id ) as subquery where cte =1;

-- Q6: Which item was purchased first by the customer after they became a member?

select customer_id, product_name from (select row_number() 
over(partition by sales.customer_id order by order_date) as cte, 
sales.customer_id, order_date, join_date, product_name from sales join menu 
on sales.product_id = menu.product_id join members on members.customer_id = sales.customer_id 
where order_date >= join_date)as subquery where cte =1 ;

-- Q7: Which item was purchased just before the customer became a member? 

select customer_id, product_name from( select row_number() 
over(partition by sales.customer_id order by order_date) as cte, 
sales.customer_id, order_date, join_date, product_name from sales 
join menu on sales.product_id = menu.product_id join members on members.customer_id = sales.customer_id
where order_date <= join_date) as subquery where cte = 1 ;

-- Q8: What is the total items and amount spent for each member before they became a member? 

SELECT members.customer_id, COUNT(DISTINCT menu.product_id) AS 'Items_ordered',
SUM(price) AS 'Money_spent' FROM members JOIN sales 
ON members.customer_id = sales.customer_id JOIN menu 
ON menu.product_id = sales.product_id WHERE order_date < join_date GROUP BY customer_id;

-- Q9: If each $1 spent equates to 10 points and sushi has a 2x points multiplier - how many points would each customer have?  

SELECT customer_id,SUM(CASE WHEN product_name = 'sushi' THEN 20 * price ELSE 10 * price
END) AS money_spent FROM sales JOIN menu ON sales.product_id = menu.product_id
GROUP BY customer_id ORDER BY customer_id;

-- Q10: In the first week after a customer joins the program (including their join date) they earn 2x points on all items, not just sushi - 
--	how many points do customer A and B have at the end of January? 

WITH dates AS( SELECT *, adddate(join_date, interval 7 day) as valid_date, '2021-01-31' 
	AS last_date FROM members) Select S.Customer_id, SUM( Case When m.product_ID = 1 THEN m.price*20 
When S.order_date between D.join_date and D.valid_date Then m.price*20 Else m.price*10 END ) 
	AS Points From Dates D join Sales S On D.customer_id = S.customer_id Join Menu M 
On M.product_id = S.product_id Where S.order_date < d.last_date Group by S.customer_id;

-- Bonus_Table_1

SELECT s.customer_id, Order_date, product_name, price, CASE
       WHEN order_Date < join_date THEN 'N' ELSE 'Y'
	END AS member FROM sales s JOIN menu m ON s.product_id = m.product_id
       JOIN members ms ON ms.customer_id = s.customer_id ORDER BY s.customer_id , order_date;
       
-- Bonus_Table_2

 with cte as (select s.customer_id, order_date, product_name, price, case 
 when order_Date < join_date then 'N' else 'Y' end  as member from sales s join menu m 
 on s.product_id = m.product_id join members ms on ms.customer_id= s.customer_id 
 order by s.customer_id, order_date) select *, case when member = 'N' then null else 
 rank() over(partition by s.customer_id, member order by order_date) end as ranking from cte;
