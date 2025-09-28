# Use the official Postgres image
FROM postgres:16

# We'll use a small wrapper to fix perms before handing off to the official entrypoint
COPY docker-entrypoint-permfix.sh /usr/local/bin/docker-entrypoint-permfix.sh
RUN chmod +x /usr/local/bin/docker-entrypoint-permfix.sh

# Ensure we can chown (needs root). The official entrypoint will drop privileges later.
USER root

# Optional: set PGDATA explicitly (matches the official default)
ENV PGDATA=/var/lib/postgresql/data

# Pre-create directory (harmless if volume mounted later) and set a sane baseline
RUN mkdir -p "$PGDATA"

# Use our wrapper as the entrypoint
ENTRYPOINT ["/usr/local/bin/docker-entrypoint-permfix.sh"]

# Default command is still postgres
CMD ["postgres"]
