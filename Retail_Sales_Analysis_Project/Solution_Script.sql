-- RETAIL SALES ANALYSIS PROJECT --
use retail_sales ;

--------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- A) Basic Data Explorations.

-- Question A.1 - Retrieve all records from the Product table.
select * from product ;

-- Question A.2 - Display product names and unit prices for products costing more than $50.
select 
productName , unitPrice
from product
where unitPrice > 50 ;

-- Question A.3 - List all customers located in Germany.
select * from customer
where country = 'Germany' ;

-----------------------------------------------------------------------------------------------------------------------------------------------
-- B) SQL Functions & Aggregations

-- Question B.1 - Calculate the total number of orders placed.
select 
count(*) as total_orders_placed
from orderdetail ;

-- Question B.2 - Find the average unit price of all products.
select 
avg(unitPrice) as average_unit_price
from orderdetail ;

-- Question B.3 - Determine the total revenue generated.
select 
sum(revenue) as total_revenue
from (
select (unitPrice*quantity*(1-discount)) as revenue
from orderdetail
) orderdetail2 ;

-----------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- C) Join Operations

-- Question C.1 - Product Category Analysis
select 
p.productName , 
c.categoryName , 
p.unitPrice
from product p join category c on p.categoryId = c.categoryId ;


-- Question C.2 - Customer Order Analysis
select 
c.companyName , 
s.orderId , 
s.orderDate
from customer c join salesorder s on c.custId = s.custId  ;

-- Question C.3 - Sales Performance by Employee
select
concat(e.firstname,' ',e.lastname) as employee_name , 
s.orderId, c.contactName
from salesorder s join employee e on s.employeeId = e.employeeId
join customer c on s.custId = c.custId ;

--------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- D) Subqueries

-- Question D.1 - Find products whose unit price is higher than the average price of all products.
select * from product
where unitPrice > (select avg(unitPrice) from product)  ;

-- Question D.2 - Retrieve customers who have placed more than 5 orders.
select 
c.custId , 
c.contactName, 
count(distinct(orderId)) as No_Of_Orders
from customer c join salesorder s on c.custId = s.custId 
group by c.custId
having count(distinct(orderId)) > 5 ;

-- Question D.3 - Identify products that have never been ordered.
select 
p.productId as Product_Id ,
p.productName as Product_Name
from product p left join orderdetail o on p.productId = o.productId 
where o.productId is null ;
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- E) Window Functions

-- Question E.1 - Rank Products by Price
select 
categoryName,
unitPrice,
dense_rank() over (partition by c.categoryName order by unitPrice) as rank_
from product p join category c on p.categoryId = c.categoryId ;

-- Question E.2 - Running Total of Sales
select 
s.orderDate as Order_Date , 
sum(o.unitPrice * o.quantity * (1-o.discount)) as Order_Revenue ,
sum(sum(o.unitPrice * o.quantity * (1-o.discount))) over (order by s.orderDate) as Running_Total_Revenue
from salesorder s join orderdetail o on s.orderId = o.orderId 
group by Order_Date ;

/* ALTERNATE SOLUTION !
 select Order_date, 
 Order_revenue, 
 sum(Order_Revenue) over (order by Order_Date) as Running_Total_Revenue 
 from (
   select Order_Date, 
   sum(Revenue) as Order_Revenue 
	from (
       select s.orderDate as Order_Date , 
       (o.unitPrice * o.quantity * (1-o.discount)) as Revenue 
       from salesorder s right join orderdetail o on s.orderId = o.orderId
         ) a 
       group by Order_Date
       ) b
*/    

-- Question E.3 - Top Customers by Revenue  
select
Customer_Name,
Total_Revenue,
row_number () over (order by Total_Revenue desc) as Customer_Rank
from (
select 
c.contactName as Customer_Name ,
sum(o.unitPrice * o.quantity * (1-o.discount)) as Total_Revenue
from salesorder s join orderdetail o on s.orderId = o.orderId
join customer c on s.custId = c.custId
group by c.contactName
) t ;

---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- F) Advanced Analytical Queries

-- Question F.1 - Which product category generates the highest revenue?
select 
c.categoryId as categoryId, 
c.categoryName as category_name ,
sum(revenue) as total_revenue
from (
select 
p.categoryId as categoryId , 
(o.unitPrice*o.quantity*(1-o.discount)) as revenue
from orderdetail o left join product p on o.productId = p.productId
) t 
join category c on t.CategoryId = c.CategoryId
group by categoryId 
order by total_revenue desc limit 1;

-- Question F.2 - Which customer has placed the most orders?
select 
c.custId as Customer_Id ,
c.contactName as Customer_Name ,
count(distinct(s.orderId)) as Total_Orders_placed
from salesorder s join customer c on s.custId = c.custId
group by Customer_Id
order by Total_Orders_placed desc ;

-- Question F.3 - Which employee handles the highest number of orders?
select 
s.employeeId as Employee_Id , 
concat(e.TitleOfCourtesy,e.firstname," ",e.lastname) as Employee_Name , 
count(distinct(s.orderId)) as Orders_Handles
from salesorder s join employee e on s.employeeId = e.employeeId
group by Employee_Id
order by Orders_Handles desc ;


---------------------------------------------------------------- (^_^) -------------------------------------------------------------------------------