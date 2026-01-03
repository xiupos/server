#!/bin/sh
set -e

check_var() {
	var_name="$1"
	eval "var_value=\${$var_name}"
	if [ -z "$var_value" ]; then
		echo "Error: Environment variable '$var_name' is not set."
		echo "This script requires: PGHOST, PGUSER, PGPASSWORD, APP_DB_NAME, APP_DB_USER, APP_DB_PASS"
		exit 1
	fi
}

echo "Starting db-init..."
echo "Checking required environment variables..."

# CNPG Superuser
check_var "PGHOST"
check_var "PGUSER"
check_var "PGPASSWORD"

# App specific
check_var "APP_DB_NAME"
check_var "APP_DB_USER"
check_var "APP_DB_PASS"

echo "Target Database: $APP_DB_NAME"
echo "Target User:     $APP_DB_USER"
echo "Target Host:     $PGHOST"

until pg_isready -h "$PGHOST" -U "$PGUSER"; do
	echo "Waiting for postgres at $PGHOST..."
	sleep 2
done

# Check & Create User (Role)
USER_EXISTS=$(psql -h "$PGHOST" -U "$PGUSER" -d postgres -tAc "SELECT 1 FROM pg_roles WHERE rolname='$APP_DB_USER'")
if [ "$USER_EXISTS" = "1" ]; then
	echo "User '$APP_DB_USER' already exists. Skipping creation."
else
	echo "Creating user '$APP_DB_USER'..."
	psql -h "$PGHOST" -U "$PGUSER" -d postgres -c "CREATE USER \"$APP_DB_USER\" WITH ENCRYPTED PASSWORD '$APP_DB_PASS';"
fi

# Check & Create Database
DB_EXISTS=$(psql -h "$PGHOST" -U "$PGUSER" -d postgres -tAc "SELECT 1 FROM pg_database WHERE datname='$APP_DB_NAME'")
if [ "$DB_EXISTS" = "1" ]; then
	echo "Database '$APP_DB_NAME' already exists. Skipping creation."
else
	echo "Creating database '$APP_DB_NAME'..."
	psql -h "$PGHOST" -U "$PGUSER" -d postgres -c "CREATE DATABASE \"$APP_DB_NAME\" OWNER \"$APP_DB_USER\";"
fi

# Grant Privileges
echo "Granting schema privileges..."
export PG_URI="postgresql://$PGUSER:$PGPASSWORD@$PGHOST/$APP_DB_NAME"
psql "$PG_URI" -c "GRANT ALL ON SCHEMA public TO \"$APP_DB_USER\";"

echo "Initialization completed successfully!"
