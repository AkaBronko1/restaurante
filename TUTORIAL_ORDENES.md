# 📋 TUTORIAL: Sistema de Órdenes y Detalles de Orden

## 🎯 Objetivo
Implementar un sistema completo de gestión de órdenes para un restaurante, donde cada orden puede contener múltiples platillos (detalles de orden) con sus cantidades y notas específicas.

---

## 📚 Conceptos Importantes

### ¿Qué es una Orden?
Una **Orden** representa un pedido realizado por un cliente en una mesa específica. Contiene información sobre:
- La mesa donde se realizó el pedido
- El empleado que tomó la orden
- La fecha y hora del pedido
- El estado de la orden (pendiente, en preparación, pagada, etc.)

### ¿Qué es un Detalle de Orden?
Un **Detalle de Orden** (OrdenDetalle) representa cada platillo individual dentro de una orden. Contiene:
- El platillo solicitado
- La cantidad de ese platillo
- Notas especiales (sin cebolla, término medio, etc.)
- El precio unitario al momento de la orden

### Relación entre Orden y OrdenDetalle
- Una **Orden** puede tener **múltiples detalles** (uno por cada platillo)
- Cada **Detalle** pertenece a **una sola orden**
- Esta es una relación **uno a muchos** (1:N)

---

## 🏗️ PASO 1: CREAR LOS MODELOS

### Explicación
Los modelos son la representación de nuestras tablas en la base de datos. Definen qué información vamos a guardar y cómo se relaciona.

### Ubicación del archivo
`apps/ordenes/models.py`

### Código implementado

```python
class Orden(models.Model):
    empleado = models.ForeignKey(AppUser, on_delete=models.CASCADE, related_name='ordenes')
    mesa = models.ForeignKey(Mesa, on_delete=models.CASCADE, related_name='ordenes')
    fecha_hora = models.DateTimeField(auto_now_add=True)
    estatus = models.CharField(max_length=50, default='pendiente')

class OrdenDetalle(models.Model):
    orden = models.ForeignKey(Orden, on_delete=models.CASCADE, related_name='detalles')
    platillo = models.ForeignKey(Platillo, on_delete=models.CASCADE, related_name='detalles')
    cantidad = models.IntegerField()
    notas = models.TextField(blank=True, null=True)
    precio_unitario = models.DecimalField(max_digits=10, decimal_places=2)

    def __str__(self):
        return f"{self.platillo.nombre} x {self.cantidad} (Orden #{self.orden.id})"

    @property
    def subtotal(self):
        return self.cantidad * self.precio_unitario
```

### ¿Para qué sirve cada campo?

#### Modelo Orden:
- **`empleado`**: ForeignKey al usuario que toma la orden. Si el empleado se elimina, se eliminan sus órdenes (CASCADE)
- **`mesa`**: ForeignKey a la mesa donde se realiza la orden. Relaciona la orden con una mesa específica
- **`fecha_hora`**: Se guarda automáticamente la fecha y hora cuando se crea la orden (auto_now_add=True)
- **`estatus`**: Estado actual de la orden (pendiente, en preparación, pagada). Por defecto es 'pendiente'

#### Modelo OrdenDetalle:
- **`orden`**: ForeignKey a la orden padre. Si se elimina la orden, se eliminan todos sus detalles (CASCADE)
- **`platillo`**: ForeignKey al platillo solicitado. Mantiene la referencia al menú
- **`cantidad`**: Número de porciones del platillo
- **`notas`**: Campo opcional para instrucciones especiales (blank=True, null=True)
- **`precio_unitario`**: Guardamos el precio al momento de la orden (histórico, por si el precio cambia después)

#### Métodos especiales:
- **`__str__`**: Define cómo se muestra el detalle en el admin y en otros lugares
- **`subtotal`**: Propiedad calculada (no se guarda en BD) que multiplica cantidad × precio

---

## 🏗️ PASO 2: CREAR LOS FORMULARIOS

### Explicación
Los formularios son las interfaces que permiten al usuario ingresar datos. Django valida automáticamente los datos según las reglas que definamos.

### Ubicación del archivo
`apps/ordenes/forms.py`

### Código implementado

