#!/bin/bash

echo "🚀 Setting up deployment configuration..."
echo ""

# Check if we're in the right directory
if [ ! -d "backend" ] || [ ! -d "frontend" ]; then
    echo "❌ Error: Please run this script from the project root directory"
    exit 1
fi

echo "✅ Project structure verified"
echo ""

# Check if GitHub Actions workflow exists
if [ ! -f ".github/workflows/ci-cd.yml" ]; then
    echo "❌ Error: GitHub Actions workflow not found. Please ensure .github/workflows/ci-cd.yml exists"
    exit 1
fi

echo "✅ GitHub Actions workflow found"
echo ""

# Check if Railway config exists
if [ ! -f "backend/railway.json" ]; then
    echo "❌ Error: Railway configuration not found. Please ensure backend/railway.json exists"
    exit 1
fi

echo "✅ Railway configuration found"
echo ""

# Check if Vercel config exists
if [ ! -f "frontend/vercel.json" ]; then
    echo "❌ Error: Vercel configuration not found. Please ensure frontend/vercel.json exists"
    exit 1
fi

echo "✅ Vercel configuration found"
echo ""

echo "📋 Next steps:"
echo ""
echo "1. Push your code to GitHub:"
echo "   git add ."
echo "   git commit -m 'Add deployment configuration'"
echo "   git push origin main"
echo ""
echo "2. Set up Railway (Backend):"
echo "   - Go to https://railway.app"
echo "   - Create new project from GitHub repo"
echo "   - Set root directory to 'backend'"
echo "   - Add environment variables (DATABASE_URL, PORT)"
echo "   - Get Railway token from Account → Tokens"
echo ""
echo "3. Set up Vercel (Frontend):"
echo "   - Go to https://vercel.com"
echo "   - Import your GitHub repository"
echo "   - Set root directory to 'frontend'"
echo "   - Configure build settings"
echo "   - Get Project ID, Org ID, and create token"
echo ""
echo "4. Add GitHub Secrets:"
echo "   - Go to your GitHub repo → Settings → Secrets"
echo "   - Add RAILWAY_TOKEN"
echo "   - Add VERCEL_TOKEN"
echo "   - Add VERCEL_ORG_ID"
echo "   - Add VERCEL_PROJECT_ID"
echo ""
echo "5. Test the deployment:"
echo "   - Push to main branch"
echo "   - Check GitHub Actions tab"
echo "   - Verify deployments on Railway and Vercel"
echo ""
echo "📖 For detailed instructions, see DEPLOYMENT.md"
echo ""
echo "🎉 Setup complete! Follow the steps above to deploy your application." 