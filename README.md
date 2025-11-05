# ghost_food

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

PasswordSupabase=djhz7cnzqB.*3Kq

8oCBOVZZfsYfyyWg

Q86kubhwR1bzXjPR

W4NseHkZNa9MMTRe

-- =================================================================
-- POLÍTICAS DE SEGURIDAD PARA EL BUCKET: product_images (CORREGIDO)
-- =================================================================

-- 1. POLÍTICA DE LECTURA PÚBLICA (SELECT)
-- Esta política no necesita cambios.
CREATE POLICY "Public read access for product images"
ON storage.objects FOR SELECT
USING ( bucket_id = 'product_images' );


-- 2. POLÍTICA DE SUBIDA PARA COCINEROS (INSERT)
-- CORRECCIÓN: Se añade '::text' para convertir el UUID a texto y poder compararlo.
CREATE POLICY "Allow cook to upload to own folder"
ON storage.objects FOR INSERT
TO authenticated
WITH CHECK ( (bucket_id = 'product_images') AND ((storage.foldername(name))[1] = auth.uid()::text) );


-- 3. POLÍTICA DE ACTUALIZACIÓN PARA COCINEROS (UPDATE)
-- CORRECCIÓN: Se añade '::text' también aquí para la consistencia.
CREATE POLICY "Allow cook to update images in own folder"
ON storage.objects FOR UPDATE
TO authenticated
USING ( (bucket_id = 'product_images') AND ((storage.foldername(name))[1] = auth.uid()::text) );
