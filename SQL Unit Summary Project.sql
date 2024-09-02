/***SQL Unit Summary Project***/

/*Business Questions*/

/*a) Is the revenue/profitability seasonal?, 
  b) Is there an upward or downward trend in the company's data over the months and years?*/

/*For these question, I'm going to analize both the company's revenue and historical 
profitability. Data will be analized by years and months*/

/*First, I'll analize the income*/

/*This query shows the Big Picture of the company's historical cumulative monthly income*/

select
	MONTH(soh.OrderDate) as [Month],
	SUM (case when year(soh.OrderDate) = 2011 then (sod.UnitPrice * sod.OrderQty)end) as Income2011,
	SUM (case when year(soh.OrderDate) = 2012 then (sod.UnitPrice * sod.OrderQty)end) as Income2012,
	SUM (case when year(soh.OrderDate) = 2013 then (sod.UnitPrice * sod.OrderQty)end) as Income2013,
	SUM (case when year(soh.OrderDate) = 2014 then (sod.UnitPrice * sod.OrderQty)end) as Income2014
from
	Sales.SalesOrderHeader as soh
		JOIN Sales.SalesOrderDetail as sod 
			on soh.SalesOrderID = sod.SalesOrderID
group by
	MONTH(soh.OrderDate)
order by
	[Month]
-------------------------------------------------------------------------------------------------
/*This query shows the big picture of both company's historical cumulative monthly 
income and profit. Based on this query, I will explore the topics
that affects the company's profitability and how to improve it*/

select
	YEAR(h.OrderDate) as [Year],
	DATENAME(MONTH,h.OrderDate) as [Month],
	DATEPART (QUARTER, OrderDate) as [Quarter],
	SUM((d.UnitPrice -(d.UnitPrice*d.UnitPriceDiscount))* d.OrderQty) as TotalIncome,
	SUM(d.LineTotal - p.StandardCost * d.OrderQty) as  TotalProfit
from Sales.SalesOrderHeader as h
	join Sales.SalesOrderDetail as d		
		on h.SalesOrderID = d.SalesOrderID
			join Production.Product as p
				on d.ProductID = p.ProductID
where d.SpecialOfferID <> 7
group by YEAR(h.OrderDate), DATENAME(MONTH,h.OrderDate), DATEPART (QUARTER, OrderDate)
order by [Year],[Month]

-------------------------------------------------------------------------------------------------

/*Now, I'll analize profitability*/

/*These queries check if column 'ListPrice' in the Product table is the same as column 'UnitPrice' 
in the SalesOrderDetail table. We can see this is not true. There are different values 
in both tables*/

select ProductID, UnitPrice, UnitPriceDiscount
from Sales.SalesOrderDetail
where ProductID in (777,800,854)

select ProductID, StandardCost,ListPrice
from Production.Product
where ProductID in (777,800,854)

-------------------------------------------------------------------------------------------------

/*This query shows the big picture of the company's historical cumulative monthly profit */

select
	MONTH(soh.OrderDate) as [Month],
	SUM (case when year(soh.OrderDate) = 2011 then (sod.LineTotal - p.StandardCost * sod.OrderQty)end) as Profit2011,
	SUM (case when year(soh.OrderDate) = 2012 then (sod.LineTotal - p.StandardCost * sod.OrderQty)end) as Profit2012,
	SUM (case when year(soh.OrderDate) = 2013 then (sod.LineTotal - p.StandardCost * sod.OrderQty)end) as Profit2013,
	SUM (case when year(soh.OrderDate) = 2014 then (sod.LineTotal - p.StandardCost * sod.OrderQty)end) as Profit2014
from
	Sales.SalesOrderHeader as soh
		JOIN Sales.SalesOrderDetail as sod 
			on soh.SalesOrderID = sod.SalesOrderID
				JOIN Production.Product as p
					on sod.ProductID = p.ProductID
group by
	MONTH(soh.OrderDate)
order by
	[Month]
----------------------------------------------

/*Analyzing monthly and quarterly sales and profit to check if there is a seasonal trend*/

--Quarterly income 
Select 
	YEAR (OrderDate) as [Year],
	DATEPART (QUARTER, OrderDate) as [Quarter],
	SUM (SubTotal) as TotalIncome
From Sales.SalesOrderHeader
group by YEAR (OrderDate), DATEPART (QUARTER, OrderDate)
order by [Year],[Quarter]

--Quarterly profit
Select 
	YEAR (h.OrderDate) as [Year],
	DATEPART (QUARTER, h.OrderDate) as [Quarter],
	SUM(d.LineTotal - p.StandardCost * d.OrderQty) as  TotalProfit
