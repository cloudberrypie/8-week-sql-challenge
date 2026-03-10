# Case Study #2 - Pizza Runner

## Intro

## Entity Realtionship Diagramm

<img width="948" height="460" alt="Screenshot 2026-03-08 at 17-49-59 Case Study #2 - Pizza Runner – 8 Week SQL Challenge – Start your SQL learning journey today!" src="https://github.com/user-attachments/assets/6a6ae71f-08b7-4cb6-bdd7-a54ac758043f" />

## Cleaning data

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
where (coc.exclusions_clean is not null 
	or coc.extras_clean is not null)
	and roc.cancellation_clean is null)
select
customer_id,
count(pizza_id)
from orders_cte
group by customer_id;
```
**What was the total volume of pizzas ordered for each hour of the day?**

