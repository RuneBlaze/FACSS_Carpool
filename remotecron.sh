mkdir -p /var/lib/pgsql/backup
1 0 * * * pg_dump carpool > /var/lib/pgsql/backup/