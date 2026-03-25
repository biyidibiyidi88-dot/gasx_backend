from django.core.management.base import BaseCommand
from mynewapp.models import CookableFood

class Command(BaseCommand):
    help = 'Loads initial sample Cookable Foods into the database'

    def handle(self, *args, **kwargs):
        foods = [
            {"name": "Omelette & Bread", "gas_req": 0.02, "time": 8},
            {"name": "Fried Plantains (Dodo)", "gas_req": 0.04, "time": 15},
            {"name": "Puff-Puff (Bofloto)", "gas_req": 0.06, "time": 20},
            {"name": "Boiled Yam / Plantain", "gas_req": 0.08, "time": 25},
            {"name": "White Rice", "gas_req": 0.07, "time": 25},
            {"name": "Tomato Stew (Fresh)", "gas_req": 0.11, "time": 35},
            {"name": "Spaghetti Stir-fry", "gas_req": 0.05, "time": 15},
            {"name": "Eru & Waterfufu", "gas_req": 0.15, "time": 50},
            {"name": "Ndolé (Meat/Fish)", "gas_req": 0.21, "time": 70},
            {"name": "Achu Soup", "gas_req": 0.18, "time": 60},
            {"name": "Koki Corn", "gas_req": 0.27, "time": 90},
            {"name": "Poulet DG", "gas_req": 0.17, "time": 55},
            {"name": "Beans (Pre-soaked)", "gas_req": 0.21, "time": 70},
            {"name": "Cornchaff", "gas_req": 0.30, "time": 100},
            {"name": "Okra Soup", "gas_req": 0.09, "time": 30},
            {"name": "Fufu Corn (Mixing phase)", "gas_req": 0.12, "time": 40},
        ]

        self.stdout.write("Loading foods...")
        
        for f in foods:
            obj, created = CookableFood.objects.get_or_create(
                name=f["name"],
                defaults={
                    "estimated_gas_required": f["gas_req"],
                    "cooking_time_minutes": f["time"]
                }
            )
            if created:
                self.stdout.write(self.style.SUCCESS(f'Created {f["name"]}'))
            else:
                self.stdout.write(f'Already exists: {f["name"]}')
        
        self.stdout.write(self.style.SUCCESS("Finished loading foods."))
