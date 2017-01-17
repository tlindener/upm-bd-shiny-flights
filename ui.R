library(shiny)
library(shinydashboard)
library(dplyr)
library(maps)
library(DT)
library(leaflet)
library(geosphere)
library(ggplot2)
library(ggthemes)

shinyUI(dashboardPage(
  dashboardHeader(title = "DataExpo 09 - Flight Delays"),
  dashboardSidebar(
    sidebarMenu(
      # Tab buttons
      menuItem("Introduction", tabName = "info", icon = icon('dashboard')),
      menuItem("Airports", tabName = "Airports", icon = icon("map")),
      menuItem("Airlines", tabName = "Airlines",icon = icon('bolt')),
      menuItem("Prediction", tabName = "Prediction",icon = icon('gear'))
    )
  ),
  dashboardBody(
    tabItems(
      tabItem(tabName = 'info',
              div(style = 'overflow-y: scroll',
                  mainPanel(
                    box(h1("The Dashboard"),
                        h3(),
                        h4("Following the BigData prediction solution from Unit 1, this Dashboard is intended to offer a precise visualizations on the same data. Through different means, it will allow a close look into the given dataset"),
                        h3(),
                        h2("Data Set"),
                        h3(),
                        h4("2008 Flight data from Stat Computing Data Expo:"),
                        h4("http://stat-computing.org/dataexpo/2009/the-data.html"),
                        width = 12)))),
      tabItem(tabName = "Airports",tabsetPanel(type = "tabs", 
                                               tabPanel("Connections",fluidRow(
                                                 column(width = 8,
                                                        box(width = NULL, solidHeader = TRUE,
                                                            leafletOutput("leaflet_airport_connections", height = 800)
                                                        )
                                                 ),
                                                 column(width = 4,
                                                        box(width = NULL, status = "warning",
                                                            selectInput("airport", "Airport", selected = "Chicago O'Hare International",
                                                                        airport_names)
                                                        ),
                                                        box(width = NULL,title="Explanation",
                                                            h4("Select a single connection between two airports to get details about the connection like cancelled flights and total flights.")
                                                        )))), 
                                               tabPanel("Delays per Size",fluidRow(
                                                 column(width = 8,
                                                        box(width = NULL, solidHeader = TRUE,height = 800,
                                                            plotOutput("airport_delays",height = 800)
                                                        )
                                                 ),
                                                 column(width = 4,
                                                        box(width = NULL, status = "warning",
                                                            sliderInput("map_delay_slider", "Average delay:",
                                                                        min = delay_min, max = delay_max, value = c(delay_min,delay_max)),
                                                            sliderInput("map_flight_slider", "Number of flights:",
                                                                        min = flight_min, max = flight_max, value = c(flight_min,flight_max))
                                                            
                                                        ),
                                                        box(width = NULL,title="Explanation",
                                                            h4("Limit the selection of airports based on number of flights of the airport")
                                                        )))),
                                               tabPanel("Delay by Weather",fluidRow(
                                                 column(width = 8,
                                                        box(width = NULL, solidHeader = TRUE,height = 800,
                                                            plotOutput("weatherDelay",height = 800)
                                                        )
                                                 ),
                                                 column(width = 4,
                                                        box(width = NULL, status = "warning",
                                                            selectInput("airport_weather_delay", "Airport", selected = "All",
                                                                        airports_names_top5)
                                                        ),
                                                        box(width = NULL,title="Explanation",
                                                            h4("Select a specific top 5 airport to get the aggregated delays per airport.")
                                                        )))
                                                 
                                               ))),
              tabItem(tabName = "Airlines", 
                      tabsetPanel(type = "tabs", 
                                  tabPanel("Delay Distribution",
                                           fluidRow(
                                             column(width = 8,
                                                    box(width = NULL,
                                                        solidHeader = TRUE,
                                                        height = 800,
                                                        plotOutput("delay_distribution",height = 800)
                                                        )),
                                             column(width = 4,
                                                    box(width = NULL,
                                                        status = "warning",
                                                        selectInput("airlineSelect",
                                                                    label = "Choose an airline to display",
                                                                    choices = c("American Airlines", "Southwest Airlines","SkyWest Airlines", "Envoy Air", "United Airlines"),
                                                                                 selected = "American Airlines"),
                                                        selectInput("delayType",
                                                                    label = "Delay Aggregation",
                                                                    choices = c("Median","Average"),
                                                                    selected = "Average")
                                                                 ),
                                                    box(width = NULL,title="Explanation",
                                                        h4("Based on the selected airline and the selected aggregration function the distribution of delays is displayed")
                                                    )))),
                                  tabPanel("Timeseries",
                                           fluidRow(
                                             column(width = 8,
                                                    box(width = NULL,
                                                        solidHeader = TRUE,
                                                        height = 800,
                                                        plotOutput("airline_timeseries",height = 800)
                                                        )
                                                    ),
                                             column(width = 4,
                                                    box(width = NULL,
                                                        status = "warning",
                                                        selectInput("ts_airlineSelect", 
                                                                                 label = "Choose an airline to display",
                                                                                 choices = c("Top 5","American Airlines", "Southwest Airlines",
                                                                                             "SkyWest Airlines", "Envoy Air", "United Airlines"),
                                                                                 selected = "American Airlines"),
                                                        selectInput("ts_delayType", 
                                                                                 label = "Delay Aggregation",
                                                                                 choices = c("Median","Average"),
                                                                                 selected = "Average")
                                                                 ),
                                                    box(width = NULL,title="Explanation",
                                                                     h4("This visualization shows a timeseries for the top 5 airlines in the dataset. The selection allows to choose between airlines and aggregation type.")
                                                                 ))))
              )), tabItem(tabName = "Prediction",
                          tabsetPanel(type = "tabs",
                                      tabPanel("Atlanta Linear Regression",
                                               fluidRow(
                                                 column(width=6,
                                                        box(width=NULL,tableOutput("atlanta_prediction")),
                                                        box(width = NULL,status ="warning",
                                                            plotOutput("atlanta_prediction_plot"))
                                                        ),
                                                 column(width=6,
                                                        box(tatus = "warning",
                                                            checkboxGroupInput("atlanta_prediction_variables", "Variables to show:",airport_atlanta_prediction_columns)),
                                                        box(title="Explanation",
                                                            h4("This component is experimental. It is supposed to provide an easy introduction to building a linear regression models in shiny. The model assumptions won't be met successfully and the dataset is limited to Atlanta (May 2008) due to performance reasons. See further explanations in the report.")
                                                 )))),
                                      tabPanel("Atlanta Dataset",
                                               fluidRow(
                                                 column(width=8,
                                                        box(width=NULL,status = "warning",
                                                            dataTableOutput("atlanta_data"))),
                                                 column(width = 4,
                                                               box(width= NULL,status = "warning",
                                                                   checkboxGroupInput("atlanta_list_variables", "Variables to show:",airport_atlanta_columns)
  
                                                                   )
                                                               )
                                                        )
                                               )
                                      
                                      
                                      )
                          
                          )
))))
  