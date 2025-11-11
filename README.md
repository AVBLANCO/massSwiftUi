# massSwiftUi

## 🧭 Recomendación de Arquitectura: MVVM-C (Model-View-ViewModel + Coordinators)

Para una aplicación moderna en **SwiftUI**, el patrón **MVVM** (Model–View–ViewModel) es el más natural y compatible.  
Agregando la capa de **Coordinators (MVVM-C)** resolvemos el problema de la navegación y modularizamos completamente el código.

---

### 1. 🧩 Modelos de Datos
Contiene la definición del modelo de persistencia (`@Model`) y las estructuras para la comunicación con la API.

---

### 2. 🌐 Servicios de Red
Contiene el gestor de red (`NetworkManager`) y los errores específicos de la capa.

---

### 3. 📍 Gestor de Ubicación
Separamos la lógica de `CLLocationManager` ya que es un servicio que puede ser inyectado.

---

### 4. ⚙️ ViewModel (Lógica y Estado)
El  `CardViewModel` y se enfoca en la lógica que interactúa con el modelo (`TullaveCard`) y los servicios (`NetworkManager`).

---

### 5. 🖼️ Vistas
Contiene todas las **Vistas** y componentes de la **UI**.  
Aquí inyectamos los **ViewModels** y usamos `@Query`.

---

##📍 Ruta
### 1: RequestLocation:
manager.requestLocation(): ideal para una solicitud única y eficiente de la ubicación.
### 1: startUpdatingLocation:
manager.startUpdatingLocation(): mantiene el seguimiento continuo, pero puede consumir más bate
