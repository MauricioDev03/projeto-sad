# ---------------------------------------------
# Projeto SAD 2025 - APP
# Autor: [Francisco Mauricio; Diogo Costa; Duarte Carneiro; Francisco Colaço]
# ---------------------------------------------

library(writexl)
library(purrr)
library(shiny)
library(httr)
library(jsonlite)
library(dplyr)
library(lubridate)
library(ggplot2)
library(leaflet)
library(glmnet)


api_key <- "c3a86c15fe8777e1b2a96865077fa80f"

#Cidades e coordenadas
cidades <- tibble(
  nome = c("Nova Iorque", "Paris", "Suzhou", "Londres", "Lisboa", "Madrid", "Berlim", "Tóquio"),
  cidade_api = c("New York,US", "Paris,FR", "Suzhou,CN", "London,UK", "Lisbon,PT", 
                 "Madrid,ES", "Berlin,DE", "Tokyo,JP"),
  lat = c(40.7128, 48.8566, 31.2989, 51.5074, 38.7169, 40.4168, 52.5200, 35.6895),
  lon = c(-74.0060, 2.3522, 120.5853, -0.1278, -9.1399, -3.7038, 13.4050, 139.6917)
)

modelo_final <- readRDS("modelo_lasso.rds")

# Função para obter previsões da API
obter_previsoes <- function(cidade, nome_visivel) {
  url <- paste0("https://api.openweathermap.org/data/2.5/forecast?q=",
                URLencode(cidade),
                "&appid=", api_key, "&units=metric")
  
  res <- GET(url)
  dados <- fromJSON(rawToChar(res$content))
  
  previsoes <- dados$list
  
  # Forçar rain e snow
  if (!"rain" %in% names(previsoes)) {
    previsoes$rain <- vector("list", length = length(previsoes$dt))
  } else if (is.data.frame(previsoes$rain)) {
    previsoes$rain <- as.list(rep(NA, length(previsoes$dt)))
  }
  
  if (!"snow" %in% names(previsoes)) {
    previsoes$snow <- vector("list", length = length(previsoes$dt))
  } else if (is.data.frame(previsoes$snow)) {
    previsoes$snow <- as.list(rep(NA, length(previsoes$dt)))
  }
  
  # Limpeza para garantir listas
  previsoes$rain <- lapply(previsoes$rain, function(x) if (is.null(x)) list() else x)
  previsoes$snow <- lapply(previsoes$snow, function(x) if (is.null(x)) list() else x)
  
  # Criar tibble e variáveis
  previsoes <- as_tibble(previsoes) %>%
    mutate(
      dt_txt = ymd_hms(dt_txt),
      date = as.Date(dt_txt),
      hour = hour(dt_txt),
      temperature = main$temp,
      humidity = main$humidity,
      wind_speed = wind$speed,
      rainfall = map_dbl(rain, ~ if (!is.null(.x) && "3h" %in% names(.x)) .x[["3h"]] else 0),
      snowfall = map_dbl(snow, ~ if (!is.null(.x) && "3h" %in% names(.x)) .x[["3h"]] else 0),
      seasons = case_when(
        month(date) %in% 3:5 ~ "Spring",
        month(date) %in% 6:8 ~ "Summer",
        month(date) %in% 9:11 ~ "Autumn",
        TRUE ~ "Winter"
      ),
      holiday = factor(0, levels = c(0, 1)),
      functioning_day = factor(1, levels = c(0, 1)),
      hour = factor(hour, levels = 0:23, ordered = TRUE),
      seasons = factor(seasons, levels = c("Spring", "Summer", "Autumn", "Winter"))
    )
  
  # Gerar previsões
  x <- model.matrix(~ temperature + humidity + wind_speed + rainfall + snowfall +
                      hour + seasons + holiday + functioning_day, data = previsoes)[, -1]
  
  previsoes$rented_bike_count <- predict(modelo_final, newx = x, s = "lambda.min")
  previsoes$cidade <- nome_visivel
  return(previsoes)
}





# UI
ui <- fluidPage(
  titlePanel("🚲 Previsão de Bicicletas Partilhadas - Dashboard"),
  leafletOutput("mapa", height = 400),
  selectInput("cidade", "Escolhe a cidade:", choices = cidades$nome),
  selectInput("dias", "Mostrar previsões para quantos dias?", choices = 1:5, selected = 3),
  plotOutput("grafico"),
  downloadButton("baixar_csv", "📥 Exportar Tabela para CSV"),
  downloadButton("baixar_excel", "📊 Exportar para Excel (.xlsx)"),
  tableOutput("tabela")
)

# Server
server <- function(input, output, session) {
  previsoes_cidades <- reactive({
    purrr::pmap_dfr(cidades, ~ obter_previsoes(..2, ..1))
  })
  
  output$mapa <- renderLeaflet({
    dados <- previsoes_cidades()
    maximos <- dados %>%
      group_by(cidade) %>%
      filter(rented_bike_count == max(rented_bike_count)) %>%
      distinct(cidade, .keep_all = TRUE)
    
    leaflet(cidades) %>%
      addTiles() %>%
      addMarkers(~lon, ~lat, label = ~nome,
                 popup = ~paste0("<b>", nome, ":</b><br>Máx. previsão: ",
                                 round(maximos$rented_bike_count[maximos$cidade == nome]),
                                 " bicicletas"))
  })
  
  output$grafico <- renderPlot({
    previsoes_cidades() %>%
      filter(cidade == input$cidade) %>%
      filter(date <= Sys.Date() + as.integer(input$dias)) %>%
      ggplot(aes(x = ymd_hms(dt_txt), y = rented_bike_count)) +
      geom_line(color = "steelblue") +
      labs(title = paste("Previsão para", input$cidade),
           x = "Data/Hora", y = "Bicicletas Alugadas Previstas") +
      theme_minimal()
  })
  
  output$baixar_csv <- downloadHandler(
    filename = function() {
      paste0("previsoes_", input$cidade, "_", Sys.Date(), ".csv")
    },
    content = function(file) {
      dados_filtrados <- previsoes_cidades() %>%
        filter(cidade == input$cidade,
               date <= Sys.Date() + as.integer(input$dias),
               hour %in% input$horas) %>%
        select(dt_txt, temperature, humidity, wind_speed, rainfall, snowfall,
               rented_bike_count)
      
      write.csv(dados_filtrados, file, row.names = FALSE)
  })
  
  output$baixar_excel <- downloadHandler(
    filename = function() {
      paste0("previsoes_", input$cidade, "_", Sys.Date(), ".xlsx")
    },
    content = function(file) {
      dados_filtrados <- previsoes_cidades() %>%
        filter(cidade == input$cidade,
               date <= Sys.Date() + as.integer(input$dias),
               hour %in% input$horas) %>%
        select(dt_txt, temperature, humidity, wind_speed, rainfall, snowfall,
               rented_bike_count)
      
      write_xlsx(dados_filtrados, path = file)
  })

  output$tabela <- renderTable({
    previsoes_cidades() %>%
      filter(cidade == input$cidade) %>%
      filter(date <= Sys.Date() + as.integer(input$dias)) %>%
      select(dt_txt, temperature, humidity, rented_bike_count)
  })
}

shinyApp(ui, server)