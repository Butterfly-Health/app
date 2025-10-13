package main

import (
	"encoding/json"
	"fmt"
	"log"
	"net/http"
	"time"
)

// Response represents a generic API response
type Response struct {
	Success bool        `json:"success"`
	Message string      `json:"message"`
	Data    interface{} `json:"data,omitempty"`
}

// HealthResponse represents the health check response
type HealthResponse struct {
	Status    string    `json:"status"`
	Timestamp time.Time `json:"timestamp"`
	Version   string    `json:"version"`
}

// enableCORS adds CORS headers to allow Swift frontend connections
func enableCORS(w http.ResponseWriter) {
	w.Header().Set("Access-Control-Allow-Origin", "*")
	w.Header().Set("Access-Control-Allow-Methods", "GET, POST, PUT, DELETE, OPTIONS")
	w.Header().Set("Access-Control-Allow-Headers", "Content-Type, Authorization")
}

// corsMiddleware wraps handlers with CORS support
func corsMiddleware(next http.HandlerFunc) http.HandlerFunc {
	return func(w http.ResponseWriter, r *http.Request) {
		enableCORS(w)

		// Handle preflight requests
		if r.Method == "OPTIONS" {
			w.WriteHeader(http.StatusOK)
			return
		}

		next(w, r)
	}
}

// healthHandler handles health check requests
func healthHandler(w http.ResponseWriter, r *http.Request) {
	w.Header().Set("Content-Type", "application/json")

	health := HealthResponse{
		Status:    "healthy",
		Timestamp: time.Now(),
		Version:   "1.0.0",
	}

	response := Response{
		Success: true,
		Message: "Server is running",
		Data:    health,
	}

	json.NewEncoder(w).Encode(response)
}

// apiHandler handles general API requests
func apiHandler(w http.ResponseWriter, r *http.Request) {
	w.Header().Set("Content-Type", "application/json")

	response := Response{
		Success: true,
		Message: "API endpoint ready for Swift frontend",
		Data: map[string]string{
			"endpoint": r.URL.Path,
			"method":   r.Method,
		},
	}

	json.NewEncoder(w).Encode(response)
}

// getUsersHandler returns sample user data
func getUsersHandler(w http.ResponseWriter, r *http.Request) {
	w.Header().Set("Content-Type", "application/json")

	users := []map[string]interface{}{
		{"id": 1, "name": "John Doe", "email": "john@example.com"},
		{"id": 2, "name": "Jane Smith", "email": "jane@example.com"},
	}

	response := Response{
		Success: true,
		Message: "Users retrieved successfully",
		Data:    users,
	}

	json.NewEncoder(w).Encode(response)
}

// postDataHandler handles POST requests from Swift frontend
func postDataHandler(w http.ResponseWriter, r *http.Request) {
	w.Header().Set("Content-Type", "application/json")

	if r.Method != "POST" {
		http.Error(w, "Method not allowed", http.StatusMethodNotAllowed)
		return
	}

	var requestData map[string]interface{}
	if err := json.NewDecoder(r.Body).Decode(&requestData); err != nil {
		response := Response{
			Success: false,
			Message: "Invalid JSON payload",
		}
		w.WriteHeader(http.StatusBadRequest)
		json.NewEncoder(w).Encode(response)
		return
	}

	response := Response{
		Success: true,
		Message: "Data received successfully",
		Data:    requestData,
	}

	json.NewEncoder(w).Encode(response)
}

func main() {
	// Register routes with CORS middleware
	http.HandleFunc("/health", corsMiddleware(healthHandler))
	http.HandleFunc("/api", corsMiddleware(apiHandler))
	http.HandleFunc("/api/users", corsMiddleware(getUsersHandler))
	http.HandleFunc("/api/data", corsMiddleware(postDataHandler))

	port := "8080"
	fmt.Printf("🚀 Server starting on port %s\n", port)
	fmt.Printf("📱 Ready to connect with Swift frontend\n")
	fmt.Printf("🔗 Health check: http://localhost:%s/health\n", port)
	fmt.Printf("🔗 API endpoint: http://localhost:%s/api\n", port)
	fmt.Printf("🔗 Users endpoint: http://localhost:%s/api/users\n", port)
	fmt.Printf("🔗 Data endpoint: http://localhost:%s/api/data\n", port)

	log.Fatal(http.ListenAndServe(":"+port, nil))
}