from Sales.SalesOrderDetail d
	left join Production.Product p
		on d.ProductID = p.ProductID
			left join Sales.SalesOrderHeader as h
				on d.SalesOrderID = h.SalesOrderID
group by YEAR (h.OrderDate), DATEPART (QUARTER, h.OrderDate)
order by [Year],[Quarter]

-------------------------------------------------------------------------------------------------
/*Query for retrieving average currency exchange rate in the different territories where 
the company has a presence*/

select*from Sales.CountryRegionCurrency
select*from Sales.Currency
select*from Sales.CurrencyRate
select*from Sales.SalesTerritory

select 
	t.CountryRegionCode,
	c.[Name],
	r.FromCurrencyCode,
	r.ToCurrencyCode,
	AVG(r.AverageRate) as AverageRate
from Sales.CountryRegionCurrency as crc
	join Sales.Currency as c
		on crc.CurrencyCode = c.CurrencyCode
			join Sales.CurrencyRate as r
				on c.CurrencyCode = r.ToCurrencyCode
					join Sales.SalesTerritory as t
						on crc.CountryRegionCode = t.CountryRegionCode
group by 
	t.CountryRegionCode,
	c.[Name],
	r.FromCurrencyCode,
	r.ToCurrencyCode

/*In the table CurrencyRate, we have the fields 'FromCurrency' and 'ToCurrency' in USD. Therefore,
it's assumed that all the payments are automatically exchanged from USD to the local currency.
Also, notice that all the payments recorded in the table SalesOrderHeader were made with credit 
cards and all intermediary financial companies are responsible for converting at the exchange 
rate at that moment. So, we don't have to convert the payments to the different currencies*/

-------------------------------------------------------------------------------------------------
/*Business Questions*/

/*c) Choose one topic that affects the company's profitability, study it and give recommendations 
based on data for how to improve the company's profitability*/

/*Now, I'll analyze the sales by territories*/

/*This query retrieves the countries in which products are sold and the sum of year-to-date sales
in every country*/

select
	s.[Group] as Continent,
	r.[Name] as Country,
	s.CountryRegionCode,
	SUM(SalesYTD) as SalesYTD,
	SUM(s.SalesLastYear) as SalesLastYear
from Sales.SalesTerritory as s
	join Person.CountryRegion r
		on s.CountryRegionCode = r.CountryRegionCode
group by s.[Group],r.[Name], s.CountryRegionCode
order by SalesYTD desc

-------------------------------------------------------------------------------------------------
/*This query shows the big picture of the total income by territories*/

select
	t.CountryRegionCode,
	r.[Name],
	SUM(h.SubTotal) as TotalIncome
from Sales.SalesOrderHeader	as h
	left join Sales.SalesTerritory as t
		on h.TerritoryID = t.TerritoryID
			left join Person.CountryRegion as r
				on t.CountryRegionCode = r.CountryRegionCode
group by t.CountryRegionCode, r.[Name]

-------------------------------------------------------------------------------------------------

/*This query breaks down the total income, the number of sales (count of orders), 
and the quantity of sold products through the years and months*/

select
	YEAR(h.OrderDate) as [Year],
	DATENAME(MONTH,h.OrderDate) as [Month],
	t.CountryRegionCode,
	r.[Name],
	COUNT(*) as NoSales,
	SUM(h.SubTotal) as TotalIncome
from Sales.SalesOrderHeader	as h
	left join Sales.SalesTerritory as t
		on h.TerritoryID = t.TerritoryID
			left join Person.CountryRegion as r
				on t.CountryRegionCode = r.CountryRegionCode
group by YEAR(h.OrderDate),	DATENAME(MONTH,h.OrderDate), t.CountryRegionCode, r.[Name]
order by 1,2,3,4

-------------------------------------------------------------------------------------------------
 /*Used this query to retrieve the column 'TotalQtyProd'. It is the total quantity of products
 ordered in every single sales order*/

select
	YEAR(h.OrderDate) as [Year],
	DATENAME(MONTH,h.OrderDate) as [Month],
	m.CountryRegionCode,
	m.[Name],
	SUM(d.OrderQty) as TotalQtyrod
from Sales.SalesOrderDetail as d
	join Sales.SalesOrderHeader as h
		on d.SalesOrderID = h.SalesOrderID
			join ( select t.TerritoryID,t.CountryRegionCode, r.[Name]
				from Sales.SalesTerritory as t
					join Person.CountryRegion as r
						on t.CountryRegionCode = r.CountryRegionCode) as m
		on h.TerritoryID = m.TerritoryID
group by YEAR(h.OrderDate), DATENAME(MONTH,h.OrderDate),m.CountryRegionCode, m.[Name]
order by 1, 2,3,4

