													#DBMS PROJECT-GROUP4
															#PART A

#DATABASE:	icc,	TABLE:	icc_test
                                                            
#1.	Import the csv file to a table in the database.

CREATE DATABASE Icc;
USE icc;
DESC icc_test;

#2.	Remove the column 'Player Profile' from the table.

ALTER TABLE icc_test
DROP COLUMN `Player Profile`;

select * from icc_test;

#3.	Extract the country name and player names from the given data and store it in separate columns for further usage.
-- Add new columns for country name and player name
-- Add new columns for name and country
ALTER TABLE icc_test
ADD COLUMN player_name VARCHAR(100),
ADD COLUMN country VARCHAR(100);

-- Update the new columns with extracted data
UPDATE icc_test
SET player_name = TRIM(SUBSTRING_INDEX(player, '(', 1)),
    country = TRIM(SUBSTRING_INDEX(player, '(', -1));

-- Remove extra parenthesis from the country column
UPDATE icc_test
SET country = TRIM(TRAILING ')' FROM country);
 
SET SQL_SAFE_UPDATES = 0;
SELECT * FROM icc_test;

#4.	From the column 'Span' extract the start_year and end_year and store them in separate columns for further usage.

ALTER TABLE icc_test
ADD COLUMN start_year VARCHAR(100),
ADD COLUMN end_year VARCHAR(100);

SELECT * FROM icc_test;

UPDATE icc_test
SET start_year =TRIM(SUBSTRING_INDEX(Span,'-',1)),
end_year =TRIM(SUBSTRING_INDEX(Span,'-',-1));

#5.	The column 'HS' has the highest score scored by the player so far in any given match. The column also has details if the player had completed the match in a NOT OUT status. Extract the data and store the highest runs and the NOT OUT status in different columns.

ALTER TABLE icc_test
ADD COLUMN high_score int,
ADD COLUMN no_status VARCHAR(3);

SELECT * FROM icc_test;

UPDATE icc_test
SET high_score =TRIM(SUBSTRING_INDEX(HS,'*',1)),
no_status =CASE
			WHEN hs LIKE'%*' THEN 'YES'
            ELSE 'NO'
		    END;
            
#6.	Using the data given, considering the players who were active in the year of 2019, 
#create a set of batting order of best 6 players using the selection criteria of those who have a good average score 
#across all matches for India.

ALTER TABLE icc_test
RENAME COLUMN AVG TO avg_scores;

SELECT player_name,span,avg_scores,country 
FROM icc_test
WHERE start_year<=2019 AND end_year>=2019 AND country = 'India'
ORDER BY avg_scores DESC
LIMIT 6;

#7.	Using the data given, considering the players who were active in the year of 2019,
# create a set of batting order of best 6 players using the selection criteria of those 
#who have the highest number of 100s across all matches for India.

SELECT * FROM icc_test;

ALTER TABLE icc_test
CHANGE COLUMN `100` century INT;


SELECT player_name,span,century,country 
FROM icc_test
WHERE start_year<=2019 AND end_year>=2019 AND country = 'India'
ORDER BY century DESC
LIMIT 6;

#8.	Using the data given, considering the players who were active in the year of 2019,
# create a set of batting order of best 6 players using 2 selection criteria of your own for India.

SELECT player_name, span,country,high_score,no_status 
FROM icc_test
WHERE start_year<=2019 AND end_year>=2019 AND country='India' AND no_status='YES'
ORDER BY high_score DESC
LIMIT 6;

#9.	Create a View named ‘Batting_Order_GoodAvgScorers_SA’ using the data given,
# considering the players who were active in the year of 2019, 
#create a set of batting order of best 6 players using the selection criteria of those 
#who have a good average score across all matches for South Africa.

CREATE VIEW Batting_Order_GoodAvgScorers_SA AS
SELECT player_name,span,country,avg_scores 
FROM icc_test
WHERE country = 'SA' AND start_year <= 2019 AND end_year >= 2019
ORDER BY avg_scores DESC
LIMIT 6;


SELECT * FROM Batting_Order_GoodAvgScorers_SA;

#10.	Create a View named ‘Batting_Order_HighestCenturyScorers_SA’ Using the data given, 
#considering the players who were active in the year of 2019, 
#create a set of batting order of best 6 players using the selection criteria of those
# who have highest number of 100s across all matches for South Africa.

