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

## Deployment

This project is configured for deployment with:
- **Backend**: Railway (Go API)
- **Frontend**: Vercel (Svelte application)
- **CI/CD**: GitHub Actions

### Quick Setup

1. Run the setup script:
   ```bash
   ./setup-deployment.sh
   ```

2. Follow the detailed deployment guide:
   ```bash
   # See DEPLOYMENT.md for complete instructions
   ```

### Environment Variables

**Backend (Railway):**
- `DATABASE_URL`: PostgreSQL connection string
- `PORT`: Server port (default: 8080)

**Frontend (Vercel):**
- `VITE_API_URL`: Backend API URL

### CI/CD Pipeline

The project includes automated CI/CD with GitHub Actions:
- Tests backend and frontend on every push
- Deploys to Railway and Vercel on main branch
- Automated testing and building 