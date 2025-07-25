# Deployment Guide: Railway (Backend) + Vercel (Frontend) + CI/CD

This guide will help you deploy your Go backend to Railway and your Svelte frontend to either Railway or Vercel with automated CI/CD using GitHub Actions.

## Prerequisites

1. GitHub repository with your code
2. Railway account (https://railway.app)
3. Vercel account (https://vercel.com)
4. GitHub account

## Step 1: Set up Railway (Backend)

### 1.1 Create Railway Account
1. Go to https://railway.app
2. Sign up with your GitHub account
3. Create a new project

### 1.2 Deploy Backend to Railway
1. In Railway dashboard, click "New Project"
2. Select "Deploy from GitHub repo"
3. Choose your repository
4. Set the root directory to `backend`
5. Railway will automatically detect the Dockerfile and deploy

### 1.3 Configure Environment Variables
1. In your Railway project, go to "Variables" tab
2. Add your environment variables:
   ```
   DATABASE_URL=your_database_connection_string
   PORT=8080
   ```

### 1.4 Get Railway Token
1. Go to Railway dashboard → Account → Tokens
2. Create a new token
3. Copy the token (you'll need this for GitHub Actions)

## Step 2: Set up Frontend Deployment

### Option A: Deploy to Railway (Recommended for Full-Stack)

#### 2.1 Add Frontend Service to Railway
1. In your Railway project, click "New Service"
2. Select "GitHub Repo"
3. Choose your repository
4. Set the root directory to `frontend`
5. Railway will use the Dockerfile for deployment

#### 2.2 Configure Frontend Environment Variables
Add these environment variables to your frontend service:
```
VITE_API_URL=https://your-backend-service-url.railway.app
```

### Option B: Deploy to Vercel (Frontend-Optimized)

#### 2.1 Create Vercel Account
1. Go to https://vercel.com
2. Sign up with your GitHub account

#### 2.2 Deploy Frontend to Vercel
1. In Vercel dashboard, click "New Project"
2. Import your GitHub repository
3. Configure the project:
   - Framework Preset: Vite
   - Root Directory: `frontend`
   - Build Command: `npm run build`
   - Output Directory: `dist`
4. Deploy the project

### 2.3 Configure Environment Variables
1. In your Vercel project, go to "Settings" → "Environment Variables"
2. Add:
   ```
   VITE_API_URL=https://your-railway-backend-url.railway.app
   ```

### 2.4 Get Vercel Project Details
1. Go to your Vercel project settings
2. Note down:
   - Project ID
   - Organization ID
3. Create a Vercel token:
   - Go to https://vercel.com/account/tokens
   - Create a new token

## Step 3: Set up GitHub Secrets

### 3.1 Add Railway Token
1. Go to your GitHub repository
2. Settings → Secrets and variables → Actions
3. Add new repository secret:
   - Name: `RAILWAY_TOKEN`
   - Value: Your Railway token

### 3.2 Add Vercel Tokens
1. Add these secrets:
   - Name: `VERCEL_TOKEN`
   - Value: Your Vercel token
   
   - Name: `VERCEL_ORG_ID`
   - Value: Your Vercel organization ID
   
   - Name: `VERCEL_PROJECT_ID`
   - Value: Your Vercel project ID

## Step 4: Configure CI/CD

### 4.1 Push Configuration Files
The following files should be in your repository:
- `.github/workflows/ci-cd.yml` (GitHub Actions workflow)
- `backend/railway.json` (Railway configuration)
- `frontend/vercel.json` (Vercel configuration)

### 4.2 Test the Pipeline
1. Push your code to the main branch
2. Check GitHub Actions tab to see the pipeline running
3. Verify deployments on Railway and Vercel

## Step 5: Update Frontend API Configuration

### 5.1 Update API Base URL
In your frontend code, make sure you're using the environment variable for the API URL:

```javascript
// In your API service files
const API_BASE_URL = import.meta.env.VITE_API_URL || 'http://localhost:8080';
```

## Step 6: Database Setup (if needed)

### 6.1 Add Database to Railway
1. In Railway project, click "New"
2. Add a PostgreSQL database
3. Copy the connection string to your environment variables

### 6.2 Run Database Migrations
1. Add your database migration scripts to the deployment
2. Update the Dockerfile to run migrations on startup if needed

## Troubleshooting

### Common Issues:

1. **Build Failures**
   - Check GitHub Actions logs
   - Verify all dependencies are properly specified

2. **Environment Variables**
   - Ensure all required env vars are set in Railway and Vercel
   - Check that frontend can access backend URL

3. **CORS Issues**
   - Add CORS headers to your Go backend
   - Configure allowed origins in your backend

4. **Database Connection**
   - Verify DATABASE_URL is correctly set
   - Check database is accessible from Railway

### Useful Commands:

```bash
# Test backend locally
cd backend
go run ./cmd/api

# Test frontend locally
cd frontend
npm run dev

# Check Railway logs
railway logs

# Check Vercel logs
vercel logs
```

## Monitoring and Maintenance

1. **Set up monitoring** in Railway and Vercel dashboards
2. **Configure alerts** for deployment failures
3. **Set up custom domains** if needed
4. **Monitor performance** using built-in analytics

## Security Best Practices

1. Never commit secrets to your repository
2. Use environment variables for all sensitive data
3. Regularly rotate your deployment tokens
4. Enable branch protection rules in GitHub
5. Set up automated security scanning

## Next Steps

1. Set up custom domains
2. Configure SSL certificates
3. Set up monitoring and alerting
4. Implement staging environments
5. Add performance monitoring 