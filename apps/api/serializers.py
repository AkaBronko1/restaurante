from rest_framework import serializers
from apps.ordenes.models import Orden, OrdenDetalle, Mesa
from apps.platillos.models import Platillo, Categoria
from apps.accounts.models import AppUser

class CategoriaSerializer(serializers.ModelSerializer):
    class Meta:
        model = Categoria
        fields = ['id', 'nombre']

class PlatilloSerializer(serializers.ModelSerializer):
    categoria = CategoriaSerializer(read_only=True)
    
    class Meta:
        model = Platillo
        fields = ['id', 'nombre', 'descripcion', 'precio', 'categoria']

class OrdenDetalleSerializer(serializers.ModelSerializer):
    platillo = PlatilloSerializer(read_only=True)
    subtotal = serializers.DecimalField(max_digits=10, decimal_places=2, read_only=True)

    class Meta:
        model = OrdenDetalle
        fields = ['id', 'platillo', 'cantidad', 'notas', 'precio_unitario', 'subtotal']

class MesaSerializer(serializers.ModelSerializer):
    estado = serializers.StringRelatedField()
    
    class Meta:
        model = Mesa
        fields = ['id', 'nombre', 'capacidad', 'estado']

class EmpleadoSerializer(serializers.ModelSerializer):
    class Meta:
        model = AppUser
        fields = ['id', 'username', 'first_name', 'last_name']

class OrdenSerializer(serializers.ModelSerializer):
    detalles = OrdenDetalleSerializer(many=True, read_only=True)
    mesa = MesaSerializer(read_only=True)
    empleado = EmpleadoSerializer(read_only=True)
    total = serializers.DecimalField(max_digits=10, decimal_places=2, read_only=True)
    
    class Meta:
        model = Orden
        fields = ['id', 'empleado', 'mesa', 'fecha_hora', 'estatus', 'detalles', 'total']
