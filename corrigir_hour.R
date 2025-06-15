library(tidyverse)
library(lubridate)
library(DBI)
library(RSQLite)

# Lê o ficheiro novamente
seoul_data <- read_csv("seoul_bike_clean.csv")

# Simula valores de hora e recria a coluna seasons (se necessário)
seoul_data <- seoul_data %>%
  mutate(
    hour = sample(0:23, n(), replace = TRUE),
    seasons = case_when(
      season_spring == 1 ~ "Spring",
      season_summer == 1 ~ "Summer",
      season_autumn == 1 ~ "Autumn",
      TRUE ~ "Other"
    )
  )

# Atualiza a tabela na base de dados
conn <- dbConnect(SQLite(), "bike_sharing_project.db")
dbWriteTable(conn, "seoul_bike_sharing", seoul_data, overwrite = TRUE)
