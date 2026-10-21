DELIMITER //

DROP TRIGGER IF EXISTS actualizar_estado_salon_trigger//
CREATE TRIGGER actualizar_estado_salon_trigger
AFTER INSERT ON reservas
FOR EACH ROW
BEGIN
    UPDATE salones 
    SET estado = 'Ocupado' 
    WHERE id = NEW.salon_id;
END //

DROP TRIGGER IF EXISTS liberar_salon_trigger//
CREATE TRIGGER liberar_salon_trigger
AFTER DELETE ON reservas
FOR EACH ROW
BEGIN
    UPDATE salones 
    SET estado = 'Disponible' 
    WHERE id = OLD.salon_id;
END //

DROP TRIGGER IF EXISTS auditoria_precios_trigger//
CREATE TRIGGER auditoria_precios_trigger
AFTER UPDATE ON salones
FOR EACH ROW
BEGIN
    IF OLD.precio_por_hora <> NEW.precio_por_hora THEN
        INSERT INTO auditoria_precio (salon_id, usuario, fecha, valor_anterior, valor_nuevo)
        VALUES (NEW.id, USER(), NOW(), OLD.precio_por_hora, NEW.precio_por_hora);
    END IF;
END //

DELIMITER ;
