# Gas Monitor Backend - Render Deployment Guide

## Prerequisites

1. **GitHub Repository**: Ensure your code is pushed to a GitHub repository
2. **Render Account**: Create a free account at [render.com](https://render.com)
3. **Database**: You can use either:
   - Render's managed PostgreSQL database (recommended for production)
   - Your existing Supabase database

## Deployment Steps

### Option 1: Deploy using render.yaml (Recommended)

1. **Connect GitHub Repository**:
   - Go to [Render Dashboard](https://dashboard.render.com)
   - Click "New" → "Blueprint"
   - Connect your GitHub repository
   - Render will automatically detect the `render.yaml` file

2. **Configure Environment Variables**:
   The following environment variables will be automatically set by the render.yaml:
   - `DEBUG=false`
   - `DJANGO_SETTINGS_MODULE=backend.settings`
   - `DATABASE_URL` (from managed database)
   - `SECRET_KEY` (auto-generated)
   - `RENDER_EXTERNAL_HOSTNAME` (auto-set)

3. **Deploy**:
   - Click "Apply" to start the deployment
   - Render will create both the web service and PostgreSQL database
   - Wait for the build process to complete (5-10 minutes)

### Option 2: Manual Web Service Creation

1. **Create Web Service**:
   - Go to Render Dashboard
   - Click "New" → "Web Service"
   - Connect your GitHub repository
   - Configure the following:
     - **Name**: `gas-monitor-backend`
     - **Environment**: `Python`
     - **Build Command**: `./build.sh`
     - **Start Command**: `cd backend && gunicorn backend.wsgi:application`
     - **Plan**: Free

2. **Environment Variables**:
   Add these environment variables in the Render dashboard:
   ```
   DEBUG=false
   DJANGO_SETTINGS_MODULE=backend.settings
   SECRET_KEY=<generate-a-secure-secret-key>
   DATABASE_URL=<your-database-connection-string>
   ```

3. **Database Setup**:
   - Create a PostgreSQL database in Render
   - Copy the DATABASE_URL to your web service environment variables

## Important Configuration Files

- **`render.yaml`**: Main deployment configuration
- **`build.sh`**: Build script that installs dependencies and runs migrations
- **`requirements.txt`**: Python dependencies (located in `/backend/`)
- **`runtime.txt`**: Python version specification
- **`Procfile`**: Process configuration for the web service

## Post-Deployment Steps

1. **Create Superuser**:
   ```bash
   # Access your deployed app's shell via Render dashboard
   python manage.py createsuperuser
   ```

2. **Test API Endpoints**:
   - Visit: `https://your-app-name.onrender.com/admin/`
   - Test API: `https://your-app-name.onrender.com/api/`

3. **Update Frontend Configuration**:
   Update your frontend to use the new backend URL:
   ```javascript
   const API_BASE_URL = 'https://your-app-name.onrender.com';
   ```

## ESP32 Integration

Your ESP32 device should send POST requests to:
```
https://your-app-name.onrender.com/gas-readings/create/
```

Include the authentication token in the headers:
```
Authorization: Token your-token-here
```

## Troubleshooting

### Common Issues:

1. **Build Failures**:
   - Check the build logs in Render dashboard
   - Ensure all dependencies are in `backend/requirements.txt`
   - Verify Python version in `runtime.txt`

2. **Database Connection Issues**:
   - Verify DATABASE_URL is correctly set
   - Check if database migrations ran successfully
   - Ensure PostgreSQL adapter (psycopg) is installed

3. **Static Files Issues**:
   - Verify WhiteNoise is properly configured
   - Check if `collectstatic` ran during build

4. **CORS Issues**:
   - Update `CORS_ALLOWED_ORIGINS` in settings.py
   - Add your frontend domain to allowed origins

### Logs and Debugging:

- View logs in Render dashboard under "Logs" tab
- Enable DEBUG temporarily by setting `DEBUG=true` (remember to disable after debugging)

## Security Considerations

- Never commit `.env` files to version control
- Use strong, unique SECRET_KEY for production
- Keep DEBUG=false in production
- Regularly update dependencies for security patches
- Use HTTPS for all API communications

## Scaling

- Render Free tier has limitations (750 hours/month)
- Consider upgrading to paid plans for production use
- Monitor resource usage in Render dashboard

## Support

For issues specific to this deployment:
1. Check Render documentation: https://render.com/docs
2. Review Django deployment best practices
3. Check the application logs for specific error messages
