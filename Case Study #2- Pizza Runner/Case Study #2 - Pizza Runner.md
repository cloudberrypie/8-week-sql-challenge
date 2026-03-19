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
**What was the average distance travelled for each customer?**
```sql
```
**What is the successful delivery percentage for each runner?**
```sql
```

```sql
```