```python
class OrdenForm(forms.ModelForm):
    class Meta:
        model = Orden
        fields = ['mesa', 'empleado']
        widgets = {
            'mesa': forms.Select(attrs={'class': 'form-control'}),
            'empleado': forms.HiddenInput(attrs={'class': 'form-control'})
        }

    def __init__(self, *args, **kwargs):
        super().__init__(*args, **kwargs)
        if 'mesa' in self.fields:
            self.fields['mesa'].queryset = Mesa.objects.filter(estado__nombre__iexact='Disponible')

    def save(self, commit=True):
        orden = super().save(commit=False)
        if commit:
            orden.estatus = 'pendiente'
            orden.empleado = self.initial['empleado']
            orden.save()

            mesa = orden.mesa
            mesa.estado = MesaEstado.objects.get(nombre='Ocupada')
            mesa.save()
        return orden

class OrdenDetalleForm(forms.Form):
    platillo = forms.ModelChoiceField(queryset=Platillo.objects.all(), widget=forms.Select(attrs={'class': 'form-control'}))
    cantidad = forms.IntegerField(widget=forms.NumberInput(attrs={'class': 'form-control'}))
    notas = forms.CharField(widget=forms.Textarea(attrs={'class': 'form-control', 'rows': 3}), required=False)    
    orden_id = forms.IntegerField(widget=forms.HiddenInput())
```

### ¿Para qué sirve cada parte?

#### OrdenForm:
- **`Meta.model`**: Le dice a Django que este formulario está basado en el modelo Orden
- **`Meta.fields`**: Solo mostramos los campos 'mesa' y 'empleado' (fecha_hora y estatus se manejan automáticamente)
- **`widgets`**: Personalizamos cómo se muestran los campos:
  - `mesa`: Select dropdown con clase Bootstrap
  - `empleado`: Campo oculto (se asigna automáticamente desde el usuario logueado)

- **`__init__`**: Método constructor que se ejecuta al crear el formulario
  - Filtramos las mesas para mostrar **solo las disponibles**
  - `estado__nombre__iexact='Disponible'`: Busca mesas cuyo estado tenga nombre "Disponible" (case insensitive)

- **`save`**: Método personalizado que se ejecuta al guardar
  - Establece `estatus = 'pendiente'` automáticamente
  - Asigna el empleado desde los datos iniciales
  - **Cambia el estado de la mesa a 'Ocupada'** automáticamente
  - Esta es lógica de negocio importante: al crear una orden, la mesa queda ocupada

#### OrdenDetalleForm:
- Es un **Form** simple (no ModelForm) porque manejamos el guardado manualmente
- **`platillo`**: Campo de selección que muestra todos los platillos disponibles
- **`cantidad`**: Campo numérico para ingresar cuántos platillos se ordenan
- **`notas`**: Campo de texto opcional para instrucciones especiales
- **`orden_id`**: Campo oculto que mantiene la referencia a qué orden pertenece este detalle

---

## 🏗️ PASO 3: CREAR LAS VISTAS

### Explicación
Las vistas son las funciones/clases que manejan la lógica del negocio. Reciben las peticiones del usuario, procesan los datos y devuelven las respuestas.

### Ubicación del archivo
`apps/ordenes/views.py`

### Código implementado

