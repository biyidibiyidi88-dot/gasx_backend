#!/usr/bin/env bash
# exit on error
set -o errexit

# Install dependencies
pip install -r requirements.txt

# Collect static files
cd backend
python manage.py collectstatic --no-input

# Run migrations
python manage.py migrate
