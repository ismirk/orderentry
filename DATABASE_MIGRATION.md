# Database Migration Guide: Docker → Railway

This guide will help you export your current database from the Docker container and import it into your Railway PostgreSQL instance.

## Prerequisites

1. Your Docker database container is running
2. You have a Railway account with a PostgreSQL database instance
3. You have the Railway CLI installed (optional but recommended)

## Step 1: Export Database from Docker

### Option A: Using the Automated Script

```bash
# Run the export script
./export-database.sh
```

### Option B: Manual Export

If you prefer to do it manually:

```bash
# 1. Create backup directory
mkdir -p database-backup

# 2. Export complete database (schema + data)
docker exec order_db pg_dump -U orderuser -d orderdb --clean --if-exists --create > database-backup/complete_backup.sql

# 3. Export only the schema
docker exec order_db pg_dump -U orderuser -d orderdb --schema-only > database-backup/schema_only.sql

# 4. Export only the data
docker exec order_db pg_dump -U orderuser -d orderdb --data-only --disable-triggers > database-backup/data_only.sql
```

## Step 2: Get Railway Database Connection Details

1. Go to your Railway project dashboard
2. Click on your PostgreSQL database service
3. Go to the "Connect" tab
4. Copy the connection string (looks like: `postgresql://user:pass@host:port/db`)
5. Note down the connection details for later use

## Step 3: Import Database to Railway

### Method A: Using Railway CLI (Recommended)

```bash
# 1. Install Railway CLI if you haven't
npm install -g @railway/cli

# 2. Login to Railway
railway login

# 3. Link to your project
railway link

# 4. Connect to your database
railway connect

# 5. Import the schema
psql < database-backup/railway_setup.sql

# 6. If you have data to import
psql < database-backup/data_only.sql
```

### Method B: Using pgAdmin or DBeaver

1. Open pgAdmin or DBeaver
2. Create a new connection using the Railway connection string
3. Connect to the database
4. Open the SQL editor
5. Run the contents of `database-backup/railway_setup.sql`
6. If you have data, also run `database-backup/data_only.sql`

### Method C: Using psql directly

```bash
# Import schema
psql "your-railway-connection-string" < database-backup/railway_setup.sql

# Import data (if any)
psql "your-railway-connection-string" < database-backup/data_only.sql
```

## Step 4: Update Environment Variables

1. In your Railway project, go to the "Variables" tab
2. Add or update the `DATABASE_URL` variable with your Railway connection string
3. Make sure your backend service is configured to use this environment variable

## Step 5: Test the Connection

### Test from Railway CLI

```bash
# Connect to your Railway database
railway connect

# Test the connection
psql -c "\dt"
```

### Test from your application

1. Deploy your backend to Railway
2. Check the logs to ensure the database connection is working
3. Test your API endpoints

## Troubleshooting

### Common Issues:

1. **Connection Refused**
   - Check if your Railway database is running
   - Verify the connection string is correct
   - Ensure your IP is not blocked

2. **Permission Denied**
   - Check if the database user has proper permissions
   - Verify the database name exists

3. **Schema Already Exists**
   - Use `CREATE TABLE IF NOT EXISTS` in your SQL
   - Or drop existing tables first

4. **Data Import Issues**
   - Check for foreign key constraints
   - Import data in the correct order
   - Use `--disable-triggers` flag for data-only imports

### Useful Commands:

```bash
# Check if tables exist
psql -c "\dt"

# Check table structure
psql -c "\d table_name"

# Check data in tables
psql -c "SELECT * FROM \"order\" LIMIT 5;"

# Reset database (if needed)
psql -c "DROP SCHEMA public CASCADE; CREATE SCHEMA public;"
```

## Verification Checklist

- [ ] Database schema is imported correctly
- [ ] All tables exist with proper structure
- [ ] Data is imported (if any)
- [ ] Foreign key relationships are intact
- [ ] Environment variables are set correctly
- [ ] Backend can connect to the database
- [ ] API endpoints work with the new database

## Next Steps

1. Update your frontend to use the new backend URL
2. Test all API endpoints
3. Monitor the application logs
4. Set up database backups in Railway
5. Configure monitoring and alerts

## Railway Database Management

### Backup Your Railway Database

```bash
# Export from Railway
railway connect
pg_dump -U your_user -d your_db > railway_backup.sql
```

### Monitor Database Usage

- Check Railway dashboard for database metrics
- Monitor connection count and query performance
- Set up alerts for high usage

### Scale Database (if needed)

- Railway allows easy scaling of PostgreSQL instances
- Upgrade to higher tiers for better performance
- Consider read replicas for high-traffic applications 