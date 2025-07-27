# Railway Environment Variable Setup Guide

## The Issue
Railway doesn't have explicit "build-time" vs "runtime" options. All environment variables are available during both build and runtime. The issue is likely in how the variable is configured or named.

## Step-by-Step Solution

### Step 1: Verify Variable Name
Make sure your environment variable is named exactly `VITE_API_URL` (case sensitive).

### Step 2: Set Environment Variable in Railway

1. **Go to Railway Dashboard**
   - Navigate to your Railway project
   - Click on your **frontend service** (not backend)

2. **Add Environment Variable**
   - Click on the "Variables" tab
   - Click "New Variable"
   - Name: `VITE_API_URL`
   - Value: `https://your-backend-service-url.railway.app`
   - Click "Add"

3. **Get Your Backend URL**
   - Go to your backend service in Railway
   - Copy the URL (it looks like `https://your-backend-service.railway.app`)
   - Use this as the value for `VITE_API_URL`

### Step 3: Redeploy the Service

1. **Trigger a New Deployment**
   - Go to your frontend service
   - Click "Deploy" or "Redeploy"
   - This ensures the environment variable is available during the build

### Step 4: Verify the Setup

1. **Check Build Logs**
   - Go to your frontend service
   - Click on the latest deployment
   - Check the build logs for any errors

2. **Test in Browser**
   - Open your frontend URL
   - Open browser developer tools (F12)
   - Go to Console tab
   - Look for the debug log: `API_CONFIG.BASE_URL (DEBUG):`
   - It should show your backend URL, not an empty string

## Troubleshooting

### Problem 1: Variable Still Empty
**Solution**: Check if the variable is set correctly
```bash
# In Railway dashboard, verify:
VITE_API_URL=https://your-backend-service.railway.app
```

### Problem 2: Build Fails
**Solution**: Check build logs for errors
- Look for any TypeScript or build errors
- Ensure all dependencies are installed

### Problem 3: Variable Not Available in Browser
**Solution**: Verify the variable name starts with `VITE_`
- Only variables starting with `VITE_` are included in the client bundle
- Check for typos in the variable name

### Problem 4: Backend URL Not Working
**Solution**: Test the backend URL directly
1. Open your backend URL in a browser
2. Add `/health` to the end
3. You should see "OK" if the backend is working

## Alternative: Runtime Configuration

If you continue having issues, you can use a runtime configuration approach:

### Option A: Configuration Endpoint
Create a simple endpoint in your backend that returns configuration:

```go
// In your backend
http.HandleFunc("/api/config", func(w http.ResponseWriter, r *http.Request) {
    w.Header().Set("Content-Type", "application/json")
    w.Write([]byte(`{"apiUrl": "https://your-backend-url.railway.app"}`))
})
```

Then in your frontend:
```javascript
// Load config at runtime
const response = await fetch('/api/config');
const config = await response.json();
const apiUrl = config.apiUrl;
```

### Option B: Use Railway's Internal Service Communication
If both services are in the same Railway project, you can use internal URLs:

```javascript
// Use internal service name
const apiUrl = 'https://your-backend-service.internal.railway.app';
```

## Verification Checklist

- [ ] Environment variable is named `VITE_API_URL`
- [ ] Value is the correct backend URL
- [ ] Variable is set in the frontend service (not backend)
- [ ] Service has been redeployed after adding the variable
- [ ] Build logs show no errors
- [ ] Browser console shows the correct API URL
- [ ] API calls work properly

## Common Mistakes

1. **Setting variable in wrong service** - Make sure it's in the frontend service
2. **Wrong variable name** - Must be exactly `VITE_API_URL`
3. **Wrong backend URL** - Use the Railway-provided URL
4. **Not redeploying** - Changes require a new deployment
5. **CORS issues** - Backend must allow requests from frontend domain

## Testing Locally

To test the environment variable locally:

```bash
cd frontend
VITE_API_URL=https://your-backend-url.railway.app npm run dev
```

This should show the correct API URL in the browser console.

## Next Steps

After setting up the environment variable:

1. Test all API endpoints
2. Monitor application logs
3. Set up custom domains if needed
4. Configure monitoring and alerts 