-- PASO 1: Limpiar triggers y funciones existentes
DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
DROP FUNCTION IF EXISTS public.handle_new_user();

-- PASO 2: Crear/actualizar tablas (solo si no existen)
CREATE TABLE IF NOT EXISTS profiles (
  id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  role TEXT NOT NULL CHECK (role IN ('cliente', 'cocinero', 'creador')),
  full_name TEXT,
  delivery_address TEXT,
  kitchen_name TEXT,
  kitchen_description TEXT,
  photo_url TEXT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TABLE IF NOT EXISTS recipes (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  creator_id UUID NOT NULL,
  name TEXT NOT NULL,
  description TEXT,
  ingredients JSONB,
  steps JSONB,
  image_url TEXT,
  category TEXT,
  base_price NUMERIC(10, 2) NOT NULL,
  type TEXT NOT NULL DEFAULT 'USER_CREATED' CHECK (type IN ('USER_CREATED', 'AI_GENERATED')),
  created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TABLE IF NOT EXISTS agreements (
  id BIGSERIAL PRIMARY KEY,
  recipe_id UUID NOT NULL,
  kitchen_id UUID NOT NULL,
  creator_id UUID NOT NULL,
  status TEXT NOT NULL DEFAULT 'REQUESTED' CHECK (status IN ('REQUESTED', 'APPROVED', 'REJECTED')),
  requested_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  approved_at TIMESTAMPTZ
);

CREATE TABLE IF NOT EXISTS orders (
  id BIGSERIAL PRIMARY KEY,
  client_id UUID NOT NULL,
  recipe_id UUID NOT NULL,
  kitchen_id UUID,
  status TEXT NOT NULL DEFAULT 'PENDING_ACCEPTANCE',
  total_price NUMERIC(10, 2) NOT NULL,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- PASO 3: Actualizar foreign keys
DO $$ 
BEGIN
    -- RECIPES
    ALTER TABLE recipes DROP CONSTRAINT IF EXISTS recipes_creator_id_fkey;
    ALTER TABLE recipes ADD CONSTRAINT recipes_creator_id_fkey 
        FOREIGN KEY (creator_id) REFERENCES public.profiles(id) ON DELETE CASCADE;
    
    -- AGREEMENTS
    ALTER TABLE agreements DROP CONSTRAINT IF EXISTS agreements_recipe_id_fkey;
    ALTER TABLE agreements DROP CONSTRAINT IF EXISTS agreements_kitchen_id_fkey;
    ALTER TABLE agreements DROP CONSTRAINT IF EXISTS agreements_creator_id_fkey;
    
    ALTER TABLE agreements 
        ADD CONSTRAINT agreements_recipe_id_fkey 
            FOREIGN KEY (recipe_id) REFERENCES public.recipes(id) ON DELETE CASCADE,
        ADD CONSTRAINT agreements_kitchen_id_fkey 
            FOREIGN KEY (kitchen_id) REFERENCES public.profiles(id) ON DELETE CASCADE,
        ADD CONSTRAINT agreements_creator_id_fkey 
            FOREIGN KEY (creator_id) REFERENCES public.profiles(id) ON DELETE CASCADE;
    
    -- ORDERS
    ALTER TABLE orders DROP CONSTRAINT IF EXISTS orders_client_id_fkey;
    ALTER TABLE orders DROP CONSTRAINT IF EXISTS orders_recipe_id_fkey;
    ALTER TABLE orders DROP CONSTRAINT IF EXISTS orders_kitchen_id_fkey;
    
    ALTER TABLE orders 
        ADD CONSTRAINT orders_client_id_fkey 
            FOREIGN KEY (client_id) REFERENCES public.profiles(id) ON DELETE CASCADE,
        ADD CONSTRAINT orders_recipe_id_fkey 
            FOREIGN KEY (recipe_id) REFERENCES public.recipes(id) ON DELETE CASCADE,
        ADD CONSTRAINT orders_kitchen_id_fkey 
            FOREIGN KEY (kitchen_id) REFERENCES public.profiles(id) ON DELETE SET NULL;
END $$;

-- PASO 4: Agregar constraint único si no existe
DO $$ 
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM pg_constraint 
        WHERE conname = 'unique_recipe_kitchen'
    ) THEN
        ALTER TABLE agreements ADD CONSTRAINT unique_recipe_kitchen 
            UNIQUE(recipe_id, kitchen_id);
    END IF;
END $$;

-- PASO 5: Crear índices (si no existen)
CREATE INDEX IF NOT EXISTS idx_recipes_creator ON recipes(creator_id);
CREATE INDEX IF NOT EXISTS idx_agreements_creator ON agreements(creator_id);
CREATE INDEX IF NOT EXISTS idx_agreements_kitchen ON agreements(kitchen_id);
CREATE INDEX IF NOT EXISTS idx_agreements_recipe ON agreements(recipe_id);
CREATE INDEX IF NOT EXISTS idx_orders_client ON orders(client_id);
CREATE INDEX IF NOT EXISTS idx_orders_kitchen ON orders(kitchen_id);

-- PASO 6: Habilitar RLS
ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.recipes ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.agreements ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.orders ENABLE ROW LEVEL SECURITY;

-- PASO 7: Eliminar políticas existentes y recrearlas
DO $$ 
BEGIN
    -- PROFILES
    DROP POLICY IF EXISTS "Allow public read access to profiles" ON public.profiles;
    DROP POLICY IF EXISTS "Allow users to update their own profile" ON public.profiles;
    DROP POLICY IF EXISTS "Allow users to insert their own profile" ON public.profiles;
    
    -- RECIPES
    DROP POLICY IF EXISTS "Allow public read access to recipes" ON public.recipes;
    DROP POLICY IF EXISTS "Allow creator to insert their own recipe" ON public.recipes;
    DROP POLICY IF EXISTS "Allow creator to update their own recipe" ON public.recipes;
    DROP POLICY IF EXISTS "Allow creator to delete their own recipe" ON public.recipes;
    
    -- AGREEMENTS
    DROP POLICY IF EXISTS "Allow involved users to view agreements" ON public.agreements;
    DROP POLICY IF EXISTS "Allow kitchen to insert a request" ON public.agreements;
    DROP POLICY IF EXISTS "Allow creator to insert agreement request" ON public.agreements;
    DROP POLICY IF EXISTS "Allow creator to update agreement status" ON public.agreements;
    
    -- ORDERS
    DROP POLICY IF EXISTS "Allow client and kitchen to view their orders" ON public.orders;
    DROP POLICY IF EXISTS "Allow client to insert their own order" ON public.orders;
    DROP POLICY IF EXISTS "Allow kitchen to update order" ON public.orders;
END $$;

-- Crear políticas PROFILES
CREATE POLICY "Allow public read access to profiles" 
  ON public.profiles FOR SELECT USING (true);

CREATE POLICY "Allow users to update their own profile" 
  ON public.profiles FOR UPDATE USING (auth.uid() = id);

CREATE POLICY "Allow users to insert their own profile" 
  ON public.profiles FOR INSERT WITH CHECK (auth.uid() = id);

-- Crear políticas RECIPES
CREATE POLICY "Allow public read access to recipes" 
  ON public.recipes FOR SELECT USING (true);

CREATE POLICY "Allow creator to insert their own recipe" 
  ON public.recipes FOR INSERT WITH CHECK (auth.uid() = creator_id);

CREATE POLICY "Allow creator to update their own recipe" 
  ON public.recipes FOR UPDATE USING (auth.uid() = creator_id);

CREATE POLICY "Allow creator to delete their own recipe" 
  ON public.recipes FOR DELETE USING (auth.uid() = creator_id);

-- Crear políticas AGREEMENTS
CREATE POLICY "Allow involved users to view agreements" 
  ON public.agreements FOR SELECT 
  USING (auth.uid() = creator_id OR auth.uid() = kitchen_id);

CREATE POLICY "Allow creator to insert agreement request" 
  ON public.agreements FOR INSERT 
  WITH CHECK (auth.uid() = creator_id);

CREATE POLICY "Allow creator to update agreement status" 
  ON public.agreements FOR UPDATE 
  USING (auth.uid() = creator_id);

-- Crear políticas ORDERS
CREATE POLICY "Allow client and kitchen to view their orders" 
  ON public.orders FOR SELECT 
  USING (auth.uid() = client_id OR auth.uid() = kitchen_id);

CREATE POLICY "Allow client to insert their own order" 
  ON public.orders FOR INSERT 
  WITH CHECK (auth.uid() = client_id);

CREATE POLICY "Allow kitchen to update order" 
  ON public.orders FOR UPDATE 
  USING (auth.uid() = kitchen_id);

-- PASO 8: Habilitar Realtime (CORREGIDO)
DO $$ 
BEGIN
    -- Intentar eliminar de la publicación (ignorar errores si no existen)
    BEGIN
        ALTER PUBLICATION supabase_realtime DROP TABLE agreements;
    EXCEPTION WHEN OTHERS THEN NULL;
    END;
    
    BEGIN
        ALTER PUBLICATION supabase_realtime DROP TABLE orders;
    EXCEPTION WHEN OTHERS THEN NULL;
    END;
    
    BEGIN
        ALTER PUBLICATION supabase_realtime DROP TABLE recipes;
    EXCEPTION WHEN OTHERS THEN NULL;
    END;
    
    -- Agregar a la publicación (ignorar errores si ya existen)
    BEGIN
        ALTER PUBLICATION supabase_realtime ADD TABLE agreements;
    EXCEPTION WHEN OTHERS THEN NULL;
    END;
    
    BEGIN
        ALTER PUBLICATION supabase_realtime ADD TABLE orders;
    EXCEPTION WHEN OTHERS THEN NULL;
    END;
    
    BEGIN
        ALTER PUBLICATION supabase_realtime ADD TABLE recipes;
    EXCEPTION WHEN OTHERS THEN NULL;
    END;
END $$;

-- PASO 9: Crear trigger para nuevos usuarios
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
  INSERT INTO public.profiles (id, role)
  VALUES (NEW.id, 'cliente')
  ON CONFLICT (id) DO NOTHING;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();


-- Función para aceptar pedidos de forma atómica
CREATE OR REPLACE FUNCTION accept_order_atomically(
  p_order_id bigint,
  p_kitchen_id uuid
)
RETURNS json
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  v_current_kitchen_id uuid;
  v_current_status text;
  v_result json;
BEGIN
  -- Bloquear la fila para evitar condiciones de carrera
  SELECT kitchen_id, status 
  INTO v_current_kitchen_id, v_current_status
  FROM orders 
  WHERE id = p_order_id
  FOR UPDATE;
  
  -- Verificar si el pedido ya fue tomado
  IF v_current_kitchen_id IS NOT NULL THEN
    v_result := json_build_object(
      'success', false,
      'message', 'Este pedido ya fue tomado por otra cocina'
    );
    RETURN v_result;
  END IF;
  
  -- Verificar si el estado es correcto
  IF v_current_status != 'PENDING_ACCEPTANCE' THEN
    v_result := json_build_object(
      'success', false,
      'message', 'Este pedido ya no está disponible'
    );
    RETURN v_result;
  END IF;
  
  -- Actualizar el pedido
  UPDATE orders
  SET 
    kitchen_id = p_kitchen_id,
    status = 'ACCEPTED'
  WHERE id = p_order_id;
  
  v_result := json_build_object(
    'success', true,
    'message', 'Pedido aceptado correctamente'
  );
  
  RETURN v_result;
END;
$$;

3....
-- Eliminar la política existente
DROP POLICY IF EXISTS "Allow client and kitchen to view their orders" ON public.orders;

-- Crear nueva política que permite a cocineros ver pedidos pendientes
CREATE POLICY "Allow users to view relevant orders" 
  ON public.orders FOR SELECT 
  USING (
    -- El cliente puede ver sus propios pedidos
    auth.uid() = client_id 
    OR 
    -- La cocina puede ver pedidos que le fueron asignados
    auth.uid() = kitchen_id
    OR
    -- Los cocineros pueden ver pedidos pendientes de sus recetas aprobadas
    (
      status = 'PENDING_ACCEPTANCE' 
      AND kitchen_id IS NULL
      AND recipe_id IN (
        SELECT recipe_id 
        FROM agreements 
        WHERE kitchen_id = auth.uid() 
        AND status = 'APPROVED'
      )
    )
  );
```

## 📝 Explicación de la nueva política:

Esta política permite que un usuario vea un pedido si:

1. ✅ Es el **cliente** que hizo el pedido (`auth.uid() = client_id`)
2. ✅ Es la **cocina** asignada al pedido (`auth.uid() = kitchen_id`)
3. ✅ Es un **cocinero** que tiene la receta **aprobada** Y el pedido está **pendiente** Y no tiene cocina asignada

## 🧪 Después de ejecutar esto:

1. **Hot restart** de tu app
2. Los logs deberían mostrar:
```
🔍 REPO DEBUG: Raw response: [{...}]  // ← Ya no vacío
🔍 REPO DEBUG: Parsed 1 orders
   - Order: X, Recipe: xxx-xxx, Kitchen: null
🔍 DEBUG: Received 1 pending orders

4...
-- 1. Agregar campos de personalización al perfil
ALTER TABLE profiles 
  ADD COLUMN IF NOT EXISTS location_city TEXT,
  ADD COLUMN IF NOT EXISTS dislikes TEXT[],
  ADD COLUMN IF NOT EXISTS allergies TEXT[];

-- 2. Actualizar política RLS de orders para pedidos de IA
DROP POLICY IF EXISTS "Allow users to view relevant orders" ON public.orders;

CREATE POLICY "Allow users to view relevant orders" 
  ON public.orders FOR SELECT 
  USING (
    -- El cliente ve sus propios pedidos
    auth.uid() = client_id 
    OR 
    -- La cocina ve pedidos asignados
    auth.uid() = kitchen_id
    OR
    -- Cocineros ven pedidos pendientes de recetas aprobadas
    (
      status = 'PENDING_ACCEPTANCE' 
      AND kitchen_id IS NULL
      AND recipe_id IN (
        SELECT recipe_id 
        FROM agreements 
        WHERE kitchen_id = auth.uid() 
        AND status = 'APPROVED'
      )
    )
    OR
    -- NUEVO: Cocineros ven TODOS los pedidos de IA (sin convenio)
    (
      status = 'PENDING_ACCEPTANCE'
      AND kitchen_id IS NULL
      AND recipe_id IN (
        SELECT id 
        FROM recipes 
        WHERE type = 'AI_GENERATED'
      )
    )
  );

5----
-- Eliminar el trigger anterior
DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
DROP FUNCTION IF EXISTS public.handle_new_user();

-- Crear nueva función que NO asigna rol
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
  -- Crear perfil vacío, SIN rol asignado
  INSERT INTO public.profiles (id)
  VALUES (NEW.id)
  ON CONFLICT (id) DO NOTHING;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Recrear el trigger
CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();
--6
-- 1. Eliminar la política de UPDATE existente que está causando el conflicto.
DROP POLICY IF EXISTS "Allow users to update their own profile" ON public.profiles;

-- 2. Crear una nueva política de UPDATE que use 'WITH CHECK'.
-- 'WITH CHECK' se asegura de que el usuario solo pueda modificar su propia fila,
-- que es exactamente lo que necesitamos al crear/actualizar el perfil.
CREATE POLICY "Allow users to update their own profile"
  ON public.profiles FOR UPDATE
  USING (true) -- Permite que la operación de UPDATE comience para cualquier fila
  WITH CHECK (auth.uid() = id); -- PERO solo la completa si el ID coincide con el del usuario.

---
Desde el 5 y 6 es para de arreglar lo que no deja poner roll y el roll se pone solito como cliente antes 
de eso no se que tocamos y se daño esa parte 
---
7-----
-- PASO 1: Eliminar el trigger y la función existentes.
DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
DROP FUNCTION IF EXISTS public.handle_new_user();

-- PASO 2: Recrear la función, pero esta vez con la configuración de seguridad correcta.
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
  -- Insertamos el perfil vacío, SIN rol asignado.
  INSERT INTO public.profiles (id)
  VALUES (NEW.id)
  ON CONFLICT (id) DO NOTHING;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql 
-- ¡ESTA ES LA LÍNEA CLAVE! Le dice a Supabase que ejecute esta función
-- con los permisos del creador de la función (el superusuario), saltándose las RLS.
SECURITY DEFINER;

-- PASO 3: Recrear el trigger para que use la nueva función.
CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();

