use pizza;

# ------------------------------------------------------------------ BASIC ------------------------------------------------------------------

# Q1 => Retrieve the total number of orders placed.
SELECT 
    COUNT(orders.order_id) AS total_orders
FROM
    orders;


# Q2 => Calculate the total revenue generated from pizza sales.
SELECT 
    ROUND(SUM(pizzas.price * order_details.quantity),
            2) AS Revenue
FROM
    order_details
		JOIN
    pizzas ON pizzas.pizza_id = order_details.pizza_id;
    
    
# Q3 => Identify the highest-priced pizza.

SELECT 
    pizzas.price, pizza_types.name
FROM
    pizza_types
        INNER JOIN
    pizzas ON pizzas.pizza_type_id = pizza_types.pizza_type_id
ORDER BY pizzas.price DESC
LIMIT 1;


# Q4 => Identify the most common pizza size ordered

SELECT 
    SUM(order_details.quantity) AS Total_order, pizzas.size
FROM
    order_details
        INNER JOIN
    pizzas ON order_details.pizza_id = pizzas.pizza_id
GROUP BY pizzas.size
ORDER BY Total_order DESC
LIMIT 1;


# Q5 => List the top 5 most ordered pizza types along with their quantities.

SELECT 
    pizza_types.name AS Pizza,
    SUM(order_details.quantity) AS Quantity
FROM
    order_details
        JOIN
    pizzas ON pizzas.pizza_id = order_details.pizza_id
        JOIN
    pizza_types ON pizzas.pizza_type_id = pizza_types.pizza_type_id
GROUP BY pizza_types.name
ORDER BY pizza_types.name DESC
LIMIT 5;


# ------------------------------------------------------------------ Intermediate ------------------------------------------------------------------

#Q6 => Join the necessary tables to find the total quantity of each pizza category ordered.

SELECT 
    category, SUM(quantity) AS quantity
FROM
    order_details
        JOIN
    pizzas ON pizzas.pizza_id = order_details.pizza_id
        JOIN
    pizza_types ON pizza_types.pizza_type_id = pizzas.pizza_type_id
GROUP BY category
ORDER BY quantity DESC;


#Q7 => Determine the distribution of orders by hour of the day.

SELECT 
    COUNT(order_id) AS Total_order_arrive,
    HOUR(orders.time) AS Hour
FROM
    orders
GROUP BY Hour
ORDER BY Total_order_arrive desc;


#Q8 => Join relevant tables to find the category-wise distribution of pizzas.

SELECT 
    category, COUNT(name) AS Total_Pizza
FROM
    pizza_types
GROUP BY category
ORDER BY Total_Pizza DESC;


#Q9 => Group the orders by date and calculate the average number of pizzas ordered per day.

SELECT 
    ROUND(AVG(Total_Order), 1)
FROM
    (SELECT 
        DATE(date) AS DATE, SUM(quantity) AS Total_Order
    FROM
        orders
    JOIN order_details ON order_details.order_id = orders.order_id
    GROUP BY DATE) AS order_quantity_per_day;


#Q10 => Determine the top 3 most ordered pizza types based on revenue.

SELECT 
    ROUND(SUM(order_details.quantity * pizzas.price),
            2) AS Revenue,
    pizza_types.name AS Pizza
FROM
    order_details
        JOIN
    pizzas ON order_details.pizza_id = pizzas.pizza_id
        JOIN
    pizza_types ON pizza_types.pizza_type_id = pizzas.pizza_type_id
GROUP BY name
ORDER BY Revenue DESC
LIMIT 3;


# ------------------------------------------------------------------ Advanced ------------------------------------------------------------------

#Q11 => Calculate the percentage contribution of each pizza type to total revenue.

SELECT 
    pizza_types.category,
    ROUND((SUM(pizzas.price * order_details.quantity) * 100 / (SELECT 
                    SUM(pizzas.price * order_details.quantity)
                FROM
                    order_details
                        JOIN
                    pizzas ON pizzas.pizza_id = order_details.pizza_id)),
            2) AS contribute
FROM
    order_details
        JOIN
    pizzas ON order_details.pizza_id = pizzas.pizza_id
        JOIN
    pizza_types ON pizza_types.pizza_type_id = pizzas.pizza_type_id
GROUP BY category
ORDER BY contribute desc;


#Q12 => Analyze the cumulative revenue generated over time.

select DATE , sum(Price) over(order by DATE) as cumulative_revenue from
( SELECT 
    SUM(order_details.quantity * pizzas.price) AS Price,
    DATE(orders.date) AS DATE
FROM
    pizzas
        JOIN
    order_details ON order_details.pizza_id = pizzas.pizza_id
        JOIN
    orders ON orders.order_id = order_details.order_id
GROUP BY DATE ) as sales;


#Q13 => Determine the top 3 most ordered pizza types based on revenue for each pizza category.

select category ,Name, Revenue from
(select category , Name , Revenue ,
Rank() over(partition by category order by Revenue desc ) as No from
(SELECT 
    pizza_types.category AS category,
    pizza_types.name AS Name,
    SUM(order_details.quantity * pizzas.price) AS Revenue
FROM
    pizzas
        JOIN
    order_details ON order_details.pizza_id = pizzas.pizza_id
        JOIN
    pizza_types ON pizza_types.pizza_type_id = pizzas.pizza_type_id
GROUP BY category , Name
ORDER BY category , Name) as data ) as data2
where No <=3;