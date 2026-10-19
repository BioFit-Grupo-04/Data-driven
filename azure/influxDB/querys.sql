// campos:

// import "influxdata/influxdb/schema"
// 
// schema.measurementFieldKeys(
//   bucket: "sensores",
//   measurement: "telemetria_academia",
//   start: -7d
// )

// qtd de capturas de um valor
from(bucket: "sensores")
  |> range(start: -1h)
  |> filter(fn: (r) => r["_measurement"] == "telemetria_academia")
  |> filter(fn: (r) => r["_field"] == "batimento")
  |> map(fn: (r) => ({r with n: 1}))
  |> group(columns: ["_value"])
  |> sum(column: "n")
  |> group()
  |> sort(columns: ["_value"])
  |> keep(columns: ["_value", "n"])

// sensores online
from(bucket: "sensores")
  |> range(start: -5m)
  |> filter(fn: (r) => r["_measurement"] == "telemetria_academia")
  |> filter(fn: (r) => r["_field"] == "batimento")
  |> group()
  |> distinct(column: "dispositivo_id")
  |> count()


// Gráfico de linha: leituras por minuto, por dispositivo
from(bucket: "sensores")
  |> range(start: -1h)
  |> filter(fn: (r) => r["_measurement"] == "telemetria_academia")
  |> filter(fn: (r) => r["_field"] == "batimento")
  |> group(columns: ["dispositivo_id"])
  |> aggregateWindow(every: 1m, fn: count, createEmpty: true)

// KPI: leituras fora da baixa plausível
from(bucket: "sensores")
  |> range(start: -1h)
  |> filter(fn: (r) => r["_measurement"] == "telemetria_academia")
  |> filter(fn: (r) => r["_field"] == "batimento" or r["_field"] == "spo2" or r["_field"] == "temperatura_pele")
  |> map(fn: (r) => ({
      r with
      fora:
        if r._field == "batimento" and (float(v: r._value) < 30.0 or float(v: r._value) > 220.0) then 1
        else if r._field == "spo2" and (float(v: r._value) < 70.0 or float(v: r._value) > 100.0) then 1
        else if r._field == "temperatura_pele" and (float(v: r._value) < 20.0 or float(v: r._value) > 45.0) then 1
        else 0
    }))
  |> keep(columns: ["fora"])
  |> group()
  |> sum(column: "fora")

// Gráfico de linha por campo
from(bucket: "sensores")
  |> range(start: -1h)
  |> filter(fn: (r) => r["_measurement"] == "telemetria_academia")
  |> filter(fn: (r) => r["_field"] == "batimento")
  |> group(columns: ["dispositivo_id"])
  |> aggregateWindow(every: 30s, fn: mean, createEmpty: false)

// Gráfico de barras: mediana por sensor
from(bucket: "sensores")
  |> range(start: -1h)
  |> filter(fn: (r) => r["_measurement"] == "telemetria_academia")
  |> filter(fn: (r) => r["_field"] == "batimento")
  |> map(fn: (r) => ({r with _value: float(v: r._value)}))
  |> group(columns: ["dispositivo_id"])
  |> median()
  |> group()
  |> keep(columns: ["dispositivo_id", "_value"])