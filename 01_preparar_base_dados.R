# ---------------------------------------------
# Projeto SAD 2025 - Parte 1: Recolha e Preparação de Dados
# Autor: [Francisco Mauricio; Diogo Costa; Duarte Carneiro; Francisco Colaço]
# ---------------------------------------------

library(tidyverse)
library(lubridate)
library(DBI)
library(RSQLite)

# Carregar os dados limpos
seoul_data <- read_csv("seoul_bike_clean.csv")
bike_systems <- read_csv("bike_systems_clean.csv")
weather_forecast <- read_csv("weather_forecast_clean.csv")
world_cities <- read_csv("world_cities_clean.csv")

# Converter coluna de data e criar coluna hour
seoul_data <- seoul_data %>%
  mutate(date = ymd(date),
         hour = NA_integer_)  

# Conectar à base de dados SQLite
conn <- dbConnect(SQLite(), "bike_sharing_project.db")


seoul_data <- seoul_data %>%
  mutate(seasons = case_when(
    season_spring == 1 ~ "Spring",
    season_summer == 1 ~ "Summer",
    season_autumn == 1 ~ "Autumn",
    TRUE ~ "Other"
  ))


# Escrever os dados na base de dados
dbWriteTable(conn, "seoul_bike_sharing", seoul_data, overwrite = TRUE)
dbWriteTable(conn, "bike_sharing_systems", bike_systems, overwrite = TRUE)
dbWriteTable(conn, "cities_weather_forecast", weather_forecast, overwrite = TRUE)
dbWriteTable(conn, "world_cities", world_cities, overwrite = TRUE)

# Confirmar tabelas
dbListTables(conn)

# (opcional) Desconectar no fim
# dbDisconnect(conn)

