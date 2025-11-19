from django.urls import path
from . import views

app_name = 'api'

urlpatterns = [
    path('ordenes-pendientes/', views.OrdenDetalleListAPIView.as_view(), name='orden_detalle_list'),
    path('ultimas-ordenes/', views.UltimasOrdenesAPIView.as_view(), name='ultimas_ordenes'),
    path('ordenes/<int:pk>/', views.OrdenDetailAPIView.as_view(), name='orden_detail'),
]
