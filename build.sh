#!/usr/bin/env bash
# exit on error
set -e

echo "--- Starting Universal Build Process ---"

# 1. Dependency installation is now primarily handled by the platform (Render/Railway)
# via the requirements.txt at the root. We can skip manual pip if needed, but
# a quick check doesn't hurt.
if command -v pip3 &> /dev/null; then
    echo "Ensuring additional dependencies from backend/requirements.txt are installed..."
    pip3 install -r backend/requirements.txt
elif command -v pip &> /dev/null; then
    pip install -r backend/requirements.txt
fi

# 2. Enter the backend directory to run Django commands
echo "Entering backend directory..."
cd backend

# 3. Collect static files
echo "Collecting static files..."
python3 manage.py collectstatic --no-input || python manage.py collectstatic --no-input

# 4. Apply database migrations
echo "Running database migrations..."
python3 manage.py migrate --no-input || python manage.py migrate --no-input

echo "--- Build completed successfully! ---"
