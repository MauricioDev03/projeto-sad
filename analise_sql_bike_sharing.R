
# Análise Exploratória com SQL no R
# Autor: [Francisco Mauricio; Diogo Costa; Duarte Carneiro; Francisco Colaço]
# Projeto: Previsão de Procura de Bicicletas

library(DBI)
library(RSQLite)

# Conectar à base de dados SQLite
conn <- dbConnect(RSQLite::SQLite(), "bike_sharing_project.db")

# Contagem de Registos
dbGetQuery(conn, "
  SELECT COUNT(*) AS total_registos
  FROM seoul_bike_sharing
")

# Horário de Funcionamento
dbGetQuery(conn, "
  SELECT COUNT(*) AS horas_com_aluguer
  FROM seoul_bike_sharing
  WHERE rented_bike_count > 0
")

# Previsão do tempo para Seul nas próximas 3 horas
dbGetQuery(conn, "
  SELECT *
  FROM cities_weather_forecast
  WHERE city = 'Seoul'
  ORDER BY forecast_date
  LIMIT 1
")

# Estações do ano
dbGetQuery(conn, "
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

# Intervalo de datas
dbGetQuery(conn, "
  SELECT MIN(date) AS primeira_data, MAX(date) AS ultima_data
  FROM seoul_bike_sharing
")

# Máximo histórico
dbGetQuery(conn, "
  SELECT date, rented_bike_count
  FROM seoul_bike_sharing
  ORDER BY rented_bike_count DESC
  LIMIT 1
")

# Popularidade horária e temperatura por estação
dbGetQuery(conn, "
  SELECT hour, seasons,
         AVG(temperature) AS temp_media,
         AVG(rented_bike_count) AS aluguer_medio
  FROM seoul_bike_sharing
  GROUP BY hour, seasons
  ORDER BY aluguer_medio DESC
  LIMIT 10
")


# Sazonalidade do aluguer
dbGetQuery(conn, "
  SELECT seasons,
         AVG(rented_bike_count) AS media,
         MIN(rented_bike_count) AS minimo,
         MAX(rented_bike_count) AS maximo,
         ROUND(STDDEV(rented_bike_count), 2) AS desvio_padrao
  FROM seoul_bike_sharing
  GROUP BY seasons
")

# Sazonalidade Meteorológica
dbGetQuery(conn, "
  SELECT seasons,
         AVG(temperature) AS temp,
         AVG(humidity) AS humidade,
         AVG(wind_speed) AS vento,
         AVG(visibility) AS visibilidade,
         AVG(dew_point_temperature) AS ponto_orvalho,
         AVG(solar_radiation) AS radiacao_solar,
         AVG(rainfall) AS precipitacao,
         AVG(snowfall) AS queda_neve,
         AVG(rented_bike_count) AS aluguer_medio
  FROM seoul_bike_sharing
  GROUP BY seasons
  ORDER BY aluguer_medio DESC
")

# Contagem total de bicicletas e info sobre Seul
dbGetQuery(conn, "
  SELECT b.city, b.country, w.latitude, w.longitude, w.population,
         SUM(b.total_bikes) AS total_bicicletas
  FROM bike_sharing_systems b
  JOIN world_cities w
    ON b.city = w.city AND b.country = w.country
  WHERE b.city = 'Seoul'
  GROUP BY b.city, b.country, w.latitude, w.longitude, w.population
")

# Cidades com total de bicicletas semelhante a Seul
dbGetQuery(conn, "
  SELECT b.city, b.country, w.latitude, w.longitude, w.population,
         b.total_bikes
  FROM bike_sharing_systems b
  JOIN world_cities w
    ON b.city = w.city AND b.country = w.country
  WHERE b.total_bikes BETWEEN 15000 AND 20000
")

# Fechar ligação à base de dados
dbDisconnect(conn)
