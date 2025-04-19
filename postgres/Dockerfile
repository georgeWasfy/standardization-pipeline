FROM postgres:15-alpine

# Copy init SQL
COPY db_structure_postgresql.sql /docker-entrypoint-initdb.d/

# Copy dataset folder including import script + CSVs
COPY dataset /docker-entrypoint-initdb.d/dataset

# Copy custom entrypoint
COPY db-entrypoint.sh /usr/local/bin/db-entrypoint.sh

# Make scripts executable
RUN chmod +x /usr/local/bin/db-entrypoint.sh \
    && chmod +x /docker-entrypoint-initdb.d/dataset/import_postgresql.sh

# Use your custom entrypoint
ENTRYPOINT ["db-entrypoint.sh"]
