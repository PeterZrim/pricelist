import os
import django

os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'pricelist.settings')
django.setup()

from django.utils.text import slugify
from products.models import Category, Product

def generate_unique_slug(instance, name, model_class):
    slug = slugify(name)
    unique_slug = slug
    counter = 1
    
    while model_class.objects.filter(slug=unique_slug).exclude(id=instance.id).exists():
        unique_slug = f"{slug}-{counter}"
        counter += 1
    
    return unique_slug

def update_slugs():
    print("Updating Category slugs...")
    for category in Category.objects.all():
        old_slug = category.slug
        new_slug = generate_unique_slug(category, category.name, Category)
        if old_slug != new_slug:
            category.slug = new_slug
            category.save()
            print(f"Updated category: {category.name} -> {new_slug}")
    
    print("\nUpdating Product slugs...")
    for product in Product.objects.all():
        old_slug = product.slug
        new_slug = generate_unique_slug(product, product.name, Product)
        if old_slug != new_slug:
            product.slug = new_slug
            product.save()
            print(f"Updated product: {product.name} -> {new_slug}")

if __name__ == '__main__':
    update_slugs()
    print("\nSlug generation completed!")
