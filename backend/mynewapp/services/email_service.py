"""
Email service for sending notifications using Resend API
"""
import resend
from django.conf import settings
from django.template.loader import render_to_string
from django.utils.html import strip_tags
import logging

logger = logging.getLogger(__name__)

class EmailService:
    """Service for sending emails via Resend API"""
    
    def __init__(self):
        resend.api_key = settings.RESEND_API_KEY
    
    def send_gas_leak_alert_email(self, user, alert):
        """
        Send gas leak alert email to user
        
        Args:
            user: CustomUser instance
            alert: Alert instance with alert_type='GAS_LEAK'
        """
        try:
            # Email subject
            subject = f"🚨 URGENT: Gas Leak Detected - {alert.sensor.sensor_name}"
            
            # Email content
            html_content = self._generate_gas_leak_email_html(user, alert)
            text_content = self._generate_gas_leak_email_text(user, alert)
            
            # Send email via Resend
            params = {
                "from": settings.DEFAULT_FROM_EMAIL,
                "to": [user.email],
                "subject": subject,
                "html": html_content,
                "text": text_content,
            }
            
            response = resend.Emails.send(params)
            
            logger.info(f"Gas leak alert email sent successfully to {user.email}. Response: {response}")
            return True, response
            
        except Exception as e:
            logger.error(f"Failed to send gas leak alert email to {user.email}: {str(e)}")
            return False, str(e)
    
    def _generate_gas_leak_email_html(self, user, alert):
        """Generate HTML email content for gas leak alert"""
        severity_colors = {
            'LOW': '#FFA500',      # Orange
            'MEDIUM': '#FF6B35',   # Red-Orange  
            'HIGH': '#FF0000',     # Red
            'CRITICAL': '#8B0000'  # Dark Red
        }
        
        severity_color = severity_colors.get(alert.severity_level, '#FF0000')
        
        html_content = f"""
        <!DOCTYPE html>
        <html>
        <head>
            <meta charset="utf-8">
            <meta name="viewport" content="width=device-width, initial-scale=1.0">
            <title>Gas Leak Alert</title>
            <style>
                body {{ font-family: Arial, sans-serif; margin: 0; padding: 20px; background-color: #f5f5f5; }}
                .container {{ max-width: 600px; margin: 0 auto; background-color: white; border-radius: 8px; overflow: hidden; box-shadow: 0 4px 6px rgba(0,0,0,0.1); }}
                .header {{ background-color: {severity_color}; color: white; padding: 20px; text-align: center; }}
                .content {{ padding: 30px; }}
                .alert-box {{ background-color: #fff3cd; border: 1px solid #ffeaa7; border-radius: 4px; padding: 15px; margin: 20px 0; }}
                .severity-badge {{ display: inline-block; background-color: {severity_color}; color: white; padding: 5px 10px; border-radius: 4px; font-weight: bold; }}
                .details {{ background-color: #f8f9fa; padding: 15px; border-radius: 4px; margin: 15px 0; }}
                .footer {{ background-color: #f8f9fa; padding: 20px; text-align: center; color: #666; }}
                .urgent {{ color: {severity_color}; font-weight: bold; }}
            </style>
        </head>
        <body>
            <div class="container">
                <div class="header">
                    <h1>🚨 GAS LEAK DETECTED</h1>
                    <p>Immediate Action Required</p>
                </div>
                
                <div class="content">
                    <p>Dear {user.get_full_name()},</p>
                    
                    <div class="alert-box">
                        <p class="urgent">A gas leak has been detected by your monitoring system!</p>
                    </div>
                    
                    <div class="details">
                        <h3>Alert Details:</h3>
                        <p><strong>Sensor:</strong> {alert.sensor.sensor_name}</p>
                        <p><strong>Location:</strong> {alert.sensor.house.address_line_1}, {alert.sensor.house.city}</p>
                        <p><strong>Severity:</strong> <span class="severity-badge">{alert.severity_level}</span></p>
                        <p><strong>Time Detected:</strong> {alert.triggered_at.strftime('%Y-%m-%d %H:%M:%S UTC')}</p>
                        <p><strong>Message:</strong> {alert.alert_message}</p>
                    </div>
                    
                    <div class="alert-box">
                        <h3>⚠️ Immediate Safety Actions:</h3>
                        <ul>
                            <li><strong>Do not use electrical switches or create sparks</strong></li>
                            <li><strong>Ventilate the area immediately</strong></li>
                            <li><strong>Turn off the gas supply if safe to do so</strong></li>
                            <li><strong>Evacuate the premises if necessary</strong></li>
                            <li><strong>Contact emergency services if the leak is severe</strong></li>
                        </ul>
                    </div>
                    
                    <p>Please check your Gas Monitor dashboard for more details and to resolve this alert once the issue is addressed.</p>
                </div>
                
                <div class="footer">
                    <p>This is an automated alert from your Gas Monitor system.</p>
                    <p>For support, please contact our team.</p>
                </div>
            </div>
        </body>
        </html>
        """
        
        return html_content
    
    def _generate_gas_leak_email_text(self, user, alert):
        """Generate plain text email content for gas leak alert"""
        text_content = f"""
        🚨 GAS LEAK DETECTED - IMMEDIATE ACTION REQUIRED

        Dear {user.get_full_name()},

        A gas leak has been detected by your monitoring system!

        ALERT DETAILS:
        - Sensor: {alert.sensor.sensor_name}
        - Location: {alert.sensor.house.address_line_1}, {alert.sensor.house.city}
        - Severity: {alert.severity_level}
        - Time Detected: {alert.triggered_at.strftime('%Y-%m-%d %H:%M:%S UTC')}
        - Message: {alert.alert_message}

        ⚠️ IMMEDIATE SAFETY ACTIONS:
        - Do not use electrical switches or create sparks
        - Ventilate the area immediately
        - Turn off the gas supply if safe to do so
        - Evacuate the premises if necessary
        - Contact emergency services if the leak is severe

        Please check your Gas Monitor dashboard for more details and to resolve this alert once the issue is addressed.

        This is an automated alert from your Gas Monitor system.
        For support, please contact our team.
        """
        
        return text_content.strip()


# Create a global instance
email_service = EmailService()
