# Pricelist Manager

A modern Django web application for managing and displaying product pricelists. Features include:

- Product categories and subcategories
- Product management with images and descriptions
- Price history tracking
- Easy-to-use admin interface
- Mobile-responsive design
- Export to PDF functionality

## Setup

1. Create a virtual environment:
```bash
python -m venv venv
source venv/bin/activate  # On Windows: venv\Scripts\activate
```

2. Install dependencies:
```bash
pip install -r requirements.txt
```

3. Set up environment variables:
Create a `.env` file in the project root with:
```
DJANGO_SECRET_KEY=your-secret-key
DJANGO_DEBUG=True
```

4. Run migrations:
```bash
python manage.py migrate
```

5. Create a superuser:
```bash
python manage.py createsuperuser
```

6. Run the development server:
```bash
python manage.py runserver
```

## Project Structure

```
pricelist/
├── manage.py
├── requirements.txt
├── .env
├── .gitignore
├── README.md
├── core/                   # Main Django project
│   ├── settings/
│   │   ├── base.py
│   │   ├── development.py
│   │   └── production.py
│   ├── urls.py
│   └── wsgi.py
└── products/              # Products app
    ├── models.py
    ├── views.py
    ├── urls.py
    ├── forms.py
    ├── admin.py
    └── templates/
```

## Features

- **Category Management**: Organize products into categories and subcategories
- **Product Management**: Add, edit, and delete products with images
- **Price History**: Track price changes over time
- **Search & Filter**: Find products quickly
- **Export**: Generate PDF pricelists
- **Responsive Design**: Works on desktop and mobile devices

## Development Guidelines

1. Follow PEP 8 style guide
2. Write tests for new features
3. Use meaningful commit messages
4. Document code changes
5. Keep dependencies updated
