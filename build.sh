#!/usr/bin/env bash
# exit on error
set -o errexit

echo "--- Starting Universal Build Process ---"

# 1. Use 'python3 -m pip' to ensure compatibility (Railway defaults to python3)
echo "Installing Python dependencies..."
python3 -m pip install --upgrade pip
python3 -m pip install -r backend/requirements.txt

# 2. Enter the backend directory to run Django commands
cd backend

# 3. Collect static files (Required for serving CSS/JS in production)
echo "Collecting static files..."
python3 manage.py collectstatic --no-input

# 4. Apply database migrations
echo "Running database migrations..."
python3 manage.py migrate

echo "--- Build completed successfully! ---"
