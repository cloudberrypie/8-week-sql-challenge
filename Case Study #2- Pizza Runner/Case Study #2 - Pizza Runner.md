# Case Study #2 - Pizza Runner

## Intro

This time Danny is running a pizza service with an Uber-like delivery system.  
He is going to need help with cleaning data, getting metrics, estimating customer experience and optimizing his recipies.  

The queries can be tested on [DB-Fiddle](https://www.db-fiddle.com/f/7VcQKQwsS3CTkGRFG7vu98/65)  
Full information for the Case Study can be found [here](https://8weeksqlchallenge.com/case-study-2/)

## Entity Realtionship Diagramm and Available Data

<img width="948" height="460" alt="Screenshot 2026-03-08 at 17-49-59 Case Study #2 - Pizza Runner – 8 Week SQL Challenge – Start your SQL learning journey today!" src="https://github.com/user-attachments/assets/6a6ae71f-08b7-4cb6-bdd7-a54ac758043f" />


**Table 1: runners**

The runners table shows the registration_date for each new runner

|runner_id|registration_date|
|---------|-----------------|
|1|2021-01-01|
|2|2021-01-03|
|3|2021-01-08|
|4|2021-01-15|

**Table 2: customer_orders**

Customer pizza orders are captured in the customer_orders table with 1 row for each individual pizza that is part of the order.  
The pizza_id relates to the type of pizza which was ordered whilst the exclusions are the ingredient_id values which should be removed from the pizza and the extras are the ingredient_id values which need to be added to the pizza.  

|order_id|customer_id|pizza_id|exclusions|extras|order_time|
|--------|-----------|--------|----------|------|----------|
|1|101|1|||2020-01-01 18:05:02.000|
|2|101|1|||2020-01-01 19:00:52.000|
|3|102|1|||2020-01-02 23:51:23.000|
|3|102|2|||2020-01-02 23:51:23.000|
|...|...|...|...|...|...|

**Table 3: runner_orders**

After each orders are received through the system - they are assigned to a runner - however not all orders are fully completed and can be cancelled by the restaurant or the customer.  
The pickup_time is the timestamp at which the runner arrives at the Pizza Runner headquarters to pick up the freshly cooked pizzas. The distance and duration fields are related to how far and long the runner had to travel to deliver the order to the respective customer.

|order_id|runner_id|pickup_time|distance|duration|cancellation|
|--------|---------|-----------|--------|--------|------------|
|1|1|2020-01-01 18:15:34|20km|32 minutes||
|2|1|2020-01-01 19:10:54|20km|27 minutes||
|3|1|2020-01-03 00:12:37|13.4km|20 mins||
|...|...|...|...|...|...|

**Table 4: pizza_names**

|pizza_id|pizza_name|
|--------|----------|
|1|Meatlovers|
|2|Vegetarian|

**Table 5: pizza_recipes**

Each pizza_id has a standard set of toppings which are used as part of the pizza recipe.

|pizza_id|toppings|
|--------|--------|
|1|1, 2, 3, 4, 5, 6, 8, 10|
|2|4, 6, 7, 9, 11, 12|

**Table 6: pizza_toppings**

This table contains all of the topping_name values with their corresponding topping_id value.

|topping_id|topping_name|
|----------|------------|
|1|Bacon|
|2|BBQ Sauce|
|3|Beef|
|...|...|

## Cleaning data

First step is to clean data. Two tables have inconsistensies and wrong data types: customer_orders and runner_orders.  
In this case I have created temporary tables for the cleaned data and performed the following transformations:
- replaced all cells with 'null', '' or 'NaN' with NULL
- for runner_orders extracted numbers with regex
- for runner_orders cast pickup_time as timestamp

**Customer orders**

```sql
drop table if exists customer_orders_clean;

create temp table customer_orders_clean as
select
	order_id,
	customer_id,
	pizza_id,
	case
		when exclusions in ('','null') then null
		else exclusions
	end as exclusions_clean,
	case
		when extras in ('','null') then null
		else extras
	end as extras_clean,
	order_time 
from customer_orders;
```

**Runner orders**

```sql
drop table if exists runner_orders_clean;

create temp table runner_orders_clean as
select
	order_id,
	runner_id,
	cast(
	case
		when pickup_time = 'null' then null
		else pickup_time
	end as timestamp) as pickup_time_clean,
	cast(
	case
		when distance = 'null' then null
		else regexp_replace(distance, '[a-zA-z]+$', '') 
	end as float)  as distance_clean,
	cast(
	case
		when duration = 'null' then null
		else regexp_replace(duration, '[a-zA-z]+$', '') 
	end as int) as duration_clean,
	case
		when cancellation in ('null', 'NaN', '') then null
		else cancellation
	end as cancellation_clean
from runner_orders;
```

## A. Pizza metrics

**How many successful orders were delivered by each runner?** 
```sql
select
runner_id,
count (order_id)
from runner_orders_clean
where cancellation_clean is null 
group by runner_id;
```
**For each customer, how many delivered pizzas had at least 1 change and how many had no changes?**
```sql
with orders_cte as(
select 
coc.pizza_id,
coc.customer_id,
coc.exclusions_clean,
coc.extras_clean,
roc.cancellation_clean
from customer_orders_clean coc
left join runner_orders_clean roc 
on coc.order_id = roc.order_id
where roc.cancellation_clean is null)
select
customer_id,
sum(case when exclusions_clean is not null
	or extras_clean is not null
	then 1 else 0 end) as ingredients_changed,
sum(case when exclusions_clean is null
	and extras_clean is null
	then 1 else 0 end) as ingredients_unchanged
from orders_cte
group by customer_id;
```
|customer_id|ingredients_changed|ingredients_unchanged|
|-----------|-------------------|---------------------|
|101|0|2|
|102|0|3|
|103|3|0|
|104|2|1|
|105|1|0|

**What was the total volume of pizzas ordered for each hour of the day?**
```sql
select 
date_part('hour', order_time) as hour,
COUNT(pizza_id)
from customer_orders_clean
group by hour
order by hour;
```

## B. Runner and Customer Experience

**What was the average time in minutes it took for each runner to arrive at the Pizza Runner HQ to pickup the order?**
```sql
with time_to_pickup as(
select
distinct(coc.order_id),
coc.order_time,
roc.pickup_time_clean,
extract(epoch from (roc.pickup_time_clean - coc.order_time))/60 as minutes,
roc.runner_id
from customer_orders_clean coc 
left join runner_orders_clean roc 
on coc.order_id = roc.order_id 
where roc.pickup_time_clean is not null)
select
runner_id,
round(avg(minutes)) as avg_time_to_pickup
from time_to_pickup
group by runner_id
order by runner_id;
```
|runner_id|avg_time_to_pickup|
|---------|------------------|
|1|14|
|2|20|
|3|10|

**What was the average distance travelled for each customer?**
```sql
select 
coc.customer_id ,
round(avg(roc.distance_clean)) as distance_travelled
from runner_orders_clean roc 
left join customer_orders_clean coc 
on roc.order_id = coc.order_id
group by coc.customer_id 
order by coc.customer_id;
```
**What is the successful delivery percentage for each runner?**
```sql
select 
runner_id ,
sum(case when cancellation_clean is null then 1 else 0 end) * 100.0 / count(runner_id) as delivered_percent
from runner_orders_clean  
group by runner_id 
order by runner_id;
```

## C. Ingredient Optimisation

**What was the most commonly added extra?**
```sql
select 
pt.topping_name,
count(extras_unnested) as times_added
from customer_orders_clean coc
join lateral unnest(string_to_array(coc.extras_clean, ',')) as extras_unnested
on true
left join pizza_toppings pt 
on pt.topping_id = cast(extras_unnested as int)
group by pt.topping_name
order by times_added desc
limit 1;
```
**Generate an order item for each record in the customers_orders table in the format of one of the following:**

    Meat Lovers
    Meat Lovers - Exclude Beef
    Meat Lovers - Extra Bacon
    Meat Lovers - Exclude Cheese, Bacon - Extra Mushroom, Peppers
```sql
select
coc.order_id ,
coc.pizza_id,
pn.pizza_name,
coc.exclusions_clean,
coc.extras_clean,
concat(pn.pizza_name,
	case when coc.exclusions_clean is not null
		then ' - Exclude '|| (select string_agg(pt.topping_name, ', ' order by pt.topping_id)
	         from unnest(string_to_array(coc.exclusions_clean, ', ')) as ex(id)
	         join pizza_toppings pt on pt.topping_id = CAST(ex.id as INTEGER))
	    else ''
	    end,
	case when coc.extras_clean is not null
		then ' - Extra '|| (select string_agg(pt.topping_name, ', ' order by pt.topping_id)
	         from unnest(string_to_array(coc.extras_clean, ', ')) as extra(id)
	         join pizza_toppings pt on pt.topping_id = CAST(extra.id as INTEGER))
	    else null
	    end)
from customer_orders_clean coc
left join pizza_names pn
on pn.pizza_id = coc.pizza_id;
```
