# Swift Frontend Connection Guide

This guide provides information on how to connect your Swift frontend to the Go backend.

## Backend Server Information

- **Base URL**: `http://localhost:8080`
- **Response Format**: JSON
- **CORS**: Enabled for all origins

## API Endpoints

### 1. Health Check
```
GET /health
```

**Response:**
```json
{
  "success": true,
  "message": "Server is running",
  "data": {
    "status": "healthy",
    "timestamp": "2025-10-13T22:40:58Z",
    "version": "1.0.0"
  }
}
```

### 2. Get Users
```
GET /api/users
```

**Response:**
```json
{
  "success": true,
  "message": "Users retrieved successfully",
  "data": [
    {
      "id": 1,
      "name": "John Doe",
      "email": "john@example.com"
    },
    {
      "id": 2,
      "name": "Jane Smith",
      "email": "jane@example.com"
    }
  ]
}
```

### 3. Post Data
```
POST /api/data
Content-Type: application/json

{
  "key": "value"
}
```

**Response:**
```json
{
  "success": true,
  "message": "Data received successfully",
  "data": {
    "key": "value"
  }
}
```

## Swift Implementation Notes

When implementing the Swift frontend, consider:

1. **URLSession** for HTTP requests
2. **Codable** protocol for JSON decoding
3. **async/await** for modern Swift concurrency
4. **Error handling** for network failures

## Example Response Structure

All API responses follow this structure:

```json
{
  "success": boolean,
  "message": string,
  "data": object (optional)
}
```

## Testing the Connection

You can test the backend from command line:

```bash
# Start the backend server
cd .. && go run main.go

# In another terminal, test endpoints
curl http://localhost:8080/health
curl http://localhost:8080/api/users
curl -X POST http://localhost:8080/api/data -H "Content-Type: application/json" -d '{"test": "data"}'
```
