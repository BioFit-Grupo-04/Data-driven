// campos:

// import "influxdata/influxdb/schema"
// 
// schema.measurementFieldKeys(
//   bucket: "sensores",
//   measurement: "telemetria_academia",
//   start: -7d
// )

// Gráfico 1: Taxa de Ingestão de Dados (Volumetria a cada 5s por tipo de sensor)
from(bucket: "sensores")
  |> range(start: v.timeRangeStart, stop: v.timeRangeStop)
  |> filter(fn: (r) => r["_measurement"] == "telemetria_academia")
  |> group(columns: ["tipo_sensor"]) 
  |> aggregateWindow(every: 5s, fn: count, createEmpty: false)
  |> yield(name: "taxa_ingestao")

// Gráfico 2: Leituras por minuto, por dispositivo (Identificação de quedas/buracos)
from(bucket: "sensores")
  |> range(start: v.timeRangeStart, stop: v.timeRangeStop)
  |> filter(fn: (r) => r["_measurement"] == "telemetria_academia")
  |> group(columns: ["dispositivo_id"])
  |> aggregateWindow(every: 1m, fn: count, createEmpty: true)
  |> yield(name: "leituras_dispositivo")

// Gráfico 3: Latência
from(bucket: "sensores")
  |> range(start: v.timeRangeStart, stop: v.timeRangeStop)
  |> filter(fn: (r) => r["_measurement"] == "telemetria_academia")
  |> filter(fn: (r) => r["_field"] == "latencia_ms")
  |> group(columns: ["tipo_sensor"])
  |> aggregateWindow(every: 1m, fn: mean, createEmpty: false)
  |> yield(name: "latencia_media")

// KPI 1: Sensores Online (Últimos 5 minutos)
from(bucket: "sensores")
  |> range(start: -5m)
  |> filter(fn: (r) => r["_measurement"] == "telemetria_academia")
  |> group()
  |> distinct(column: "dispositivo_id")
  |> count()

// KPI 2: Anomalias de Injeção / Leituras fora da faixa (Hardware Limits)
from(bucket: "sensores")
  |> range(start: -1h)
  |> filter(fn: (r) => r["_measurement"] == "telemetria_academia")
  |> filter(fn: (r) => r["_field"] == "batimento" or r["_field"] == "spo2" or r["_field"] == "temperatura_pele" or r["_field"] == "distancia")
  |> map(fn: (r) => ({
      r with
      fora:
        // Limites físicos absurdos que indicam falha no sensor ou injeção de dados corrompidos
        if r._field == "batimento" and (float(v: r._value) < 0.0 or float(v: r._value) > 300.0) then 1
        else if r._field == "spo2" and (float(v: r._value) < 0.0 or float(v: r._value) > 100.0) then 1
        else if r._field == "temperatura_pele" and (float(v: r._value) < -10.0 or float(v: r._value) > 80.0) then 1
        else if r._field == "distancia" and (float(v: r._value) < 0.0 or float(v: r._value) > 400.0) then 1 // Limite HC-SR04
        else 0
    }))
  |> keep(columns: ["fora"])
  |> group()
  |> sum(column: "fora")