```python
class OrdenListView(LoginRequiredMixin, ListView):
    model = Orden
    template_name = 'ordenes/ordenes_list.html'
    context_object_name = 'ordenes'
    ordering = ['-fecha_hora']

class OrdenCreateView(LoginRequiredMixin, CreateView):
    model = Orden
    form_class = OrdenForm
    template_name = 'ordenes/ordenes_form.html'
    success_url = '/ordenes/ordenes/'

    def get_initial(self):
        initial = super().get_initial()
        initial['empleado'] = self.request.user
        return initial

class OrdenDetalleView(LoginRequiredMixin, ListView):
    model = OrdenDetalle
    template_name = 'ordenes/orden_detalle_list.html'
    context_object_name = 'orden_detalles'

    def get_context_data(self, **kwargs):
        context = super().get_context_data(**kwargs)
        context['orden'] = Orden.objects.get(id=self.kwargs.get('orden_id'))
        context['form'] = OrdenDetalleForm(initial={'orden_id': self.kwargs.get('orden_id')})
        return context

    def get_queryset(self):
        orden_id = self.kwargs.get('orden_id')
        return OrdenDetalle.objects.filter(orden__id=orden_id)

    def post(self, request, *args, **kwargs):
        form = OrdenDetalleForm(request.POST)
        if form.is_valid():
            orden_detalle = OrdenDetalle(
                orden=Orden.objects.get(id=form.cleaned_data['orden_id']),
                platillo=form.cleaned_data['platillo'],
                cantidad=form.cleaned_data['cantidad'],
                notas=form.cleaned_data['notas'],
                precio_unitario=form.cleaned_data['platillo'].precio
            )
            orden_detalle.save()
            return self.get(request, *args, **kwargs)
        else:
            return render(request, self.template_name, {
                'form': form, 
                'orden_detalles': self.get_queryset(), 
                'orden': Orden.objects.get(id=self.kwargs.get('orden_id'))
            })

class OrdenDetalleUpdateView(LoginRequiredMixin, View):
    def get(self, request, pk):
        detalle = OrdenDetalle.objects.get(id=pk)
        form = OrdenDetalleForm(initial={
            'platillo': detalle.platillo,
            'cantidad': detalle.cantidad,
            'notas': detalle.notas,
            'orden_id': detalle.orden.id
        })
        return render(request, 'ordenes/orden_detalle_edit_form.html', {'form': form, 'detalle': detalle})

    def post(self, request, pk):
        detalle = OrdenDetalle.objects.get(id=pk)
        form = OrdenDetalleForm(request.POST)
        if form.is_valid():
            detalle.platillo = form.cleaned_data['platillo']
            detalle.cantidad = form.cleaned_data['cantidad']
            detalle.notas = form.cleaned_data['notas']
            detalle.precio_unitario = form.cleaned_data['platillo'].precio
            detalle.save()
            return render(request, 'ordenes/orden_detalle_list.html', {
                'orden_detalles': OrdenDetalle.objects.filter(orden=detalle.orden),
                'orden': detalle.orden,
                'form': OrdenDetalleForm(initial={'orden_id': detalle.orden.id})
            })
        else:
            return render(request, 'ordenes/orden_detalle_edit_form.html', {'form': form, 'detalle': detalle})

class OrdenDetalleDeleteView(LoginRequiredMixin, DeleteView):
    model = OrdenDetalle
    template_name = 'ordenes/orden_detalle_confirm_delete.html'

    def get_success_url(self):
        return f'/ordenes/ordenes/{self.object.orden.id}/detalles/'
```

### ¿Para qué sirve cada vista?

#### OrdenListView (Listar Órdenes):
- **Hereda de ListView**: Vista genérica de Django para mostrar listas
- **LoginRequiredMixin**: Requiere que el usuario esté autenticado
- **model = Orden**: Indica que trabaja con el modelo Orden
- **template_name**: El archivo HTML que se usará para mostrar la lista
- **context_object_name = 'ordenes'**: El nombre de la variable que usaremos en el template
- **ordering = ['-fecha_hora']**: Ordena las órdenes de más reciente a más antigua (el - indica descendente)

#### OrdenCreateView (Crear Orden):
- **Hereda de CreateView**: Vista genérica para crear nuevos registros
- **form_class = OrdenForm**: Usa el formulario que creamos
- **success_url**: A dónde redirigir después de crear la orden exitosamente
- **get_initial()**: Método que establece valores iniciales del formulario
  - Asigna automáticamente el empleado actual (request.user) al formulario
  - Esto evita que el usuario tenga que seleccionar su propio nombre

#### OrdenDetalleView (Gestionar Detalles):
Esta vista es más compleja porque hace varias cosas:

1. **Muestra la lista de detalles** de una orden específica (método GET)
2. **Permite agregar nuevos detalles** a la orden (método POST)

- **get_context_data()**: Prepara datos adicionales para el template
  - Obtiene la orden específica usando `orden_id` de la URL
  - Crea un formulario nuevo prellenado con el `orden_id`
  
- **get_queryset()**: Define qué detalles mostrar
  - Filtra solo los detalles que pertenecen a la orden actual
  - `orden__id`: Notación de Django para acceder a campos relacionados

