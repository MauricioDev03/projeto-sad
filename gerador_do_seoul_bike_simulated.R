library(tidyverse)
library(lubridate)

# 1. Gerar a sequência de datas e horas para 1 ano completo
datas_horas <- expand.grid(
  date = seq.Date(ymd("2023-01-01"), ymd("2023-12-31"), by = "day"),
  hour = 0:23
) %>%
  arrange(date, hour)

# 2. Gerar variáveis sazonais com base no mês
datas_horas <- datas_horas %>%
  mutate(
    month = month(date),
    seasons = case_when(
      month %in% 3:5  ~ "Spring",
      month %in% 6:8  ~ "Summer",
      month %in% 9:11 ~ "Autumn",
      TRUE            ~ "Winter"
    )
  )

# 3. Simular variáveis meteorológicas com padrões sazonais
set.seed(123)

seoul_simulado <- datas_horas %>%
  mutate(
    temperature = case_when(
      seasons == "Winter" ~ rnorm(n(), 0, 5),
      seasons == "Spring" ~ rnorm(n(), 13, 5),
      seasons == "Summer" ~ rnorm(n(), 25, 5),
      seasons == "Autumn" ~ rnorm(n(), 15, 5)
    ),
    humidity = runif(n(), 30, 90),
    wind_speed = runif(n(), 1, 5),
    rainfall = rlnorm(n(), meanlog = 0.5, sdlog = 1) * rbinom(n(), 1, 0.3),
    snowfall = if_else(seasons == "Winter", runif(n(), 0, 1) * rbinom(n(), 1, 0.2), 0),
    holiday = as.factor(if_else(wday(date) %in% c(1, 7), 1, rbinom(n(), 1, 0.05))),
    functioning_day = as.factor(if_else(holiday == 1, 0, 1)),
    rented_bike_count = round(
      100 +
        10 * sin(2 * pi * hour / 24) +                # padrão horário
        temperature * 2 - humidity * 0.5 -            # efeito clima
        wind_speed * 2 - rainfall * 3 - snowfall * 10 +
        rnorm(n(), 0, 15)
    )
  ) %>%
  mutate(
    rented_bike_count = pmax(0, rented_bike_count)  # impedir valores negativos
  ) %>%
  select(date, hour, temperature, humidity, wind_speed, rainfall, snowfall,
         rented_bike_count, seasons, holiday, functioning_day)

# 4. Guardar como CSV
write_csv(seoul_simulado, "seoul_bike_simulated.csv")

# Pronto! Já podes usá-lo como dataset principal para modelação
