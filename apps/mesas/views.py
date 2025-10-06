# apps/mesas/views.py
from django.shortcuts import render
from django.views.generic import ListView
from django.views.generic.edit import CreateView, UpdateView, DeleteView
from django.contrib.auth.mixins import LoginRequiredMixin
from .models import Mesa
from .forms import MesaForm

# CRUD Completo para Mesa
class MesaListView(LoginRequiredMixin, ListView):
    model = Mesa
    template_name = 'mesas/mesas_list.html'
    context_object_name = 'mesas'

class MesaCreateView(LoginRequiredMixin, CreateView):
    model = Mesa
    form_class = MesaForm
    template_name = 'mesas/mesas_form.html'
    success_url = '/mesas/lista/'

class MesaUpdateView(LoginRequiredMixin, UpdateView):
    model = Mesa
    form_class = MesaForm
    template_name = 'mesas/mesas_edit_form.html'
    success_url = '/mesas/lista/'

class MesaDeleteView(LoginRequiredMixin, DeleteView):
    model = Mesa
    template_name = 'mesas/mesas_confirm_delete.html'
    success_url = '/mesas/lista/'

# Vista adicional para Mesas Estado (no aparece en sidebar)
class MesasEstadoView(LoginRequiredMixin, ListView):
    model = Mesa
    template_name = 'mesas/mesas_estados.html'
    context_object_name = 'mesas'
    
    def get_context_data(self, **kwargs):
        context = super().get_context_data(**kwargs)
        # Agrupar mesas por estado para mostrar mejor
        context['mesas_disponibles'] = Mesa.objects.filter(estado='disponible')
        context['mesas_ocupadas'] = Mesa.objects.filter(estado='ocupada')
        context['mesas_reservadas'] = Mesa.objects.filter(estado='reservada')
        context['mesas_mantenimiento'] = Mesa.objects.filter(estado='mantenimiento')
        return context