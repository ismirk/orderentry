-- Create order table
CREATE TABLE "order" (
    order_id SERIAL PRIMARY KEY,
    order_date DATE,
    description VARCHAR(50),
    customer_name VARCHAR(20),
    total NUMERIC
);

-- Create order_details table
CREATE TABLE order_details (
    order_id INTEGER,
    order_no INTEGER,
    product_item VARCHAR(50),
    unit_price NUMERIC,
    qty NUMERIC,
    subtotal NUMERIC,
    PRIMARY KEY (order_id, order_no),
    FOREIGN KEY (order_id) REFERENCES "order"(order_id)
); 