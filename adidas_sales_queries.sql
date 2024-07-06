-- Use Case 1: Regional Sales Performance Analysis
-- This query calculates the top 5 states by total sales in each region.

WITH RegionalSales AS (
    SELECT 
        Region, 
        State, 
        SUM(CAST(Units_Sold AS INT)) AS Total_Units_Sold, 
        SUM(CAST(Total_Sales AS DECIMAL(18,2))) AS Total_Sales, 
        AVG(CAST(REPLACE(Operating_Margin, '%', '') AS DECIMAL(18,2))/100) AS Average_Operating_Margin,
        ROW_NUMBER() OVER(PARTITION BY Region ORDER BY SUM(CAST(Total_Sales AS DECIMAL(18,2))) DESC) AS RowNum
    FROM 
        [Adidas_sales].[dbo].[Adidas US Sales Datasets]
    GROUP BY 
        Region, 
        State
)
SELECT 
    Region,
    State,
    Total_Units_Sold,
    Total_Sales,
    Average_Operating_Margin
FROM 
    RegionalSales
WHERE 
    RowNum <= 5
ORDER BY 
    Region, Total_Sales DESC;

-- Use Case 2: Product Category Sales Comparison
-- This query categorizes products and compares their sales performance.

SELECT 
    CASE 
        WHEN Product LIKE '%Footwear%' THEN 'Footwear'
        WHEN Product LIKE '%Apparel%' THEN 'Apparel'
        ELSE 'Other'
    END AS Product_Category,
    SUM(CAST(Units_Sold AS INT)) AS Total_Units_Sold, 
    SUM(CAST(Total_Sales AS DECIMAL(18,2))) AS Total_Sales, 
    AVG(CAST(REPLACE(Operating_Margin, '%', '') AS DECIMAL(18,2))/100) AS Average_Operating_Margin
FROM 
    [Adidas_sales].[dbo].[Adidas US Sales Datasets]
GROUP BY 
    CASE 
        WHEN Product LIKE '%Footwear%' THEN 'Footwear'
        WHEN Product LIKE '%Apparel%' THEN 'Apparel'
        ELSE 'Other'
END
ORDER BY 
    Total_Sales DESC;

-- Use Case 3: Monthly Sales and Profit Trends
-- This query aggregates sales and profit data by month and year.

SELECT 
    d.Year,
    d.Month,
    SUM(CAST(a.Units_Sold AS INT)) AS Total_Units_Sold, 
    SUM(CAST(a.Total_Sales AS DECIMAL(18,2))) AS Total_Sales, 
    SUM(CAST(a.Operating_Profit AS DECIMAL(18,2))) AS Total_Operating_Profit
FROM 
    [Adidas_sales].[dbo].[Adidas US Sales Datasets] a
JOIN 
    (SELECT DISTINCT 
        DATEPART(YEAR, Invoice_Date) AS Year, 
        DATEPART(MONTH, Invoice_Date) AS Month, 
        Invoice_Date
    FROM 
        [Adidas_sales].[dbo].[Adidas US Sales Datasets]) d
ON a.Invoice_Date = d.Invoice_Date
GROUP BY 
    d.Year, 
    d.Month
ORDER BY 
    d.Year, 
    d.Month;

-- Use Case 4: Impact of Discounts and Promotions on Sales
-- This query compares sales data for different sales methods.

SELECT 
    Sales_Method, 
    SUM(CAST(Units_Sold AS INT)) AS Total_Units_Sold, 
    SUM(CAST(Total_Sales AS DECIMAL(18,2))) AS Total_Sales, 
    AVG(CAST(REPLACE(Operating_Margin, '%', '') AS DECIMAL(18,2))/100) AS Average_Operating_Margin,
    COUNT(DISTINCT Invoice_Date) AS Days_Sold,
    (SUM(CAST(Units_Sold AS INT)) / COUNT(DISTINCT Invoice_Date)) AS Average_Daily_Sales
FROM 
    [Adidas_sales].[dbo].[Adidas US Sales Datasets]
GROUP BY 
    Sales_Method
ORDER BY 
    Total_Sales DESC;

-- Use Case 5: Inventory Management and Stock Optimization
-- This query calculates inventory optimization metrics for each product.

WITH ProductSales AS (
    SELECT 
        Product, 
        SUM(CAST(Units_Sold AS INT)) AS Total_Units_Sold, 
        SUM(CAST(Total_Sales AS DECIMAL(18,2))) AS Total_Sales, 
        AVG(CAST(REPLACE(Operating_Margin, '%', '') AS DECIMAL(18,2))/100) AS Average_Operating_Margin,
        COUNT(DISTINCT Invoice_Date) AS Days_Sold,
        (SUM(CAST(Units_Sold AS INT)) / COUNT(DISTINCT Invoice_Date)) AS Average_Daily_Sales
    FROM 
        [Adidas_sales].[dbo].[Adidas US Sales Datasets]
    GROUP BY 
        Product
),
ReorderPoints AS (
    SELECT 
        Product,
        Total_Units_Sold,
        Total_Sales,
        Average_Operating_Margin,
        Days_Sold,
        Average_Daily_Sales,
        (Average_Daily_Sales * 30) AS Safety_Stock,
        (Average_Daily_Sales * 15) AS Reorder_Point
    FROM 
        ProductSales
)
SELECT 
    Product,
    Total_Units_Sold,
    Total_Sales,
    Average_Operating_Margin,
    Days_Sold,
    Average_Daily_Sales,
    Safety_Stock,
    Reorder_Point
FROM 
    ReorderPoints
ORDER BY 
    Total_Sales DESC;
