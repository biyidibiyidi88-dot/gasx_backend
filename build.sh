#!/usr/bin/env bash
# exit on error
set -e

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
        return 1
    fi
}

PIP_CMD=$(find_pip || true)

if [ -z "$PIP_CMD" ]; then
    echo "WARNING: Neither pip, pip3, nor 'python -m pip' was found."
    echo "Attempting to proceed without manual installation (relying on platform defaults)..."
else
    echo "Using $PIP_CMD for dependency installation..."
    $PIP_CMD install -r backend/requirements.txt
fi

# 2. Enter the backend directory to run Django commands
echo "Entering backend directory..."
cd backend

# 3. Collect static files
echo "Collecting static files..."
if command -v python3 &> /dev/null; then
    python3 manage.py collectstatic --no-input
elif command -v python &> /dev/null; then
    python manage.py collectstatic --no-input
else
    echo "ERROR: Neither python3 nor python found to run manage.py"
    exit 1
fi

# 4. Apply database migrations
echo "Running database migrations..."
if command -v python3 &> /dev/null; then
    python3 manage.py migrate --no-input
elif command -v python &> /dev/null; then
    python manage.py migrate --no-input
fi

echo "--- Build completed successfully! ---"
