create database AdventureWorks;
use adventureworks;
select * from sales;
alter table sales rename column ï»¿ProductKey to ProductKey;
alter table sales modify column OrderDate date, modify column DueDate date, modify column YearMonthOrderDate varchar(7);

select * from dimdate;
alter table dimdate rename column ï»¿DateKey to DateKey;
alter table dimdate modify column FullDateAlternateKey date;

select * from dimcustomer;
alter table dimcustomer rename column ï»¿CustomerKey to CustomerKey;
alter table dimcustomer modify column BirthDate date, modify column DateFirstPurchase date;

select * from dimsalesterritory;
alter table dimsalesterritory rename column ï»¿SalesTerritoryKey to SalesTerritoryKey;

select * from dimproduct;
alter table dimproduct rename column ï»¿ProductKey to ProductKey;
alter table dimproduct modify column StartDate date;






#1 Total Sales
select concat(round(sum(SalesAmount)/1000000,2),'M') as TotalSales from sales;

#2 Total Profit
select concat(round((sum(SalesAmount)-sum(ProductStandardCost))/1000000,2),'M') as TotalProfit from sales;

#3 Production Cost
select concat(round(sum(ProductStandardCost)/1000000,2),'M') as ProductionCost from sales;

#4 Average Revenue per Customer (Total Revenue/Unique Customers)
select round(sum(SalesAmount)/count(distinct CustomerKey),2) as AverageRevenuePerCustomer from Sales;

#5 Average Order value (Total Revenue/Total Orders)
select round(sum(SalesAmount)/count(OrderDateKey),2) as AverageOrderValue from sales;

#6 Genderwise Order Quantity
select case 
when c.Gender='M' then 'Male'
when c.Gender='F' then 'Female'
else c.Gender
end as Gender,sum(s.OrderQuantity) as TotalOrderQuantity from dimcustomer c 
inner join sales s on c.CustomerKey=s.CustomerKey 
group by c. Gender;

#7 Countrywise Sales
select st.SalesTerritoryCountry as Country,concat(round(sum(s.SalesAmount)/1000000,2),'M') as Sales 
from dimsalesterritory st inner join sales s on st.SalesTerritoryKey=s.SalesTerritoryKey
group by Country order by sum(s.SalesAmount) desc;

#8 Yearwise Sales
select OrderDateYear as OrderYear, concat(round(sum(SalesAmount)/1000,2),'K') as TotalSales 
from sales group by OrderYear order by sum(SalesAmount) desc;

#9 Yearwise Quarterwise Sales
select OrderDateYear as Year, QuarterOrderDate as Quarter, concat(round(sum(SalesAmount)/1000000,2),'M') as Sales 
from sales group by Quarter,Year order by sum(SalesAmount) desc;

#10 Monthwise  Production Cost and Sales Amount
select MonthNameOrderDate as Month, 
concat(round(sum(ProductStandardCost)/1000000,2),'M') as ProductionCost ,
concat(round(sum(SalesAmount)/1000000,2),'M') as Sales 
from sales group by Month order by sum(SalesAmount) desc;

#11 Regionwise Production Cost- Top 7
select st.SalesTerritoryRegion as Region,concat(round(sum(s.ProductStandardCost)/1000000,2),'M') as ProductionCost 
from dimsalesterritory st
inner join sales s on st.SalesTerritoryKey=s.SalesTerritoryKey
group by Region order by sum(s.ProductStandardCost) desc limit 7;

#12 Fiscal Year wise Profit
-- select d.FiscalYear as FiscalYear,concat(round(sum(s.SalesAmount-s.ProductStandardCost)/1000000,2),'M') as Profit from dimdate d
-- inner join sales s on d.DateKey=s.OrderDateKey
-- group by FiscalYear order by FiscalYear;

#13 Sales Territory Group wise Orders
select st.SalesTerritoryGroup as TerritoryGroup,count(OrderDateKey) as Orders
from dimsalesterritory st
inner join sales s on st.SalesTerritoryKey=s.SalesTerritoryKey
group by SalesTerritoryGroup order by Orders desc ;

#14 Category and SubCategory wise sales
select p.ProductCategoryName as category,p.EnglishProductSubcategoryName as Subcategory,
concat(round(sum(SalesAmount)/1000,2),'K') as Sales from dimproduct p
inner join sales s on p.ProductKey=s.ProductKey
group by category,Subcategory order by sum(SalesAmount) desc ;

#15 Subcategorywise Orders
select  p.EnglishProductSubcategoryName as Subcategory,count(OrderDateKey) as Orders
from dimproduct p
inner join sales s on p.ProductKey=s.ProductKey
group by Subcategory order by Orders desc ;

#16 Yearwise Sales Growth Rate
with cte as(
select OrderDateYear as Year, round(sum(SalesAmount),2) as TotalSales from sales group by Year
)
select Year, TotalSales,concat(round((TotalSales-lag(TotalSales) over(order by Year))/lag(TotalSales) over(order by Year)*100,2
),'%') as SalesGrowthRate from cte;

#17 Least Selling Products
select p.EnglishProductName as Product,concat(round(sum(s.SalesAmount)/1000,2),"k") as TotalSales from dimproduct p
inner join sales s on p.ProductKey=s.ProductKey
group by Product order by sum(s.SalesAmount) limit 10;

#18 Region by Customer Volume Top 7
select st.SalesTerritoryRegion as Region,count(s.CustomerKey) as CustomerVolume from dimsalesterritory st
inner join sales s on st.SalesTerritoryKey=s.SalesTerritoryKey
group by Region order by CustomerVolume desc limit 7;

#19 Country by Customer Volume Top 7
select st.SalesTerritoryCountry as Country,count(s.CustomerKey) as CustomerVolume from dimsalesterritory st
inner join sales s on st.SalesTerritoryKey=s.SalesTerritoryKey
group by Country order by CustomerVolume desc limit 7;

#20 Top 5 Product with Maximum Profit
select p.EnglishProductName as Product, concat(round(sum(s.SalesAmount-s.ProductStandardCost)/1000,2),'K') as TotalProfit
from sales s inner join dimproduct p on s.ProductKey=p.ProductKey
group by Product order by sum(s.SalesAmount-s.ProductStandardCost) desc limit 5;

#21 Yearwise Profit Growth Rate
with ProfitData as(
select OrderDateYear as Year, round(sum(SalesAmount-ProductStandardCost),2) as TotalProfit
from sales group by Year ),
ProfitGrowth as(
select Year, TotalProfit, round(lag(TotalProfit) over(order by Year),2) as PreviousYearProfit,
case when lag(TotalProfit) over(order by Year) is null then null
else concat(round(((TotalProfit-lag(TotalProfit) over(order by Year))/lag(TotalProfit) over(order by Year))*100,2),'%')
end as ProfitGrowthRate from ProfitData)
select * from ProfitGrowth;
