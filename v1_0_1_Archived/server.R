library(shiny)
library(maptools)
library(ggplot2)
library(mapproj)
library(magrittr)
library(reshape2)
# shinyapps.io supports only UTF-8 encoding for Chinese characters!!!!
# Read borders from the .shp file
mymap <- readShapePoly("data/mapdata201701120616/DistrictBorder1051214/TOWN_MOI_1051214.shp")
# Paste county names and town names together without space
# iconv is used to convert encoding
CountyTown <- paste0(iconv(mymap$COUNTYNAME, from = "UTF-8"),
                    iconv(mymap$TOWNNAME, from = "UTF-8"))
# Fortify mymap as a data frame
mymap2 <- fortify(mymap) %>%
  transform(id = factor(id, labels = CountyTown))
# Read older adults proportion data
raw_data <- read.csv("data/OldRate.csv")
# Add countytown names to the older adults proportion data frame
# because the original chinese characters seem unacceptable in shiny app
source("data/HOPE.R", encoding = "UTF-8")
raw_data$CountyTown <- hope
merged_data <- merge(data.frame(CountyTown = CountyTown), raw_data)
names(merged_data)[1] <- "id"
merged_data <- transform(merged_data, id = factor(id, levels = levels(mymap2$id))) %>%
  melt(id.vars = "id") %>%
  transform(variable = factor(variable, labels = c("104年12月", "105年6月", "105年12月")))
merged_data$aged <- sapply(1:nrow(merged_data),
                           function(i){
                             if (merged_data$value[i] < 7) {"未達高齡化"}
                             else if (merged_data$value[i] < 14) {"高齡化"}
                             else if (merged_data$value[i] < 20) {"高齡"}
                             else {"超高齡"}
                           })
merged_data <- transform(merged_data, aged = factor(aged,levels = c("未達高齡化", "高齡化", "高齡", "超高齡")))

shinyServer(function(input, output) {
  # county_data <- reactive({merged_data[grep(input$county, merged_data$id),]})
  # county_map <- reactive({mymap[grep(input$county, iconv(mymap$COUNTYNAME, from = "UTF-8")),]})
  # NOT WORKING above
  county_dataindex <- reactive({grep(input$county, merged_data$id)})
  county_mapindex <- reactive({grep(input$county, iconv(mymap$COUNTYNAME, from = "UTF-8"))})
  output$distPlot <- renderPlot({
    county_data <- merged_data[county_dataindex(),]
    county_map <- mymap[county_mapindex(),]
    county_map2 <- fortify(county_map)
    ids <- unique(as.numeric(county_map2$id))
    county_map2 <- transform(county_map2, id = factor(id, labels = CountyTown[ids+1]))
    if (input$type == "老年人口百分比") {
      if (input$times == "105年12月") {
        subcounty_data <- subset(county_data, variable == input$times)
        g <- ggplot(subcounty_data) +
          geom_map(map = county_map2, aes(map_id = id, fill = value), color = "white") +
          expand_limits(x = range(county_map2$long), y = range(county_map2$lat)) +
          coord_map()
        g <- g + scale_fill_gradient(limits = c(6, 28), low = "#ffeda0", high = "#f03b20")
        # Uniformize the scale of colors
        g <- g + labs(list(fill = "百分比"))
        g <- g + theme_dark()
        g + theme(axis.title = element_blank(),
                  axis.text = element_blank(),
                  axis.line = element_blank(),
                  axis.ticks = element_blank(),
                  panel.grid = element_blank())
      }
      else {
        g <- ggplot(county_data) +
          geom_map(map = county_map2, aes(map_id = id, fill = value), color = "white") +
          expand_limits(x = range(county_map2$long), y = range(county_map2$lat)) +
          coord_map() + facet_wrap(~ variable, ncol = 2)
        g <- g + scale_fill_gradient(limits = c(6, 28), low = "#ffeda0", high = "#f03b20")
        g <- g + labs(list(fill = "百分比"))
        g <- g + theme_dark()
        g + theme(axis.title = element_blank(),
                  axis.text = element_blank(),
                  axis.line = element_blank(),
                  axis.ticks = element_blank(),
                  panel.grid = element_blank())
      }
    }
    else {
      color_values <- c("#2c7bb6", "#abd9e9", "#fdae61", "#d7191c")
      label_values <- c("未達高齡化 (< 7%)",
                        expression("高齡化 (">= "7%, < 14%)"),
                        expression("高齡 (">= "14%, < 20%)"),
                        "超高齡 (> 20%)")
      # Prepared for matching according the sub-datasets later
      if (input$times == "105年12月") {
        subcounty_data <- subset(county_data, variable == input$times)
        MatchedIndex <- sort(match(unique(subcounty_data$aged), levels(merged_data$aged)))
        # I have to sort the index or otherwise the orders of matched indexes will be
        # the same as unique(subcounty_data$aged)
        # Example: match(unique(c(3,3,2,5,1,2,2,4)), 1:10)
        g <- ggplot(subcounty_data) +
          geom_map(map = county_map2, aes(map_id = id, fill = aged), color = "white") +
          expand_limits(x = range(county_map2$long), y = range(county_map2$lat)) +
          coord_map()
        g <- g + scale_fill_manual(values = color_values[MatchedIndex],
                                   labels = label_values[MatchedIndex])
        # If used all values and labels directly, counties which don't have all levels
        # (e.g. only aging and aged) will show from low levels (not aging and aging in this case) regardless
        g <- g + labs(list(fill = "高齡類型"))
        g <- g + theme_dark()
        g + theme(axis.title = element_blank(),
                  axis.text = element_blank(),
                  axis.line = element_blank(),
                  axis.ticks = element_blank(),
                  panel.grid = element_blank())  
      }
      else {
        MatchedIndex <- sort(match(unique(county_data$aged), levels(merged_data$aged)))
        g <- ggplot(county_data) +
          geom_map(map = county_map2, aes(map_id = id, fill = aged), color = "white") +
          expand_limits(x = range(county_map2$long), y = range(county_map2$lat)) +
          coord_map() + facet_wrap(~ variable, ncol = 2)
        g <- g + scale_fill_manual(values = color_values[MatchedIndex],
                                   labels = label_values[MatchedIndex])
        g <- g + labs(list(fill = "高齡類型"))
        g <- g + theme_dark()
        g + theme(axis.title = element_blank(),
                  axis.text = element_blank(),
                  axis.line = element_blank(),
                  axis.ticks = element_blank(),
                  panel.grid = element_blank())
      }
    }
  })
  output$districtdata <- renderDataTable({
    county_data <- merged_data[county_dataindex(),] %>%
      transform(id = as.character(id),
                variable = as.character(variable),
                aged = as.character(aged))
    if (input$times == "105年12月") {
      subcounty_data <- subset(county_data, variable == input$times)
      names(subcounty_data) <- c("鄉/鎮/市/區", "資料時間",
                                 "老年人口百分比", "高齡類型")
      subcounty_data
    }
    else {
      names(county_data) <- c("鄉/鎮/市/區", "資料時間",
                              "老年人口百分比", "高齡類型")
      county_data
    }
  })
})