CREATE VIEW Batting_Order_HighestCenturyScorers_SA AS
SELECT player_name,span,century,country 
FROM icc_test
WHERE start_year<=2019 AND end_year>=2019 AND country ='SA'
ORDER BY century DESC
LIMIT 6;

SELECT * FROM Batting_Order_HighestCenturyScorers_SA;

#11.	Using the data given, Give the number of player_played for each country.

SELECT * FROM icc_test;

SELECT count(country) AS player_played,country FROM icc_test
GROUP BY country;

#12.	Using the data given, Give the number of player_played for Asian and Non-Asian continent
SELECT 
    CASE 
        WHEN country IN ('INDIA', 'SL', 'ICC/SA') THEN 'Asian'
        ELSE 'Non-Asian'
    END AS continent,
    COUNT(player) AS player_played
FROM icc_test
GROUP BY continent;


#part B
#import ddl case study,data,constraints through open sql script

-- 1.	Company sells the product at different discounted rates. 
-- Refer actual product price in product table and selling price in the order item table. 
-- Write a query to find out total amount saved in each order then display the orders from highest to lowest amount saved. 

SELECT 
	oi.OrderId,
    oi.ProductId,
    p.ProductName,
    p.UnitPrice AS ProductPrice,
    oi.UnitPrice AS SellingPrice,
    SUM(p.UnitPrice - oi.UnitPrice) AS AmountSaved
FROM
    Product AS p
        JOIN
    orderitem AS oi ON p.Id = oi.ProductId
GROUP BY oi.OrderId , oi.ProductId , p.UnitPrice , oi.UnitPrice
ORDER BY AmountSaved DESC;

-- 2.Mr. Kavin want to become a supplier. He got the database of "Richard's Supply" for reference. Help him to pick: 
-- a. List few products that he should choose based on demand.
-- b. Who will be the competitors for him for the products suggested in above questions.

SELECT 
    p.ProductName AS HighDemandProducts,
    SUM(oi.Quantity) AS TotalQuantityOrdered,
    s.CompanyName AS SupplierCompanyName,
    s.ContactName AS SupplierContactName
FROM
    orderitem AS oi
        JOIN
    product AS p ON p.Id = oi.ProductId
        JOIN
    supplier AS s ON s.Id = p.SupplierId
GROUP BY p.ProductName , s.CompanyName , s.CompanyName , s.ContactName
ORDER BY TotalQuantityOrdered DESC
LIMIT 10;

-- 3.Create a combined list to display customers and suppliers details considering the following criteria 
-- ●	Both customer and supplier belong to the same country
-- ●	Customer who does not have supplier in their country
-- ●	Supplier who does not have customer in their country

-- Both customer and supplier belong to the same country
SELECT 
    c.Id AS CustomerID,
    CONCAT(c.FirstName, c.LastName) AS CustomerName,
    c.Phone AS CustomerPhone,
    c.City AS CustomerCity,
    s.Id AS SupplierID,
    s.CompanyName AS SupplierCompanyName,
    s.ContactName AS SupplierContactName,
    s.ContactTitle AS SupplierContactTitle,
    s.Phone AS SupplierPhone,
    s.Fax AS SupplierFax,
    s.City AS SupplierCity,
    s.Country
FROM
    orderitem oi,
    orders o,
    customer c,
    product p,
    supplier s
WHERE
    oi.OrderId = o.Id
        AND o.CustomerId = c.Id
        AND p.Id = oi.ProductId
        AND p.SupplierId = s.Id
        AND c.Country = s.Country
GROUP BY s.Id , c.Id
ORDER BY s.Country ASC;

-- Customer who does not have supplier in their country
SELECT 
    c.Id AS CustomerID,
    CONCAT(c.FirstName, c.LastName) AS CustomerName,
    c.Phone,
    c.City,
    c.Country
FROM
    orderitem oi,
    orders o,
    customer c,
    product p,
    supplier s
WHERE
    oi.OrderId = o.Id
        AND o.CustomerId = c.Id
        AND p.Id = oi.ProductId
        AND p.SupplierId = s.Id
        AND c.Country <> s.Country
GROUP BY c.Id;

