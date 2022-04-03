# proves functionality of shiny app

# 0. Setup ---------------------------------------------

library(shiny)
library(tidyverse)
library(lubridate)
library(stringr)
library(forecast)

data_url <-
    "https://covid19-dashboard.ages.at/data/CovidFaelle_Timeline.csv"
temp_file <- "./temp/CovidFaelle_Timeline.csv"

# PARAMETERS ------------------------------------------

input <- list()
input$training_weeks <- 15
input$final_training_day <- today() - 14
input$province <- 9 # select 1-9, 10 = all

# 1. Get & slice data ------------------------------
download.file(url = data_url, 
              destfile = temp_file)

covid_raw <- read.csv2(temp_file, encoding = "UTF-8")

covid_slim <- covid_raw %>%
        mutate(date = dmy_hms(Time)) %>%
        
        ### only keep defined number of training days
        filter(
            date <= input$final_training_day &
                date >= input$final_training_day -
                days(input$training_weeks * 7)
        ) %>%
        
        ### keep only daily figures, no calculated columns
        select(c(13, 2:5, 9, 11))


sub_set <- covid_slim %>%
        filter(BundeslandID == input$province) %>%
        select(date, AnzahlFaelle)

wd1 <- wday(min(sub_set$date), week_start = 1)

t_series <- ts(sub_set$AnzahlFaelle,
       start = c(1, wd1),
       #week 1 of observation and weekday
       frequency = 7)

# 3. Decomposition Plot  -----------------------------

ddata <- decompose(t_series, "multiplicative")

p1 <- plot(ddata)

mymodel <- auto.arima(t_series)

### plot(mymodel$residuals)
next_2_weeks <- forecast(mymodel, c(95), h = 2 * 7)

# 5. Plot Forecast  -----------------------------

p2 <- plot(next_2_weeks)
    