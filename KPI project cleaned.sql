create table sales_data_staging
like sales_data;

select * from sales_data_staging;

insert sales_data_staging
Select * from sales_data;



-- remove duplicates
-- standardize data
-- null values
-- remove columns

with cte as
( 
select *, row_number() over(partition by TransactionID order by TransactionID) as rn
from sales_data_staging 
);

CREATE TABLE `sales_data_staging2` (
  `TransactionID` text,
  `DateOfSale` text,
  `CustomerID` text,
  `Region` text,
  `Product` text,
  `Category` text,
  `SalesAmount` text,
  `QuantitySold` int DEFAULT NULL,
  `Discount` int DEFAULT NULL,
  `CostOfGoodsSold` double DEFAULT NULL,
  `rn` int
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

insert into sales_data_staging2
select *, row_number() over(partition by TransactionID order by TransactionID) as rn
from sales_data_staging ;

SELECT *
FROM sales_data_staging3
WHERE DateOfSale NOT REGEXP '^[0-9]{4}-[0-9]{2}-[0-9]{2}$';

UPDATE sales_data_staging3
SET DateOfSale = CONCAT(
    SUBSTR(DateOfSale, 7, 4), '-',  
    SUBSTR(DateOfSale, 4, 2), '-',  
    SUBSTR(DateOfSale, 1, 2)        
)
WHERE DateOfSale REGEXP '^[0-9]{2}-[0-9]{2}-[0-9]{4}$';

SELECT *
FROM sales_data_staging3
WHERE DateOfSale REGEXP '^[0-9]{4}/[0-9]{2}/[0-9]{2}$';

UPDATE sales_data_staging3
SET DateOfSale = REPLACE(DateOfSale, '/', '-')
WHERE DateOfSale REGEXP '^[0-9]{4}/[0-9]{2}/[0-9]{2}$';

-- standardize data

select * from sales_data_staging2;

update sales_data_staging2
set DateOfSale = trim(DateofSale)
where DateOfSale like '% ' or DateOfSale like ' %'
;

update sales_data_staging2
set Region = upper(trim(Region));

update sales_data_staging2
set Product = lower(trim(Product));


-- deal with blank/null values
select * from sales_data_staging2;

select * from sales_data_staging2
where SalesAmount = '';

delete from sales_data_staging2
where DateOfSale = '';

update sales_data_staging2
set Region = 'UNKNOWN'
where Region = '';

CREATE TABLE `sales_data_staging3` (
  `TransactionID` text,
  `DateOfSale` text,
  `CustomerID` text,
  `Region` text,
  `Product` text,
  `Category` text,
  `SalesAmount` text,
  `QuantitySold` int DEFAULT NULL,
  `Discount` int DEFAULT NULL,
  `CostOfGoodsSold` double DEFAULT NULL,
  `rn` int DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

insert into sales_data_staging3
Select * from sales_data_staging2;

Select * from sales_data_staging3;

UPDATE sales_data_staging3
SET SalesAmount = (SELECT AVG(SalesAmount) FROM sales_data_staging2 WHERE SalesAmount <> '')
WHERE SalesAmount = '';

update sales_data_staging3 
set SalesAmount = round(SalesAmount, 2);

ALTER TABLE sales_data_staging3
MODIFY DateOfSale DATE;


-- remove useless columns

Select * from sales_data_staging3;

alter table sales_data_staging3
drop column rn;

select * from sales_data_staging3 where
TransactionID = '' or
DateOfSale = '' or
CustomerID = '' or 
Region = '' or 
Product = '' or
Category = '' or
SalesAmount = '' or
QuantitySold = '' or
Discount = '' or
CostOfGoodsSold = '';

select	* from sales_data_staging3
where DateOfSale = '2024-02-30';

delete from sales_data_staging3
where DateOfSale = '2024-02-30';

ALTER TABLE sales_data_staging3
MODIFY DateOfSale DATE;
