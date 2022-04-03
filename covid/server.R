# 0. Setup ---------------------------------------------

library(shiny)
library(tidyverse)
library(lubridate)
library(stringr)
library(forecast)

data_url <-
    "https://xcovid19-dashboard.ages.at/data/CovidFaelle_Timeline.csv"
temp_file <- "./temp/CovidFaelle_Timeline.csv"


# PARAMETERS ------------------------------------------

# input <- list()
# input$training_weeks <- 15
# input$final_training_day <- today() - 14
# input$province <- 9 # select 1-9, 10 = all

shinyServer(function(input, output) {

    # 1. Get data  ------------------------------
    ### done once when loading the app
    ### NOT reactive

    ### Download of new data only works offline
    # download.file(url = data_url,
    #               destfile = temp_file)
    
    covid_raw <- read.csv2(temp_file, encoding = "UTF-8")

    # 2. Slice data based on input  ------------------------------
    t_series <- eventReactive( input$update, {
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
            
            
            # 3. Time Series definition  -----------------------------
            
            sub_set <- covid_slim %>%
                filter(BundeslandID == input$province) %>%
                select(date, AnzahlFaelle)
            
            wd1 <- wday(min(sub_set$date), week_start = 1)
            
            ts(sub_set$AnzahlFaelle,
               start = c(1, wd1),
               #week 1 of observation and weekday
               frequency = 7)
    })
            
            
    # 4. Decomposition Plot  -----------------------------
        
    ddata <- eventReactive(input$update, {
            decompose(t_series(), "multiplicative")
        })

    output$decompose_plot <- renderPlot({
        plot(ddata())
        
    })
    
    # 5. Calculate forecast  -----------------------------
    mymodel <- eventReactive(input$update, {
        auto.arima(t_series())
    })

    next_2_weeks <- eventReactive(input$update, {
        forecast(mymodel(), c(95), h = 2 * 7)
    })
    
    
    # 6. Plot Forecast  -----------------------------
    
    
    output$prediction_plot <- renderPlot({
        plot(next_2_weeks())
        grid()
        
    })
    
})
