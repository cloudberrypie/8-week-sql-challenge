# Case Study #3 - Foodie-Fi

## Intro

Danny created Foodie-Fi - a subscription-based streaming service focused entirely on food content - to fill a gap in the market for cooking-focused entertainment. The platform offers monthly and annual subscriptions with unlimited access to exclusive food videos from around the world. 

We are going to look at Foodie-Fi subscription data and try to get some insight about customer behavior!

## Entity Relationship Diagram and Available Data

<img width="698" height="290" alt="image" src="https://github.com/user-attachments/assets/6096f46c-c923-4817-9309-a150939195d0" />

## A. Customer Journey

|customer_id|plan_id|plan_name|start_date|prev_event|
|-----------|-------|---------|----------|----------|
|1|0|trial|2020-08-01||
|1|1|basic monthly|2020-08-08|7|
|2|0|trial|2020-09-20||
|2|3|pro annual|2020-09-27|7|
|11|0|trial|2020-11-19||
|11|4|churn|2020-11-26|7|
|13|0|trial|2020-12-15||
|13|1|basic monthly|2020-12-22|7|
|13|2|pro monthly|2021-03-29|97|
|15|0|trial|2020-03-17||
|15|2|pro monthly|2020-03-24|7|
|15|4|churn|2020-04-29|36|
|16|0|trial|2020-05-31||
|16|1|basic monthly|2020-06-07|7|
|16|3|pro annual|2020-10-21|136|
|18|0|trial|2020-07-06||
|18|2|pro monthly|2020-07-13|7|
|19|0|trial|2020-06-22||
|19|2|pro monthly|2020-06-29|7|
|19|3|pro annual|2020-08-29|61|

## B. Data Analysis Questions

### What is the monthly distribution of trial plan start_date values for our dataset - use the start of the month as the group by value?

```sql
select 
date_part('month', s.start_date) as start_month,
count(s.customer_id) as trial_subscriptions
from foodie_fi.subscriptions s
	left join foodie_fi.plans p
	on s.plan_id = p.plan_id
where p.plan_name = 'trial'
group by start_month
order by start_month;
```

|start_month|trial_subscriptions|
|-----------|-------------------|
|1.0|88|
|2.0|68|
|3.0|94|
|4.0|81|
|5.0|88|
|6.0|79|
|7.0|89|
|8.0|88|
|9.0|87|
|10.0|79|
|11.0|75|
|12.0|84|

<img width="766" height="353" alt="chart" src="https://github.com/user-attachments/assets/51021f96-67f7-4b9d-8e13-b4f44ba306f1" />

### What is the customer count and percentage of customers who have churned rounded to 1 decimal place?

```sql
select 
sum(case when s.plan_id = 4 then 1 else 0 end) as churn_customers,
sum(case when s.plan_id = 4 then 1 else 0 end) * 100.0 / count (distinct customer_id) as churn_percent
from foodie_fi.subscriptions s;
```

|churn_customers|churn_percent|
|---------------|-------------|
|307|30.7|
 
### How many customers have churned straight after their initial free trial - what percentage is this rounded to the nearest whole number?

```sql
select
sum(case when plan_id = 4 and plan_prev = 0 then 1 else 0 end) as churn_after_trial,
sum(case when plan_id = 4 and plan_prev = 0 then 1 else 0 end) * 100.0 / count (distinct customer_id) as churn_percent
from(select 
	customer_id,
	plan_id,
	lag(plan_id) over (partition by customer_id) as plan_prev
	from foodie_fi.subscriptions);
```

|churn_after_trial|churn_percent|
|-----------------|-------------|
|92|9.2|





