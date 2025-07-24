#!/bin/bash

echo "🗄️  Database Export Script for Railway Migration"
echo "================================================"
echo ""

# Check if Docker is running
if ! docker info > /dev/null 2>&1; then
    echo "❌ Error: Docker is not running. Please start Docker first."
    exit 1
fi

# Check if the order_db container exists and is running
if ! docker ps | grep -q order_db; then
    echo "❌ Error: order_db container is not running."
    echo "Please start your database first:"
    echo "cd backend && docker-compose up -d postgres"
    exit 1
fi

echo "✅ Docker and order_db container are running"
echo ""

# Create backup directory
BACKUP_DIR="./database-backup"
mkdir -p "$BACKUP_DIR"

echo "📦 Exporting database from order_db container..."
echo ""

# Export the database schema and data
echo "1. Exporting database schema and data..."
docker exec order_db pg_dump -U orderuser -d orderdb --clean --if-exists --create > "$BACKUP_DIR/orderdb_backup.sql"

if [ $? -eq 0 ]; then
    echo "✅ Database export completed successfully!"
    echo "📁 Backup saved to: $BACKUP_DIR/orderdb_backup.sql"
else
    echo "❌ Database export failed!"
    exit 1
fi

echo ""

# Create a Railway-compatible version
echo "2. Creating Railway-compatible database file..."
cat > "$BACKUP_DIR/railway_setup.sql" << 'EOF'
-- Railway Database Setup Script
-- This script will create the database structure and import data

-- Create tables
CREATE TABLE IF NOT EXISTS "order" (
    order_id SERIAL PRIMARY KEY,
    order_date DATE,
    description VARCHAR(50),
    customer_name VARCHAR(20),
    total NUMERIC
);

CREATE TABLE IF NOT EXISTS order_details (
    order_id INTEGER,
    order_no INTEGER,
    product_item VARCHAR(50),
    unit_price NUMERIC,
    qty NUMERIC,
    subtotal NUMERIC,
    PRIMARY KEY (order_id, order_no),
    FOREIGN KEY (order_id) REFERENCES "order"(order_id)
);

-- Add any sample data if needed
-- INSERT INTO "order" (order_date, description, customer_name, total) VALUES (...);
-- INSERT INTO order_details (order_id, order_no, product_item, unit_price, qty, subtotal) VALUES (...);
EOF

echo "✅ Railway setup script created: $BACKUP_DIR/railway_setup.sql"
echo ""

# Create a data-only export for importing existing data
echo "3. Creating data-only export..."
docker exec order_db pg_dump -U orderuser -d orderdb --data-only --disable-triggers > "$BACKUP_DIR/data_only.sql"

if [ $? -eq 0 ]; then
    echo "✅ Data-only export completed: $BACKUP_DIR/data_only.sql"
else
    echo "⚠️  Data-only export failed (this is okay if you have no data yet)"
fi

echo ""
echo "📋 Next Steps for Railway Database Setup:"
echo ""
echo "1. Go to your Railway project dashboard"
echo "2. Click on your PostgreSQL database service"
echo "3. Go to the 'Connect' tab"
echo "4. Copy the connection string (it looks like: postgresql://user:pass@host:port/db)"
echo "5. Use one of these methods to import your data:"
echo ""
echo "   Method A - Using Railway CLI:"
echo "   railway login"
echo "   railway connect"
echo "   psql < $BACKUP_DIR/railway_setup.sql"
echo ""
echo "   Method B - Using pgAdmin or DBeaver:"
echo "   - Connect using the Railway connection string"
echo "   - Run the SQL from $BACKUP_DIR/railway_setup.sql"
echo ""
echo "   Method C - Using psql directly:"
echo "   psql 'your-railway-connection-string' < $BACKUP_DIR/railway_setup.sql"
echo ""
echo "6. Update your Railway environment variables:"
echo "   DATABASE_URL=your-railway-connection-string"
echo ""
echo "📁 Backup files created:"
echo "   - $BACKUP_DIR/orderdb_backup.sql (complete backup)"
echo "   - $BACKUP_DIR/railway_setup.sql (Railway setup script)"
echo "   - $BACKUP_DIR/data_only.sql (data only, if any)"
echo ""
echo "🎉 Database export completed successfully!" 