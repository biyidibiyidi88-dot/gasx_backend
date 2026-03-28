#!/usr/bin/env bash
# exit on error
set -o errexit

echo "--- Starting Universal Build Process ---"

# 1. Use 'python -m pip' to ensure compatibility across all platforms (Render/Railway)
echo "Installing Python dependencies..."
python -m pip install --upgrade pip
python -m pip install -r backend/requirements.txt

# 2. Enter the backend directory to run Django commands
cd backend

# 3. Collect static files (Required for serving CSS/JS in production)
echo "Collecting static files..."
python manage.py collectstatic --no-input

# 4. Apply database migrations
echo "Running database migrations..."
python manage.py migrate

echo "--- Build completed successfully! ---"