-------------------------------------------------------------------------------------------------

/*Now, I'll break down the product categories and their sales by territories*/

select*from Production.Product
select*from Production.ProductCategory
select*from Production.ProductSubcategory

/*In the Product table, there are items with NULL values in the SubCategory field.
Let's check if these products were sold in the SalesOrderDetail table*/

select*
from Sales.SalesOrderDetail as d
	join Production.Product as p
		on d.ProductID = p.ProductID
where p.ProductSubcategoryID is null

--There are no products sold without SubCategory. OK

--------------------------------------------------------------------------------------------------

/*This is the main query of my dataset. Based on this query, I performed the whole analisys
and created a dashboard to visualize the data, trends, patterns, insights of the company's 
revenue and profit*/

select 
	d.SalesOrderID,
	h.CustomerID,
	case 
		when [Type].typeCustomer = 'SC' then 'Stores'
		else 'Individuals'
	end as CustomerType,
	YEAR(h.OrderDate) as [Year],
	DATENAME(MONTH,h.OrderDate) as [Month],
	t.CountryRegionCode,
	r.[Name] as Country,
	p.[Name] as ProductName,
	sc.[Name] as SubCategory,
	c.[Name] as Category,
	d.OrderQty as ProductQty,
	case 
		when h.OnlineOrderFlag = 0 then 'Vendor'
		else 'Online'
	end as SalesType,
	CONCAT(pp.[FirstName], ' ', pp.[LastName]) as VendorName,
	so.SpecialOfferID,
	so.[Description] as InfoDesc,
	so.[Type] as TypeDesc,
	d.UnitPriceDiscount as '%Discount',

	d.UnitPrice,
	p.StandardCost,
	d.UnitPrice * d.UnitPriceDiscount as UnitDiscount,
	d.UnitPrice - (d.UnitPrice * d.UnitPriceDiscount) as UnitPrice_Discounted,
	d.OrderQty * d.UnitPrice * d.UnitPriceDiscount as TotalDiscount,

	d.LineTotal as TotalIncome,
	d.LineTotal - p.StandardCost * d.OrderQty as  TotalProfit,
	((d.UnitPrice - (d.UnitPrice * d.UnitPriceDiscount) - p.StandardCost)/p.StandardCost) as '%Profit'
from Sales.SalesOrderDetail as d
	join Production.Product as p
		on d.ProductID = p.ProductID
			join Production.ProductSubcategory as sc
				on p.ProductSubcategoryID = sc.ProductSubcategoryID
					join Production.ProductCategory as c
						on sc.ProductCategoryID = c.ProductCategoryID
							join Sales.SalesOrderHeader as h
								on h.SalesOrderID = d.SalesOrderID
									join Sales.Customer as cus
										on h.CustomerID = cus.CustomerID
											join Sales.SalesTerritory as t
												on h.TerritoryID = t.TerritoryID
													join Person.CountryRegion as r
														on t.CountryRegionCode = r.CountryRegionCode
															join Sales.SpecialOffer as so
																on d.SpecialOfferID = so.SpecialOfferID
																		left join Sales.SalesPerson as per
																		on h.SalesPersonID = per.BusinessEntityID
																			left join HumanResources.Employee as e
																				on per.BusinessEntityID = e.BusinessEntityID
																					left join Person.Person pp
																						on	e.BusinessEntityID = pp.BusinessEntityID
																							join (
																									select distinct											
																										hh.CustomerID as IDCust,
																										perp.personType as typeCustomer
																								
																									from Sales.SalesOrderHeader as hh
																										join Sales.Customer as cust
																											on hh.CustomerID = cust.CustomerID
																												join Person.Person as perp
																													on perp.BusinessEntityID = cust.PersonID
																								 ) as [type]
																								on h.CustomerID = [type].IDCust
																						
----------------------------------------------------------------------------------------------------------------------------------------------------------------

/*ANALYSIS OF ONLINE SALES VS STORES SALES*/

/*OnlineOrderFlag: 0 = Order placed by sales person. 1 = Order placed online by customer.*/

/*We have 27 659 records for online sales and 3 806 records for stores sales*/


--Online Orders
select	
	COUNT(*) as NoOrdenesONLINE,
	SUM(SubTotal) as TotalIngresos
from Sales.SalesOrderHeader
where OnlineOrderFlag=1 

--Stores Orders
select	
	COUNT(*) as NoOrdenesVENDEDOR,
	SUM(SubTotal) as TotalIngresos
from Sales.SalesOrderHeader
where OnlineOrderFlag=0 

--------------------------------------------------------------------------------------------------