-- Este archivo contiene una vista reutilizable y consultas de ejemplo para
-- generar reportes de reservas, disponibilidad, clientes y cambios de precios.
-- =============================================================
-- 4. VISTAS Y CONSULTAS SQL
-- =============================================================

-- A. Vista requerida: presenta datos de reserva junto con el cliente y el salón.
-- Una vista es una consulta guardada que se puede consultar como si fuera una tabla.
CREATE OR REPLACE VIEW vista_resumen_reservas AS
SELECT
    c.nombre_completo AS nombre_cliente, -- Nombre de la persona o empresa.
    s.nombre AS nombre_salon, -- Salón relacionado con la reserva.
    r.fecha_inicio, -- Fecha y hora en que empieza el evento.
    r.fecha_fin, -- Fecha y hora en que termina el evento.
    r.valor_total AS total, -- Importe total calculado, incluido el IVA.
    s.estado AS estado -- Estado actual del salón.
FROM reservas r
-- INNER JOIN relaciona las filas usando sus llaves; solo muestra reservas
-- que tienen un cliente y un salón asociados.
INNER JOIN clientes c ON r.cliente_id = c.id
INNER JOIN salones s ON r.salon_id = s.id;

-- B. Consultar reservas cuya fecha de inicio cae dentro del rango indicado.
-- BETWEEN incluye ambos extremos; los horarios abarcan todo noviembre de 2026.
SELECT *
FROM reservas
WHERE fecha_inicio BETWEEN '2026-11-01 00:00:00' AND '2026-11-30 23:59:59';

-- C. Listar salones disponibles cuya capacidad supera las 100 personas.
-- Cambia 100 por el mínimo de capacidad que necesites consultar.
SELECT *
FROM salones
WHERE capacidad > 100
    AND estado = 'Disponible';

-- D. Contar reservas por cliente y mostrar solo empresas con más de tres.
-- COUNT cuenta las reservas; GROUP BY agrupa por cliente y HAVING filtra el conteo.
SELECT c.id, c.nombre_completo, c.identificacion, COUNT(r.id) AS total_reservas
FROM clientes c
INNER JOIN reservas r ON c.id = r.cliente_id
WHERE c.tipo_cliente = 'Corporativo'
GROUP BY c.id, c.nombre_completo, c.identificacion
HAVING COUNT(r.id) > 3;

-- E. Consultar la vista creada en la sección A para ver el resumen completo.
SELECT * FROM vista_resumen_reservas;

-- F. Consultar el historial que llena automáticamente el trigger de auditoría.
SELECT * FROM auditoria_precios;

-- Prueba opcional del trigger de auditoría:
-- descomenta la instrucción siguiente para cambiar el precio del salón 1.
-- El cambio es permanente hasta que se vuelva a actualizar manualmente.
-- UPDATE salones SET precio_por_hora = 90000.00 WHERE id = 1;

