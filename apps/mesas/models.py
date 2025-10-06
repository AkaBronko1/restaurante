# apps/mesas/models.py
from django.db import models

class Mesa(models.Model):
    ESTADOS_CHOICES = [
        ('disponible', 'Disponible'),
        ('ocupada', 'Ocupada'),
        ('reservada', 'Reservada'),
        ('mantenimiento', 'Mantenimiento'),
    ]
    
    numero = models.IntegerField(unique=True)
    capacidad = models.IntegerField()
    estado = models.CharField(max_length=20, choices=ESTADOS_CHOICES, default='disponible')
    
    def __str__(self):
        return f"Mesa {self.numero}"
    
    class Meta:
        ordering = ['numero']