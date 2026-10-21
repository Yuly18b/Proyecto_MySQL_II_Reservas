-- =============================================================
-- PROYECTO MyQL: SISTEMA DE GESTIÓN DE RESERVAS PARA SALONES
-- =============================================================

-- 1. Crear Base de Datos
CREATE DATABASE IF NOT EXISTS gestion_reservas;
USE gestion_reservas;

-- Eliminar tablas si ya existen (para evitar errores al repetir pruebas)
DROP TABLE IF EXISTS pagos;
DROP TABLE IF EXISTS auditoria_precio;
DROP TABLE IF EXISTS reservas;
DROP TABLE IF EXISTS salones;
DROP TABLE IF EXISTS clientes;

-- 2. Creación de Tablas (DDL)

CREATE TABLE salones (
    id INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    capacidad INT NOT NULL,
    precio_por_hora DECIMAL(10, 2) NOT NULL,
    estado ENUM('Disponible', 'En mantenimiento', 'Ocupado') DEFAULT 'Disponible',
    encargado_responsable VARCHAR(100) NOT NULL
);

CREATE TABLE clientes (
    id INT AUTO_INCREMENT PRIMARY KEY,
    identificacion VARCHAR(20) UNIQUE NOT NULL,
    nombre_completo VARCHAR(150) NOT NULL,
    telefono VARCHAR(20),
    correo_electronico VARCHAR(100) UNIQUE,
    tipo_cliente ENUM('Individual', 'Corporativo') NOT NULL
);

CREATE TABLE reservas (
    id INT AUTO_INCREMENT PRIMARY KEY,
    cliente_id INT NOT NULL,
    salon_id INT NOT NULL,
    fecha_inicio DATETIME NOT NULL,
    fecha_fin DATETIME NOT NULL,
    total_horas DECIMAL(5, 2),
    valor_total DECIMAL(10, 2),
    FOREIGN KEY (cliente_id) REFERENCES clientes(id) ON DELETE CASCADE,
    FOREIGN KEY (salon_id) REFERENCES salones(id) ON DELETE CASCADE
);

CREATE TABLE pagos (
    id INT AUTO_INCREMENT PRIMARY KEY,
    reserva_id INT NOT NULL,
    fecha_pago DATETIME DEFAULT CURRENT_TIMESTAMP,
    monto_pagado DECIMAL(10, 2) NOT NULL,
    metodo_pago ENUM('Efectivo', 'Tarjeta', 'Transferencia') NOT NULL,
    FOREIGN KEY (reserva_id) REFERENCES reservas(id) ON DELETE CASCADE
);

CREATE TABLE auditoria_precio (
    id INT AUTO_INCREMENT PRIMARY KEY,
    salon_id INT NOT NULL,
    usuario VARCHAR(100) DEFAULT (CURRENT_USER()),
    fecha DATETIME DEFAULT CURRENT_TIMESTAMP,
    valor_anterior DECIMAL(10, 2),
    valor_nuevo DECIMAL(10, 2),
    FOREIGN KEY (salon_id) REFERENCES salones(id) ON DELETE CASCADE
);

-- Insertar Salones
INSERT INTO salones (nombre, capacidad, precio_por_hora, estado, encargado_responsable) VALUES
('Salón Esmeralda', 120, 80000.00, 'Disponible', 'Carlos Pérez'),
('Salón Diamante', 50, 45000.00, 'Disponible', 'Ana Gómez'),
('Salón Zafiro', 200, 150000.00, 'Disponible', 'Luis Torres');

-- Insertar Clientes
INSERT INTO clientes (identificacion, nombre_completo, telefono, correo_electronico, tipo_cliente) VALUES
('1098765432', 'Sofía Ramírez', '3101234567', 'sofia@gmail.com', 'Individual'),
('900123456', 'Tecnologías del Caribe S.A.S', '3209876543', 'contacto@tecscaribe.com', 'Corporativo'),
('800987654', 'Inversiones Globales Ltda', '3154567890', 'admin@invglobal.com', 'Corporativo');


-- Registrar una reserva de prueba (ej: 4 horas en el Salón Esmeralda)
INSERT INTO reservas (cliente_id, salon_id, fecha_inicio, fecha_fin, total_horas, valor_total) VALUES
(2, 1, '2026-11-01 10:00:00', '2026-11-01 14:00:00', 4.0, 380800.00);

-- Registrar un pago de prueba para esa reserva
INSERT INTO pagos (reserva_id, monto_pagado, metodo_pago) VALUES
(1, 380800.00, 'Transferencia');
