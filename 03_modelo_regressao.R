
library(tidyverse)
library(lubridate)
library(caret)
library(glmnet)

# Carregar e preparar o dataset simulado
seoul <- read_csv("seoul_bike_simulated.csv")

# Formatando variáveis categóricas corretamente
seoul <- seoul %>%
  mutate(
    hour = factor(hour, ordered = TRUE),
    seasons = as.factor(seasons),
    holiday = as.factor(holiday),
    functioning_day = as.factor(functioning_day)
  )

# Dividir dados em treino (80%) e teste (20%)
set.seed(123)
train_index <- createDataPartition(seoul$rented_bike_count, p = 0.8, list = FALSE)
train_data <- seoul[train_index, ]
test_data  <- seoul[-train_index, ]

# Modelos de Regressão Linear Base

# Modelo com variáveis meteorológicas
modelo_meteo <- lm(rented_bike_count ~ temperature + humidity + wind_speed + rainfall + snowfall,
                   data = train_data)
pred_meteo <- predict(modelo_meteo, newdata = test_data)
rmse_meteo <- RMSE(pred_meteo, test_data$rented_bike_count)

# Modelo com variáveis temporais
modelo_tempo <- lm(rented_bike_count ~ hour + seasons + holiday + functioning_day,
                   data = train_data)
pred_tempo <- predict(modelo_tempo, newdata = test_data)
rmse_tempo <- RMSE(pred_tempo, test_data$rented_bike_count)

# Modelos Refinados

# Modelo com termos polinomiais
modelo_poly <- lm(rented_bike_count ~ poly(temperature, 2) + poly(humidity, 2) +
                    wind_speed + rainfall + snowfall, data = train_data)
pred_poly <- predict(modelo_poly, newdata = test_data)
rmse_poly <- RMSE(pred_poly, test_data$rented_bike_count)

# Modelo com interações
modelo_inter <- lm(rented_bike_count ~ temperature * humidity + hour + seasons,
                   data = train_data)
pred_inter <- predict(modelo_inter, newdata = test_data)
rmse_inter <- RMSE(pred_inter, test_data$rented_bike_count)

# Regularização com GLMNet (Ridge, Lasso, Elastic Net)

# Preparar matrizes
x <- model.matrix(rented_bike_count ~ temperature + humidity + wind_speed +
                    rainfall + snowfall + hour + seasons + holiday + functioning_day,
                  data = train_data)[, -1]
y <- train_data$rented_bike_count

x_test <- model.matrix(rented_bike_count ~ temperature + humidity + wind_speed +
                         rainfall + snowfall + hour + seasons + holiday + functioning_day,
                       data = test_data)[, -1]
y_test <- test_data$rented_bike_count

# Ridge Regression (α = 0)
modelo_ridge <- cv.glmnet(x, y, alpha = 0)
pred_ridge <- predict(modelo_ridge, newx = x_test, s = "lambda.min")
rmse_ridge <- RMSE(pred_ridge, y_test)

# Lasso Regression (α = 1)
modelo_lasso <- cv.glmnet(x, y, alpha = 1)
pred_lasso <- predict(modelo_lasso, newx = x_test, s = "lambda.min")
rmse_lasso <- RMSE(pred_lasso, y_test)

# Elastic Net (α = 0.5)
modelo_elastic <- cv.glmnet(x, y, alpha = 0.5)
pred_elastic <- predict(modelo_elastic, newx = x_test, s = "lambda.min")
rmse_elastic <- RMSE(pred_elastic, y_test)

# Comparar todos os modelos
resultados <- tibble(
  Modelo = c("Meteorológico", "Temporal", "Polinómios", "Interações",
             "Ridge", "Lasso", "Elastic Net"),
  RMSE = c(rmse_meteo, rmse_tempo, rmse_poly, rmse_inter,
           rmse_ridge, rmse_lasso, rmse_elastic)
)

print(resultados)

# Gráfico comparativo de RMSE
ggplot(resultados, aes(x = reorder(Modelo, RMSE), y = RMSE, fill = Modelo)) +
  geom_col(show.legend = FALSE) +
  labs(title = "Comparação de Modelos por RMSE",
       x = "Modelo", y = "Erro Quadrático Médio (RMSE)") +
  theme_minimal()

# Guardar o modelo final para o Shiny App
saveRDS(modelo_lasso, "modelo_lasso.rds")

