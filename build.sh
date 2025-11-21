#!/usr/bin/env bash
# exit on error
set -o errexit

# Install dependencies
pip install -r requirements.txt

# Collect static files
python manage.py collectstatic --no-input

# Run migrations
python manage.py migrate

# Create superuser if it doesn't exist
echo "from apps.accounts.models import AppUser; AppUser.objects.filter(username='admin').exists() or AppUser.objects.create_superuser('admin', 'admin@example.com', 'admin123')" | python manage.py shell
