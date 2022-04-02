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
                    value = today(),
                    max = today(),
                    min = today() - days(7 * 10)
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
                        "Overall" = 10
                    )
                ),
                actionButton("update", label = "Calculate")
            ),
            
            # Show a plot of the generated distribution
            mainPanel(tabsetPanel(
                type = "tabs",
                tabPanel("Analysis", 
                         h3("Time Series Analysis:"),
                         plotOutput("decompose_plot")
                         ),
                tabPanel("Prediction", 
                         h3("14 Days Prediction:"),
                         plotOutput("prediction_plot")
                         )
            ))
        )
    )
)
        