from django.core.management.base import BaseCommand
from rest_framework.authtoken.models import Token
from mynewapp.models import CustomUser

class Command(BaseCommand):
    help = 'Create or get authentication token for ESP32 testing'

    def add_arguments(self, parser):
        parser.add_argument('--email', type=str, help='User email', default='tchouabiyidi@icloud.comm')

    def handle(self, *args, **options):
        email = options['email']
        
        try:
            # Get the user
            user = CustomUser.objects.get(email=email)
            
            # Create or get token
            token, created = Token.objects.get_or_create(user=user)
            
            if created:
                self.stdout.write(f"Created new token for {email}")
            else:
                self.stdout.write(f"Retrieved existing token for {email}")
            
            self.stdout.write(
                self.style.SUCCESS(
                    f'\n=== ESP32 Authentication Token ===\n'
                    f'User: {user.email}\n'
                    f'Token: {token.key}\n'
                    f'===================================\n'
                    f'\nUse this token in your ESP32 code:\n'
                    f'const char* authToken = "{token.key}";'
                )
            )

        except CustomUser.DoesNotExist:
            self.stdout.write(
                self.style.ERROR(f'User with email {email} does not exist')
            )
        except Exception as e:
            self.stdout.write(
                self.style.ERROR(f'Error creating token: {str(e)}')
            )