- **post()**: Maneja la creación de nuevos detalles
  - Valida el formulario recibido
  - Si es válido, crea un nuevo OrdenDetalle con todos los datos
  - **Importante**: Guarda `precio_unitario` desde `platillo.precio` para mantener histórico
  - Vuelve a mostrar la página con el nuevo detalle agregado
  - Si hay errores, muestra el formulario con los mensajes de error

#### OrdenDetalleUpdateView (Editar Detalle):
- **Hereda de View**: Vista básica que maneja GET y POST manualmente
- **get()**: Muestra el formulario de edición
  - Obtiene el detalle específico por su ID
  - Pre-llena el formulario con los datos actuales
  
- **post()**: Procesa la actualización
  - Actualiza los campos del detalle existente
  - Actualiza también el `precio_unitario` por si el precio del platillo cambió
  - Redirige a la lista de detalles mostrando el cambio

#### OrdenDetalleDeleteView (Eliminar Detalle):
- **Hereda de DeleteView**: Vista genérica para eliminar registros
- **template_name**: Muestra una página de confirmación antes de eliminar
- **get_success_url()**: Calcula dinámicamente a dónde volver después de eliminar
  - Usa `self.object.orden.id` para obtener el ID de la orden padre
  - Regresa a la lista de detalles de esa orden

---

## 🏗️ PASO 4: CONFIGURAR LAS URLS

### Explicación
Las URLs definen las rutas que los usuarios pueden visitar en el navegador y qué vista se ejecutará para cada ruta.

### Ubicación del archivo
`apps/ordenes/urls.py`

### Código implementado

```python
from django.urls import path
from . import views

app_name = 'ordenes'

urlpatterns = [
    # URLs de Órdenes
    path('ordenes/', views.OrdenListView.as_view(), name='ordenes_list'),
    path('ordenes/nuevo/', views.OrdenCreateView.as_view(), name='ordenes_create'),
    
    # URLs de Detalles de Orden
    path('ordenes/<int:orden_id>/detalles/', views.OrdenDetalleView.as_view(), name='ordenes_detalle_list'),
    path('ordenes/<int:pk>/detalles/edit/', views.OrdenDetalleUpdateView.as_view(), name='ordenes_detalle_update'),
    path('ordenes/detalles/eliminar/<int:pk>/', views.OrdenDetalleDeleteView.as_view(), name='ordenes_detalle_delete'),
]
```

### ¿Para qué sirve cada URL?

#### Configuración general:
- **`app_name = 'ordenes'`**: Define el namespace (espacio de nombres) de las URLs
  - Permite usar `{% url 'ordenes:ordenes_list' %}` en los templates
  - Evita conflictos si otras apps tienen URLs con el mismo nombre

#### URL de Lista:
```python
path('ordenes/', views.OrdenListView.as_view(), name='ordenes_list')
```
- **Ruta**: `/ordenes/ordenes/`
- **Vista**: OrdenListView
- **Propósito**: Muestra todas las órdenes del sistema
- **Nombre**: 'ordenes_list' para referenciarla en templates

#### URL de Crear:
```python
path('ordenes/nuevo/', views.OrdenCreateView.as_view(), name='ordenes_create')
```
- **Ruta**: `/ordenes/ordenes/nuevo/`
- **Vista**: OrdenCreateView
- **Propósito**: Formulario para crear una nueva orden
- **Nombre**: 'ordenes_create'

#### URL de Detalles (Lista y Crear):
```python
path('ordenes/<int:orden_id>/detalles/', views.OrdenDetalleView.as_view(), name='ordenes_detalle_list')
```
- **Ruta**: `/ordenes/ordenes/5/detalles/` (ejemplo con orden_id=5)
- **Parámetro**: `<int:orden_id>` captura el ID de la orden desde la URL
- **Vista**: OrdenDetalleView
- **Propósito**: Muestra los detalles de una orden específica y permite agregar más
- **Nombre**: 'ordenes_detalle_list'

#### URL de Editar Detalle:
```python
path('ordenes/<int:pk>/detalles/edit/', views.OrdenDetalleUpdateView.as_view(), name='ordenes_detalle_update')
```
- **Ruta**: `/ordenes/ordenes/12/detalles/edit/` (ejemplo con pk=12)
- **Parámetro**: `<int:pk>` captura el ID del detalle específico
- **Vista**: OrdenDetalleUpdateView
- **Propósito**: Editar un detalle existente
- **Nombre**: 'ordenes_detalle_update'

