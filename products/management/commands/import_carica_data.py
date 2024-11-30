import os
import sqlite3
import sys
from django.core.management.base import BaseCommand
from django.utils.text import slugify
from django.core.files import File
from products.models import Category, Product

class Command(BaseCommand):
    help = 'Import categories and products from carica-menu database'

    def handle(self, *args, **kwargs):
        # Set UTF-8 encoding for stdout
        if sys.stdout.encoding != 'utf-8':
            sys.stdout.reconfigure(encoding='utf-8')
            
        self.stdout.write('Starting import...')
        
        # Connect to carica-menu database
        carica_db_path = os.path.join(
            os.path.dirname(os.path.dirname(os.path.dirname(os.path.dirname(os.path.dirname(__file__))))),
            'carica-menu',
            'db.sqlite3'
        )
        
        if not os.path.exists(carica_db_path):
            self.stdout.write(self.style.ERROR(f'Database not found at: {carica_db_path}'))
            return

        conn = sqlite3.connect(carica_db_path)
        conn.text_factory = str  # Handle Unicode properly
        cursor = conn.cursor()
        
        # Import categories
        cursor.execute('SELECT id, name FROM menu_category')
        categories = cursor.fetchall()
        
        category_id_map = {}  # Map old IDs to new Category objects
        
        for cat_id, cat_name in categories:
            try:
                category, created = Category.objects.get_or_create(
                    name=cat_name,
                    defaults={
                        'slug': slugify(cat_name),
                        'description': '',
                    }
                )
                category_id_map[cat_id] = category
                
                if created:
                    self.stdout.write(f'Created category: {category.name}')
                else:
                    self.stdout.write(f'Category already exists: {category.name}')
            except Exception as e:
                self.stdout.write(f'Error creating category {cat_name}: {str(e)}')

        # Import menu items as products
        cursor.execute('''
            SELECT id, name, description, price, category_id, is_available, image 
            FROM menu_menuitem
        ''')
        menu_items = cursor.fetchall()
        
        for item_id, name, description, price, category_id, is_available, image in menu_items:
            if category_id in category_id_map:
                category = category_id_map[category_id]
                try:
                    product, created = Product.objects.get_or_create(
                        name=name,
                        defaults={
                            'category': category,
                            'slug': slugify(name),
                            'sku': f'SKU{item_id:06d}',
                            'description': description or '',
                            'price': price,
                            'available': bool(is_available),
                            'stock': 100 if is_available else 0,
                        }
                    )
                    
                    if created:
                        self.stdout.write(f'Created product: {product.name}')
                    else:
                        self.stdout.write(f'Product already exists: {product.name}')

                    if image:
                        image_path = os.path.join(
                            os.path.dirname(carica_db_path),
                            'media',
                            image
                        )
                        if os.path.exists(image_path):
                            try:
                                with open(image_path, 'rb') as source_image:
                                    product.image.save(
                                        os.path.basename(image),
                                        File(source_image),
                                        save=True
                                    )
                            except Exception as e:
                                self.stdout.write(f'Error copying image for {product.name}: {str(e)}')
                except Exception as e:
                    self.stdout.write(f'Error creating product {name}: {str(e)}')

        conn.close()
        self.stdout.write(self.style.SUCCESS('Import completed successfully!'))
