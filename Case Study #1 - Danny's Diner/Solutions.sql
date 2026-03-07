-- Case Study #1 - Danny's Diner - SQL

-- 1. What is the total amount each customer spent at the restaurant?

SELECT
	s.customer_id,
    SUM (menu.price) as total_sum
 FROM sales AS s
 LEFT JOIN menu
 ON s.product_id = menu.product_id
 GROUP BY s.customer_id
 ORDER BY s.customer_id;

-- 2. How many days has each customer visited the restaurant?

SELECT
	s.customer_id,
	COUNT (DISTINCT s.order_DATE)
FROM sales as s
GROUP BY s.customer_id
ORDER BY s.customer_id;

-- 3. What was the first item from the menu purchased by each customer?

WITH rank_table AS (
  SELECT
      s.customer_id,
      menu.product_name,
      DENSE_RANK () 
      OVER (PARTITION BY s.customer_id ORDER BY s.order_date) AS ranking
  FROM sales AS s
  LEFT JOIN menu
  ON s.product_id = menu.product_id)
  
  SELECT
	customer_id,
    product_name
  FROM rank_table
  WHERE ranking = 1
  GROUP BY customer_id, product_name;

-- 4. What is the most purchased item on the menu and how many times was it purchased by all customers?

 SELECT
 	menu.product_name,
    COUNT (s.product_id) AS times_ordered
 FROM sales AS s
 LEFT JOIN menu
 ON s.product_id = men.product_id
 GROUP BY men.product_name
 ORDER BY times_ordered DESC
 LIMIT 1;

-- 5. Which item was the most popular for each customer?

WITH ranking_table AS(
SELECT
	s.customer_id,
	menu.product_name,
	COUNT (menu.product_name) AS times_ordered,
	DENSE_RANK () OVER (PARTITION BY customer_id ORDER BY COUNT (menu.product_name) DESC) AS ranking
FROM sales AS s
LEFT JOIN menu
ON s.product_id = menu.product_id
GROUP BY customer_id, product_name)

SELECT 
	customer_id,
    product_name,
    ranking
FROM ranking_table
WHERE ranking = 1;

-- 6. Which item was purchased first by the customer after they became a member?

WITH visits_memrbers AS( 
SELECT
	s.*,
    mem.join_date,
    RANK() OVER (PARTITION BY s.customer_id ORDER BY s.order_date) AS visits_after
FROM sales as s
RIGHT JOIN members as mem
ON s.customer_id = mem.customer_id
AND s.order_date >= mem.join_date)

SELECT
	v.customer_id,
    menu.product_name,
    v.order_date
FROM visits_memrbers AS v
LEFT JOIN menu
ON v.product_id = menu.product_id
WHERE v.visits_after = 1
ORDER BY customer_id;       

-- 7. Which item was purchased just before the customer became a member?

WITH visits_prememrbers AS( 
SELECT
	s.*,
    mem.join_date,
    RANK() OVER (PARTITION BY s.customer_id ORDER BY s.order_date DESC) AS visits_before
FROM sales as s
RIGHT JOIN members as mem
ON s.customer_id = mem.customer_id
AND s.order_date < mem.join_date)

SELECT
	v.customer_id,
    menu.product_name,
    v.order_date
FROM visits_prememrbers AS v
LEFT JOIN menu
ON v.product_id = menu.product_id
WHERE v.visits_before = 1
ORDER BY customer_id;   

-- 8. What is the total items and amount spent for each member before they became a member?

SELECT
	s.customer_id,
	COUNT (s.product_id) AS items_purchased,
    SUM (menu.price) AS total_amount
FROM sales as s
RIGHT JOIN members as mem
ON s.customer_id = mem.customer_id
AND s.order_date < mem.join_date
LEFT JOIN menu
ON s.product_id = menu.product_id
GROUP BY s.customer_id
ORDER BY s.customer_id;

-- 9. If each $1 spent equates to 10 points and sushi has a 2x points multiplier - how many points would each customer have?

WITH points_table AS(
SELECT
	s.customer_id,
    menu.product_name,
    menu.price,
    CASE
    	WHEN product_name = 'sushi' THEN (price * 20)
        ELSE (price*10)
    END AS points
FROM sales as s
LEFT JOIN menu
ON s.product_id = menu.product_id)

SELECT
	customer_id,
    SUM (points)
FROM points_table
GROUP BY customer_id
ORDER BY customer_id;

-- 10. In the first week after a customer joins the program (including their join date) they earn 2x points on all items, not just sushi - how many points do customer A and B have at the end of January?

WITH points_members AS(
SELECT
	s.customer_id,
  	s.order_date,
    mem.join_date,
    mem.join_date + 6 AS end_deal,
    menu.product_name,
    menu.price,
    CASE
    	WHEN product_name = 'sushi' THEN price * 20
        WHEN product_name <> 'sushi' AND order_date BETWEEN join_date AND  mem.join_date + 6 THEN price * 20
        ELSE price * 10
    END AS points
FROM sales as s
LEFT JOIN menu
	ON s.product_id = menu.product_id
RIGHT JOIN members as mem
	ON mem.customer_id = s.customer_id)
    
SELECT 
	customer_id,    
    SUM (points)
FROM points_members
WHERE order_date < '2021-02-01'
GROUP BY customer_id
ORDER BY customer_id;




