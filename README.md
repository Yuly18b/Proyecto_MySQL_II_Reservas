# Sistema de Gestión de Reservas para Salones de Eventos (Proyecto MySQL II)

## 📌 Descripción del Proyecto
Este proyecto es una solución integral basada en MySQL diseñada para automatizar y gestionar el proceso de reservas de salones de eventos de la empresa. El sistema permite administrar de forma eficiente los salones disponibles, los clientes (individuales y corporativos), las reservas con cálculo automático de horas e IVA, los pagos y un sistema de control mediante triggers y auditoría de precios.

---

## 🛠️ Estructura del Repositorio
Los scripts están organizados de forma modular siguiendo las buenas prácticas de desarrollo:

```text
📁 Proyecto-1-Gestion-Reservas/
│
├── 📄 README.md
└── 📁 database/
    ├── 📄 1_base_datos_tablas.sql    (Creación de BD, tablas y datos de prueba)
    ├── 📄 2_funciones.sql         (Funciones de cálculo total con IVA y disponibilidad)
    ├── 📄 3_triggers.sql          (Disparadores para control de estados y auditoría)
    └── 📄 4_vistas_consultas.sql    (Vistas relacionales y consultas clave)


🚀 Instrucciones de Ejecución
Para poner en marcha la base de datos de forma correcta, ejecuta los scripts en tu gestor MySQL (como MySQL Workbench) en el siguiente orden estricto:

1_base_datos_tablas.sql: Crea la base de datos gestion_reservas, establece las relaciones entre las tablas e inserta los registros iniciales de prueba.

2_funciones.sql: Crea las funciones lógicas almacenadas en el servidor.

3_triggers.sql: Configura los disparadores automáticos para la gestión de estados y auditoría.

4_vistas_consultas.sql: Genera la vista resumen y ejecuta las consultas analíticas del negocio.

⚙️ Funcionalidades y Componentes Principales
1. Funciones Almacenadas
calcular_total_reserva(precio_hora, horas): Calcula el costo total multiplicando las horas por el precio por hora y aplicando automáticamente el 19% de IVA.

verificar_disponibilidad(salon_id, fecha_inicio, fecha_fin): Valida si un salón está libre y sin cruces de horarios, retornando 1 (Disponible) o 0 (Ocupado/Mantenimiento).

2. Triggers (Disparadores)
actualizar_estado_salon_trigger: Cambia automáticamente el estado del salón a Ocupado al momento de registrar una nueva reserva.

liberar_salon_trigger: Devuelve el estado del salón a Disponible cuando se elimina una reserva.

auditoria_precios_trigger: Registra automáticamente en la tabla auditoria_precio los cambios de tarifas realizados, guardando el usuario, la fecha y los valores anterior y nuevo.

3. Vistas y Consultas Clave
vista_resumen_reservas: Vista que unifica la información del cliente, el salón, las fechas, el estado y el valor total de la reserva.

Consultas avanzadas: Incluye filtros por rangos de fechas (BETWEEN), capacidades de salones e identificación de clientes corporativos con más de 3 reservas (GROUP BY y HAVING).

👥 Créditos y Autores

Desarrollador: David Sierra

Desarrolladora: Nelly Yulied Benítez Martínez

Institución / Programa: Campuslands - Proyecto Base de Datos MysQL II
