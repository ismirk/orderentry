package handlers

import (
	"database/sql"
	"encoding/json"
	"fmt"
	"log"
	"net/http"

	"data_model1/internal/database"
	"data_model1/internal/models"
)

func TestEndpoint(w http.ResponseWriter, r *http.Request) {
	log.Printf("Test endpoint hit: %s %s", r.Method, r.URL.Path)
	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(map[string]string{"message": "Test endpoint working"})
}

func CreateOrder(w http.ResponseWriter, r *http.Request) {
	if r.Method != http.MethodPost {
		http.Error(w, "Method not allowed", http.StatusMethodNotAllowed)
		return
	}

	var order models.Order
	if err := json.NewDecoder(r.Body).Decode(&order); err != nil {
		log.Printf("Error decoding request body: %v", err)
		http.Error(w, fmt.Sprintf("Invalid request body: %v", err), http.StatusBadRequest)
		return
	}

	// Log the received order
	log.Printf("Received order: %+v", order)

	// Calculate subtotals and total
	order.CalculateTotal()

	// Start transaction
	tx, err := database.DB.Begin()
	if err != nil {
		log.Printf("Error starting transaction: %v", err)
		http.Error(w, fmt.Sprintf("Error starting transaction: %v", err), http.StatusInternalServerError)
		return
	}
	defer tx.Rollback() // Rollback if not committed

	// Insert order
	orderQuery := `
		INSERT INTO "order" (order_date, description, customer_code, total)
		VALUES ($1, $2, $3, $4)
		RETURNING order_id`

	log.Printf("Order query: %s", orderQuery)

	err = tx.QueryRow(
		orderQuery,
		order.OrderDate,
		order.Description,
		order.CustomerCode,
		order.Total,
	).Scan(&order.OrderID)

	if err != nil {
		log.Printf("Error creating order: %v", err)
		http.Error(w, fmt.Sprintf("Error creating order: %v", err), http.StatusInternalServerError)
		return
	}

	// Insert order details
	detailsQuery := `
		INSERT INTO order_details (order_id, order_no, product_code, product_name, unit_price, qty, subtotal)
		VALUES ($1, $2, $3, $4, $5, $6, $7)`

	for _, detail := range order.Details {
		detail.OrderID = order.OrderID // Set the order_id for each detail
		_, err = tx.Exec(
			detailsQuery,
			detail.OrderID,
			detail.OrderNo,
			detail.ProductCode,
			detail.ProductName,
			detail.UnitPrice,
			detail.Qty,
			detail.Subtotal,
		)
		if err != nil {
			log.Printf("Error creating order details: %v", err)
			http.Error(w, fmt.Sprintf("Error creating order details: %v", err), http.StatusInternalServerError)
			return
		}
	}

	// Commit transaction
	if err = tx.Commit(); err != nil {
		log.Printf("Error committing transaction: %v", err)
		http.Error(w, fmt.Sprintf("Error committing transaction: %v", err), http.StatusInternalServerError)
		return
	}

	w.Header().Set("Content-Type", "application/json")
	w.WriteHeader(http.StatusCreated)
	if err := json.NewEncoder(w).Encode(order); err != nil {
		log.Printf("Error encoding response: %v", err)
		http.Error(w, fmt.Sprintf("Error encoding response: %v", err), http.StatusInternalServerError)
		return
	}
}

func CreateOrderDetails(w http.ResponseWriter, r *http.Request) {
	if r.Method != http.MethodPost {
		http.Error(w, "Method not allowed", http.StatusMethodNotAllowed)
		return
	}

	var details models.OrderDetails
	if err := json.NewDecoder(r.Body).Decode(&details); err != nil {
		http.Error(w, "Invalid request body", http.StatusBadRequest)
		return
	}

	query := `
		INSERT INTO order_details (order_id, order_no, product_code, product_name, unit_price, qty)
		VALUES ($1, $2, $3, $4, $5, $6)`

	_, err := database.DB.Exec(
		query,
		details.OrderID,
		details.OrderNo,
		details.ProductCode,
		details.ProductName,
		details.UnitPrice,
		details.Qty,
	)

	if err != nil {
		http.Error(w, "Error creating order details", http.StatusInternalServerError)
		return
	}

	w.WriteHeader(http.StatusCreated)
}

