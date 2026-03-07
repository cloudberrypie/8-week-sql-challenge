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


