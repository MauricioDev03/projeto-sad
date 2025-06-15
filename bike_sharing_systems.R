# Carregar pacotes
library(tidyverse)
library(DBI)
library(RSQLite)

# Ligar à base de dados
conn <- dbConnect(SQLite(), "bike_sharing_project.db")

# Criar manualmente os dados do sistema de partilha
bike_sharing_systems <- tibble(
  system_id = 1:3,
  system_name = c("Lisboa Roda", "RideBerlin", "BikeCo NY"),
  city = c("Lisbon", "Berlin", "New York"),
  country = c("Portugal", "Germany", "USA"),
  latitude = c(38.7169, 52.52, 40.7128),
  longitude = c(-9.1399, 13.405, -74.006),
  total_bikes = c(17000, 16000, 18000)  # valores entre 15.000 e 20.000
)

# Escrever na base de dados
dbWriteTable(conn, "bike_sharing_systems", bike_sharing_systems, overwrite = TRUE)

# Confirmar que foi gravado
dbListTables(conn)
