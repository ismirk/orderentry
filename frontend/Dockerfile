# Use Node.js 18 Alpine for smaller image size
FROM node:18-alpine

# Set working directory
WORKDIR /app

# Copy package files
COPY package*.json ./

# Install all dependencies (including dev dependencies for build)
RUN npm ci

# Copy source code
COPY . .

# Build the application
RUN npm run build

# Install serve to run the built app
RUN npm install -g serve

# Expose port
EXPOSE 3000

# Start the application
CMD ["serve", "-s", "dist", "-l", "3000"] 