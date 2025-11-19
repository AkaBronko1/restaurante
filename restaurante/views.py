from django.shortcuts import render
from django.contrib.auth.decorators import login_required
from django.db.models import Sum, Count
from apps.ordenes.models import Orden
from datetime import datetime
from django.db import models
from datetime import timedelta

def main_index(request):
    return render(request, 'main/index.html')

@login_required(login_url='accounts:login')
def index_user(request):
    # Órdenes pagadas de hoy
    ordenes_hoy = Orden.objects.filter(estatus='pagada', fecha_hora__date=datetime.today())    

    # Total de ventas hoy
    total_sales = sum(orden.total for orden in ordenes_hoy)
    cantidad_ordenes = ordenes_hoy.count()

    # Órdenes de la semana
    ordenes_semana = Orden.objects.filter(
        estatus='pagada', fecha_hora__week=datetime.today().isocalendar()[1]
    )

    # Días de la semana del 1 (lunes) al 7 (domingo)
    dias_semana = [datetime.today() - timedelta(days=datetime.today().isocalendar()[2] - 1) + timedelta(days=i) for i in range(7)]
    ventas_por_dia = []
    for dia in dias_semana:        
        ventas_dia = ordenes_semana.filter(
            fecha_hora__date=dia.date()
        ).aggregate(
            total=Sum(models.F('detalles__cantidad') * models.F('detalles__precio_unitario'))
        )['total'] or 0
        
        ventas_por_dia.append({
            'dia': dia.strftime('%Y-%m-%d'), 
            'total': float(ventas_dia)  # Asegurar que sea float
        })

    # Últimas 5 órdenes
    ultimas_ordenes = Orden.objects.all().order_by('-fecha_hora')[:5]

    # Platillos más vendidos
    platillos_mas_vendidos = Orden.objects.filter(
        estatus='pagada',
        detalles__platillo__isnull=False  # Filtrar detalles sin platillo
    ).values(
        'detalles__platillo__nombre',
        'detalles__platillo__categoria__nombre'
    ).annotate(
        cantidad=Sum('detalles__cantidad'),
        ingresos=Sum(models.F('detalles__cantidad') * models.F('detalles__precio_unitario'))
    ).order_by('-cantidad')[:10]

    context = {
        'ventas_totales': total_sales,
        'cantidad_ordenes': cantidad_ordenes,
        'ordenes_semana': ordenes_semana,
        'ventas_por_dia': ventas_por_dia,
        'ultimas_ordenes': ultimas_ordenes,
        'platillos_mas_vendidos': platillos_mas_vendidos,
    }

    return render(request, 'main/main_index.html', context)