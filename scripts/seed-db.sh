#!/bin/bash
set -e

echo "============================================================"
echo "🌱  seed-db.sh — Database seeder"
echo "============================================================"
echo ""
echo "Add SQL statements, psql commands, or Python seeding scripts"
echo "here. Make sure docker-compose services are running first:"
echo "  make docker-up"
echo ""
echo "Example:"
echo "  PGPASSWORD=\${POSTGRES_PASSWORD:-password} psql \\"
echo "    -h localhost -U \${POSTGRES_USER:-devuser} \\"
echo "    -d \${POSTGRES_DB:-devdb} \\"
echo "    -f sql/schema.sql"
echo ""
echo "ℹ️   No seed data configured yet."
echo "============================================================"
