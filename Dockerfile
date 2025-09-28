# Use the official PostgreSQL image as the base image
FROM postgres:latest
RUN chmod 750 -R /var/lib/postgresql/data
CMD ["postgres"]