func LookupCustomer(w http.ResponseWriter, r *http.Request) {
	const pageSize = 25

	// Parse query parameters
	page := 1
	if p := r.URL.Query().Get("page"); p != "" {
		fmt.Sscanf(p, "%d", &page)
		if page < 1 {
			page = 1
		}
	}
	customerName := r.URL.Query().Get("customer_name")

	// Build query
	var (
		rows        *sql.Rows
		err         error
		whereClause string
		args        []interface{}
	)
	if customerName != "" {
		whereClause = "WHERE customer_name ILIKE $1"
		args = append(args, customerName+"%")
	}

	offset := (page - 1) * pageSize
	query := fmt.Sprintf(`SELECT customer_code, customer_name FROM customer %s ORDER BY customer_code LIMIT %d OFFSET %d`, whereClause, pageSize, offset)
	rows, err = database.DB.Query(query, args...)
	if err != nil {
		http.Error(w, fmt.Sprintf("Error querying customer: %v", err), http.StatusInternalServerError)
		return
	}
	defer rows.Close()

	var customers []models.Customer
	for rows.Next() {
		var c models.Customer
		if err := rows.Scan(&c.CustomerCode, &c.CustomerName); err != nil {
			http.Error(w, fmt.Sprintf("Error scanning customer: %v", err), http.StatusInternalServerError)
			return
		}
		customers = append(customers, c)
	}

	// Get total count for pagination
	totalCount := 0
	countQuery := "SELECT COUNT(*) FROM customer"
	countArgs := []interface{}{}
	if customerName != "" {
		countQuery += " WHERE customer_name ILIKE $1"
		countArgs = append(countArgs, customerName+"%")
	}
	if err := database.DB.QueryRow(countQuery, countArgs...).Scan(&totalCount); err != nil {
		http.Error(w, fmt.Sprintf("Error counting customer: %v", err), http.StatusInternalServerError)
		return
	}

	totalPages := (totalCount + pageSize - 1) / pageSize

	result := map[string]interface{}{
		"num_rows":    len(customers),
		"data":        customers,
		"total_pages": totalPages,
		"is_empty":    len(customers) == 0,
	}
	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(result)
}

func LookupProduct(w http.ResponseWriter, r *http.Request) {
	const pageSize = 25

	// Parse query parameters
	page := 1
	if p := r.URL.Query().Get("page"); p != "" {
		fmt.Sscanf(p, "%d", &page)
		if page < 1 {
			page = 1
		}
	}
	productName := r.URL.Query().Get("product_name")

	// Build query
	var (
		rows        *sql.Rows
		err         error
		whereClause string
		args        []interface{}
	)
	if productName != "" {
		whereClause = "WHERE product_name ILIKE $1"
		args = append(args, productName+"%")
	}

	offset := (page - 1) * pageSize
	query := fmt.Sprintf(`SELECT product_code, product_name, product_price FROM product %s ORDER BY product_code LIMIT %d OFFSET %d`, whereClause, pageSize, offset)
	rows, err = database.DB.Query(query, args...)
	if err != nil {
		http.Error(w, fmt.Sprintf("Error querying product: %v", err), http.StatusInternalServerError)
		return
	}
	defer rows.Close()

	var products []models.Product
	for rows.Next() {
		var p models.Product
		if err := rows.Scan(&p.ProductCode, &p.ProductName, &p.ProductPrice); err != nil {
			http.Error(w, fmt.Sprintf("Error scanning product: %v", err), http.StatusInternalServerError)
			return
		}
		products = append(products, p)
	}

	// Get total count for pagination
	totalCount := 0
	countQuery := "SELECT COUNT(*) FROM product"
	countArgs := []interface{}{}
	if productName != "" {
		countQuery += " WHERE product_name ILIKE $1"
		countArgs = append(countArgs, productName+"%")
	}
	if err := database.DB.QueryRow(countQuery, countArgs...).Scan(&totalCount); err != nil {
		http.Error(w, fmt.Sprintf("Error counting product: %v", err), http.StatusInternalServerError)
		return
	}

	totalPages := (totalCount + pageSize - 1) / pageSize

	result := map[string]interface{}{
		"num_rows":    len(products),
		"data":        products,
		"total_pages": totalPages,
		"is_empty":    len(products) == 0,
	}
	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(result)
}
