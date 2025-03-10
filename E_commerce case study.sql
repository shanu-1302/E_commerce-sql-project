# CREATING DATABASE OF ECOMMERCE TO STORE THE DATA 
create database E_commerce; 

# Understanding the dataset by analyze all the tables

Describe customersdata; # EACH CUSTOMER HAS UNIQUE CUST ID WITH NAME AND LOCATION
Describe productdata; # IT CONTAINS PRODUCTID WITH NAME, CATEGORY AND PRICE
Describe order_id; # IT CONTAINS ORDER ID WITH ORDER DATE, THE CUSTOMERID WHO ORDERED AND TOTAL AMOUNT OF THE BILL
Describe orderdetails; #IT CONTAINS ORDERID OF PRODUCTS DETAILS WITH PRODUCTID, QUANTITY AND ITS UNIT PRICE

# MARKET SEGMENT ANALYSIS
# IDENTIFYING THE TOP 3 CITIES WITH HIGHEST NUMBER OF CUSTOMERS 

Select location, count(customer_id) as TotalCustomers from customersdata
group by location
order by count(customer_id) desc
Limit 3;   

## Delhi, Chennai,Jaipur are top 3 Cities
## Marketing Strategies- setup local warehouses for fastdelivery
## collobrate with localized delivery partners for cost_effective deliveries
## Identify the local high demand products mostly purchased by the customers for better inventory management

# ENGAGEMENT DEPTH ANALYSIS
# DISTRIBUTION OF CUSTOMERS BY THEIR NO OF ORDERS PLACED
select totalorders,count(customer_id) as Customercount
from (
select customer_id,count(order_id) as TotalOrders from order_id
group by customer_id
order by count(order_id) asc
) as cust_ord_data
group by totalorders
order by totalorders asc; 
## Identifies the customerscount baased on the orders
## this trend analyses that as the number of orders increases, the customercount decreases

# SEGEMENTATION OF CUSTOMERS INTO DIFF CATEGORIES

 SELECT Totalorders, CASE 
	WHEN Totalorders = 1 THEN 'One-Time buyer'
	WHEN Totalorders BETWEEN 2 AND 4 THEN 'Occasional Shoppers'
	ELSE 'Regular Customers'
	END TYPEOFCUSTOMER
FROM (
select totalorders,count(customer_id) as Customercount
from (
select customer_id,count(order_id) as TotalOrders from order_id
group by customer_id
order by count(order_id) asc
) as cust_ord_data
group by totalorders
order by totalorders asc) CUSTCOUNT;
## Insight: Mostly this e_commerce company experiences the occasional customers with orders in the range of 2 to 4

# IDENTIFYING THE HIGH_REVENUE PREMIUM PRODUCTS

SELECT product_id,avg(quantity) as AvgQuantity,SUM(quantity*price_per_unit) as TotalRevenue
FROM orderdetails
GROUP BY product_id
HAVING avg(quantity)=2
ORDER BY TotalRevenue DESC; 
## Product 1 & 8 exhibits high revenue where as product 1 is the most premium product with highest revenue

# CATEGORY_WISE_CUSTOMER REACH
# IDENTIFYING THE TOTAL UNIQUE CUSTOMERS UNDER EACH CATEGORY
 
 Select p.category,count(distinct o.customer_id) as Total_Unique_Customers
 from productdata p
 join orderdetails od on p.product_id=od.product_id
 join order_id o on od.order_id=o.order_id
 group by p.category
 order by count(distinct o.customer_id) desc;
 ## Electronics product category needs more focus as it is in high demand among the customers followed by wearable tech and Photography.
 
 # SALES TREND ANALYSIS
 # Analyzing the sales growth over month_on_month percentage change
UPDATE order_id 
SET order_date = STR_TO_DATE(order_date, '%d-%m-%Y'); # updating the date format which is in text to date type