#### URL de Eliminar Detalle:
```python
path('ordenes/detalles/eliminar/<int:pk>/', views.OrdenDetalleDeleteView.as_view(), name='ordenes_detalle_delete')
```
- **Ruta**: `/ordenes/ordenes/detalles/eliminar/12/` (ejemplo con pk=12)
- **Parámetro**: `<int:pk>` captura el ID del detalle a eliminar
- **Vista**: OrdenDetalleDeleteView
- **Propósito**: Confirmar y eliminar un detalle
- **Nombre**: 'ordenes_detalle_delete'

---

## 🏗️ PASO 5: CREAR LOS TEMPLATES

### Explicación
Los templates son los archivos HTML que definen cómo se verá la información en el navegador. Usamos el sistema de plantillas de Django para mostrar datos dinámicamente.

---

### 5.1 Template: Lista de Órdenes

#### Ubicación del archivo
`templates/ordenes/ordenes_list.html`

#### Código implementado

```html
{% extends 'main/base_user.html' %}

{% block content %}
<h1>Lista de Ordenes</h1>

<a class="btn btn-primary" href="{% url 'ordenes:ordenes_create' %}">Agregar orden</a>

<table class="table">
    <thead>
        <tr>
            <th></th>
            <th>Fecha</th>
            <th>Mesa</th>
            <th>Estatus</th>
        </tr>
    </thead>
    <tbody>
        {% for orden in ordenes %}
        <tr>
            <td>
                <a class="btn btn-primary" href="{% url 'ordenes:ordenes_detalle_list' orden.pk %}">Editar</a>
            </td>
            <td>{{orden.fecha_hora}}</td>
            <td>{{orden.mesa.nombre}}</td>
            <td>{{orden.estatus}}</td>
        </tr>
        {% endfor %}
    </tbody>
</table>

{% endblock %}
```

#### ¿Para qué sirve cada parte?

- **`{% extends 'main/base_user.html' %}`**: Hereda la estructura base (menú, sidebar, estilos)
- **`{% block content %}`**: Define el contenido específico de esta página
- **Botón "Agregar orden"**: 
  - `{% url 'ordenes:ordenes_create' %}`: Genera automáticamente la URL correcta
  - Lleva al formulario de crear orden
- **Tabla de órdenes**:
  - `{% for orden in ordenes %}`: Itera sobre todas las órdenes (viene de la vista)
  - `orden.pk`: El ID de la orden (Primary Key)
  - `orden.fecha_hora`: Muestra cuándo se creó la orden
  - `orden.mesa.nombre`: Accede al nombre de la mesa relacionada
  - `orden.estatus`: Muestra el estado actual (pendiente, pagada, etc.)
- **Botón "Editar"**: Lleva a la página de detalles de esa orden específica

---

### 5.2 Template: Crear Orden

#### Ubicación del archivo
`templates/ordenes/ordenes_form.html`

#### Código implementado

```html
{% extends 'main/base_user.html' %}

{% block content %}
<h1>Agregar Orden</h1>

<form action="{% url 'ordenes:ordenes_create' %}" method="post">
    {% csrf_token %}
    {{ form.as_p }}
    <button type="submit" class="btn btn-primary">Guardar</button>
</form>
{% endblock %}
```

#### ¿Para qué sirve cada parte?

- **`<form action="..." method="post">`**: 
  - `action`: Define a dónde se envían los datos
  - `method="post"`: Indica que es una operación de creación/modificación
- **`{% csrf_token %}`**: Token de seguridad obligatorio de Django
  - Previene ataques CSRF (Cross-Site Request Forgery)
- **`{{ form.as_p }}`**: Renderiza todos los campos del formulario
  - `as_p` significa que cada campo se envuelve en etiquetas `<p>`
  - Django genera automáticamente los inputs según el formulario
- **Botón "Guardar"**: Envía el formulario al servidor

---

### 5.3 Template: Lista de Detalles de Orden

#### Ubicación del archivo
`templates/ordenes/orden_detalle_list.html`

#### Código implementado

