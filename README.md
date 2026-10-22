# Sistema de Gestión de Reservas para Salones de Eventos

Proyecto de bases de datos MySQL para Eventos Premier S.A.S.

## Descripción del proyecto

Base de datos relacional desarrollada en MySQL para apoyar la gestión de alquiler de salones para eventos. Permite administrar salones, clientes individuales y corporativos, reservas, pagos y auditoría de cambios en los precios. Incluye funciones almacenadas, triggers, una vista de resumen y consultas de reporte.

## Estructura del repositorio

```text
README.md
Proyecto MySQL II/
├── 1_base_datos_tablas.sql
├── 2_funciones.sql
├── 3_triggers.sql
└── 4_vistas_consultas.sql
```

## Requisitos

- MySQL Server con permisos para crear bases de datos, funciones y triggers.
- Un cliente MySQL, por ejemplo MySQL Workbench o la consola de MySQL.

## Instrucciones de ejecución

1. Clona o descarga este repositorio.
2. Abre los archivos SQL de la carpeta `Proyecto MySQL II` en tu cliente MySQL.
3. Ejecuta los scripts en este orden:
   1. `1_base_datos_tablas.sql`: crea la base `gestion_reservas`, sus tablas y datos de prueba.
   2. `2_funciones.sql`: crea las funciones de cálculo de tarifas y verificación de disponibilidad.
   3. `3_triggers.sql`: crea los triggers de actualización de estados y auditoría de precios.
   4. `4_vistas_consultas.sql`: crea la vista de resumen y ejecuta las consultas de reporte.

> **Importante:** el primer script elimina las tablas existentes antes de volver a crearlas. Al ejecutarlo nuevamente, se perderán los datos guardados en esas tablas.

## Componentes principales

### Funciones almacenadas

- `calcular_total_reserva`: calcula el costo de la reserva incluyendo el IVA del 19 %.
- `verificar_disponibilidad`: comprueba que el salón exista, no esté en mantenimiento y que el intervalo no se cruce con otra reserva; devuelve `1` si está disponible y `0` si no lo está. Los intervalos contiguos se consideran válidos.

Ejemplos para ejecutar después de crear los scripts:

```sql
SELECT calcular_total_reserva(80000.00, 4.00) AS total_con_iva;

SELECT verificar_disponibilidad(
   1,
   '2026-12-01 10:00:00',
   '2026-12-01 14:00:00'
) AS disponible;
```

Las reservas insertadas después de instalar los triggers calculan automáticamente las horas y el valor total según el precio del salón y el IVA. Ejemplo (usar un horario libre y un cliente existente):

```sql
INSERT INTO reservas (cliente_id, salon_id, fecha_inicio, fecha_fin)
VALUES (1, 1, '2026-12-01 10:00:00', '2026-12-01 14:00:00');

SELECT id, total_horas, valor_total
FROM reservas
WHERE id = LAST_INSERT_ID();
```

### Triggers

- `actualizar_estado_salon_trigger`: marca el salón como ocupado al insertar una reserva.
- `liberar_salon_trigger`: vuelve a marcar el salón como disponible al eliminar una reserva.
- `auditoria_precios_trigger`: registra en `auditoria_precios` los cambios en el precio por hora.

Para comprobar la auditoría, cambia el precio y consulta el historial. El cambio de precio permanece guardado:

```sql
UPDATE salones
SET precio_por_hora = 90000.00
WHERE id = 1;

SELECT * FROM auditoria_precios;
```

### Vista y consultas

- `vista_resumen_reservas`: combina la información de las reservas, los clientes y los salones.
- Consultas de reservas en un rango de fechas, salones disponibles por capacidad y clientes corporativos con más de tres reservas.
- Consulta de los registros de auditoría de precios en `auditoria_precios`.

Ejemplos de consultas (también disponibles en `4_vistas_consultas.sql`):

```sql
SELECT *
FROM reservas
WHERE fecha_inicio BETWEEN '2026-11-01 00:00:00' AND '2026-11-30 23:59:59';

SELECT *
FROM salones
WHERE capacidad > 100 AND estado = 'Disponible';

SELECT c.id, c.nombre_completo, c.identificacion, COUNT(r.id) AS total_reservas
FROM clientes c
INNER JOIN reservas r ON c.id = r.cliente_id
WHERE c.tipo_cliente = 'Corporativo'
GROUP BY c.id, c.nombre_completo, c.identificacion
HAVING COUNT(r.id) > 3;

SELECT * FROM vista_resumen_reservas;
```

## Publicación en GitHub

Antes de entregar, confirma que los cuatro scripts y este README estén incluidos en el repositorio y que el último commit esté subido a GitHub. Ejecuta los scripts en el orden indicado en una instancia MySQL de prueba y verifica que se creen las tablas, funciones, triggers y la vista.

## Créditos

- **Autores:** David Santiago Sierra Niño y Nelly Yulied Benítez Martínez.
- **Programa:** Análisis y Desarrollo de Software (SENA) / Campuslands.
