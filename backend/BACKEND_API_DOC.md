# Backend API Documentation

## 1. Create Order

- **Endpoint:** `/api/orders/create/save`
- **Method:** `POST`
- **Description:** Create a new order with order details.
- **Request Body (JSON):**
```json
{
  "order_date": "2025-06-11",
  "description": "Order description",
  "customer_code": "C001",
  "details": [
    {
      "order_no": 1,
      "product_item": "Product A",
      "unit_price": 10.5,
      "qty": 2
    },
    {
      "order_no": 2,
      "product_item": "Product B",
      "unit_price": 5.0,
      "qty": 1
    }
  ]
}
```
- **Response (201 Created):**
```json
{
  "order_id": 1,
  "order_date": "2025-06-11T00:00:00Z",
  "description": "Order description",
  "customer_code": "C001",
  "total": 26.0,
  "details": [
    {
      "order_id": 1,
      "order_no": 1,
      "product_item": "Product A",
      "unit_price": 10.5,
      "qty": 2,
      "subtotal": 21.0
    },
    {
      "order_id": 1,
      "order_no": 2,
      "product_item": "Product B",
      "unit_price": 5.0,
      "qty": 1,
      "subtotal": 5.0
    }
  ]
}
```

---

## 2. Lookup Customer

- **Endpoint:** `/api/orders/create/lookup_customer`
- **Method:** `GET`
- **Description:** Lookup customers with pagination and optional name prefix filter.
- **Query Parameters:**
  - `page` (integer, required): Page number (starting from 1)
  - `customer_name` (string, optional): Filter by customer name prefix (case-insensitive)

- **Example Request:**
  `/api/orders/create/lookup_customer?page=1&customer_name=John`

- **Response (200 OK):**
```json
{
  "num_rows": 1,
  "data": [
    {
      "customer_code": "C001",
      "customer_name": "John Doe"
    }
  ],
  "total_pages": 1,
  "is_empty": false
}
```

---

## 3. Lookup Product

- **Endpoint:** `/api/orders/create/lookup_product`
- **Method:** `GET`
- **Description:** Lookup products with pagination and optional name prefix filter.
- **Query Parameters:**
  - `page` (integer, required): Page number (starting from 1)
  - `product_name` (string, optional): Filter by product name prefix (case-insensitive)

- **Example Request:**
  `/api/orders/create/lookup_product?page=1&product_name=Laptop`

- **Response (200 OK):**
```json
{
  "num_rows": 1,
  "data": [
    {
      "product_code": "P001",
      "product_name": "Laptop Pro",
      "product_price": 999.99
    }
  ],
  "total_pages": 1,
  "is_empty": false
}
```

---

## 4. Test Endpoint

- **Endpoint:** `/api/test`
- **Method:** `GET`
- **Description:** Simple test endpoint to verify API is running.
- **Response (200 OK):**
```json
{
  "message": "Test endpoint working"
}
``` 