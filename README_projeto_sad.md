## Tecnologias e Ferramentas

- Linguagem:R
- Pacotes principais: `dplyr`, `ggplot2`, `tidymodels`, `glmnet`, `shiny`, `httr`, `jsonlite`
- Modelos testados: Regressão linear, Ridge, Lasso, Elastic Net, Modelos com polinómios e interações
- Dashboard: R Shiny com integração à API da OpenWeather
- Dados meteorológicos: API OpenWeather
- Interface: Dashboard interativo com R Shiny

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


## Referências

- [OpenWeather API](https://openweathermap.org)
- [Documentação glmnet](https://cran.r-project.org/web/packages/glmnet/)
- [R Shiny](https://shiny.rstudio.com)
