# Case Study #2 - Pizza Runner

## Intro

## Entity Realtionship Diagramm

<img width="948" height="460" alt="Screenshot 2026-03-08 at 17-49-59 Case Study #2 - Pizza Runner – 8 Week SQL Challenge – Start your SQL learning journey today!" src="https://github.com/user-attachments/assets/6a6ae71f-08b7-4cb6-bdd7-a54ac758043f" />

## Cleaning data

**Replace empty values**

```sql
-- Cleaning NULL values
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
```sql
drop table if exists runner_orders_clean;

create temp table runner_orders_clean as
select
	order_id,
	runner_id,
	case
		when pickup_time = 'null' then null
		else pickup_time
	end as pickup_time_clean,
	case
		when distance = 'null' then null
		else regexp_replace(distance, '[a-zA-z]+$', '') 
	end as distance_clean,
	case
		when duration = 'null' then null
		else regexp_replace(duration, '[a-zA-z]+$', '') 
	end as duration_clean,
	case
		when cancellation in ('null', 'NaN', '') then null
		else cancellation
	end as cancellation_clean
from runner_orders;
```



