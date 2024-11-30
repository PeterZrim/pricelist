from django.contrib import admin
from .models import Category, Product, PriceHistory

# Register your models here.

@admin.register(Category)
class CategoryAdmin(admin.ModelAdmin):
    list_display = ['name', 'slug', 'parent']
    prepopulated_fields = {'slug': ('name',)}
    search_fields = ['name']
    list_filter = ['parent']


class PriceHistoryInline(admin.TabularInline):
    model = PriceHistory
    extra = 1


@admin.register(Product)
class ProductAdmin(admin.ModelAdmin):
    list_display = ['name', 'sku', 'category', 'price', 'stock', 'available', 'updated']
    list_filter = ['available', 'created', 'updated', 'category']
    list_editable = ['price', 'stock', 'available']
    prepopulated_fields = {'slug': ('name',)}
    search_fields = ['name', 'sku']
    inlines = [PriceHistoryInline]
    
    def save_model(self, request, obj, form, change):
        if change and 'price' in form.changed_data:
            # Create price history entry when price changes
            PriceHistory.objects.create(
                product=obj,
                price=obj.price,
                notes=f"Price updated by {request.user}"
            )
        super().save_model(request, obj, form, change)