```html
{% extends 'main/base_user.html' %}

{% block content %}
<h1>Orden No. {{ orden.id }} - {{ orden.fecha_hora }}</h1>

<form action="{% url 'ordenes:ordenes_detalle_list' orden.id %}" method="post">
    {% csrf_token %}
    {{ form.as_p }}
    <button type="submit" class="btn btn-primary">Guardar</button>
</form>

<table class="table">
    <thead>
        <tr>
            <th></th>
            <th>Platillo</th>
            <th>Cantidad</th>
            <th>Notas</th>            
        </tr>
    </thead>
    <tbody>
        {% for detalle in orden_detalles %}
        <tr>
            <td>
                <a class="btn btn-primary" href="{% url 'ordenes:ordenes_detalle_update' detalle.id %}">Editar</a>
                <a class="btn btn-danger" href="{% url 'ordenes:ordenes_detalle_delete' detalle.id %}">Eliminar</a>
            </td>
            <td>{{detalle.platillo.nombre}}</td>
            <td>{{detalle.cantidad}}</td>
            <td>{{detalle.notas}}</td>
        </tr>
        {% endfor %}
    </tbody>
</table>

<a href="{% url 'ordenes:ordenes_list' %}" class="btn btn-secondary">Regresar</a>

{% endblock %}
```

#### ¿Para qué sirve cada parte?

- **Título dinámico**: Muestra el número de orden y la fecha
  - `{{ orden.id }}`: ID de la orden
  - `{{ orden.fecha_hora }}`: Fecha y hora de creación
- **Formulario para agregar detalles**:
  - Permite agregar nuevos platillos a la orden
  - Se envía a la misma URL (orden_detalle_list)
  - La vista detecta que es POST y crea el detalle
- **Tabla de detalles**:
  - Muestra todos los platillos ya agregados a la orden
  - `{% for detalle in orden_detalles %}`: Itera sobre los detalles
  - `detalle.platillo.nombre`: Nombre del platillo (relación ForeignKey)
  - `detalle.cantidad`: Cuántas porciones
  - `detalle.notas`: Instrucciones especiales
- **Botones de acción**:
  - "Editar": Modifica cantidad o notas del detalle
  - "Eliminar": Quita el platillo de la orden
- **Botón "Regresar"**: Vuelve a la lista de órdenes

---

### 5.4 Template: Editar Detalle de Orden

#### Ubicación del archivo
`templates/ordenes/orden_detalle_edit_form.html`

#### Código implementado

```html
{% extends 'main/base_user.html' %}

{% block content %}
<h1>Editar Detalle de Orden</h1>

<form action="{% url 'ordenes:ordenes_detalle_update' detalle.id %}" method="post">
    {% csrf_token %}
    {{ form.as_p }}
    <button type="submit" class="btn btn-primary">Guardar</button>
    <a href="{% url 'ordenes:ordenes_detalle_list' detalle.orden.id %}" class="btn btn-secondary">Regresar</a>
</form>
{% endblock %}
```

#### ¿Para qué sirve cada parte?

- **`action="{% url 'ordenes:ordenes_detalle_update' detalle.id %}"`**:
  - Envía el formulario a la URL de actualización
  - Incluye el ID del detalle que se está editando
- **`{{ form.as_p }}`**: Muestra los campos pre-llenados con los datos actuales
- **Botón "Regresar"**:
  - `detalle.orden.id`: Accede al ID de la orden padre
  - Vuelve a la lista de detalles de esa orden

---

### 5.5 Template: Confirmar Eliminación de Detalle

#### Ubicación del archivo
`templates/ordenes/orden_detalle_confirm_delete.html`

#### Código implementado

```html
{% extends 'main/base_user.html' %}

{% block content %}
<h1>Eliminar Detalle de Orden</h1>

<form method="post">
    {% csrf_token %}
    <p>¿Estás seguro de que deseas eliminar este detalle?</p>
    <p><strong>Platillo:</strong> {{ object.platillo.nombre }}</p>
    <p><strong>Cantidad:</strong> {{ object.cantidad }}</p>
    <button type="submit" class="btn btn-danger">Eliminar</button>
    <a class="btn btn-primary" href="{% url 'ordenes:ordenes_detalle_list' object.orden.id %}">Regresar</a>
</form>
{% endblock %}
```

#### ¿Para qué sirve cada parte?

