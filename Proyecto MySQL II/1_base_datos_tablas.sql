-- =============================================================
-- PROYECTO MySQL: SISTEMA DE GESTIÓN DE RESERVAS PARA SALONES
-- Este archivo crea la base de datos, sus tablas relacionadas y
-- algunos registros iniciales para poder probar el sistema.
-- =============================================================

-- 1. Crear y seleccionar la base de datos.
-- IF NOT EXISTS evita un error si la base ya fue creada anteriormente.
CREATE DATABASE IF NOT EXISTS gestion_reservas;
USE gestion_reservas;

-- 2. Preparar una instalación limpia.
-- Se eliminan primero las tablas dependientes para respetar las llaves foráneas.
-- ATENCIÓN: al ejecutar este bloque nuevamente, se borran los datos existentes.
DROP TABLE IF EXISTS pagos;
DROP TABLE IF EXISTS auditoria_precios;
-- Elimina también el nombre antiguo de la tabla de auditoría, si existe.
DROP TABLE IF EXISTS auditoria_precio;
DROP TABLE IF EXISTS reservas;
DROP TABLE IF EXISTS salones;
DROP TABLE IF EXISTS clientes;

-- 3. Crear las tablas (DDL significa lenguaje de definición de datos).

-- Catálogo de los salones que ofrece la empresa.
CREATE TABLE salones (
    id INT AUTO_INCREMENT PRIMARY KEY, -- Identificador único, generado automáticamente.
    nombre VARCHAR(100) NOT NULL, -- Nombre que identifica al salón.
    capacidad INT NOT NULL, -- Número máximo de personas que puede recibir.
    precio_por_hora DECIMAL(10, 2) NOT NULL, -- Tarifa por hora, con dos decimales.
    estado ENUM('Disponible', 'En mantenimiento', 'Ocupado') DEFAULT 'Disponible', -- Solo admite estos estados; inicia disponible.
    encargado_responsable VARCHAR(100) NOT NULL -- Persona responsable del salón.
);

-- Información de las personas o empresas que realizan reservas.
CREATE TABLE clientes (
    id INT AUTO_INCREMENT PRIMARY KEY, -- Identificador interno del cliente.
    identificacion VARCHAR(20) UNIQUE NOT NULL, -- Documento o identificación empresarial; no se puede repetir.
    nombre_completo VARCHAR(150) NOT NULL, -- Nombre de la persona o razón social.
    telefono VARCHAR(20), -- Dato opcional de contacto telefónico.
    correo_electronico VARCHAR(100) UNIQUE, -- Correo opcional; si se registra, debe ser único.
    tipo_cliente ENUM('Individual', 'Corporativo') NOT NULL -- Clasifica al cliente en una de las dos categorías.
);

-- Cada fila representa el uso de un salón por parte de un cliente durante un intervalo.
CREATE TABLE reservas (
    id INT AUTO_INCREMENT PRIMARY KEY, -- Identificador único de la reserva.
    cliente_id INT NOT NULL, -- Cliente que solicita el servicio.
    salon_id INT NOT NULL, -- Salón que se va a utilizar.
    fecha_inicio DATETIME NOT NULL, -- Fecha y hora de inicio.
    fecha_fin DATETIME NOT NULL, -- Fecha y hora de finalización.
    total_horas DECIMAL(5, 2), -- Duración calculada por el trigger antes de guardar.
    valor_total DECIMAL(10, 2), -- Precio calculado por el trigger, incluyendo IVA.
    -- Las llaves foráneas garantizan que cliente y salón existan.
    -- ON DELETE CASCADE elimina sus reservas cuando se elimina el cliente o salón.
    FOREIGN KEY (cliente_id) REFERENCES clientes(id) ON DELETE CASCADE,
    FOREIGN KEY (salon_id) REFERENCES salones(id) ON DELETE CASCADE
);

-- Pagos asociados a una reserva; una reserva puede tener uno o varios pagos.
CREATE TABLE pagos (
    id INT AUTO_INCREMENT PRIMARY KEY, -- Identificador único del pago.
    reserva_id INT NOT NULL, -- Reserva a la que corresponde el pago.
    fecha_pago DATETIME DEFAULT CURRENT_TIMESTAMP, -- Si no se indica, usa la fecha y hora actuales.
    monto_pagado DECIMAL(10, 2) NOT NULL, -- Cantidad de dinero recibida.
    metodo_pago ENUM('Efectivo', 'Tarjeta', 'Transferencia') NOT NULL, -- Medio usado para pagar.
    -- Si se elimina la reserva, también se eliminan sus pagos asociados.
    FOREIGN KEY (reserva_id) REFERENCES reservas(id) ON DELETE CASCADE
);

-- Historial de cambios de las tarifas. El trigger de auditoría inserta aquí cada cambio.
CREATE TABLE auditoria_precios (
    id INT AUTO_INCREMENT PRIMARY KEY, -- Identificador del registro de auditoría.
    salon_id INT NOT NULL, -- Salón cuyo precio cambió.
    usuario VARCHAR(100) DEFAULT (CURRENT_USER()), -- Usuario de MySQL que hizo el cambio.
    fecha DATETIME DEFAULT CURRENT_TIMESTAMP, -- Momento en que se registró el cambio.
    valor_anterior DECIMAL(10, 2), -- Tarifa antes de la actualización.
    valor_nuevo DECIMAL(10, 2), -- Tarifa después de la actualización.
    FOREIGN KEY (salon_id) REFERENCES salones(id) ON DELETE CASCADE
);

-- 4. Datos de prueba: salones disponibles con capacidades y tarifas distintas.
INSERT INTO salones (nombre, capacidad, precio_por_hora, estado, encargado_responsable) VALUES
('Salón Esmeralda', 120, 80000.00, 'Disponible', 'Carlos Pérez'),
('Salón Diamante', 50, 45000.00, 'Disponible', 'Ana Gómez'),
('Salón Zafiro', 200, 150000.00, 'Disponible', 'Luis Torres');

-- Clientes de prueba: una persona individual y dos clientes corporativos.
INSERT INTO clientes (identificacion, nombre_completo, telefono, correo_electronico, tipo_cliente) VALUES
('1098765432', 'Sofía Ramírez', '3101234567', 'sofia@gmail.com', 'Individual'),
('900123456', 'Tecnologías del Caribe S.A.S', '3209876543', 'contacto@tecscaribe.com', 'Corporativo'),
('800987654', 'Inversiones Globales Ltda', '3154567890', 'admin@invglobal.com', 'Corporativo');

-- Reserva inicial de ejemplo: cliente 2 usa el salón 1 durante cuatro horas.
-- El importe de ejemplo corresponde a 4 horas x $80 000 + IVA del 19 %.
-- Estos valores se escriben aquí porque los triggers se crean después, en el script 3.
INSERT INTO reservas (cliente_id, salon_id, fecha_inicio, fecha_fin, total_horas, valor_total) VALUES
(2, 1, '2026-11-01 10:00:00', '2026-11-01 14:00:00', 4.0, 380800.00);

-- Pago de ejemplo asociado a la reserva inicial.
INSERT INTO pagos (reserva_id, monto_pagado, metodo_pago) VALUES
(1, 380800.00, 'Transferencia');
