# Data Model Project

This project is organized into two main directories:

## Project Structure

```
data_model1/
├── backend/          # Backend API and database
│   ├── cmd/         # Go API server
│   ├── internal/    # Go internal packages
│   ├── init-scripts/ # Database initialization scripts
│   ├── go.mod       # Go dependencies
│   ├── go.sum       # Go dependencies checksum
│   ├── Dockerfile   # Backend container
│   ├── docker-compose.yml # Backend services
│   ├── create_tables.sql # Database schema
│   └── BACKEND_API_DOC.md # API documentation
├── frontend/        # Frontend Svelte application
│   ├── src/         # Svelte source code
│   ├── public/      # Static assets
│   ├── package.json # Node.js dependencies
│   └── ...
├── order_details.csv # Sample data
├── order_table.csv  # Sample data
└── sample data model.xlsx # Data model specification
```

## Getting Started

### Backend
To run the backend services:
```bash
cd backend
docker-compose up -d
```

### Frontend
To run the frontend development server:
```bash
cd frontend
npm install
npm run dev
```

## Development

- Backend: Go API with PostgreSQL database
- Frontend: Svelte application with Vite
- Database: PostgreSQL with initialization scripts
- Containerization: Docker and Docker Compose 