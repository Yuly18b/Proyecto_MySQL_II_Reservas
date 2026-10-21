DELIMITER //

DROP FUNCTION IF EXISTS calcular_total_reserva//
CREATE FUNCTION calcular_total_reserva(p_precio_hora DECIMAL(10,2), p_horas DECIMAL(5,2))
RETURNS DECIMAL(10,2)
DETERMINISTIC
BEGIN
    DECLARE v_subtotal DECIMAL(10,2);
    DECLARE v_total DECIMAL(10,2);
    SET v_subtotal = p_precio_hora * p_horas;
    SET v_total = v_subtotal * 1.19; -- IVA del 19%
    RETURN v_total;
END //

DROP FUNCTION IF EXISTS verificar_disponibilidad//
CREATE FUNCTION verificar_disponibilidad(p_salon_id INT, p_fecha_inicio DATETIME, p_fecha_fin DATETIME)
RETURNS INT
DETERMINISTIC
BEGIN
    DECLARE v_estado VARCHAR(30);
    DECLARE v_consecutivos INT;

    SELECT estado INTO v_estado FROM salones WHERE id = p_salon_id;
    IF v_estado <> 'Disponible' THEN
        RETURN 0;
    END IF;

    SELECT COUNT(*) INTO v_consecutivos 
    FROM reservas 
    WHERE salon_id = p_salon_id 
      AND (
          (p_fecha_inicio BETWEEN fecha_inicio AND fecha_fin) OR
          (p_fecha_fin BETWEEN fecha_inicio AND fecha_fin) OR
          (fecha_inicio BETWEEN p_fecha_inicio AND p_fecha_fin)
      );

    IF v_consecutivos > 0 THEN
        RETURN 0;
    ELSE
        RETURN 1;
    END IF;
END //

DELIMITER ;