-- Supplier who does not have customer in their country
SELECT 
    s.Id AS SupplierID,
    s.CompanyName AS SupplierCompanyName,
    s.ContactName AS SupplierContactName,
    s.ContactTitle AS SupplierContactTitle,
    s.Phone AS SupplierPhone,
    s.Fax AS SupplierFax,
    s.City AS SupplierCity,
    s.Country
FROM
    orderitem oi,
    orders o,
    customer c,
    product p,
    supplier s
WHERE
    oi.OrderId = o.Id
        AND o.CustomerId = c.Id
        AND p.Id = oi.ProductId
        AND p.SupplierId = s.Id
        AND c.Country <> s.Country
GROUP BY s.Id;

-- 4.Every supplier supplies specific products to the customers. Create a view of suppliers and total sales made by their products and write a query on this view to find out top 2 suppliers (using windows function) in each country by total sales done by the products.

CREATE VIEW Supplier_total_sales AS
    SELECT 
        s.Id AS SupplierID,
        s.CompanyName AS SupplierCompanyName,
        s.ContactName AS SupplierContactName,
        s.country AS Country,
        p.ProductName AS Product,
        SUM(oi.quantity) AS Quantity,
        AVG(oi.UnitPrice) AS AvgUnitPrice,
        SUM(oi.quantity * oi.UnitPrice) AS TotalSales
    FROM
        supplier AS s
            JOIN
        product AS p ON s.Id = p.SupplierId
            JOIN
        orderitem AS oi ON p.Id = oi.ProductId
    GROUP BY s.Id , s.CompanyName , s.ContactName , p.productName , s.country;
    
-- Query Supplier_total_Sales view to find out top 2 suppliers using windows function in each country by total sales done by the products 

WITH ranked_suppliers AS (
    SELECT
        SupplierID,
        SupplierCompanyName,
        SupplierContactName,
        Country,
        Product,
        TotalSales,
        ROW_NUMBER() OVER (PARTITION BY Country ORDER BY TotalSales DESC) AS ranks
    FROM
        supplier_total_sales
)
SELECT
    SupplierID,
        SupplierCompanyName,
        SupplierContactName,
        Country,
        Product,
        TotalSales
FROM
    ranked_suppliers
WHERE
    ranks <= 2;
    
    -- 5.Find out for which products, UK is dependent on other countries for the supply. List the countries which are supplying these products in the same list.

SELECT 
    c.city AS UK_City,
    p.ProductName AS Product_Imported,
    s.country AS Supplier_Country
FROM
    customer AS c
        JOIN
    orders AS o ON c.Id = o.CustomerId
        JOIN
    orderitem AS oi ON o.Id = oi.OrderId
        JOIN
    product AS p ON p.Id = oi.ProductId
        JOIN
    supplier AS s ON s.Id = p.SupplierId
WHERE
    c.country = 'UK'
        AND s.Country NOT LIKE 'UK'
ORDER BY s.Country ASC;

-- 6.Create two tables as ‘customer’ and ‘customer_backup’ as follow - 
-- ‘customer’ table attributes -
-- Id, FirstName,LastName,Phone
-- ‘customer_backup’ table attributes - 
-- Id, FirstName,LastName,Phone
-- Create a trigger in such a way that It should insert the details into the  ‘customer_backup’ table when you delete the record from the ‘customer’ table automatically.

-- Query for creating 'customer' table
CREATE TABLE customer (
    Id INT PRIMARY KEY,
    FirstName VARCHAR(50),
    LastName VARCHAR(50),
    Phone VARCHAR(20)
);
-- Query for creating 'customer_backup' table
CREATE TABLE customer_backup (
    Id INT PRIMARY KEY,
    FirstName VARCHAR(50),
    LastName VARCHAR(50),
    Phone VARCHAR(20)
);

-- Query for creating a trigger to automatically insert deleted records into 'customer_backup' table
DELIMITER $$
CREATE TRIGGER trg_customer_backup
AFTER DELETE ON customer
FOR EACH ROW
BEGIN
INSERT INTO customer_backup(Id, FirstName, LastName, Phone)
VALUES (OLD.Id,OLD.FirstName,OLD.LastName,OLD.Phone);
END$$
DELIMITER ;

#To Check:
INSERT INTO customer (Id, FirstName, LastName, Phone)
VALUES 
(0, 'NameA', 'LastNameA', 9999999999);

SELECT * FROM customer;
DELETE FROM customer
WHERE Id = 0;
SELECT * FROM customer_backup;

