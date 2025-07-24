package main

import (
	"log"
	"net/http"
	"os"

	"data_model1/internal/database"
	"data_model1/internal/handlers"
)

func main() {
	// Initialize database connection
	if err := database.InitDB(); err != nil {
		log.Fatalf("Failed to initialize database: %v", err)
	}
	defer database.DB.Close()

	// Set up routes
	http.HandleFunc("/health", func(w http.ResponseWriter, r *http.Request) {
		w.WriteHeader(http.StatusOK)
		w.Write([]byte("OK"))
	})
	http.HandleFunc("/api/test", handlers.TestEndpoint)
	http.HandleFunc("/api/orders/create/save", handlers.CreateOrder)
	http.HandleFunc("/api/orders/create/lookup_customer", handlers.LookupCustomer)
	http.HandleFunc("/api/orders/create/lookup_product", handlers.LookupProduct)

	// Get port from environment variable or use default
	port := os.Getenv("PORT")
	if port == "" {
		port = "8080"
	}

	// Start server
	log.Printf("Server starting on port %s", port)
	if err := http.ListenAndServe(":"+port, nil); err != nil {
		log.Fatalf("Failed to start server: %v", err)
	}
}
