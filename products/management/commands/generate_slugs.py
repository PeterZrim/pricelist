from django.core.management.base import BaseCommand
from django.utils.text import slugify
from products.models import Category, Product

class Command(BaseCommand):
    help = 'Generate unique slugs for all categories and products'

    def generate_unique_slug(self, instance, name, model_class):
        slug = slugify(name)
        unique_slug = slug
        counter = 1
        
        while model_class.objects.filter(slug=unique_slug).exclude(id=instance.id).exists():
            unique_slug = f"{slug}-{counter}"
            counter += 1
        
        return unique_slug

    def handle(self, *args, **kwargs):
        self.stdout.write("Updating Category slugs...")
        for category in Category.objects.all():
            old_slug = category.slug
            new_slug = self.generate_unique_slug(category, category.name, Category)
            if old_slug != new_slug:
                category.slug = new_slug
                category.save()
                self.stdout.write(f"Updated category: {category.name} -> {new_slug}")
        
        self.stdout.write("\nUpdating Product slugs...")
        for product in Product.objects.all():
            old_slug = product.slug
            new_slug = self.generate_unique_slug(product, product.name, Product)
            if old_slug != new_slug:
                product.slug = new_slug
                product.save()
                self.stdout.write(f"Updated product: {product.name} -> {new_slug}")
        
        self.stdout.write(self.style.SUCCESS("\nSlug generation completed!"))
