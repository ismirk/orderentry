# Vite Configuration for Railway Deployment

This guide explains the changes made to `vite.config.ts` for Railway deployment.

## 🔧 Changes Made

### 1. Environment Variable Support
```typescript
// Get the API URL from environment or use default
const apiUrl = process.env.VITE_API_URL || 'http://localhost:8080';
const isProduction = process.env.NODE_ENV === 'production';
```

### 2. Dynamic Proxy Configuration
```typescript
server: {
  port: process.env.PORT ? parseInt(process.env.PORT) : 3000,
  proxy: {
    '/api': {
      target: apiUrl, // Now uses environment variable
      changeOrigin: true,
      secure: false,
      rewrite: (path) => path.replace(/^\/api/, '/api')
    }
  }
}
```

### 3. Production Preview Configuration
```typescript
preview: {
  port:  process.env.PORT ? parseInt(process.env.PORT) : 3000,
  host: '0.0.0.0' // Important for Railway
}
```

### 4. Build Optimization
```typescript
build: {
  outDir: 'dist',
  sourcemap: !isProduction,
  rollupOptions: {
    output: {
      manualChunks: undefined
    }
  }
}
```

## 🚀 How It Works

### Development Environment
- **Local Development**: Proxy forwards `/api` requests to `http://localhost:8080`
- **Environment Variable**: Can override with `VITE_API_URL=http://your-backend-url`

### Production Environment (Railway)
- **No Proxy**: Frontend is served as static files, no proxy needed
- **Direct API Calls**: Frontend makes direct HTTP requests to backend URL
- **Environment Variable**: `VITE_API_URL` set to Railway backend URL

## 📋 Environment Variables

### Railway Frontend Service
```
VITE_API_URL=https://your-backend-service-url.railway.app
PORT=3000
NODE_ENV=production
```

### Local Development
```bash
# Optional: Override API URL for local development
VITE_API_URL=http://localhost:8080 npm run dev
```

## 🔄 Migration from Development to Production

### Before (Development Only)
```typescript
proxy: {
  '/api': {
    target: 'http://localhost:8080', // Hardcoded
    changeOrigin: true,
    secure: false
  }
}
```

### After (Development + Production)
```typescript
proxy: {
  '/api': {
    target: apiUrl, // Dynamic from environment
    changeOrigin: true,
    secure: false,
    rewrite: (path) => path.replace(/^\/api/, '/api')
  }
}
```

## 🛠️ Key Benefits

1. **Environment Flexibility**: Works in both development and production
2. **Railway Compatibility**: Proper port and host configuration
3. **Build Optimization**: Production-optimized builds
4. **Environment Variables**: Secure configuration management
5. **Proxy Support**: Maintains development proxy functionality

## 🔍 Testing the Configuration

### Local Development
```bash
cd frontend
npm run dev
# API calls will be proxied to localhost:8080
```

### Production Build Test
```bash
cd frontend
npm run build
npm run preview
# API calls will use VITE_API_URL environment variable
```

### Railway Deployment
```bash
# Push to trigger Railway deployment
git push origin main
# Railway will use the production configuration
```

## ⚠️ Important Notes

1. **Proxy Only in Development**: The proxy only works during `npm run dev`
2. **Production Direct Calls**: In production, frontend makes direct HTTP requests
3. **CORS Configuration**: Backend must allow requests from frontend domain
4. **Environment Variables**: Must be set in Railway dashboard
5. **Build Process**: Railway builds the app and serves static files

## 🔧 Troubleshooting

### Common Issues:

1. **API Calls Failing in Production**
   - Check `VITE_API_URL` is set correctly in Railway
   - Verify backend CORS configuration
   - Check network tab for request URLs

2. **Build Failures**
   - Ensure all dependencies are in `package.json`
   - Check for TypeScript errors
   - Verify Node.js version compatibility

3. **Port Issues**
   - Railway sets `PORT` environment variable
   - Preview server listens on `0.0.0.0` for Railway

4. **Environment Variables Not Working**
   - Variables must start with `VITE_` to be available in client
   - Check Railway environment variable configuration
   - Verify variable names match exactly

## 📝 Next Steps

1. **Deploy to Railway**: Push your code to trigger deployment
2. **Set Environment Variables**: Configure `VITE_API_URL` in Railway
3. **Test API Communication**: Verify frontend can reach backend
4. **Monitor Logs**: Check Railway logs for any issues
5. **Optimize Performance**: Consider CDN and caching strategies 