# apps/mesas/urls.py
from django.urls import path
from . import views

app_name = 'mesas'

urlpatterns = [
    # URLs CRUD normales
    path('lista/', views.MesaListView.as_view(), name='mesas_list'),
    path('add/', views.MesaCreateView.as_view(), name='mesas_create'),
    path('<int:pk>/edit/', views.MesaUpdateView.as_view(), name='mesas_edit'),
    path('<int:pk>/delete/', views.MesaDeleteView.as_view(), name='mesas_delete'),
    
    # URL especial para Mesas Estado (no aparece en sidebar)
    path('estados/', views.MesasEstadoView.as_view(), name='mesas_estados'),
]