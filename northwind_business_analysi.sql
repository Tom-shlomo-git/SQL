
/*
Query 1:
Identify the top 10 customers who generate the highest revenue.
Revenue is calculated as UnitPrice * Quantity * (1 - Discount).
*/

select top 10 with TIES 
    c.CustomerID,
    c.CompanyName,
    round(sum(od.UnitPrice * od.Quantity * (1 - od.Discount)),0) as 'Revenue'
from Customers c join Orders o 
    ON c.CustomerID = o.CustomerID
join [Order Details] od 
    on o.OrderID = od.OrderID
group by c.CustomerID, c.CompanyName
order by Revenue desc


/*
Query 2:
Analyze which countries generate the highest total sales revenue.
*/

select c.Country,
       round(sum(od.UnitPrice * od.Quantity * (1 - od.Discount)),0) as 'TotalRevenue'
from Customers c join Orders o 
    on c.CustomerID = o.CustomerID
join [Order Details] od 
    on o.OrderID = od.OrderID
group by c.Country
order by TotalRevenue desc


/*
Query 3:
Identify the products that were sold in the highest quantities.
*/

select p.ProductID,
       p.ProductName,
    sum(od.Quantity) as 'TotalUnitsSold'
from Products p join [Order Details] od 
    on p.ProductID = od.ProductID
group by p.ProductID,p.ProductName
order by TotalUnitsSold desc


/*
Query 4:
Analyze the number of orders handled by each employee and customer.
ROLLUP is used to generate subtotals for employees and customers.
*/

select concat(FirstName,' ',e.LastName) as 'Full Name',
       c.CompanyName,
       count(o.OrderID) as 'Count Order'
from Orders o join Employees e
    on o.EmployeeID = e.EmployeeID
join Customers c
    on c.CustomerID = o.CustomerID
group by rollup (concat(FirstName,' ',e.LastName), c.CompanyName)


/*
Query 5:
Identify which customers place the highest number of orders.
*/

select c.CustomerID,
       c.CompanyName,
    count(o.OrderID) as 'NumberOfOrders'
from Customers c join Orders o 
    on c.CustomerID = o.CustomerID
group by c.CustomerID,c.CompanyName
ORDER BY NumberOfOrders desc


/*
Query 6:
Calculate the total company revenue per year.
*/

select year(o.OrderDate) as 'OrderYear',
       round(sum(od.UnitPrice * od.Quantity * (1 - od.Discount)),0) as 'TotalRevenue'
from Orders o join [Order Details] od 
    on o.OrderID = od.OrderID
group by year(o.OrderDate)
order by OrderYear


/*
Query 7:
Calculate shipping time for each order by measuring the difference 
between the order date and the shipped date.
*/

select OrderID,
       datediff(day, OrderDate, ShippedDate) as 'ShippingDays'
from Orders
order by datediff(day, OrderDate, ShippedDate) desc


/*
Query 8:
Calculate the average shipping time for all orders.
*/

select 
    avg(datediff(day, OrderDate, ShippedDate)) AS 'AvgShippingDays'
from Orders
where ShippedDate IS NOT NULL


/*
Query 9:
Find products that are more expensive than ProductID = 8.
*/

select ProductName,
       UnitPrice
from Products
where UnitPrice > (SELECT UnitPrice
                   from Products
                   WHERE ProductID = 8)


/*
Query 10:
Determine which shipping company delivers orders the fastest
by calculating the average shipping time.
*/

select s.CompanyName AS Shipper,
    avg(datediff(day, o.OrderDate, o.ShippedDate)) as 'AvgShippingDays'
from Orders o join Shippers s 
    on o.ShipVia = s.ShipperID
WHERE o.OrderDate IS NOT NULL AND o.ShippedDate IS NOT NULL
group by s.CompanyName
ORDER BY AvgShippingDays