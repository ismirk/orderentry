FROM golang:1.21-alpine

WORKDIR /app

# Copy go mod and sum files
COPY go.mod ./
COPY go.sum ./

# Download dependencies
RUN go mod download && go mod verify

# Copy source code
COPY . .

# Build the application
RUN go build -o main ./cmd/api

# Expose port
EXPOSE 8080

# Run the application
CMD ["./main"]