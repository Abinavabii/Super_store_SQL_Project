create database e_commerce;
use e_commerce;

create table customers (
Customer_id varchar(100) primary key,
Customer_name varchar(100),
Gender varchar(100),
City varchar(50),
State varchar(50));

select * from customers;
describe customers;

create table products (
product_id varchar(50) primary key ,
product_name varchar(100),
category varchar(100),
sub_category varchar(100),
price decimal(10,2));

select * from products;
describe products;

create table orders (
order_id varchar(100) primary key,
customer_id varchar(100),
order_date varchar(100),
ship_date varchar(100),
payment_method varchar(50),
foreign key (customer_id) references customers(Customer_id));

select * from orders;
desc orders;

create table order_items (
order_item_id int primary key,
order_id varchar(100),
product_id varchar (100),
quantity int,
sales_amount decimal(10,2),
profit decimal(10,2),
foreign key (order_id) references orders(order_id),
foreign key (product_id) references products(product_id));

select * from order_items;
desc order_items;

select * from customers
where Customer_id is null
or Customer_name is null
or Gender is null
or City is null
or state is null;
-- PART 1 

-- 1. TOTAL SALES

select sum(sales_amount) as total_sales
from order_items;

-- 2. TOTAL NUMBER OF CUSTOMERS

select count(*) as total_customers
from customers;

-- 3. TOTAL ORDERS 

select count(*) as total_orders
from orders;

-- 4. AVERAGE SALES AMOUNT

select avg(sales_amount) as avg_sales
from order_items;

-- HIGHEST AND LOWEST SALES

select max(sales_amount) as highest_sale,
min(sales_amount) as lowest_sales
from order_items;

-- PART 2 

-- 1. CATEGORY WISE SALES

select p.category, sum(oi.sales_amount) as total_sales
from products p
join order_items oi
on p.product_id = oi.product_id
group by p.category;

-- 2. SATE WISE PROFIT

select c.State,sum(oi.profit) as total_profit
from customers c
join orders o
on c.Customer_id = o.customer_id
join order_items oi
on o.order_id = oi.order_id 
group by c.state; 

-- 3. STATE WISE ORDER COUNT

select c.state, count(o.order_id) as total_count
from customers c
join orders o
on c.Customer_id = o.customer_id
group by c.state;

-- 4. TOP 5 CUSTOMERS BY SALES

select c.Customer_name, sum(oi.sales_amount) as total_sales
from customers c 
join orders o
on c.Customer_id = o.customer_id
join order_items oi
on oi.order_id = o.order_id
group by c.Customer_name
order by total_sales desc
limit 5;

-- 5. LEAST PROFITABLE CATEGORIES

select p.category, sum(oi.profit) as total_profit
from products p
join order_items oi
on p.product_id = oi.product_id
group by  category
order by total_profit ;

-- PART 3

-- 1. CUSTOMERS ORDERS WITH PRODUCT DETAILS

select c.Customer_name, o.order_id, p.product_name
from customers c 
join orders o
on c.Customer_id = o.customer_id
join order_items oi
on oi.order_id = o.order_id
join products p
on p.product_id = oi.product_id;

-- 2. PRODUCT SOLD IN EACH STATE

select c.state,p.product_name from customers c 
join orders o
on c.Customer_id = o.customer_id
join order_items oi
on oi.order_id = o.order_id
join products p
on p.product_id = oi.product_id;

-- PART 4

-- 1. CLASSIFY CUSTOMERS
  -- HIGH VALUE
  -- MEDIUM VALUE
  -- LOW VALUE

select c.Customer_name,sum(oi.sales_amount) as total_purchase,
case
when sum(oi.sales_amount) > 2500 then 'High Value'
when sum(oi.sales_amount) between 1000 and 2500 then 'Medium Value'
else 'Low Value'
end as customers_category
from customers c 
join orders o
on o.customer_id = c.Customer_id
join order_items oi
on oi.order_id = o.order_id
group by c.Customer_name;

-- 2 PRODUCT CLASSIFICATION
 -- HIGH PROFIT
 -- LOW PROFIT
 -- LOSS

select p.product_name, sum(oi.profit) AS total_profit,
case
when sum(oi.profit) > 100 then 'High Profit'
when sum(oi.profit) >0 then 'low Profit'
else 'Loss'
end as profit_type
from products p 
join order_items oi
on p.product_id = oi.product_id
group by p.product_name;

-- PART 5

-- 1. PRODUCT WITH ABOVE AVERAGE

select p.product_name, sum(oi.sales_amount) as total_sales
from products p 
join order_items oi 
on p.product_id = oi.product_id
group by p.product_name
having sum(oi.sales_amount) > 
                         (select avg(sales_amount)
                         from order_items);


-- 2. SECOND HIGHEST SELLING PRODUCT
                
select product_name,total_sales
from
(
select
p.product_name,
SUM(oi.sales_amount) as total_sales,
dense_rank() over
(order by SUM(oi.sales_amount) desc) rnk
from products p
join order_items oi
on p.product_id = oi.product_id
group by p.product_name
)x 
where rnk=2;
                
-- PART 6

 -- 1. RANK CUSTOMERS BY SALES
 
select c.Customer_name, sum(oi.sales_amount) as total_sales,
rank() over(order by sum(oi.sales_amount) desc ) as customer_rank
from customers c 
join orders o
on o.customer_id = c.Customer_id
join order_items oi
on oi.order_id = o.order_id
group by c.Customer_name;

-- 2. TOP 3 PRODUCTS IN EACH CATEGORY

select * from(
    select p.product_name,p.category,sum(oi.sales_amount) as total_sales,
    dense_rank() over(partition by p.category
    order by sum(oi.sales_amount) desc) as rnk
    from products p 
    join order_items oi
    on p.product_id = oi.product_id
    group by p.category,p.product_name)x
    where rnk <=3;
    
-- RUNNING TOTAL

select sales_amount, sum(sales_amount) over (order by order_id) as runnig_total
from order_items;
    




