-- Los triggers son acciones automáticas de MySQL que se ejecutan al insertar,
-- modificar o eliminar filas. Aquí se validan y calculan reservas, se actualiza
-- el estado de los salones y se conserva un historial de cambios de precio.
-- Se usa // como delimitador temporal porque cada trigger contiene varios ;.
DELIMITER //

-- Antes de insertar una reserva, calcula sus horas e importe y valida el horario.
-- Se elimina primero la definición anterior para que este script sea repetible.
DROP TRIGGER IF EXISTS calcular_totales_reserva_insert//
CREATE TRIGGER calcular_totales_reserva_insert
BEFORE INSERT ON reservas
FOR EACH ROW
BEGIN
    DECLARE v_precio_hora DECIMAL(10,2); -- Tarifa actual del salón solicitado.

    -- Impide guardar una reserva sin un intervalo de tiempo válido.
    IF NEW.fecha_inicio IS NULL OR NEW.fecha_fin IS NULL OR NEW.fecha_fin <= NEW.fecha_inicio THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'La fecha de fin debe ser posterior a la fecha de inicio.';
    END IF;

    -- NEW representa los valores que se están intentando guardar.
    -- La función devuelve 0 si el horario no está disponible o el salón no es válido.
    IF verificar_disponibilidad(NEW.salon_id, NEW.fecha_inicio, NEW.fecha_fin) = 0 THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'El salón no existe, está en mantenimiento o ya tiene una reserva en ese horario.';
    END IF;

    -- Obtener la tarifa vigente para calcular el total de esta reserva.
    SELECT precio_por_hora INTO v_precio_hora
    FROM salones
    WHERE id = NEW.salon_id;

    -- TIMESTAMPDIFF calcula minutos; se divide entre 60 para guardar horas.
    -- La función agrega el IVA y devuelve el valor final.
    SET NEW.total_horas = TIMESTAMPDIFF(MINUTE, NEW.fecha_inicio, NEW.fecha_fin) / 60;
    SET NEW.valor_total = calcular_total_reserva(v_precio_hora, NEW.total_horas);
END //

-- Si cambian las fechas o el salón de una reserva, volver a calcular duración
-- e importe antes de guardar la modificación. Este trigger valida el intervalo,
-- pero no comprueba si el nuevo horario se cruza con otra reserva.
DROP TRIGGER IF EXISTS calcular_totales_reserva_update//
CREATE TRIGGER calcular_totales_reserva_update
BEFORE UPDATE ON reservas
FOR EACH ROW
BEGIN
    DECLARE v_precio_hora DECIMAL(10,2); -- Tarifa actual del salón de la reserva.

    -- Validar que el nuevo intervalo siga teniendo una duración positiva.
    IF NEW.fecha_inicio IS NULL OR NEW.fecha_fin IS NULL OR NEW.fecha_fin <= NEW.fecha_inicio THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'La fecha de fin debe ser posterior a la fecha de inicio.';
    END IF;

    -- Buscar el precio actual asociado al salón indicado en la fila nueva.
    SELECT precio_por_hora INTO v_precio_hora
    FROM salones
    WHERE id = NEW.salon_id;

    -- Actualizar automáticamente ambos valores derivados de fechas y tarifa.
    SET NEW.total_horas = TIMESTAMPDIFF(MINUTE, NEW.fecha_inicio, NEW.fecha_fin) / 60;
    SET NEW.valor_total = calcular_total_reserva(v_precio_hora, NEW.total_horas);
END //

-- Después de guardar una reserva, el salón asociado queda marcado como ocupado.
DROP TRIGGER IF EXISTS actualizar_estado_salon_trigger//
CREATE TRIGGER actualizar_estado_salon_trigger
AFTER INSERT ON reservas
FOR EACH ROW
BEGIN
    -- NEW.salon_id es el salón de la reserva recién creada.
    UPDATE salones 
    SET estado = 'Ocupado' 
    WHERE id = NEW.salon_id;
END //

-- Después de borrar una reserva, recalcular el estado del salón.
-- Si aún conserva reservas queda Ocupado; si no, queda Disponible.
-- Un salón que esté en mantenimiento conserva ese estado.
DROP TRIGGER IF EXISTS liberar_salon_trigger//
CREATE TRIGGER liberar_salon_trigger
AFTER DELETE ON reservas
FOR EACH ROW
BEGIN
    -- OLD contiene los valores que tenía la reserva antes de eliminarla.
    UPDATE salones
    SET estado = CASE
        WHEN estado = 'En mantenimiento' THEN 'En mantenimiento'
        WHEN EXISTS (SELECT 1 FROM reservas WHERE salon_id = OLD.salon_id)
            THEN 'Ocupado'
        ELSE 'Disponible'
    END
    WHERE id = OLD.salon_id;
END //

-- Después de modificar un salón, registrar únicamente los cambios de tarifa.
-- Los cambios de nombre, estado o encargado no generan una fila de auditoría.
DROP TRIGGER IF EXISTS auditoria_precios_trigger//
CREATE TRIGGER auditoria_precios_trigger
AFTER UPDATE ON salones
FOR EACH ROW
BEGIN
    -- Comparar OLD (valor anterior) con NEW (valor actualizado).
    IF OLD.precio_por_hora <> NEW.precio_por_hora THEN
        -- Guardar el salón, usuario, fecha y ambos valores para mantener trazabilidad.
        INSERT INTO auditoria_precios (salon_id, usuario, fecha, valor_anterior, valor_nuevo)
        VALUES (NEW.id, USER(), NOW(), OLD.precio_por_hora, NEW.precio_por_hora);
    END IF;
END //

-- Restaurar el delimitador normal para las sentencias ejecutadas después de este archivo.
DELIMITER ;
