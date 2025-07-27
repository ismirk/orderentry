# Vite Environment Variables Issue

## Problem
The `VITE_API_URL` environment variable is not being properly loaded in the frontend application when deployed on Railway.

## Root Cause
Vite environment variables must be available at **build time**, not just runtime. When you set environment variables in Railway's runtime environment, they're not available during the Docker build process where Vite creates the static files.

## Solutions

### Solution 1: Set Build-time Environment Variables in Railway (Recommended)

1. Go to your Railway dashboard
2. Navigate to your frontend service
3. Go to the "Variables" tab
4. Add `VITE_API_URL` as a variable
5. Make sure it's set for the **build environment** (not just runtime)

### Solution 2: Use Railway's Build-time Variables

Railway allows you to set environment variables that are available during the build process:

```bash
# In Railway dashboard, add these variables:
VITE_API_URL=https://your-backend-url.railway.app
NODE_ENV=production
```

### Solution 3: Use Railway's Build Command with Environment Variables

You can also set environment variables in your Railway service configuration:

```json
{
  "build": {
    "builder": "DOCKERFILE",
    "dockerfilePath": "frontend/Dockerfile",
    "context": "frontend",
    "env": {
      "VITE_API_URL": "https://your-backend-url.railway.app"
    }
  }
}
```

## Current Implementation

The application now uses `import.meta.env.VITE_API_URL` which is the correct way to access Vite environment variables in the browser.

## Verification Steps

1. Check that `VITE_API_URL` is set in Railway's build environment
2. Redeploy the frontend service
3. Check the browser console for the debug log: `API_CONFIG.BASE_URL (DEBUG):`
4. Verify the API calls are using the correct URL

## Troubleshooting

If the environment variable is still not working:

1. **Check Railway Logs**: Look at the build logs to see if the environment variable is being passed
2. **Verify Variable Name**: Ensure it's exactly `VITE_API_URL` (case sensitive)
3. **Check Build Context**: Make sure the variable is available during the Docker build
4. **Test Locally**: Try building locally with the environment variable set

## Alternative Approach for Runtime Configuration

If you need runtime configuration, consider using a configuration endpoint:

1. Create an API endpoint that returns configuration
2. Load configuration at runtime from this endpoint
3. This allows changing configuration without rebuilding

Example:
```javascript
// Load config at runtime
const response = await fetch('/api/config');
const config = await response.json();
const apiUrl = config.apiUrl;
``` 