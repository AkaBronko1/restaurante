from django.shortcuts import render
from rest_framework.response import Response
from rest_framework.views import APIView
from rest_framework import generics
from apps.ordenes.models import Orden, OrdenDetalle
from rest_framework.authentication import SessionAuthentication, BasicAuthentication
from rest_framework.permissions import IsAuthenticated
from .serializers import OrdenDetalleSerializer, OrdenSerializer

class OrdenDetalleListAPIView(APIView):
    """
    API endpoint que retorna los detalles de órdenes pendientes
    """
    authentication_classes = [SessionAuthentication, BasicAuthentication]
    permission_classes = [IsAuthenticated]

    def get(self, request, format=None):
        orden_detalles = OrdenDetalle.objects.filter(orden__estatus='pendiente')
        serializer = OrdenDetalleSerializer(orden_detalles, many=True)
        return Response(serializer.data)

class UltimasOrdenesAPIView(generics.ListAPIView):
    """
    API endpoint que retorna las últimas órdenes del sistema
    Por defecto retorna las últimas 10 órdenes ordenadas por fecha_hora descendente
    """
    authentication_classes = [SessionAuthentication, BasicAuthentication]
    permission_classes = [IsAuthenticated]
    serializer_class = OrdenSerializer
    
    def get_queryset(self):
        # Obtener las últimas 10 órdenes por defecto
        queryset = Orden.objects.all().order_by('-fecha_hora')[:10]
        
        # Opción para filtrar por estatus mediante query params
        estatus = self.request.query_params.get('estatus', None)
        if estatus:
            queryset = Orden.objects.filter(estatus=estatus).order_by('-fecha_hora')[:10]
        
        return queryset

class OrdenDetailAPIView(generics.RetrieveAPIView):
    """
    API endpoint que retorna el detalle completo de una orden específica
    """
    authentication_classes = [SessionAuthentication, BasicAuthentication]
    permission_classes = [IsAuthenticated]
    serializer_class = OrdenSerializer
    queryset = Orden.objects.all()
