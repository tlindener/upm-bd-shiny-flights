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
      menuItem("Introduction", tabName = "info", icon = icon('bolt')),
      menuItem("Airports", tabName = "Airports", icon = icon("map")),
      menuItem("Airlines", tabName = "Airlines",icon = icon('bolt'))
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
                                                        box(h2("Explanation"),
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
                                                            sliderInput("map_flight_slider", "Number of flights:",
                                                                        min = flight_min, max = flight_max, value = c(flight_min,flight_max)),
                                                            sliderInput("map_delay_slider", "Average delay:",
                                                                        min = delay_min, max = delay_max, value = c(delay_min,delay_max))
                                                        ),
                                                        box(h2("Explanation"),
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
                                                        box(h2("Explanation"),
                                                            h4("Select a single connection between two airports to get details about the connection like cancelled flights and total flights.")
                                                        )))
                                                 
                                               ))),
              tabItem(tabName = "Airlines", tabsetPanel(type = "tabs", 
                                                        tabPanel("Delay Distribution",fluidRow(
                                                          column(width = 8,
                                                                 box(width = NULL, solidHeader = TRUE,height = 800,
                                                                     plotOutput("delay_distribution",height = 800)
                                                                 )
                                                          ),
                                                          column(width = 4,
                                                                 box(width = NULL, status = "warning",
                                                                     selectInput("airlineSelect", 
                                                                                 label = "Choose an airline to display",
                                                                                 choices = c("American Airlines", "Southwest Airlines",
                                                                                             "SkyWest Airlines", "Envoy Air", "United Airlines"),
                                                                                 selected = "American Airlines"),
                                                                     selectInput("delayType", 
                                                                                 label = "Delay Aggregation",
                                                                                 choices = c("Median","Average"),
                                                                                 selected = "Average")
                                                                 ),
                                                                 box(h2("Explanation"),
                                                                     h4("Select a single connection between two airports to get details about the connection like cancelled flights and total flights.")
                                                                 )))),
                                                        tabPanel("Timeseries",fluidRow(
                                                          column(width = 8,
                                                                 box(width = NULL, solidHeader = TRUE,height = 800,
                                                                     plotOutput("airline_timeseries",height = 800)
                                                                 )
                                                          ),
                                                          column(width = 4,
                                                                 box(width = NULL, status = "warning",
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
                                                                 box(h2("Explanation"),
                                                                     h4("Limit the selection of airports based on number of flights of the airport")
                                                                 ))))
              ))))))
  