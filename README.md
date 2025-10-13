# app
This is the main app and backend in a monorepo.

## Project Structure

- `main.go` - Go backend server with REST API
- `swift-frontend/` - Swift frontend application (to be implemented)

## Go Backend

The Go backend provides a REST API for the Swift frontend to connect to.

### Prerequisites

- Go 1.24 or higher

### Running the Backend

```bash
# Run the server
go run main.go
```

The server will start on `http://localhost:8080`

### Available API Endpoints

- `GET /health` - Health check endpoint
- `GET /api` - General API information
- `GET /api/users` - Get sample user data
- `POST /api/data` - Post data to the server

All endpoints return JSON responses and support CORS for cross-platform communication.

### Example API Requests

**Health Check:**
```bash
curl http://localhost:8080/health
```

**Get Users:**
```bash
curl http://localhost:8080/api/users
```

**Post Data:**
```bash
curl -X POST http://localhost:8080/api/data \
  -H "Content-Type: application/json" \
  -d '{"key": "value"}'
```

## Swift Frontend

The Swift frontend will connect to the Go backend API. Implementation is in the `swift-frontend/` directory.

## Development

### Building the Backend

```bash
go build -o server main.go
./server
```

### Testing the Backend

```bash
go test ./...
```
