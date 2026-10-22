-- Las funciones almacenadas permiten reutilizar cálculos y reglas de negocio
-- directamente desde consultas y triggers de MySQL.
-- Se cambia temporalmente el delimitador para que MySQL no confunda los ;
-- dentro de cada función con el final de su definición.
DELIMITER //

-- Eliminar la versión anterior permite volver a ejecutar este archivo.
DROP FUNCTION IF EXISTS calcular_total_reserva//
-- Calcula el precio de una reserva antes de guardarlo.
-- Parámetros: precio por hora del salón y duración de la reserva en horas.
-- Resultado: subtotal más IVA del 19 %. Por ejemplo, 80 000 x 4 x 1.19.
CREATE FUNCTION calcular_total_reserva(p_precio_hora DECIMAL(10,2), p_horas DECIMAL(5,2))
RETURNS DECIMAL(10,2)
DETERMINISTIC -- Los mismos valores de entrada siempre producen el mismo resultado.
BEGIN
    DECLARE v_subtotal DECIMAL(10,2); -- Precio antes de impuestos.
    DECLARE v_total DECIMAL(10,2); -- Precio final con IVA.
    SET v_subtotal = p_precio_hora * p_horas; -- Tarifa por hora multiplicada por duración.
    SET v_total = v_subtotal * 1.19; -- Se agrega el IVA del 19 %.
    RETURN v_total; -- Devuelve el importe final al lugar donde se llamó la función.
END //

-- Eliminar la versión anterior antes de crear la función de disponibilidad.
DROP FUNCTION IF EXISTS verificar_disponibilidad//
-- Revisa si el salón puede reservarse durante las fechas recibidas.
-- Devuelve 1 cuando puede reservarse y 0 si los datos no son válidos,
-- el salón no existe, está en mantenimiento o el horario se cruza con otra reserva.
CREATE FUNCTION verificar_disponibilidad(p_salon_id INT, p_fecha_inicio DATETIME, p_fecha_fin DATETIME)
RETURNS INT
NOT DETERMINISTIC -- El resultado depende del estado actual de las tablas.
READS SQL DATA -- La función consulta información, pero no modifica tablas.
BEGIN
    DECLARE v_estado VARCHAR(30); -- Estado actual del salón.
    DECLARE v_consecutivos INT; -- Cantidad de reservas que coinciden en horario.

    -- Rechazar valores incompletos o un intervalo de duración cero/negativa.
    IF p_salon_id IS NULL OR p_fecha_inicio IS NULL OR p_fecha_fin IS NULL
       OR p_fecha_fin <= p_fecha_inicio THEN
        RETURN 0;
    END IF;

    -- Leer el estado del salón. Si no se encuentra, v_estado queda NULL.
    SELECT estado INTO v_estado FROM salones WHERE id = p_salon_id;
    IF v_estado IS NULL OR v_estado = 'En mantenimiento' THEN
        RETURN 0;
    END IF;

    -- Dos intervalos se cruzan cuando la reserva existente empieza antes de
    -- que termine la nueva y termina después de que esta empiece. Si solo se
    -- tocan en el límite (por ejemplo, una termina a las 10 y otra inicia a las 10),
    -- no se consideran cruzadas.
    SELECT COUNT(*) INTO v_consecutivos
    FROM reservas
    WHERE salon_id = p_salon_id
      AND fecha_inicio < p_fecha_fin
      AND fecha_fin > p_fecha_inicio;

    -- Una o más coincidencias significa que el salón ya tiene una reserva en ese horario.
    IF v_consecutivos > 0 THEN
        RETURN 0;
    ELSE
        RETURN 1;
    END IF;
END //

DELIMITER ;
