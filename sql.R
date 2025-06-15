# Carregar os pacotes
library(DBI)
library(RSQLite)
library(readr)

# Criar ligação à base de dados (vai criar o ficheiro se não existir)
conn <- dbConnect(RSQLite::SQLite(), "bike_sharing_project.db")

# Ler os CSVs limpos
seoul_data <- read_csv("seoul_bike_clean.csv")
bike_systems <- read_csv("bike_systems_clean.csv")
weather_forecast <- read_csv("weather_forecast_clean.csv")
world_cities <- read_csv("world_cities_clean.csv")

# Enviar para a base de dados
dbWriteTable(conn, "seoul_bike_sharing", seoul_data, overwrite = TRUE)
dbWriteTable(conn, "bike_sharing_systems", bike_systems, overwrite = TRUE)
dbWriteTable(conn, "cities_weather_forecast", weather_forecast, overwrite = TRUE)
dbWriteTable(conn, "world_cities", world_cities, overwrite = TRUE)

# Tarefa 1
dbGetQuery(conn, "
  SELECT COUNT(*) AS total_registos
  FROM seoul_bike_sharing
")

# Tarefa 2
dbGetQuery(conn, "
  SELECT COUNT(*) AS horas_com_aluguer
  FROM seoul_bike_sharing
  WHERE rented_bike_count > 0
")

# Tarefa 3
dbGetQuery(conn, "
  SELECT *
  FROM cities_weather_forecast
  WHERE city = 'Seoul'
  ORDER BY forecast_date
  LIMIT 1
")

# Tarefa 4
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





