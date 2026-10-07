/* =====================================================================
   Retail_Ventas - Consultas de análisis exploratorio (EDA)
   Ejecutar sobre las tablas creadas con 01_crear_tablas_y_cargar_datos.sql
   ===================================================================== */

-- 1. Volumen y período de las ventas
SELECT
    COUNT(*)                     AS cantidad_ventas,
    COUNT(DISTINCT customer_id)  AS clientes_con_compras,
    COUNT(DISTINCT product_id)   AS productos_vendidos,
    MIN(fecha_compra)            AS primera_venta,
    MAX(fecha_compra)            AS ultima_venta,
    SUM(monto_total)             AS ventas_totales
FROM dbo.ventas;

-- 2. Distribución de unidades por venta
SELECT
    cantidad,
    COUNT(*) AS cantidad_ventas
FROM dbo.ventas
GROUP BY cantidad
ORDER BY cantidad;

-- 3. Ventas por segmento de cliente (transacciones, monto y ticket promedio)
SELECT
    cli.segmento,
    COUNT(*)                                   AS cantidad_ventas,
    SUM(vta.monto_total)                       AS ventas,
    CAST(AVG(vta.monto_total) AS DECIMAL(12,2)) AS ticket_promedio
FROM dbo.clientes AS cli
INNER JOIN dbo.ventas AS vta ON vta.customer_id = cli.customer_id
GROUP BY cli.segmento
ORDER BY ventas DESC;

-- 4. Ventas por medio de pago
SELECT
    medio_pago,
    COUNT(*)          AS cantidad_ventas,
    SUM(monto_total)  AS ventas
FROM dbo.ventas
GROUP BY medio_pago
ORDER BY cantidad_ventas DESC;

-- 5. Ventas por país
SELECT
    cli.pais,
    COUNT(*)              AS cantidad_ventas,
    SUM(vta.monto_total)  AS ventas
FROM dbo.clientes AS cli
INNER JOIN dbo.ventas AS vta ON vta.customer_id = cli.customer_id
GROUP BY cli.pais
ORDER BY ventas DESC;

-- 6. Participación de cada categoría en transacciones y en monto
SELECT
    prod.categoria,
    COUNT(*)                                                         AS cantidad_ventas,
    SUM(vta.monto_total)                                             AS ventas,
    CAST(100.0 * COUNT(*) / SUM(COUNT(*)) OVER () AS DECIMAL(5,1))   AS pct_transacciones,
    CAST(100.0 * SUM(vta.monto_total) / SUM(SUM(vta.monto_total)) OVER () AS DECIMAL(5,1)) AS pct_monto
FROM dbo.productos AS prod
INNER JOIN dbo.ventas AS vta ON vta.product_id = prod.product_id
GROUP BY prod.categoria
ORDER BY ventas DESC;

-- 7. Top 10 productos por cantidad de ventas
SELECT TOP 10
    prod.product_id,
    prod.nombre_producto,
    COUNT(*)              AS cantidad_ventas,
    SUM(vta.cantidad)     AS unidades_vendidas,
    SUM(vta.monto_total)  AS ventas
FROM dbo.ventas AS vta
INNER JOIN dbo.productos AS prod ON prod.product_id = vta.product_id
GROUP BY prod.product_id, prod.nombre_producto
ORDER BY cantidad_ventas DESC;

-- 8. Ventas mensuales (para detectar meses incompletos y tendencia)
SELECT
    YEAR(fecha_compra)            AS anio,
    MONTH(fecha_compra)           AS mes,
    COUNT(DISTINCT fecha_compra)  AS dias_con_ventas,
    COUNT(*)                      AS cantidad_ventas,
    SUM(monto_total)              AS ventas
FROM dbo.ventas
GROUP BY YEAR(fecha_compra), MONTH(fecha_compra)
ORDER BY anio, mes;

-- 9. Control de calidad: ventas con fecha anterior al registro del cliente
SELECT COUNT(*) AS ventas_antes_del_registro
FROM dbo.ventas AS vta
INNER JOIN dbo.clientes AS cli ON cli.customer_id = vta.customer_id
WHERE vta.fecha_compra < cli.fecha_registro;