- **Página de confirmación**: Evita eliminaciones accidentales
- **`{{ object }}`**: La DeleteView proporciona automáticamente el objeto a eliminar
- **Muestra información del detalle**:
  - `object.platillo.nombre`: Qué platillo se va a eliminar
  - `object.cantidad`: Cuántas porciones
- **Botón "Eliminar"**: Confirma y ejecuta la eliminación
- **Botón "Regresar"**: Cancela la acción

---

## 🏗️ PASO 6: CREAR LAS MIGRACIONES

### Explicación
Las migraciones son archivos que Django genera para crear o modificar las tablas en la base de datos. Son como un "historial de cambios" de la estructura de la BD.

### Comandos ejecutados

```bash
# Activar el entorno virtual (si no está activado)
.venv\Scripts\activate

# Crear las migraciones
python manage.py makemigrations

# Aplicar las migraciones a la base de datos
python manage.py migrate
```

### ¿Qué hace cada comando?

#### makemigrations:
- Lee los modelos en `models.py`
- Compara con las migraciones anteriores
- Genera un archivo Python en `migrations/` con los cambios
- Archivo generado: `apps/ordenes/migrations/0001_initial.py` o similar

#### migrate:
- Lee todos los archivos de migración pendientes
- Ejecuta las sentencias SQL necesarias
- Crea las tablas en la base de datos
- Tablas creadas:
  - `ordenes_orden` (con campos empleado_id, mesa_id, fecha_hora, estatus)
  - `ordenes_ordendetalle` (con campos orden_id, platillo_id, cantidad, notas, precio_unitario)

### Verificación
Después de migrar, puedes verificar en el admin de Django o hacer consultas:

```python
python manage.py shell

# Ver órdenes
from apps.ordenes.models import Orden
Orden.objects.all()

# Ver detalles
from apps.ordenes.models import OrdenDetalle
OrdenDetalle.objects.all()
```

---

## 🏗️ PASO 7: ACTUALIZAR LA NAVEGACIÓN

### Explicación
Para que los usuarios puedan acceder fácilmente al sistema de órdenes, agregamos enlaces en el menú lateral (sidebar).

### Ubicación del archivo
`templates/main/base_user.html`

### Código agregado

```html
<div class="menu-item">
    <a href="{% url 'ordenes:ordenes_list' %}" class="menu-link">
        <i class="bi bi-cart"></i>
        <span class="menu-text">Órdenes</span>
    </a>
</div>
```

### ¿Para qué sirve?

- **Icono carrito**: `<i class="bi bi-cart"></i>` representa visualmente las órdenes
- **Enlace directo**: Al hacer clic, va a la lista de órdenes
- **Consistencia UI**: Sigue el mismo estilo que otros elementos del menú

---

## 🎯 PASO 8: PROBAR EL SISTEMA

### Flujo completo de uso

#### 1. Crear una Orden:
1. Usuario hace clic en "Órdenes" en el menú
2. Clic en "Agregar orden"
3. Selecciona una mesa (solo muestra disponibles)
4. Clic en "Guardar"
5. Sistema crea la orden y cambia mesa a "Ocupada"

#### 2. Agregar Platillos (Detalles):
1. En la lista de órdenes, clic en "Editar" de una orden
2. Se muestra el formulario para agregar platillos
3. Selecciona un platillo del menú
4. Ingresa cantidad (ej: 2)
5. Opcionalmente agrega notas (ej: "Sin cebolla")
6. Clic en "Guardar"
7. Sistema crea el detalle guardando el precio actual del platillo

#### 3. Editar un Detalle:
1. En la lista de detalles, clic en "Editar" de un platillo
2. Modifica cantidad o notas
3. Clic en "Guardar"
4. Sistema actualiza el detalle

#### 4. Eliminar un Detalle:
1. En la lista de detalles, clic en "Eliminar"
2. Confirma la eliminación
3. Sistema quita el platillo de la orden

---

## 📊 DIAGRAMA DE FLUJO DEL SISTEMA

