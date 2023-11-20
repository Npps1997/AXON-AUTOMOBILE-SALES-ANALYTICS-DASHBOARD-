-- Dashboard 1: Sales Overview

-- 1. Total Sales Over Time
SELECT 
    orderDate,
    SUM(quantityOrdered * priceEach) AS totalSales
FROM 
    Orders
    JOIN OrderDetails ON Orders.orderNumber = OrderDetails.orderNumber
GROUP BY 
    orderDate
ORDER BY 
    orderDate;

-- 2. Sales by Product Line
SELECT
    pl.productLine,
    SUM(od.quantityOrdered * od.priceEach) AS totalSales
FROM
    OrderDetails od
JOIN
    Products p ON od.productCode = p.productCode
JOIN
    ProductLines pl ON p.productLine = pl.productLine
GROUP BY
    pl.productLine;

-- 3. Sales by Country
SELECT
    c.country,
    SUM(od.quantityOrdered * od.priceEach) AS totalSales
FROM
    OrderDetails od
JOIN
    Orders o ON od.orderNumber = o.orderNumber
JOIN
    Customers c ON o.customerNumber = c.customerNumber
GROUP BY
    c.country;

-- 4. Top-Selling Products
SELECT
    productName,
    SUM(quantityOrdered * priceEach) AS revenue
FROM
    Products
    JOIN OrderDetails ON Products.productCode = OrderDetails.productCode
GROUP BY
    productName
ORDER BY
    revenue DESC
LIMIT 10;

-- 5. Sales Contribution by Product Line
SELECT
    pl.productLine,
    SUM(od.quantityOrdered * od.priceEach) AS totalSales,
    (SUM(od.quantityOrdered * od.priceEach) / (SELECT SUM(quantityOrdered * priceEach) FROM OrderDetails)) * 100 AS salesPercentage
FROM
    productlines pl
JOIN
    products p ON pl.productLine = p.productLine
JOIN
    orderdetails od ON p.productCode = od.productCode
GROUP BY
    pl.productLine
ORDER BY
    totalSales DESC;

-- Dashboard 2: Customer Analysis

-- 1. Customer Distribution by Country
SELECT
    country,
    COUNT(customerNumber) AS customerCount
FROM
    Customers
GROUP BY
    country;

-- 2. Top Customers by Sales
SELECT
    customerName,
    SUM(quantityOrdered * priceEach) AS totalSales
FROM
    Customers
    JOIN Orders ON Customers.customerNumber = Orders.customerNumber
    JOIN OrderDetails ON Orders.orderNumber = OrderDetails.orderNumber
GROUP BY
    customerName
ORDER BY
    totalSales DESC
LIMIT 10;

-- 3. Sales Performance of Sales Representatives
SELECT
    CONCAT(firstName, ' ', lastName) AS salesRep,
    SUM(quantityOrdered * priceEach) AS totalSales
FROM
    Employees
    JOIN Customers ON Employees.employeeNumber = Customers.salesRepEmployeeNumber
    JOIN Orders ON Customers.customerNumber = Orders.customerNumber
    JOIN OrderDetails ON Orders.orderNumber = OrderDetails.orderNumber
GROUP BY
    salesRep;

-- 4. Customer Credit Limits and Balances
SELECT
    customerName,
    creditLimit,
    SUM(amount) AS outstandingBalance
FROM
    Customers
    LEFT JOIN Payments ON Customers.customerNumber = Payments.customerNumber
GROUP BY
    customerName, creditLimit;

-- 5. High-Value Customers
SELECT
    Customers.customerNumber,
    customerName,
    COUNT(Orders.orderNumber) AS totalOrders,
    AVG(quantityOrdered * priceEach) AS averageOrderValue
FROM
    Customers
    JOIN Orders ON Customers.customerNumber = Orders.customerNumber
    JOIN OrderDetails ON Orders.orderNumber = OrderDetails.orderNumber
GROUP BY
    Customers.customerNumber
ORDER BY
    totalOrders DESC;

-- Dashboard 3: Product Performance

-- 1. Inventory Levels
SELECT
    productName,
    quantityInStock
FROM
    Products;

-- 2. Quantity Sold Over Time
SELECT
    orderDate,
    productName,
    quantityOrdered
FROM
    OrderDetails
    JOIN Orders ON OrderDetails.orderNumber = Orders.orderNumber
    JOIN Products ON OrderDetails.productCode = Products.productCode
ORDER BY
    orderDate;

-- 3. Profitability by Product
SELECT
    productName,
    (SUM(quantityOrdered * priceEach) - SUM(quantityOrdered * buyPrice)) AS profit
FROM
    Products
    JOIN OrderDetails ON Products.productCode = OrderDetails.productCode
GROUP BY
    productName;

-- 4. Product Lines Comparison
SELECT
    ProductLines.productLine,
    SUM(quantityOrdered * priceEach) AS totalSales
FROM
    OrderDetails
    JOIN Products ON OrderDetails.productCode = Products.productCode
    JOIN ProductLines ON Products.productLine = ProductLines.productLine
GROUP BY
    ProductLines.productLine;

-- 5. Top 3 Products with Low Stock
SELECT
    productCode,
    productName,
    quantityInStock
FROM
    Products
ORDER BY
    quantityInStock
LIMIT 3;

-- Dashboard 4: Operational Insights

-- 1. Order Status and Fulfillment Timeline
SELECT
    orderNumber,
    orderDate,
    requiredDate,
    shippedDate,
    DATEDIFF(shippedDate, orderDate) AS fulfillmentTime
FROM
    Orders;

-- 2. Employee Performance Metrics
SELECT
    CONCAT(firstName, ' ', lastName) AS employee,
    SUM(quantityOrdered * priceEach) AS totalSales,
    AVG(DATEDIFF(shippedDate, orderDate)) AS avgOrderProcessingTime
FROM
    Employees
    JOIN Customers ON Employees.employeeNumber = Customers.salesRepEmployeeNumber
    JOIN Orders ON Customers.customerNumber = Orders.customerNumber
    JOIN OrderDetails ON Orders.orderNumber = OrderDetails.orderNumber
GROUP BY
    employee;

-- 3. Office-Wise Performance
SELECT
    o.officeCode,
    o.city,
    SUM(quantityOrdered * priceEach) AS totalSales
FROM
    Offices o
    JOIN Employees e ON o.officeCode = e.officeCode
    JOIN Customers c ON e.employeeNumber = c.salesRepEmployeeNumber
    JOIN Orders ON c.customerNumber = Orders.customerNumber
    JOIN OrderDetails ON Orders.orderNumber = OrderDetails.orderNumber
GROUP BY
    o.officeCode;

-- 4. Top 10 Paying Customers
SELECT
    c.customerNumber,
    c.customerName,
    SUM(p.amount) AS totalPayments
FROM
    Customers c
    JOIN Payments p ON c.customerNumber = p.customerNumber
GROUP BY
    c.customerNumber
ORDER BY
    totalPayments DESC
LIMIT 10;

-- 5. Overdue Payments
SELECT
    c.customerNumber,
    c.customerName,
    o.orderNumber,
    o.orderDate,
    p.paymentDate,
    (o.orderDate - p.paymentDate) AS daysOverdue
FROM
    Customers c
    JOIN Orders o ON c.customerNumber = o.customerNumber
    JOIN Payments p ON c.customerNumber = p.customerNumber
WHERE
    p.paymentDate IS NULL OR p.paymentDate > o.orderDate;
