/* =====================================================================
   Retail_Ventas - Ventas de los últimos 30 días
   ---------------------------------------------------------------------
   Objetivo: listar nombre del cliente, fecha de compra y total de la
   venta de los últimos 30 días, ordenado por fecha descendente.

   Convención de "últimos 30 días":
   - Se toma como referencia la última fecha con ventas del dataset
     (07/04/2025), no la fecha actual: los datos son históricos y usar
     GETDATE() no devolvería filas.
   - Se cuentan 30 fechas calendario, con la fecha de la última venta
     como día 1: del 09/03/2025 al 07/04/2025, ambos inclusive.
     Por eso se restan 29 días a la fecha máxima.
   - fecha_compra es de tipo DATE (sin hora): la comparación >= incluye
     el día completo.

   Resultado esperado: 250 filas.
   ===================================================================== */

SELECT
    cli.nombre       AS nombre_cliente,
    vta.fecha_compra,
    vta.monto_total  AS total_venta
FROM dbo.clientes AS cli
INNER JOIN dbo.ventas AS vta
    ON vta.customer_id = cli.customer_id
WHERE vta.fecha_compra >= DATEADD(DAY, -29, (SELECT MAX(v2.fecha_compra) FROM dbo.ventas AS v2))
ORDER BY vta.fecha_compra DESC;
