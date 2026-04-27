CREATE DATABASE supply_chain_db;
USE supply_chain_db;
-- Products
CREATE TABLE products (
    product_id INT PRIMARY KEY,
    product_name VARCHAR(50),
    category VARCHAR(50)
);

-- Suppliers
CREATE TABLE suppliers (
    supplier_id INT PRIMARY KEY,
    supplier_name VARCHAR(50),
    city VARCHAR(50)
);

-- Orders
CREATE TABLE orders (
    order_id INT PRIMARY KEY,
    product_id INT,
    supplier_id INT,
    order_date DATE,
    delivery_date DATE,
    quantity INT,
    FOREIGN KEY (product_id) REFERENCES products(product_id),
    FOREIGN KEY (supplier_id) REFERENCES suppliers(supplier_id)
);

-- Inventory
CREATE TABLE inventory (
    product_id INT PRIMARY KEY,
    stock INT,
    reorder_level INT,
    FOREIGN KEY (product_id) REFERENCES products(product_id)
);
-- Products
INSERT INTO products VALUES
(1,'Laptop','Electronics'),
(2,'Phone','Electronics'),
(3,'Shoes','Fashion'),
(4,'Watch','Fashion');

-- Suppliers
INSERT INTO suppliers VALUES
(1,'ABC Traders','Delhi'),
(2,'XYZ Suppliers','Mumbai'),
(3,'Global Supply','Bangalore');

-- Orders
INSERT INTO orders VALUES
(1,1,1,'2024-01-01','2024-01-05',10),
(2,2,2,'2024-01-03','2024-01-10',15),
(3,3,3,'2024-01-05','2024-01-08',20),
(4,4,1,'2024-01-07','2024-01-15',12),
(5,1,2,'2024-02-01','2024-02-06',8);

-- Inventory
INSERT INTO inventory VALUES
(1,50,20),
(2,30,15),
(3,10,25),
(4,60,20);

INSERT INTO products (product_id, product_name, category)
SELECT 
    id,
    CONCAT('Product_', id),
    ELT(1 + FLOOR(RAND()*3), 'Electronics', 'Fashion', 'Accessories')
FROM (
    SELECT 5 as id UNION SELECT 6 UNION SELECT 7 UNION SELECT 8 UNION SELECT 9
    UNION SELECT 10 UNION SELECT 11 UNION SELECT 12 UNION SELECT 13 UNION SELECT 14
    UNION SELECT 15 UNION SELECT 16 UNION SELECT 17 UNION SELECT 18 UNION SELECT 19
) t;

INSERT INTO suppliers (supplier_id, supplier_name, city)
SELECT 
    id,
    CONCAT('Supplier_', id),
    ELT(1 + FLOOR(RAND()*5), 'Delhi', 'Mumbai', 'Bangalore', 'Chennai', 'Hyderabad')
FROM (
    SELECT 4 as id UNION SELECT 5 UNION SELECT 6 UNION SELECT 7 UNION SELECT 8
    UNION SELECT 9 UNION SELECT 10 UNION SELECT 11 UNION SELECT 12 UNION SELECT 13
) t;

INSERT INTO inventory (product_id, stock, reorder_level)
SELECT 
    product_id,
    FLOOR(10 + RAND()*100),
    FLOOR(10 + RAND()*50)
FROM products
WHERE product_id >= 5;

INSERT INTO orders (order_id, product_id, supplier_id, order_date, delivery_date, quantity)
SELECT 
    id,
    (SELECT product_id FROM products ORDER BY RAND() LIMIT 1),
    (SELECT supplier_id FROM suppliers ORDER BY RAND() LIMIT 1),
    DATE_ADD('2024-01-01', INTERVAL FLOOR(RAND()*120) DAY),
    DATE_ADD('2024-01-01', INTERVAL FLOOR(3 + RAND()*10) DAY),
    FLOOR(1 + RAND()*20)
FROM (
    SELECT 10 as id UNION SELECT 11 UNION SELECT 12 UNION SELECT 13 UNION SELECT 14
    UNION SELECT 15 UNION SELECT 16 UNION SELECT 17 UNION SELECT 18 UNION SELECT 19
    UNION SELECT 20 UNION SELECT 21 UNION SELECT 22 UNION SELECT 23 UNION SELECT 24
    UNION SELECT 25 UNION SELECT 26 UNION SELECT 27 UNION SELECT 28 UNION SELECT 29
    UNION SELECT 30 UNION SELECT 31 UNION SELECT 32 UNION SELECT 33 UNION SELECT 34
) t;

-- Total Orders per Product
SELECT 
    p.product_name,
    SUM(o.quantity) AS total_orders
FROM orders o
JOIN products p ON o.product_id = p.product_id
GROUP BY p.product_name;

-- Delivery Delay Analysis
SELECT 
    order_id,
    DATEDIFF(delivery_date, order_date) AS delivery_days
FROM orders;

-- Late Deliveries (>5 days)
SELECT 
    order_id,
    DATEDIFF(delivery_date, order_date) AS delay
FROM orders
WHERE DATEDIFF(delivery_date, order_date) > 5;

-- Supplier Performance
SELECT 
    s.supplier_name,
    AVG(DATEDIFF(o.delivery_date, o.order_date)) AS avg_delivery_time
FROM orders o
JOIN suppliers s ON o.supplier_id = s.supplier_id
GROUP BY s.supplier_name;

-- Low Stock Alert
SELECT 
    p.product_name,
    i.stock,
    i.reorder_level
FROM inventory i
JOIN products p ON i.product_id = p.product_id
WHERE i.stock < i.reorder_level;

-- Monthly Order Trend
SELECT 
    MONTH(order_date) AS month,
    SUM(quantity) AS total_quantity
FROM orders
GROUP BY MONTH(order_date)
ORDER BY month;

-- Top Products (Ranking)
SELECT 
    p.product_name,
    SUM(o.quantity) AS total_sales,
    RANK() OVER (ORDER BY SUM(o.quantity) DESC) AS rank_
FROM orders o
JOIN products p ON o.product_id = p.product_id
GROUP BY p.product_name;

SELECT 
    p.product_name,
    p.category,
    s.supplier_name,
    s.city,
    o.order_date,
    o.delivery_date,
    o.quantity,
    DATEDIFF(o.delivery_date, o.order_date) AS delivery_days,
    i.stock,
    i.reorder_level
FROM orders o
JOIN products p ON o.product_id = p.product_id
JOIN suppliers s ON o.supplier_id = s.supplier_id
JOIN inventory i ON p.product_id = i.product_id;