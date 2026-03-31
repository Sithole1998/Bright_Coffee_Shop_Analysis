-- Exploratory Data Analysis (EDA)

---------------------------------------------------------------------------
---1. Checking the data in a coding environment (Databricks)
---------------------------------------------------------------------------
SELECT * 
FROM `coffee_shop_analysis`.`coffee_project`.`coffee_shop` 
LIMIT 100;

-----------------------------------------------------------------------------
---2. Checking the date range
-----------------------------------------------------------------------------
--- Data was collected for a period of 6 months from 2023-01-01 to 2023-06-30

SELECT MIN(transaction_date) AS minimum_date,
       MAX(transaction_date) AS maximum_date
FROM `coffee_shop_analysis`.`coffee_project`.`coffee_shop`; 

---------------------------------------------------------------------------------------------------
---3. Checking the different store locations 
----------------------------------------------------------------------------------------------------
--- BrightCoffeeShop consist of 3 store location namely: Lower Manhattan, Hell's Kitchen and Astoria

SELECT DISTINCT (store_location)
FROM `coffee_shop_analysis`.`coffee_project`.`coffee_shop`; 

----------------------------------------------------------------------------------------------
---4. Checking the different product_category sold at BrightCoffeShop
----------------------------------------------------------------------------------------------
--- The different products are classified into 9 categories

SELECT DISTINCT (product_category)
FROM `coffee_shop_analysis`.`coffee_project`.`coffee_shop`; 

---------------------------------------------------------------------------------------------
---5. Checking product types sold at the coffee Shop 
---------------------------------------------------------------------------------------------
--- The product are classified into 9 different types 

SELECT DISTINCT (product_type)
FROM `coffee_shop_analysis`.`coffee_project`.`coffee_shop`;

-------------------------------------------------------------------------------------------
---6. Checking product details sold 
------------------------------------------------------------------------------------------- 
--- The products are classified into 80 different product details 

SELECT DISTINCT (product_detail)
FROM `coffee_shop_analysis`.`coffee_project`.`coffee_shop`;

-----------------------------------------------------------------------------------------
---7. Checking NULL values (Empty cells)
------------------------------------------------------------------------------------------
--- There dataset does not contain empty cells 

SELECT *
FROM `coffee_shop_analysis`.`coffee_project`.`coffee_shop`
WHERE unit_price IS NULL
OR transaction_qty IS NULL
OR transaction_time IS NULL
OR transaction_date IS NULL;

-------------------------------------------------------------------------------------
---8. Checking lowest and highest pice in the shop 
-------------------------------------------------------------------------------------
--- lowest_price = 0.8; highest_price = 45

SELECT MIN(unit_price) AS lowest_price,
       MAX(unit_price) AS highest_price
FROM `coffee_shop_analysis`.`coffee_project`.`coffee_shop`;

------------------------------------------------------------------------------------
---9. Extracting the day and month name 
-----------------------------------------------------------------------------------
SELECT transaction_date, 
       Dayname(transaction_date) AS day_name,
       Monthname(transaction_date) AS month_name
FROM `coffee_shop_analysis`.`coffee_project`.`coffee_shop`;

---------------------------------------------------------------------------------
---10. Calculating the revenue
---------------------------------------------------------------------------------
SELECT unit_price,
       transaction_qty,
      (unit_price * transaction_qty) AS revenue_per_day
FROM `coffee_shop_analysis`.`coffee_project`.`coffee_shop`;

---------------------------------------------------------------------------------
---11. Fix comma decimals from 3,1 to 3.1
---------------------------------------------------------------------------------
SELECT 
  REPLACE(unit_price, ',', '.') AS unit_price_clean
  FROM `coffee_shop_analysis`.`coffee_project`.`coffee_shop`;

  ------------------------------------------------------------------------------
  ---12 Check for duplicates 
  ------------------------------------------------------------------------------
  SELECT *,
  COUNT(*) AS duplicate_count
  FROM `coffee_shop_analysis`.`coffee_project`.`coffee_shop`
  GROUP BY ALL
  HAVING COUNT (*) >1;
  
  ---------------------------------------------------------------------------
  ---13. Check for incorrect values for unit price and transaction_qty
  ---------------------------------------------------------------------------
SELECT unit_price,
       transaction_qty
FROM `coffee_shop_analysis`.`coffee_project`.`coffee_shop`
WHERE unit_price <= 0 
      OR transaction_qty <= 0;


--------------------------------------------------------------------------------
---12. DATA PROCESSING (Combining functions to get a clean and enhanced dataset)
---------------------------------------------------------------------------------

--- Date and time function function
SELECT 
transaction_date,
DAY(transaction_date) AS day_of_month,
Dayname(transaction_date) AS day_name,
Monthname(transaction_date) AS month_name,
DATE_FORMAT(transaction_time, 'HH:mm:ss') AS purchase_time,

--- CASE statements for weekend vs weekdays 
CASE 
    WHEN Dayname(transaction_date) IN ('Sun', 'Sat') THEN 'weekend'
    ELSE 'weekday'
END AS day_classification, 

--- CASE statements for time_bucket
CASE 
    WHEN DATE_FORMAT(transaction_time, 'HH:mm:ss') BETWEEN '06:00:00' AND '09:59:59' THEN '01. Early Morning'
    WHEN DATE_FORMAT(transaction_time, 'HH:mm:ss') BETWEEN '10:00:00' AND '13:59:59' THEN '02. Late Morning'
    WHEN DATE_FORMAT(transaction_time, 'HH:mm:ss') BETWEEN '14:00:00' AND '17:59:59' THEN '03. Afternoon'
    WHEN DATE_FORMAT(transaction_time, 'HH:mm:ss') >= '18:00:00' THEN '04. Evening'
END AS time_bucket,

---product quantity 
transaction_qty AS quantity_sold,

--- Count of IDs 
COUNT(DISTINCT transaction_id) AS number_of_sales, 
COUNT(DISTINCT product_id) AS number_of_products, 
COUNT(DISTINCT store_id) AS number_of_stores, 

-- Calculating revenue by day
transaction_qty,
unit_price,
SUM(transaction_qty*unit_price) AS revenue_by_day,

--- CASE statement for spending levels 
CASE 
    WHEN (transaction_qty*unit_price) <= 50 THEN 'Low spend'
    WHEN (transaction_qty*unit_price) BETWEEN 51 AND 150 THEN 'Medium spend'
    WHEN (transaction_qty*unit_price) BETWEEN 151 AND 250 THEN 'High spend'
    ELSE 'Ballers'
END AS spend_bucket, 

--- Categorical columns 
store_location,
product_category,
product_detail,
product_type

FROM `coffee_shop_analysis`.`coffee_project`.`coffee_shop`
GROUP BY transaction_date,
         day_of_month,
         day_name,
         month_name,
         purchase_time,
         day_classification,
         time_bucket,
         unit_price,
         spend_bucket,
         transaction_qty,
         store_location,
         product_category,
         product_detail,
         product_type;







