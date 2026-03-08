# Case Study #1 - Danny's Diner

## Intro

Danny has opened a diner. He has gathered data on customers, orders and memberships over several weeks. He wants to get insights about his business.  
The queries can be tested on [DB-Fiddle](https://www.db-fiddle.com/f/2rM8RAnq7h5LLDTzZiRWcd/138)


## Entity Relationship Diagramm

<img width="858" height="426" alt="Screenshot 2026-03-07 at 22-28-50 Case Study #1 - Danny&#39;s Diner – 8 Week SQL Challenge – Start your SQL learning journey today!" src="https://github.com/user-attachments/assets/e8f6ba91-516a-477c-8f79-142714d3bdbf" />


## Questions

1. What is the total amount each customer spent at the restaurant?  
2. How many days has each customer visited the restaurant?
3. What was the first item from the menu purchased by each customer?
4. What is the most purchased item on the menu and how many times was it purchased by all customers?
5. Which item was the most popular for each customer?
6. Which item was purchased first by the customer after they became a member?
7. Which item was purchased just before the customer became a member?
8. What is the total items and amount spent for each member before they became a member?
9. If each $1 spent equates to 10 points and sushi has a 2x points multiplier - how many points would each customer have?
10. In the first week after a customer joins the program (including their join date) they earn 2x points on all items, not just sushi - how many points do customer A and B have at the end of January?


## Solutions

### 1. What is the total amount each customer spent at the restaurant?

```sql
SELECT
	s.customer_id,
  SUM (menu.price) as total_sum
 FROM sales AS s
 LEFT JOIN menu
   ON s.product_id = menu.product_id
 GROUP BY s.customer_id
 ORDER BY s.customer_id;
```

| customer_id | total_sum |
| ----------- | --------- |
| A           | 76        |
| B           | 74        |
| C           | 36        |

### 2. How many days has each customer visited the restaurant?

```sql
SELECT
	s.customer_id,
  SUM (menu.price) as total_sum
 FROM sales AS s
 LEFT JOIN menu
   ON s.product_id = menu.product_id
 GROUP BY s.customer_id
 ORDER BY s.customer_id;
```

| customer_id | count |
| ----------- | ----- |
| A           | 4     |
| B           | 6     |
| C           | 2     |

### 3. What was the first item from the menu purchased by each customer?

```sql
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
```

| customer_id | product_name |
| ----------- | ------------ |
| A           | curry        |
| A           | sushi        |
| B           | curry        |
| C           | ramen        |


### 4. What is the most purchased item on the menu and how many times was it purchased by all customers?

```sql
SELECT
 	menu.product_name,
    COUNT (s.product_id) AS times_ordered
 FROM sales AS s
 LEFT JOIN menu
 ON s.product_id = menu.product_id
 GROUP BY menu.product_name
 ORDER BY times_ordered DESC
 LIMIT 1;
```

| product_name | times_ordered |
| ------------ | ------------- |
| ramen        | 8             |


### 5. Which item was the most popular for each customer?

```sql
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
```
| customer_id | product_name | ranking |
| ----------- | ------------ | ------- |
| A           | ramen        | 1       |
| B           | ramen        | 1       |
| B           | curry        | 1       |
| B           | sushi        | 1       |
| C           | ramen        | 1       |


### 6. Which item was purchased first by the customer after they became a member?
	
```sql
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
```

| customer_id | product_name | order_date |
| ----------- | ------------ | ---------- |
| A           | curry        | 2021-01-07 |
| B           | sushi        | 2021-01-11 |


### 7. Which item was purchased just before the customer became a member?

```sql
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
```

| customer_id | product_name | order_date |
| ----------- | ------------ | ---------- |
| A           | sushi        | 2021-01-01 |
| A           | curry        | 2021-01-01 |
| B           | sushi        | 2021-01-04 |


### 8. What is the total items and amount spent for each member before they became a member?

```sql
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
```

| customer_id | items_purchased | total_amount |
| ----------- | --------------- | ------------ |
| A           | 2               | 25           |
| B           | 3               | 40           |


### 9. If each $1 spent equates to 10 points and sushi has a 2x points multiplier - how many points would each customer have?

```sql
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
```

| customer_id | sum |
| ----------- | --- |
| A           | 860 |
| B           | 940 |
| C           | 360 |


### 10. In the first week after a customer joins the program (including their join date) they earn 2x points on all items, not just sushi - how many points do customer A and B have at the end of January?

```sql
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
```

| customer_id | sum  |
| ----------- | ---- |
| A           | 1370 |
| B           | 820  |

---
