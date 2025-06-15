# Previsão da Procura de Bicicletas Partilhadas com Dados Meteorológicos

Este projeto foi desenvolvido no âmbito da unidade curricular de Sistemas de Apoio à Decisão da Licenciatura em Informática de Gestão. O objetivo foi criar um sistema preditivo que antecipa a procura horária de bicicletas partilhadas em contexto urbano, com base em dados meteorológicos e temporais, e disponibilizá-lo através de um dashboard interativo em R Shiny.

## Objetivo

Prever o número de alugueres de bicicletas em 8 cidades:
- Nova Iorque
- Paris
- Suzhou
- Londres
- Tokyo
- Madrid
- Lisboa
- Berlim

A previsão permite otimizar a alocação de recursos por parte das empresas de mobilidade urbana.

## Tecnologias e Ferramentas

- Linguagem:R
- Pacotes principais: `dplyr`, `ggplot2`, `tidymodels`, `glmnet`, `shiny`, `httr`, `jsonlite`
- Modelos testados: Regressão linear, Ridge, Lasso, Elastic Net, Modelos com polinómios e interações
- Dashboard: R Shiny com integração à API da OpenWeather
- Dados meteorológicos: API OpenWeather
- Interface: Dashboard interativo com R Shiny


## Estrutura do Projeto

```
projeto-sad/
├── dados/               # Dados usados (csv ou rds)
├── scripts/
│   ├── eda.R            # Análise exploratória
│   ├── modelagem.R      # Construção e avaliação dos modelos
│   └── app.R            # Aplicação Shiny
└── relatorio/           # Relatório final do projeto
```

---


## Principais Resultados

O modelo Lasso foi o que apresentou melhor desempenho (RMSE = 15.5) e foi o escolhido para a aplicação final.


## Como Executar o Projeto

1. Instalar os pacotes necessários no R:

```R
install.packages(c("tidyverse", "ggplot2", "lubridate", "glmnet", "shiny", "httr"))
```

2. Correr o script `app.R`:

```R
shiny::runApp("app.R")
```


---

## Autores

- Francisco Mauricio; Diogo Costa; Duarte Carneiro; Francisco Colaço
- Projeto académico para a Universidade Autónoma de Lisboa, 2025

---

## Referências

- [OpenWeather API](https://openweathermap.org)
- [Documentação glmnet](https://cran.r-project.org/web/packages/glmnet/)
- [R Shiny](https://shiny.rstudio.com)
