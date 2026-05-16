# Dockerfile — Artifact-based build
#
# CRITICAL RULE FOR THIS ASSIGNMENT:
# This Dockerfile does NOT run pip install against the repo source tree.
# It expects a pre-built artifact (app.tar.gz) to be present in the build context.
# The artifact already contains: source code + staticfiles + frozen dependencies.
#
# The dev pipeline produces the artifact, commits it to the repo,
# then runs: docker build --build-arg ARTIFACT=app-<sha>.tar.gz .
# The test pipeline does the same but builds a fresh artifact inline.

FROM python:3.11-slim

# Prevent Python from writing .pyc files and buffer stdout
ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1

WORKDIR /app

# Install system dependencies needed by psycopg2
RUN apt-get update \
    && apt-get install -y --no-install-recommends gcc libpq-dev \
    && rm -rf /var/lib/apt/lists/*

# ARG lets the pipeline pass in the artifact filename at build time.
ARG ARTIFACT=app.tar.gz

# Copy the artifact into the image — this is the ONLY copy step for app code.
COPY ${ARTIFACT} /tmp/app.tar.gz

# Extract the artifact. After this, /app contains everything the app needs.
RUN tar -xzf /tmp/app.tar.gz -C /app --strip-components=1 \
    && rm /tmp/app.tar.gz

# Install Python dependencies from the frozen requirements.txt inside the artifact.
RUN pip install --upgrade pip \
    && pip install --no-cache-dir -r requirements.txt

# Expose port 8000 (Django/gunicorn listens here inside the container)
EXPOSE 8000

# Start gunicorn — production web server for Django
CMD ["gunicorn", "book_shop.wsgi:application", "--bind", "0.0.0.0:8000", "--workers", "2"]
