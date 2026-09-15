# Tienda V9

Versión multi-dispositivo con Supabase.

## 1. Crear base de datos
En Supabase abre **SQL Editor** y ejecuta `supabase_schema.sql`.
Después ejecuta `seed_tienda.sql`.

## 2. Configurar la aplicación
Abre `index.html`, o publícala en GitHub Pages. La pantalla inicial solicita:
- Supabase Project URL
- Supabase Publishable Key
- correo y contraseña

La URL y la clave publicable se guardan en el navegador. Nunca coloques una `secret key` o `service_role` en este archivo.

## 3. Publicar en GitHub
Sube los archivos a un repositorio y activa GitHub Pages.

## 4. iPhone
Abre la URL publicada en Safari → Compartir → Añadir a pantalla de inicio.

## 5. Funciones V9
- Base central en la nube.
- Productos/precios.
- Inventario y proveedores.
- Ventas contado/crédito.
- Cliente obligatorio para crédito.
- Estado de cuenta conectado a ventas y abonos.
- Edición/eliminación de ventas.
- Corrección transaccional del inventario al editar/eliminar ventas.
- Abonos con validación contra saldo.
- Login.
- PWA.

Nota: Supabase debe tener RLS habilitado y las políticas del archivo SQL deben estar aplicadas.


## V9.1 — Correcciones
- Proveedores: ahora se pueden editar los registros existentes.
- Inventario: ahora se puede agregar y editar existencia/proveedor desde el formulario.
- Productos nuevos: se crea automáticamente su registro de inventario con existencia 0.
- Clientes: el formulario queda preparado para edición.
- Se actualizó el caché de la PWA para evitar que el navegador conserve la versión anterior.
