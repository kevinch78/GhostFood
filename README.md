# Ghost Food 👻🍲

**Ghost Food** es una innovadora aplicación móvil desarrollada en Flutter que conecta a creadores de recetas, cocinas fantasma (ghost kitchens) y clientes finales. La plataforma permite a los usuarios crear, compartir y monetizar recetas, mientras que los clientes pueden pedir platillos únicos, ¡incluso generados por inteligencia artificial!

## ✨ Características Principales

- **🤖 Asistente IA (GhostChef):** Un chatbot inteligente que genera recetas personalizadas basadas en los antojos, gustos y alergias del usuario.
- **🛍️ Marketplace de Recetas:** Un espacio donde los "Creadores" publican sus recetas y los "Cocineros" (dueños de cocinas) pueden solicitar licencias para prepararlas.
- **👤 Sistema de Roles:**
  - **Cliente:** Explora el menú, interactúa con el GhostChef AI para crear recetas y realiza pedidos.
  - **Creador:** Diseña y publica sus propias recetas, gestionando su portafolio.
  - **Cocinero:** Gestiona una cocina, solicita acuerdos para preparar recetas del marketplace, y atiende los pedidos de los clientes.
- **🛒 Carrito de Compras y Pedidos:** Funcionalidad completa para que los clientes añadan platillos a su carrito y realicen pedidos.
- **⚙️ Gestión de Perfil:** Los usuarios pueden editar su información, incluyendo alergias y disgustos para personalizar la experiencia con la IA.
- **☁️ Backend con Supabase:** Utiliza Supabase para la autenticación, base de datos en tiempo real (PostgreSQL) y almacenamiento de archivos.
- **🚀 State Management con GetX:** Arquitectura robusta y reactiva gracias al framework GetX.

---

## 🚀 Cómo Empezar: Guía de Instalación y Configuración

Sigue estos pasos para clonar, configurar y ejecutar el proyecto en tu máquina local.

### 1. Prerrequisitos

Asegúrate de tener instalado el **Flutter SDK**. Si no lo tienes, sigue la [guía oficial de instalación de Flutter](https://docs.flutter.dev/get-started/install).

```bash
# Verifica tu instalación de Flutter
flutter doctor
```

### 2. Configuración de Supabase

El backend de la aplicación funciona con Supabase. Necesitarás crear un proyecto y configurarlo.

1.  **Crea un Proyecto en Supabase:**
    -   Ve a [supabase.com](https://supabase.com/) y crea una cuenta o inicia sesión.
    -   Crea un nuevo proyecto. Guarda bien la **URL del Proyecto** y la **Clave anónima (anon key)**.

2.  **Configura la Base de Datos:**
    -   Dentro de tu proyecto de Supabase, ve a `SQL Editor`.
    -   Copia y ejecuta los scripts SQL que se encuentran en el archivo `schema.sql` de este repositorio para crear las tablas (`profiles`, `recipes`, `orders`, etc.) y sus relaciones.
    *Nota: Si el archivo `schema.sql` no está presente, deberás crearlo a partir de la estructura de la base de datos original.*

3.  **Configura el Almacenamiento (Storage):**
    -   Ve a la sección `Storage` en el dashboard de Supabase.
    -   Crea un nuevo bucket llamado `product_images`. **Asegúrate de que la opción "Public bucket" esté desmarcada.**
    -   Ve a `Database` -> `Policies` y crea las siguientes políticas de seguridad (RLS) para el bucket `storage.objects`. Esto permitirá que los usuarios suban y lean imágenes de forma segura.

    ```sql
    -- POLÍTICA 1: Permite la lectura pública de imágenes en el bucket.
    CREATE POLICY "Public read access for product images"
    ON storage.objects FOR SELECT
    USING ( bucket_id = 'product_images' );

    -- POLÍTICA 2: Permite a un usuario autenticado subir imágenes a su propia carpeta.
    -- La carpeta se nombra con el ID del usuario (auth.uid).
    CREATE POLICY "Allow authenticated user to upload to own folder"
    ON storage.objects FOR INSERT
    TO authenticated
    WITH CHECK ( (bucket_id = 'product_images') AND ((storage.foldername(name))[1] = auth.uid()::text) );

    -- POLÍTICA 3: Permite a un usuario autenticado actualizar/eliminar imágenes en su propia carpeta.
    CREATE POLICY "Allow authenticated user to update images in own folder"
    ON storage.objects FOR UPDATE
    TO authenticated
    USING ( (bucket_id = 'product_images') AND ((storage.foldername(name))[1] = auth.uid()::text) );
    ```

4.  **Habilita Row Level Security (RLS):**
    -   Asegúrate de que RLS esté habilitado para todas las tablas que creaste (`profiles`, `recipes`, etc.).
    -   Define las políticas de RLS para cada tabla según la lógica de negocio (por ejemplo, un usuario solo puede editar su propio perfil).

### 3. Configuración del Proyecto Flutter

1.  **Clona el Repositorio:**
    ```bash
    git clone <URL_DEL_REPOSITORIO>
    cd ghost_food
    ```

2.  **Crea el Archivo de Configuración:**
    -   En la raíz del proyecto (`ghost_food/`), crea un archivo llamado `.env`.
    -   Añade tus credenciales de Supabase que guardaste en el paso 2.1:

    ```
    SUPABASE_URL=URL_DE_TU_PROYECTO_SUPABASE
    SUPABASE_ANON_KEY=TU_ANON_KEY_DE_SUPABASE
    
    ```

3.  **Instala las Dependencias:**
    Abre una terminal en la raíz del proyecto y ejecuta:
    ```bash
    flutter pub get
    ```

### 4. Ejecuta la Aplicación

¡Todo listo! Ahora puedes ejecutar la aplicación en un emulador o dispositivo físico.

```bash
# Inicia la aplicación
flutter run
```

Al iniciar, la aplicación se conectará a tu instancia de Supabase. Podrás registrar nuevos usuarios y empezar a explorar todas las funcionalidades de Ghost Food.

SUPABASE_URL= https://innjdcwufpcbbojxdkks.supabase.co
SUPABASE_ANON_KEY= eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImlubmpkY3d1ZnBjYmJvanhka2tzIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTk4NTIzMjMsImV4cCI6MjA3NTQyODMyM30.-Jat9iArDrOGg9I7X9fEWptHacRI9OTQOLNIuqGEEjU

