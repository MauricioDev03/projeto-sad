library(tidyverse)

# Carregar o CSV limpo original
seoul_raw <- read_csv("seoul_bike_clean.csv")

# Criar coluna "seasons" a partir das dummies
seoul_raw <- seoul_raw %>%
  mutate(seasons = case_when(
    season_spring == 1 ~ "Spring",
    season_summer == 1 ~ "Summer",
    season_autumn == 1 ~ "Autumn",
    TRUE ~ "Winter"  # caso nenhuma das anteriores seja 1
  ))

# Simular valores realistas de precipitação (rainfall) e queda de neve (snowfall)
set.seed(42)
seoul_raw <- seoul_raw %>%
  mutate(
    rainfall = round(runif(n(), min = 0, max = 20), 1),       # entre 0 e 20 mm
    snowfall = round(rnorm(n(), mean = 2, sd = 3), 1),        # média 2 cm, pode dar negativos
    snowfall = ifelse(snowfall < 0, 0, snowfall),             # ajustar negativos para 0
    functioning_day = sample(c(1, 0), n(), replace = TRUE, prob = c(0.9, 0.1)),  # 90% dias úteis
    holiday = sample(c(1, 0), n(), replace = TRUE, prob = c(0.05, 0.95))        # 5% feriados
  )

# Converter colunas finais

seoul_raw <- seoul_raw %>%
  mutate(
    date = ymd(date),  # agora com o formato certo
    hour = factor(hour, levels = 0:23, ordered = TRUE)
  )

# Verificar que a coluna date está correta
glimpse(seoul_raw)


unique(read_csv("seoul_bike_clean.csv")$date)


write_csv(seoul_raw, "seoul_bike_final.csv")
