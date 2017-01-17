library(shiny)


shinyServer(function(input, output) {
  
  output$atlanta_data <- renderDataTable({
    airport_atlanta[, c("DayofMonth","DayOfWeek",  "FlightNum"  ,"ArrDelay",input$atlanta_list_variables), drop = FALSE]
  }, rownames = TRUE)
  
  
  
  lmResults <- reactive({
    regress.exp <- paste("ArrDelay ~ ",paste(c("DepDelay",input$atlanta_prediction_variables), collapse="+"),sep = "")
    lm(regress.exp, data=airport_atlanta)  
  })
  
  output$atlanta_prediction <- renderTable({
    results <- summary(lmResults())
      data.frame(R2=results$r.squared,
                         adj.R2=results$adj.r.squared,
                         DOF.model=results$df[1],
                         DOF.available=results$df[2],
                         DOF.total=sum(results$df[1:2]),
                         f.value=results$fstatistic[1],
                         f.denom=results$fstatistic[2],
                         f.numer=results$fstatistic[3],
                         p=1-pf(results$fstatistic[1],
                                results$fstatistic[2],
                                results$fstatistic[3]))
    
  })
  output$atlanta_prediction_plot <- renderPlot({
    fit <- lmResults()
    ggplot(fit$model, aes_string(x = names(fit$model)[2], y = names(fit$model)[1])) + 
      geom_point() +
      stat_smooth(method = "lm", col = "red") +
      labs(title = paste("Adj R2 = ",signif(summary(fit)$adj.r.squared, 5),
                         "Intercept =",signif(fit$coef[[1]],5 ),
                         " Slope =",signif(fit$coef[[2]], 5),
                         " P =",signif(summary(fit)$coef[2,4], 5)))
  })
  
  
  
  output$leaflet_airport_connections = renderLeaflet({
    #filter airports
    delays_sub = airport_connections %>% filter(airport_origin == input$airport)
    lat_start = delays_sub$lat_origin[1]
    lon_start = delays_sub$lon_origin[1]
    
    lat_end = delays_sub$lat_dest
    lon_end = delays_sub$lon_dest
    
    
    local_map = us_map
    
    
    for (i in 1:length(delays_sub$airport_dest)){
      detail = paste('Destination: ', delays_sub$airport_dest[i] ,"<br>" ,
                     'Cancelled flights = ', delays_sub$sum_cancelled[i] , '<br>',
                     'Total Flights = ', delays_sub$num_flights[i], sep = '')
      
      
      inter <- gcIntermediate(c(lon_start, lat_start), c(lon_end[i], lat_end[i]), n=200, addStartEnd=TRUE)
      
      local_map = local_map %>% addPolylines(data = inter, weight = 2, color = "red", opacity = 0.9 ,popup = detail)
      #local_map = local_map %>% addPolylines(data = inter, weight = 2, color = "red", opacity = 0.9)
    }
    
    # output final map
    local_map
  })
  
  output$airline_timeseries = renderPlot({
    data = switch(input$ts_delayType, 
                  "Median" = timemed,
                  "Average" = timeavg)
    color = c("red", "blue", "purple", "green", "red")
    carrier = switch(input$ts_airlineSelect,"Top 5" = "all",
                     "American Airlines" = "AA",
                     "Southwest Airlines" = "WN",
                     "SkyWest Airlines" = "OO", 
                     "Envoy Air" = "MQ", 
                     "United Airlines" = "UA")
    
    if (carrier == "all"){
      airline = c("AA", "WN", "OO", "MQ", "UA")
      color = c("red", "blue", "purple", "green", "red")
    }
    if (carrier == "AA"){
      color = color[1]
      airline = carrier
    }
    if (carrier == "WN"){
      color = color[2]
      airline = carrier
    }
    if (carrier == "OO"){
      color = color[3]
      airline = carrier
    }
    if (carrier == "MQ"){
      color = color[4]
      airline = carrier
    }
    if (carrier == "UA"){
      color = color[5]
      airline = carrier
    }
    ts.plot(data[,airline],gpars=list(col=color))
    
  })
  
  #Delays by Weather effect
  output$weatherDelay = renderPlot({
    
    aggregate <- switch(input$airport_weather_delay, 
                        "All" = weather_delays,
                        "William B Hartsfield-Atlanta Intl" = aggregateATL,
                        "Chicago O'Hare International" = aggregateORD,
                        "Dallas-Fort Worth International" = aggregateDFW,
                        "Los Angeles International" = aggregateLAX,
                        "Denver Intl" = aggregateDEN)
    
    
    p <- ggplot(aggregate, aes(Events, size=num_arr_delays))
    p <- p+ geom_point(aes(y=avg_arr_delay), colour="red")
    p <- p+ geom_point(aes(y=avg_dep_delay), colour="green")
    p <- p+ geom_point(aes(y=avg_weather_delay), colour="blue")
    p <- p+ theme(axis.text.x = element_text(size  = 10,angle = 45,hjust = 1,vjust = 1))
    p <- p+ scale_size(range=c(3,14))
    p
  })
  
  output$delay_distribution = renderPlot({
    data = switch(input$delayType, 
                  "Median" = timemed,
                  "Average" = timeavg)
    
    airline = switch(input$airlineSelect,
                     "American Airlines" = "AA",
                     "Southwest Airlines" = "WN",
                     "SkyWest Airlines" = "OO", 
                     "Envoy Air" = "MQ", 
                     "United Airlines" = "UA")
    qplot(data[airline], geom="histogram",xlab=paste(input$delayType,"Delay for",input$airlineSelect))
  })
  
  output$airport_delays <- renderPlot({
    min_flights <- input$map_flight_slider[1]
    max_flights <-  input$map_flight_slider[2]
    min_delays <- input$map_delay_slider[1]
    max_delays <-  input$map_delay_slider[2]
    
    map_delay_sub <- airports %>% filter( num_flights > min_flights & num_flights < max_flights & arr_delay_avg > min_delays &arr_delay_avg < max_delays)
    
    p <- ggplot()
    p <- p+  geom_polygon(aes(long,lat,group=group), size = 0.1, colour= "#090D2A", fill="#090D2A", alpha=0.8, data=base_map) 
    p <- p +geom_point(data=map_delay_sub,aes(Long,Lat,size=num_flights,color=arr_delay_avg))+scale_size(range=c(1,12))
    p <- p + theme(legend.position="bottom")
    p <- p + labs(title="Number of Flights at Airport")
    p <- p +  theme(axis.line=element_blank(),
                    axis.text.x=element_blank(),
                    axis.text.y=element_blank(),
                    axis.ticks=element_blank(),
                    axis.title.x=element_blank(),
                    axis.title.y=element_blank(),
                    panel.background=element_blank(),
                    panel.border=element_blank(),
                    panel.grid.major=element_blank(),
                    panel.grid.minor=element_blank(),
                    plot.background=element_blank())+scale_colour_gradient(low="lightblue",high="red")
    p
  })
  
})
