# apps/mesas/forms.py
import django.forms as forms
from .models import Mesa

class MesaForm(forms.ModelForm):
    class Meta:
        model = Mesa
        fields = ['numero', 'capacidad', 'estado']
        widgets = {
            'numero': forms.NumberInput(attrs={
                'class': 'form-control', 
                'placeholder': 'Ingrese el número de mesa'
            }),
            'capacidad': forms.NumberInput(attrs={
                'class': 'form-control', 
                'placeholder': 'Ingrese la capacidad de personas'
            }),
            'estado': forms.Select(attrs={
                'class': 'form-control'
            })
        }
        labels = {
            'numero': 'Número de Mesa',
            'capacidad': 'Capacidad (personas)',
            'estado': 'Estado'
        }