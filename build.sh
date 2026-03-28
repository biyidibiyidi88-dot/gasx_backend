#!/usr/bin/env bash
# exit on error
set -o errexit

echo "--- Starting Universal Build Process ---"

# Function to find the best way to run pip
find_pip() {
    if command -v pip3 &> /dev/null; then
        echo "pip3"
    elif command -v pip &> /dev/null; then
        echo "pip"
    elif python3 -m pip --version &> /dev/null; then
        echo "python3 -m pip"
    elif python -m pip --version &> /dev/null; then
        echo "python -m pip"
    else
        echo "ERROR: Neither pip, pip3, nor 'python -m pip' was found." >&2
        return 1
    fi
}

PIP_CMD=$(find_pip)
echo "Using $PIP_CMD for dependency installation..."

# 1. Install dependencies
$PIP_CMD install --upgrade pip
$PIP_CMD install -r backend/requirements.txt

# 2. Enter the backend directory to run Django commands
cd backend

# 3. Collect static files
echo "Collecting static files..."
python3 manage.py collectstatic --no-input || python manage.py collectstatic --no-input

# 4. Apply database migrations
echo "Running database migrations..."
python3 manage.py migrate || python manage.py migrate

echo "--- Build completed successfully! ---"
