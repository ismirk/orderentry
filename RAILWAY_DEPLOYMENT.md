# Railway Deployment Guide: Backend + Frontend

This guide will help you deploy both your Go backend and Svelte frontend on Railway.

## Prerequisites

1. Railway account (https://railway.app)
2. GitHub repository with your code
3. Railway CLI (optional but recommended)

## Step 1: Set up Railway Project

### 1.1 Create Railway Project
1. Go to https://railway.app
2. Click "New Project"
3. Select "Deploy from GitHub repo"
4. Choose your repository

### 1.2 Add Services
You'll need to add three services to your Railway project:

1. **Backend Service** (Go API)
2. **Frontend Service** (Svelte App)
3. **Database Service** (PostgreSQL)

## Step 2: Configure Backend Service

### 2.1 Add Backend Service
1. In your Railway project, click "New Service"
2. Select "GitHub Repo"
3. Choose your repository
4. Set the root directory to `backend`
5. Railway will automatically detect the Dockerfile

### 2.2 Configure Environment Variables
Add these environment variables to your backend service:
```
DATABASE_URL=your_railway_database_connection_string
PORT=8080
```

### 2.3 Backend Configuration Files
Your backend should have:
- `backend/Dockerfile` - Container configuration
- `backend/railway.json` - Railway-specific settings
- `backend/go.mod` - Go dependencies

## Step 3: Configure Frontend Service

### 3.1 Add Frontend Service
1. In your Railway project, click "New Service"
2. Select "GitHub Repo"
3. Choose your repository
4. Set the root directory to `frontend`
5. Railway will use the Dockerfile for deployment

### 3.2 Configure Environment Variables
Add these environment variables to your frontend service:
```
VITE_API_URL=https://your-backend-service-url.railway.app
PORT=3000
NODE_ENV=production
```

**Important**: The `VITE_API_URL` should point to your Railway backend service URL.

### 3.3 Frontend Configuration Files
Your frontend should have:
- `frontend/Dockerfile` - Container configuration
- `frontend/railway.json` - Railway-specific settings
- `frontend/package.json` - Node.js dependencies

## Step 4: Configure Database Service

### 4.1 Add PostgreSQL Database
1. In your Railway project, click "New Service"
2. Select "Database" → "PostgreSQL"
3. Railway will create a managed PostgreSQL instance

### 4.2 Get Database Connection String
1. Click on your PostgreSQL service
2. Go to "Connect" tab
3. Copy the connection string
4. Add it to your backend service's `DATABASE_URL` environment variable

## Step 5: Set up CI/CD with GitHub Actions

### 5.1 Add GitHub Secrets
Go to your GitHub repository → Settings → Secrets and add:
```
RAILWAY_TOKEN=your_railway_token
```

### 5.2 Configure Workflow
The `.github/workflows/ci-cd.yml` file will:
- Test both backend and frontend
- Deploy backend to Railway
- Deploy frontend to Railway
- Deploy frontend to Vercel (optional)

## Step 6: Deploy and Test

### 6.1 Initial Deployment
1. Push your code to the main branch
2. Railway will automatically deploy both services
3. Check the deployment logs for any issues

### 6.2 Test Your Application
1. **Backend Health Check**: Visit `https://your-backend-url.railway.app/health`
2. **Frontend**: Visit `https://your-frontend-url.railway.app`
3. **API Test**: Test your API endpoints

## Step 7: Configure Custom Domains (Optional)

### 7.1 Add Custom Domain
1. In Railway, go to your service settings
2. Click "Custom Domains"
3. Add your domain and configure DNS

### 7.2 Update Environment Variables
Update your frontend's `VITE_API_URL` to use your custom domain.

## Railway vs Vercel Comparison

### Railway Advantages:
- **Unified Platform**: Backend, frontend, and database in one place
- **Easy Service Communication**: Services can communicate internally
- **Database Integration**: Managed PostgreSQL with easy connection
- **Cost Effective**: Often cheaper for full-stack applications
- **Docker Support**: Full containerization support

### Vercel Advantages:
- **Frontend Optimized**: Built specifically for frontend applications
- **Edge Network**: Global CDN with edge functions
- **Automatic Optimizations**: Image optimization, caching, etc.
- **Better Frontend Performance**: Optimized for static sites and SPAs

## Configuration Files

### Backend Railway Config (`backend/railway.json`)
```json
{
  "$schema": "https://railway.app/railway.schema.json",
  "build": {
    "builder": "DOCKERFILE",
    "dockerfilePath": "Dockerfile"
  },
  "deploy": {
    "startCommand": "./main",
    "healthcheckPath": "/health",
    "healthcheckTimeout": 300,
    "restartPolicyType": "ON_FAILURE",
    "restartPolicyMaxRetries": 10
  }
}
```

### Frontend Railway Config (`frontend/railway.json`)
```json
{
  "$schema": "https://railway.app/railway.schema.json",
  "build": {
    "builder": "DOCKERFILE",
    "dockerfilePath": "Dockerfile"
  },
  "deploy": {
    "healthcheckPath": "/",
    "healthcheckTimeout": 300,
    "restartPolicyType": "ON_FAILURE",
    "restartPolicyMaxRetries": 10
  }
}
```

## Environment Variables Setup

### Backend Environment Variables:
```
DATABASE_URL=postgresql://user:pass@host:port/db
PORT=8080
NODE_ENV=production
```

### Frontend Environment Variables:
```
VITE_API_URL=https://your-backend-url.railway.app
NODE_ENV=production
```

## Troubleshooting

### Common Issues:

1. **Build Failures**
   - Check Dockerfile syntax
   - Verify all dependencies are included
   - Check Railway build logs

2. **Service Communication**
   - Ensure environment variables are set correctly
   - Check that services are in the same Railway project
   - Verify API URLs are correct

3. **Database Connection**
   - Verify DATABASE_URL is correct
   - Check if database is accessible
   - Ensure database migrations are run

4. **Frontend Build Issues**
   - Check if all dependencies are in package.json
   - Verify build command works locally
   - Check for TypeScript errors

### Useful Commands:

```bash
# Install Railway CLI
npm install -g @railway/cli

# Login to Railway
railway login

# Link to project
railway link

# View logs
railway logs

# Connect to database
railway connect

# Deploy manually
railway up
```

## Monitoring and Maintenance

1. **Set up monitoring** in Railway dashboard
2. **Configure alerts** for service failures
3. **Monitor resource usage** and costs
4. **Set up automatic backups** for database
5. **Configure custom domains** and SSL

## Cost Optimization

1. **Use Railway's free tier** for development
2. **Scale services** based on actual usage
3. **Monitor resource usage** regularly
4. **Use appropriate instance sizes**
5. **Consider using Railway's usage-based pricing**

## Next Steps

1. Set up monitoring and alerting
2. Configure custom domains
3. Set up staging environments
4. Implement database backups
5. Add performance monitoring
6. Set up CI/CD for multiple environments 