#!/bin/bash
# Daily backup script (the handout's example, pointed at this lab's folder)
DATE=$(date +%Y%m%d_%H%M%S)
BACKUP_DIR="backups"
DB_NAME="shop_db"
pg_dump -h localhost -U "$USER" -d $DB_NAME -Fc > "$BACKUP_DIR/${DB_NAME}_${DATE}.dump"
echo "Saved $BACKUP_DIR/${DB_NAME}_${DATE}.dump"
# Keep only the last 7 days of backups
find $BACKUP_DIR -name "${DB_NAME}_*.dump" -mtime +7 -delete
