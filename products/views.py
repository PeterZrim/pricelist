from django.shortcuts import render, redirect, get_object_or_404
from django.http import HttpResponse
from django.contrib.auth.decorators import login_required
from django.contrib.admin.views.decorators import staff_member_required
from django.contrib import messages
from .models import Category, Product
from .forms import ProductForm, CategoryForm
import qrcode
from io import BytesIO
from datetime import datetime

def product_list(request):
    # Get all categories and prefetch related products for better performance
    categories = Category.objects.prefetch_related('products').all()
    return render(request, 'products/product_list.html', {
        'categories': categories
    })

def category_detail(request, slug):
    category = get_object_or_404(Category.objects.prefetch_related('products'), slug=slug)
    return render(request, 'products/category_detail.html', {
        'category': category
    })

def product_detail(request, category_slug, product_slug):
    product = get_object_or_404(Product, category__slug=category_slug, slug=product_slug)
    return render(request, 'products/product_detail.html', {
        'product': product
    })

def generate_qr(request, download=False):
    # Get the current URL
    current_site = request.build_absolute_uri('/')[:-1]  # Remove trailing slash
    menu_url = f"{current_site}"
    
    # Create QR code instance
    qr = qrcode.QRCode(
        version=1,
        error_correction=qrcode.constants.ERROR_CORRECT_L,
        box_size=10,
        border=4,
    )
    
    # Add the data
    qr.add_data(menu_url)
    qr.make(fit=True)
    
    # Create the QR code image
    img = qr.make_image(fill_color="black", back_color="white")
    
    # Save it to a memory buffer
    buffer = BytesIO()
    img.save(buffer, format='PNG')
    buffer.seek(0)
    
    # If download is requested, set content disposition
    if download:
        current_date = datetime.now().strftime('%d-%m-%Y')
        filename = f"Carica QR cenik {current_date}.png"
        response = HttpResponse(buffer, content_type='image/png')
        response['Content-Disposition'] = f'attachment; filename="{filename}"'
        return response
    
    # Otherwise just display the image
    return HttpResponse(buffer, content_type='image/png')

@staff_member_required
def product_add(request):
    if request.method == 'POST':
        form = ProductForm(request.POST, request.FILES)
        if form.is_valid():
            form.save()
            messages.success(request, 'Izdelek uspešno dodan.')
            return redirect('products:product_list')
    else:
        form = ProductForm()
    return render(request, 'products/product_form.html', {'form': form, 'title': 'Dodaj izdelek'})

@staff_member_required
def product_edit(request, pk):
    product = get_object_or_404(Product, pk=pk)
    if request.method == 'POST':
        form = ProductForm(request.POST, request.FILES, instance=product)
        if form.is_valid():
            form.save()
            messages.success(request, 'Izdelek uspešno posodobljen.')
            return redirect('products:product_list')
    else:
        form = ProductForm(instance=product)
    return render(request, 'products/product_form.html', {'form': form, 'title': 'Uredi izdelek'})

@staff_member_required
def product_delete(request, pk):
    product = get_object_or_404(Product, pk=pk)
    if request.method == 'POST':
        product.delete()
        messages.success(request, 'Izdelek uspešno izbrisan.')
        return redirect('products:product_list')
    return render(request, 'products/product_confirm_delete.html', {'product': product})

@staff_member_required
def category_add(request):
    if request.method == 'POST':
        form = CategoryForm(request.POST)
        if form.is_valid():
            form.save()
            messages.success(request, 'Kategorija uspešno dodana.')
            return redirect('products:product_list')
    else:
        form = CategoryForm()
    return render(request, 'products/category_form.html', {'form': form, 'title': 'Dodaj kategorijo'})

@staff_member_required
def category_edit(request, pk):
    category = get_object_or_404(Category, pk=pk)
    if request.method == 'POST':
        form = CategoryForm(request.POST, instance=category)
        if form.is_valid():
            form.save()
            messages.success(request, 'Kategorija uspešno posodobljena.')
            return redirect('products:product_list')
    else:
        form = CategoryForm(instance=category)
    return render(request, 'products/category_form.html', {'form': form, 'title': 'Uredi kategorijo'})

@staff_member_required
def category_delete(request, pk):
    category = get_object_or_404(Category, pk=pk)
    if request.method == 'POST':
        category.delete()
        messages.success(request, 'Kategorija uspešno izbrisana.')
        return redirect('products:product_list')
    return render(request, 'products/category_confirm_delete.html', {'category': category})
