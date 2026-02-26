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
    """
    Premium Animated-style Email (Converted for Gmail/Outlook Compatibility)
    """
    # Dynamic values
    full_name = user.get_full_name() or user.username
    sensor_name = alert.sensor.sensor_name
    location = f"{alert.sensor.house.address_line_1}, {alert.sensor.house.city}"
    time_str = alert.triggered_at.strftime('%B %d, %Y – %H:%M %p %Z')
    
    # Severity Color Logic
    severity_color = "#ef4444" # Default Red
    if alert.severity_level == 'CRITICAL':
        severity_color = "#991b1b" # Darker Red

    return f"""
    <!DOCTYPE html>
    <html lang="en">
    <head>
      <meta charset="UTF-8">
      <meta name="viewport" content="width=device-width, initial-scale=1.0">
    </head>
    <body style="margin: 0; padding: 24px 16px; font-family: 'Helvetica Neue', Helvetica, Arial, sans-serif; background-color: #f8f9fc; color: #1a1a2e;">
      
      <div style="max-width: 640px; margin: 0 auto; background-color: #ffffff; border-radius: 24px; overflow: hidden; box-shadow: 0 20px 40px -12px rgba(239, 68, 68, 0.25); border: 1px solid rgba(239,68,68,0.1);">
        
        <div style="background: linear-gradient(135deg, #ef4444 0%, #991b1b 100%); background-color: #ef4444; color: #ffffff; padding: 60px 40px; text-align: center;">
          <h1 style="margin: 0; font-size: 36px; font-weight: 900; letter-spacing: -1.5px; text-transform: uppercase;">🚨 GAS LEAK ALERT</h1>
          <p style="margin: 16px 0 0; font-size: 20px; font-weight: 600; opacity: 0.9;">{alert.severity_level} – Evacuate & Act Now</p>
        </div>

        <div style="padding: 40px;">
          <h2 style="font-size: 24px; font-weight: 800; margin: 0 0 24px;">Dear {full_name},</h2>

          <div style="background-color: rgba(239,68,68,0.05); border: 1px solid rgba(239,68,68,0.2); border-radius: 16px; padding: 24px; margin-bottom: 32px;">
            <p style="color: #ef4444; font-size: 24px; font-weight: 900; margin: 0 0 12px;">Danger: Gas Leak Detected</p>
            <p style="margin: 0; font-size: 16px; color: #2d3748; line-height: 1.6;">
              Abnormal gas levels detected. This is an emergency situation — your safety is our top priority.
            </p>
          </div>

          <table role="presentation" width="100%" style="margin-bottom: 32px; border-collapse: collapse;">
            <tr>
              <td style="padding: 10px 0; color: #64748b; font-weight: 700; font-size: 14px; text-transform: uppercase; width: 100px;">Sensor</td>
              <td style="padding: 10px 0; font-weight: 600; font-size: 16px;">{sensor_name}</td>
            </tr>
            <tr>
              <td style="padding: 10px 0; color: #64748b; font-weight: 700; font-size: 14px; text-transform: uppercase;">Location</td>
              <td style="padding: 10px 0; font-weight: 600; font-size: 16px;">{location}</td>
            </tr>
            <tr>
              <td style="padding: 10px 0; color: #64748b; font-weight: 700; font-size: 14px; text-transform: uppercase;">Severity</td>
              <td style="padding: 10px 0;">
                <span style="background-color: #ef4444; color: #ffffff; padding: 6px 16px; border-radius: 20px; font-weight: 800; font-size: 14px;">{alert.severity_level}</span>
              </td>
            </tr>
            <tr>
              <td style="padding: 10px 0; color: #64748b; font-weight: 700; font-size: 14px; text-transform: uppercase;">Detected</td>
              <td style="padding: 10px 0; font-weight: 600; font-size: 16px;">{time_str}</td>
            </tr>
          </table>

          <div style="background-color: #fff1f2; border-left: 4px solid #ef4444; border-radius: 8px; padding: 24px; margin-bottom: 40px;">
            <p style="font-size: 20px; font-weight: 800; margin: 0 0 16px; color: #991b1b;">Immediate Safety Actions</p>
            <ul style="padding: 0; margin: 0; list-style-type: none;">
              <li style="margin-bottom: 12px; font-size: 16px;"><strong>⚠️ NO sparks:</strong> Do not use lights or phones</li>
              <li style="margin-bottom: 12px; font-size: 16px;"><strong>⚠️ Ventilate:</strong> Open all doors & windows</li>
              <li style="margin-bottom: 12px; font-size: 16px;"><strong>⚠️ Evacuate:</strong> Leave the building immediately</li>
            </ul>
          </div>

          <div style="text-align: center;">
            <a href="https://gas-monitor-frontend.vercel.app/" style="display: inline-block; background-color: #ef4444; color: #ffffff; padding: 18px 40px; border-radius: 12px; text-decoration: none; font-size: 18px; font-weight: 800; box-shadow: 0 10px 20px rgba(239,68,68,0.3);">Open Dashboard →</a>
          </div>

        </div>

        <div style="background-color: #f1f5f9; padding: 24px; text-align: center; font-size: 13px; color: #64748b;">
          Automated Emergency Notification • Support available 24/7
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
