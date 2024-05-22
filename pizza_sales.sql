create database pizza_sales;
use pizza_sales;

-- Retrieve the total number of orders placed.
select count(distinct order_id) as Total_orders from pizza_sales.orders;

-- Calculate the total revenue generated from pizza sales.
select sum(price) as total_revenue from pizza_sales.pizza;

-- Identify the highest-priced pizza.
select p2.name,p1.size,p1.price from pizza_sales.pizza p1
join pizza_sales.pizza_type p2 on p1.pizza_type_id = p2.pizza_type_id
order by p1.price desc;

-- Identify the most common pizza size ordered.
select p.size,count(p.size) as TotalCount from pizza_sales.order_details o
join pizza_sales.pizza p on 
o.pizza_id = p.pizza_id
group by p.size
order by TotalCount desc;

-- List the top 5 most ordered pizza types along with their quantities.
select pt.name,pt.ingredients, count(od.order_id) as Total from pizza_sales.pizza_type pt
join pizza_sales.pizza p on 
pt.pizza_type_id = p.pizza_type_id
join pizza_sales.order_details od on
p.pizza_id = od.pizza_id
group by pt.name,pt.ingredients
order by Total desc;

-- find the total quantity of each pizza category ordered
select pt.category,count(od.order_id) as TotalCount
from pizza_sales.pizza_type pt
join pizza_sales.pizza p on 
pt.pizza_type_id = p.pizza_type_id
join pizza_sales.order_details od on
p.pizza_id = od.pizza_id
group by pt.category
order by TotalCount desc;

-- Determine the distribution of orders by hour of the day.
select distinct hour(o.time) as hours,
count(o.order_id) as total from orders o 
group by hours
order by total desc;

-- find the category-wise distribution of pizzas.
select pt.category,pt.name,count(od.order_id) as TotalCount
from pizza_sales.pizza_type pt
join pizza_sales.pizza p on 
pt.pizza_type_id = p.pizza_type_id
join pizza_sales.order_details od on
p.pizza_id = od.pizza_id
group by pt.category,pt.name
order by TotalCount desc;

-- 	Group the orders by date and calculate the average number of pizzas ordered per day.
select round(avg(Qty),0) from
(select o.date as Date, sum(od.quantity) as Qty
from pizza_sales.orders o join pizza_sales.order_details od
on o.order_id = od.order_id
group by Date
order by Qty desc) as Quantity;

-- top 3 most ordered pizza types based on revenue
select pt.name as Name,
round(sum(od.quantity*p.price),2) as Revenue from pizza_sales.order_details od
join pizza_sales.pizza p on od.pizza_id = p.pizza_id
join pizza_sales.pizza_type pt on p.pizza_type_id = pt.pizza_type_id
group by Name
order by Revenue desc limit 3;

-- percentage contribution of each pizza type to total revenue
select pt.category as category,
round(sum(od.quantity * p.price) * 100.0 / sum(sum(od.quantity * p.price)) over (),2) as total_percentage
from pizza_sales.order_details od
join pizza_sales.pizza p on od.pizza_id = p.pizza_id
join pizza_sales.pizza_type pt on p.pizza_type_id = pt.pizza_type_id
group by pt.category
order by total_percentage desc;

-- cumulative revenue generated over time.

-- Determine the top 3 most ordered pizza types based on revenue for each pizza category.
with cte as(
select pt.name,pt.category,
round(sum(p.price*od.quantity),2) as Revenue,
rank() over (partition by category order by sum(p.price*od.quantity) desc) as rnk
from pizza_sales.pizza_type pt
join pizza_sales.pizza p on 
pt.pizza_type_id = p.pizza_type_id
join pizza_sales.order_details od on
p.pizza_id = od.pizza_id
group by pt.category,pt.name
order by Revenue desc
)

select * from cte where rnk<=3 order by rnk asc;