SELECT MONTH_NO AS Month, Totalsales,
    ROUND(((Totalsales - LAG(Totalsales) OVER (ORDER BY MONTH_NO)) / LAG(Totalsales) OVER (ORDER BY MONTH_NO)) * 100,2) AS PercentChange
FROM (
SELECT DATE_FORMAT(order_date,'%Y-%m') AS MONTH_NO, SUM(Total_amount) AS Totalsales FROM order_id
GROUP BY DATE_FORMAT(order_date,'%Y-%m')
ORDER BY MONTH_NO
) AS MD;
## In the month februaury 0f 2024 the sales experience the largest decline 
## As per the analysis, sales are fluctauated with no clear trend from march to august in 2023
## Highest growth was observed in april,july and december month of 2023.

# AVERAGE ODER VALUE FLUCTUATION-- HELPS TO PRICING AND PROMOTIONAL STRATEGIES
SELECT Month, AvgOrderValue,
	round(AvgOrderValue-LAG(AvgOrderValue) over (order by month),2) as ChangeInValue
FROM (
SELECT DATE_FORMAT(order_date,'%Y-%m') as Month, AVG(Total_amount) as AvgOrderValue
FROM order_id
GROUP BY DATE_FORMAT(order_date,'%Y-%m')
) AS average
GROUP BY Month
ORDER BY ChangeInValue DESC;
# December month of 2023 has the highest change in the average order value
# Due to Seasonal Demand 

#INVENTORY REFERESH RATE
# Identifying the products with the fastest turnover rates, suggesting high demand and the need for frequent restocking.

SELECT product_id, count(order_id) as SalesFrequency,sum(quantity*price_per_unit) as totalrevenue
FROM orderdetails
GROUP BY product_id
ORDER BY SalesFrequency desc
Limit 5;
## product 7,3,4,2 and 8 are the top 5 products which are high in demand which need to be restock frequently

# LOW ENGAGEMENT PRODUCTS
#  Identifying the products list purchased by less than 40% of the customer base, indicating potential mismatches between inventory and customer interest

SELECT 
    p.product_id,
    p.name AS Name,
    COUNT(DISTINCT o.customer_id) AS UniqueCustomerCount
FROM 
    productdata p
JOIN
    OrderDetails od ON p.product_id = od.product_id
JOIN   
    order_id o ON od.order_id = o.order_id
JOIN
    customersdata c ON o.customer_id = c.customer_id
GROUP BY
    p.product_id, p.name
HAVING 
    COUNT(DISTINCT o.customer_id) < (SELECT COUNT(DISTINCT customer_id) * 0.4 FROM customersdata)
ORDER BY 
    UniqueCustomerCount ASC;
## SmartPhone 6 and Wireless Earbuds are the products which are less in demand
## May be due to factors like poor visbility in platform
## Strategic Action: Implement the marketing campaigns to get the awareness and interest

# CUSTOMER ACQUISTION TREND
# Evaluating the month-on-month growth rate in the customer base to understand the effectiveness of marketing campaigns and market expansion efforts.

SELECT 
    FirstPurchaseMonth,
    COUNT(customer_id) as TotalNewCustomers
FROM(
    SELECT 
        DATE_FORMAT(MIN(order_date),'%Y-%m') as FirstPurchaseMonth,
        customer_id
    FROM 
        order_id
    GROUP BY 
        customer_id) AS A
GROUP BY
    FirstPurchaseMonth
ORDER BY
    FirstPurchaseMonth;
## Growth Trend in the customers base is declining, it shows that marketing efforts are not much effective

#PEAK SALES PERIOD IDENTIFICATION
# Identifing the months with the highest sales volume, aiding in planning for stock levels, marketing efforts, and staffing in anticipation of peak demand periods

SELECT 
    Date_format(Order_date,'%Y-%m') as Month,
    SUM(total_amount) as TotalSales
FROM 
    order_id
GROUP BY 
     Date_format(Order_date,'%Y-%m')
ORDER BY
    TotalSales desc
Limit 3;
## September and December months will require major restocking of product and increased staffs.

