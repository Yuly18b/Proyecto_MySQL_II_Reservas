-- ========================================================
-- 5. CREACIÓN DE LA VISTA
-- ========================================================

CREATE OR REPLACE VIEW vista_resumen_reservas AS
SELECT 
    c.nombre_completo AS nombre_cliente,
    s.nombre AS nombre_salon,
    r.fecha_inicio,
    r.fecha_fin,
    r.valor_total AS total,
    s.estado AS estado_salon
FROM reservas r
JOIN clientes c ON r.cliente_id = c.id
JOIN salones s ON r.salon_id = s.id;


-- ========================================================
-- CONSULTAS DE PRUEBA REQUERIDAS POR EL PROYECTO
-- ========================================================

-- A. Consultar reservas en un rango de fechas
SELECT * FROM reservas 
WHERE fecha_inicio BETWEEN '2026-10-01 00:00:00' AND '2026-12-31 23:59:59';

-- B. Salones con capacidad mayor a 40 y disponibles
SELECT * FROM salones 
WHERE capacidad > 40 AND estado = 'Disponible';

-- C. Clientes corporativos que hayan hecho más de 3 reservas (Con COUNT y HAVING)
SELECT c.id, c.nombre_completo, c.tipo_cliente, COUNT(r.id) AS total_reservas
FROM clientes c
LEFT JOIN reservas r ON c.id = r.cliente_id
WHERE c.tipo_cliente = 'Corporativo'
GROUP BY c.id, c.nombre_completo, c.tipo_cliente
HAVING COUNT(r.id) > 3;

-- D. Consultar la vista general de reservas
SELECT * FROM vista_resumen_reservas;

-- E. Probar actualización de precio en un salón para activar el Trigger de Auditoría
UPDATE salones SET precio_por_hora = 90000.00 WHERE id = 1;

-- F. Ver la tabla de auditoría para comprobar el registro del cambio de precio
SELECT * FROM auditoria_precio;

