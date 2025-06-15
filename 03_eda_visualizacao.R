# ---------------------------------------------
# Projeto SAD 2025 - Parte 3: Visualição 
# Autor: [Francisco Mauricio; Diogo Costa; Duarte Carneiro; Francisco Colaço]
# ---------------------------------------------

library(tidyverse)
library(lubridate)

# Carregar os dados limpos
seoul <- read_csv("seoul_bike_clean.csv")

# Reformular a coluna DATE como data
seoul <- seoul %>%
  mutate(date = ymd(date))  # formato ISO detectado no CSV

# Converter HOUR para fator ordenado
seoul <- seoul %>%
  mutate(hour = factor(hour, levels = 0:23, ordered = TRUE))

# Resumo do conjunto de dados
glimpse(seoul)
summary(seoul)

# Adicionar colunas ausentes (simuladas para EDA)

set.seed(123)  # para reprodutibilidade

seoul <- seoul %>%
  mutate(
    # Criar coluna 'seasons' a partir de dummies
    seasons = case_when(
      season_spring == 1 ~ "Spring",
      season_summer == 1 ~ "Summer",
      season_autumn == 1 ~ "Autumn",
      TRUE ~ "Winter"  # assume que o resto é inverno
    ),
    # Simular feriados (5 dias aleatórios)
    holiday = if_else(date %in% sample(unique(date), 5), 1, 0),
    # Simular funcionamento (90% dos casos)
    functioning_day = if_else(runif(n()) > 0.1, 1, 0),
    # Simular precipitação e neve
    rainfall = runif(n(), 0, 5),
    snowfall = runif(n(), 0, 1)
  )

# Quantos feriados existem
feriados <- seoul %>% filter(holiday == 1) %>% nrow()
print(paste("Nº de feriados:", feriados))

# Percentagem de registos em feriado
percent_feriados <- feriados / nrow(seoul) * 100
print(paste("Percentagem em feriados:", round(percent_feriados, 2), "%"))

# Nº esperado de registos num ano (365 dias x 24 horas)
esperado <- 365 * 24
print(paste("Registos esperados:", esperado))

# Nº de registos em dias funcionais
registos_funcionais <- seoul %>% filter(functioning_day == 1) %>% nrow()
print(paste("Registos em dias funcionais:", registos_funcionais))

# Precipitação total e queda de neve por estação
precipitacao_sazonal <- seoul %>%
  group_by(seasons) %>%
  summarise(
    precipitacao_total = sum(rainfall, na.rm = TRUE),
    neve_total = sum(snowfall, na.rm = TRUE)
  )
print(precipitacao_sazonal)



library(ggplot2)

ggplot(seoul, aes(x = date, y = rented_bike_count)) +
  geom_point(alpha = 0.6, color = "steelblue") +
  labs(title = "Alugueres de Bicicletas ao Longo do Tempo",
       x = "Data", y = "Nº de Bicicletas Alugadas")


´
ggplot(seoul, aes(x = date, y = rented_bike_count, color = as.factor(hour))) +
  geom_point(alpha = 0.7) +
  scale_color_viridis_d() +
  labs(title = "Alugueres ao Longo do Tempo por Hora do Dia",
       x = "Data", y = "Alugueres", color = "Hora")


ggplot(seoul, aes(x = rented_bike_count)) +
  geom_histogram(aes(y = ..density..), bins = 20, fill = "lightblue", color = "black", alpha = 0.7) +
  geom_density(color = "darkblue", size = 1) +
  labs(title = "Distribuição do Nº de Bicicletas Alugadas",
       x = "Bicicletas Alugadas", y = "Densidade")


ggplot(seoul, aes(x = temperature, y = rented_bike_count, color = as.factor(hour))) +
  geom_point(alpha = 0.6) +
  facet_wrap(~ seasons) +
  scale_color_viridis_d() +
  labs(title = "Relação Temperatura vs Alugueres por Estação",
       x = "Temperatura (ºC)", y = "Bicicletas Alugadas", color = "Hora")


ggplot(seoul, aes(x = as.factor(hour), y = rented_bike_count, fill = seasons)) +
  geom_boxplot(outlier.alpha = 0.3) +
  labs(title = "Distribuição de Alugueres por Hora e Estação",
       x = "Hora do Dia", y = "Bicicletas Alugadas") +
  theme_minimal()



seoul_diario <- seoul %>%
  group_by(date) %>%
  summarise(
    total_rain = sum(rainfall, na.rm = TRUE),
    total_snow = sum(snowfall, na.rm = TRUE)
  )

# Visualização opcional (duas linhas no mesmo gráfico)
ggplot(seoul_diario, aes(x = date)) +
  geom_line(aes(y = total_rain), color = "blue", size = 1, alpha = 0.7) +
  geom_line(aes(y = total_snow), color = "gray40", size = 1, linetype = "dashed") +
  labs(title = "Precipitação e Queda de Neve Diária",
       x = "Data", y = "Milímetros",
       caption = "Linha azul = chuva | Linha cinza = neve")


dias_neve <- seoul_diario %>% filter(total_snow > 0) %>% nrow()
print(paste("Número de dias com neve:", dias_neve))
