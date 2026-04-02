-----Retrieve the total number of orders placed.

select count(order_id) as total_orders from orders;
--------------------------------------------------------------------------------------------------------------------------

----Calculate the total revenue generated from pizza sales.

select sum(od.quntity*p.price) as total_revenue from order_details od
join pizzas p on p.pizza_id = od.pizza_id; 
-----------------------------------------------------------------------------------------------------------------------------


-----Identify the highest-priced pizza.

select p.pizza_id, pt.name,p.price from pizza_types pt
join pizzas p on p.pizza_type_id = pt.pizza_type_id
order by p.price desc
limit 1;
------------------------------------------------------------------------------------------------------------------------------

----Identify the most common pizza size ordered.

select p.size,count(od.order_details_id) as order_count  from pizzas p
join order_details od on od.pizza_id = p.pizza_id
group by p.size
order by order_count desc
limit 1;
----------------------------------------------------------------------------------------------------------------------------------

----List the top 5 most ordered pizza types along with their quantities.

select pt.name, sum(od.quntity) as pizz_quntity from pizza_types pt
join pizzas p on p.pizza_type_id = pt.pizza_type_id
join order_details od on od.pizza_id = p.pizza_id
group by pt.name
order by pizz_quntity desc
limit 5;
-------------------------------------------------------------------------------------------------------------------------------------

---Join the necessary tables to find the total quantity of each pizza category ordered.

select pt.category, sum(od.quntity) as pizz_quntity_per_category from pizza_types pt
join pizzas p on p.pizza_type_id = pt.pizza_type_id
join order_details od on od.pizza_id = p.pizza_id
group by pt.category
order by pizz_quntity_per_category desc;
----------------------------------------------------------------------------------------------------------------------------------------

---Determine the distribution of orders by hour of the day.

select extract(hour from time) as hours, count(order_id) as count_orders_per_hour from orders
group by extract(hour from time) 
order by count_orders_per_hour desc;
------------------------------------------------------------------------------------------------------------------------------------------

-----Join relevant tables to find the category-wise distribution of pizzas.
select category,Count(name) from pizza_types
group by category;
--------------------------------------------------------------------------------------------------------------------------------------------

-----Group the orders by date and calculate the average number of pizzas ordered per day.

select round(avg(total_orders),0) as avg_orders_per_day from(select o.order_date, sum(od.quntity) as total_orders 
from orders o
join order_details od on od.order_id = o.order_id
group by o.order_date) as order_quntity;
----------------------------------------------------------------------------------------------------------------------------

-----Determine the top 3 most ordered pizza types based on revenue.

select pt.name, sum(od.quntity * p.price) as revenue
from pizza_types pt
join pizzas p on p.pizza_type_id = pt.pizza_type_id
join order_details od on od.pizza_id = p.pizza_id
group by pt.name
order by revenue desc
limit 3;
-------------------------------------------------------------------------------------------------------------------------------

-----Calculate the percentage contribution of each pizza type to total revenue.
select pt.category, round(sum(od.quntity * p.price)/(select sum(od.quntity*p.price) as total_revenue from order_details od
join pizzas p on p.pizza_id = od.pizza_id)*100,2) as revenue
from pizza_types pt
join pizzas p on p.pizza_type_id = pt.pizza_type_id
join order_details od on od.pizza_id = p.pizza_id
group by pt.category
order by revenue desc;
-----------------------------------------------------------------------------------------------------------------------------------

----Analyze the cumulative revenue generated over time.

select order_date,
sum(revenue) over (order by order_date)as cum_revenue from(
select o.order_date,sum(od.quntity * p.price) as revenue
from order_details od
join pizzas p on p.pizza_id = od.pizza_id
join orders o on o.order_id = od.order_id
group by o.order_date) as sales;
---------------------------------------------------------------------------------------------------------------------------------------

----Determine the top 3 most ordered pizza types based on revenue for each pizza category.

select category, name, revenue from(
select category, name, revenue,
rank() over (partition by category order by revenue desc) as rn
from(select pt.category, pt.name,
sum(od.quntity * p.price) as revenue from pizza_types pt
join pizzas p on p.pizza_type_id = pt.pizza_type_id
join order_details od on od.pizza_id = p.pizza_id
group by  pt.category, pt.name) a) b
where rn<=3;
-----------------------------------------------------------------------------------------------------------------------------------------