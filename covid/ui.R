#
# This is the user-interface definition of a Shiny web application. You can
# run the application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#

library(shiny)
library(tidyverse)
library(lubridate)
library(stringr)
library(forecast)

latest_update <- date("2022-04-03")

# Define UI for application
shinyUI(
    fluidPage(
        # Application title
        titlePanel("Covid Case Number Forecast for Austria"),
        
        # Sidebar with a slider input for number of bins
        sidebarLayout(
            sidebarPanel(
                h3("Set Parameters:"),
                sliderInput(
                    "training_weeks",
                    "Number of training weeks",
                    min = 5,
                    max = 50,
                    value = 15
                ),
                dateInput(
                    "final_training_day",
                    "Final training day",
                    value = latest_update,
                    max = latest_update,
                    min = latest_update - days(7 * 10)
                ),
                radioButtons(
                    "province",
                    "Select Austrian Province",
                    choices = c(
                        "Burgenland" = 1,
                        "Kärnten" = 2,
                        "Niederösterreich" = 3,
                        "Oberösterreich" = 4,
                        "Salzburg" = 5,
                        "Steiermark" = 6,
                        "Tirol" = 7,
                        "Vorarlberg" = 8,
                        "Wien" = 9,
                        "Total" = 10
                    )
                ),
                actionButton("update", label = "Calculate"),
                p("\n"),
                p(HTML("<em><red>Important: data updated on 2022-04-03<br>(automated updates fail on shinyapps.io)</em>"),
                       style="color:red;")
            ),
            
            # Show a plot of the generated distribution
            mainPanel(tabsetPanel(
                type = "tabs",
                tabPanel("Analysis", 
                         tags$h3("Time Series Analysis:"),
                         tags$p("Dcomposition analysis takes the training (i.e. historic) data as specified by the input parameters and decomposes it into a (smoothed trend, a 7-day seasonal component and the remaining random part."),
                         tags$div("The applied method is described at ", 
                                  tags$a(href="https://www.rdocumentation.org/packages/stats/versions/3.6.2/topics/decompose", "rdocumentation.")),
                         tags$div("The data is used from ", 
                                  tags$a(href="https://www.data.gv.at/katalog/dataset/ef8e980b-9644-45d8-b0e9-c6aaf0eff0c0", "data.gv.at-Open Data Österreich.")),
                         plotOutput("decompose_plot")
                         ),
                tabPanel("Prediction", 
                         h3("14 Days Prediction:"),
                         tags$p("The forecast uses the elements from the decomposition analysis and calculates a forecast for 14 days following the final training day. Try changing the final training day to compare forecast and as-is or the number of training weeks to compare different forecasts."),
                         tags$div("The applied method is described at ", 
                                  tags$a(href="https://www.rdocumentation.org/packages/forecast/versions/8.16/topics/auto.arima", "rdocumentation.")),
                         tags$div("The data is used from ", 
                                  tags$a(href="https://www.data.gv.at/katalog/dataset/ef8e980b-9644-45d8-b0e9-c6aaf0eff0c0", "data.gv.at-Open Data Österreich.")),
                         plotOutput("prediction_plot")
                         )
            ))
        )
    )
)
        