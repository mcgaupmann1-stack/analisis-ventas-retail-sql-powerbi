# Medidas DAX del dashboard

Todas las medidas están agrupadas en la tabla `Tabla_Medidas`. Las comparaciones entre períodos usan la tabla `Calendario`, marcada como tabla de fechas y relacionada con `Ventas[fecha_compra]`.

## Tabla Calendario

```dax
Calendario =
ADDCOLUMNS (
    CALENDAR ( DATE ( 2024, 4, 1 ), DATE ( 2025, 4, 30 ) ),
    "Año", YEAR ( [Date] ),
    "MesNum", MONTH ( [Date] ),
    "AñoMes", YEAR ( [Date] ) * 100 + MONTH ( [Date] ),
    "Mes", FORMAT ( [Date], "mmm yyyy" )
)
```

La columna `Mes` se ordena por `AñoMes` para que los meses aparezcan en orden cronológico.

## Medidas base

| Medida | Fórmula | Qué calcula |
|---|---|---|
| Ventas | `SUM ( Ventas[monto_total] )` | Monto vendido en el período filtrado |
| Transacciones | `COUNTROWS ( Ventas )` | Cantidad de ventas (cada fila es una venta) |
| Clientes Activos | `DISTINCTCOUNT ( Ventas[customer_id] )` | Clientes distintos que compraron |
| Ticket Promedio | `DIVIDE ( [Ventas], [Transacciones] )` | Monto promedio por venta |

**Ticket Promedio:** numerador = ventas del mes seleccionado; denominador = cantidad de transacciones del mismo mes. Ejemplo marzo 2025: $ 97.991,01 ÷ 244 = **$ 401,60**.

## Comparación contra el mes anterior

```dax
Ventas Mes Anterior = CALCULATE ( [Ventas], DATEADD ( Calendario[Date], -1, MONTH ) )

Var % Ventas = DIVIDE ( [Ventas] - [Ventas Mes Anterior], [Ventas Mes Anterior] )
```

El mismo patrón se repite para `Clientes Activos`, `Transacciones` y `Ticket Promedio`.

## Variación semestral

```dax
Var % Semestral =
VAR actual =
    CALCULATE ( [Ventas], DATESINPERIOD ( Calendario[Date], MAX ( Calendario[Date] ), -6, MONTH ) )
VAR anterior =
    CALCULATE ( [Ventas], DATESINPERIOD ( Calendario[Date], EDATE ( MAX ( Calendario[Date] ), -6 ), -6, MONTH ) )
RETURN
    DIVIDE ( actual - anterior, anterior )
```

- **Numerador:** ventas de los 6 meses que terminan en el mes seleccionado, menos las de los 6 meses previos.
- **Denominador:** ventas de los 6 meses previos.
- **Ejemplo (marzo 2025):** oct 2024–mar 2025 = $ 608.065 vs. abr–sep 2024 = $ 607.823 → **+0,04 % (≈ 0,0 %)**.
- **Nota:** abril 2024 está incompleto (el dataset empieza el 05/04/2024), por lo que el semestre previo puede estar levemente subestimado.

## Texto y color de las variaciones

```dax
Var Ventas Texto =
VAR v = [Var % Ventas]
RETURN IF ( v >= 0, "▲ ", "▼ " ) & FORMAT ( v, "0.0%" ) & " vs mes anterior"

Color Var Ventas = IF ( [Var % Ventas] >= 0, "#2E7D32", "#C62828" )
```

`Color Var Ventas` se aplica con formato condicional (**Valor del campo**) sobre el color del texto en tarjetas y etiquetas de datos.
