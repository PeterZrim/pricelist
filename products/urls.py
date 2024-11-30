from django.urls import path
from django.contrib.auth.views import LogoutView
from . import views

app_name = 'products'

urlpatterns = [
    # Main views
    path('', views.product_list, name='product_list'),
    path('category/<slug:slug>/', views.category_detail, name='category_detail'),
    path('category/<slug:category_slug>/product/<slug:product_slug>/', views.product_detail, name='product_detail'),
    
    # QR code
    path('qr/', views.generate_qr, name='generate_qr'),
    path('qr/download/', views.generate_qr, {'download': True}, name='download_qr'),
    
    # Product CRUD
    path('product/add/', views.product_add, name='product_add'),
    path('product/<int:pk>/edit/', views.product_edit, name='product_edit'),
    path('product/<int:pk>/delete/', views.product_delete, name='product_delete'),
    
    # Category CRUD
    path('category/add/', views.category_add, name='category_add'),
    path('category/<int:pk>/edit/', views.category_edit, name='category_edit'),
    path('category/<int:pk>/delete/', views.category_delete, name='category_delete'),

    # Authentication
    path('logout/', LogoutView.as_view(next_page='/'), name='logout'),
]
