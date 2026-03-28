#!/usr/bin/env bash
# exit on error
set -o errexit

echo "Starting build process..."

# Install dependencies from backend directory
echo "Installing Python dependencies..."
pip install -r backend/requirements.txt

# Change to backend directory
cd backend

# Collect static files
echo "Collecting static files..."
python manage.py collectstatic --no-input

# Run migrations
echo "Running database migrations..."
python manage.py migrate

echo "Build completed successfully!"
#!/usr/bin/env bash
# exit on error
set -o errexit

echo "--- Starting Universal Build Process ---"

# 1. Use 'python -m pip' to ensure compatibility across all platforms
echo "Installing Python dependencies..."
python -m pip install --upgrade pip
python -m pip install -r backend/requirements.txt

# 2. Enter the backend directory to run Django commands
cd backend

# 3. Collect static files (Required for Render/Railway to serve CSS/JS)
echo "Collecting static files..."
python manage.py collectstatic --no-input

# 4. Apply database migrations
echo "Running database migrations..."
python manage.py migrate

echo "--- Build completed successfully! ---"