# ---------------------------------------------
# Projeto SAD 2025 - Parte 2: Análise SQL
# Autor: [Francisco Mauricio; Diogo Costa; Duarte Carneiro; Francisco Colaço]
# ---------------------------------------------

library(DBI)
library(RSQLite)

# Ligar à base de dados criada no ficheiro 01
conn <- dbConnect(SQLite(), "bike_sharing_project.db")

# Horas com alugueres > 0
tarefa2 <- dbGetQuery(conn, "
  SELECT COUNT(*) AS horas_com_aluguer
  FROM seoul_bike_sharing
  WHERE rented_bike_count > 0
")
print(tarefa2)

# Previsão do tempo para Seul nas próximas 3 horas
tarefa3 <- dbGetQuery(conn, "
  SELECT *
  FROM cities_weather_forecast
  WHERE city = 'Lisbon'
  ORDER BY forecast_date
  LIMIT 1
")
print(tarefa3)

# Estações únicas
tarefa4 <- dbGetQuery(conn, "
  SELECT
    MAX(season_spring) AS primavera,
    MAX(season_summer) AS verao,
    MAX(season_autumn) AS outono,
    CASE
      WHEN MAX(season_spring + season_summer + season_autumn) < COUNT(*) THEN 1
      ELSE 0
    END AS inverno
  FROM seoul_bike_sharing
")
print(tarefa4)


# Primeira e última data
tarefa5 <- dbGetQuery(conn, "
  SELECT MIN(date) AS primeira_data, MAX(date) AS ultima_data
  FROM seoul_bike_sharing
")

# Corrigir o formato da data (convertido de dias desde 1970-01-01)
tarefa5 <- tarefa5 %>%
  mutate(
    primeira_data = as.Date(primeira_data, origin = "1970-01-01"),
    ultima_data = as.Date(ultima_data, origin = "1970-01-01")
  )

print(tarefa5)


# Data com maior número de alugueres
tarefa6 <- dbGetQuery(conn, "
  SELECT date, hour, rented_bike_count
  FROM seoul_bike_sharing
  ORDER BY rented_bike_count DESC
  LIMIT 1
")
print(tarefa6)


# Temperatura e aluguer médio por hora e estação (top 10)
tarefa7 <- dbGetQuery(conn, "
  SELECT hour, seasons,
         AVG(temperature) AS temp_media,
         AVG(rented_bike_count) AS aluguer_medio
  FROM seoul_bike_sharing
  GROUP BY hour, seasons
  ORDER BY aluguer_medio DESC
  LIMIT 10
")
print(tarefa7)



# Média, mínimo, máximo e desvio padrão por estação

# Query SQL sem o desvio padrão
tarefa8 <- dbGetQuery(conn, "
  SELECT seasons,
         AVG(rented_bike_count) AS media,
         MIN(rented_bike_count) AS minimo,
         MAX(rented_bike_count) AS maximo
  FROM seoul_bike_sharing
  GROUP BY seasons
")

# Buscar os dados completos para cálculo do desvio padrão no R
tarefa8_desvio <- dbGetQuery(conn, "
  SELECT seasons, rented_bike_count
  FROM seoul_bike_sharing
")

# Calcular o desvio padrão no R
library(dplyr)
desvios <- tarefa8_desvio %>%
  group_by(seasons) %>%
  summarise(desvio_padrao = sd(rented_bike_count))

# Juntar os resultados
tarefa8_final <- left_join(tarefa8, desvios, by = "seasons")




# Estatísticas meteorológicas por estação
tarefa9 <- dbGetQuery(conn, "
  SELECT seasons,
         AVG(temperature) AS temp,
         AVG(humidity) AS humidade,
         AVG(wind_speed) AS vento,
         AVG(rented_bike_count) AS aluguer_medio
  FROM seoul_bike_sharing
  GROUP BY seasons
  ORDER BY aluguer_medio DESC
")
print(tarefa9)

# Total de bicicletas e dados de Seul
tarefa10 <- dbGetQuery(conn, "
  SELECT b.city, b.country, w.latitude, w.longitude, w.population,
         SUM(b.system_id) AS total_bicicletas
  FROM bike_sharing_systems b
  JOIN world_cities w
    ON b.city = w.city AND b.country = w.country
  WHERE b.city = 'Lisbon'
  GROUP BY b.city, b.country, w.latitude, w.longitude, w.population
")
print(tarefa10)

# Cidades com bicicletas entre 15.000 e 20.000
tarefa11 <- dbGetQuery(conn, "
  SELECT b.city, b.country, w.latitude, w.longitude, w.population,
         b.total_bikes
  FROM bike_sharing_systems b
  JOIN world_cities w
    ON b.city = w.city AND b.country = w.country
  WHERE b.total_bikes BETWEEN 15000 AND 20000
")

print(tarefa11)



# Fechar ligação (opcional)
# dbDisconnect(conn)