```
┌─────────────┐
│   Usuario   │
└──────┬──────┘
       │
       ▼
┌─────────────────┐
│  Lista Órdenes  │ ◄──────┐
└────────┬────────┘        │
         │                 │
         ├─► Crear Orden   │
         │        │        │
         │        ▼        │
         │   Selecciona    │
         │      Mesa       │
         │        │        │
         │        ▼        │
         │   Orden creada  │
         │   Mesa ocupada  │
         │        │        │
         │        ▼        │
         ├─► Gestionar     │
         │    Detalles     │
         │        │        │
         │        ├─► Agregar Platillo
         │        │        │
         │        │        ▼
         │        │   Guarda precio
         │        │   actual platillo
         │        │        │
         │        ├─► Editar Detalle
         │        │        │
         │        └─► Eliminar Detalle
         │                 │
         └─────────────────┘
```

---

## 🔑 CONCEPTOS CLAVE IMPLEMENTADOS

### 1. Relaciones ForeignKey
- **Orden → Mesa**: Una orden pertenece a una mesa
- **Orden → Empleado**: Una orden es tomada por un empleado
- **OrdenDetalle → Orden**: Cada detalle pertenece a una orden
- **OrdenDetalle → Platillo**: Cada detalle referencia un platillo

### 2. Lógica de Negocio Automática
- Mesa disponible → Ocupada al crear orden
- Guardar precio histórico en cada detalle
- Usuario autenticado se asigna automáticamente como empleado
- Filtrado automático de mesas disponibles

### 3. Validaciones
- LoginRequiredMixin: Solo usuarios autenticados
- Formularios validan tipos de datos
- Confirmación antes de eliminar

### 4. Optimización
- Ordenamiento por fecha descendente
- Propiedad calculada para subtotal (no ocupa espacio en BD)
- Filtros en consultas para eficiencia

---

## 🎓 CONCLUSIONES

### ¿Qué aprendimos?

A lo largo de este tutorial aprendí a implementar un sistema completo de órdenes para restaurante, comenzando por el modelado de datos donde diseñé relaciones entre tablas usando ForeignKeys para conectar órdenes con mesas, empleados y platillos. Comprendí cómo crear y personalizar formularios en Django, aplicando validaciones automáticas y lógica personalizada como el filtrado de mesas disponibles. Utilicé vistas basadas en clases (Class-Based Views) que me permitieron reutilizar código de manera eficiente, aprendiendo la diferencia entre ListView, CreateView, UpdateView y DeleteView. Desarrollé templates dinámicos que muestran información de la base de datos usando el sistema de plantillas de Django, y configuré URLs con parámetros para capturar IDs y navegar entre órdenes y sus detalles. Finalmente, implementé lógica de negocio automática que simplifica procesos del restaurante, como cambiar el estado de las mesas a "Ocupada" al crear una orden y guardar precios históricos de los platillos para mantener un registro preciso de cada venta.

### Sistema Completo Implementado

✅ Crear órdenes para mesas  
✅ Agregar múltiples platillos a una orden  
✅ Editar cantidades y notas  
✅ Eliminar platillos de la orden  
✅ Guardar precio histórico  
✅ Cambiar estados de mesa automáticamente  
✅ Interfaz intuitiva con Bootstrap  

---

## 📝 NOTAS IMPORTANTES

### Precio Histórico
Guardamos el `precio_unitario` en cada detalle porque:
- El precio del platillo puede cambiar en el futuro
- Necesitamos saber el precio al momento de la orden
- Importante para reportes y contabilidad

### Estados de Mesa
La mesa cambia de estado automáticamente:
- Al crear orden → "Ocupada"
- Al pagar orden → "Disponible" (implementado en el sistema de pagos)

### Seguridad
- `LoginRequiredMixin` en todas las vistas
- CSRF token en todos los formularios POST
- on_delete=CASCADE para mantener integridad referencial

---

## 🚀 PRÓXIMOS PASOS

Este sistema de órdenes es la base para:
1. Sistema de pagos (procesar y cerrar órdenes)
2. Reportes de ventas
3. Gestión de cocina (estatus de preparación)
4. Cálculo de totales y tickets
5. Historial de órdenes por mesa/empleado

---

## 📌 REPOSITORIO
- **URL**: https://github.com/AkaBronko1/restaurante
- **Commit de Órdenes**: Buscar commits con "Implementar sistema de órdenes"

---

**Fin del Tutorial - Sistema de Órdenes y Detalles de Orden**
