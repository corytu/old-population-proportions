library(shiny)
library(magrittr)
library(maptools)
library(leaflet)
library(rgeos)

# Read the borders from .shp file
mymap <- readShapePoly("data/mapdata201701120616/TOWN_MOI_1051214.shp")
# Read the old population data
clean_data <- read.csv("data/OldRateStatus.csv", fileEncoding = "UTF-8", stringsAsFactors = FALSE)
clean_data[, names(clean_data) %>% grep("_status$", .)] %<>%
  lapply(function(column) {factor(column, levels = c("未達高齡化", "高齡化", "高齡", "超高齡"))})

# Prepare vectors of time points
timepoints_en <- names(clean_data) %>% grep("^Y\\d+M\\d+$", ., value = TRUE)
timepoints_ch <- c("104年12月",
                   sprintf("%d年%d月",
                           rep(105:200, each = 2, length.out = (ncol(clean_data)-2)/2),
                           rep(c(6,12), each = 1, length.out = (ncol(clean_data)-2)/2)))

# Create a dataframe for later merging
CountyTown <- paste0(iconv(mymap$COUNTYNAME, from = "UTF-8"),
                     iconv(mymap$TOWNNAME, from = "UTF-8"))
joint <- data.frame(CountyTown, TOWNCODE = mymap$TOWNCODE)

# Create UI
ui <- fluidPage(
  titlePanel("臺灣各鄉鎮市區老化情形"),
  sidebarLayout(
    sidebarPanel(
      selectInput("selecttime", "請選擇時間點：", rev(timepoints_ch)),
      radioButtons("datatype", "請選擇欲觀看資料型別：", c("老年人口百分比", "高齡類型")),
      submitButton("確認"),
      helpText(HTML("區域邊界資料來源：<a href=\"http://data.gov.tw/dataset/7441\">內政部國土測繪中心 [2017] 鄉鎮市區界線（TWD97經緯度）</a>")),
      helpText(HTML("老化人口資料來源：<a href=\"https://data.gov.tw/dataset/8411\">內政部戶政司 [2017] 各村（里）戶籍人口統計月報表</a>")),
      helpText(HTML("此開放資料依<a href=\"https://data.gov.tw/license\">政府資料開放授權條款（Open Government Data License）</a>進行公眾釋出，使用者於遵守本條款各項規定之前提下，得利用之。")),
      helpText(HTML("老化數據資料整理：張永泓<br>系統建置暨維護：涂玉臻")),
      helpText("最後更新：107年2月"),
      helpText(HTML("在<a href=\"https://github.com/corytu/OldPopulationProportions\">GitHub</a>上查看原始碼"))
    ),
    mainPanel(
      leafletOutput("mapplot", height = 700),
      br(),
      dataTableOutput("districtdata")
    )
  )
)

# Create server
server <- function(input, output) {
  # Do things only after the actionButton is clicked
  
  # Subset the interested data
  match_data <- reactive({
    match_time <- timepoints_en[match(input$selecttime, timepoints_ch)]
    if (input$datatype == "高齡類型") {
      match_time <- paste(match_time, "status", sep = "_")
    }
    clean_data <- clean_data[,c("CountyTown", match_time)]
    names(clean_data) <- c("CountyTown", "Values")
    clean_data
  })
  
  # Merging the proportion data into the sp object
  merge_map <- reactive({
    merge(match_data(), joint) %>%
      merge(x = mymap)
  })
  
  # Plot the map
  output$mapplot <- renderLeaflet({
    if (input$datatype == "老年人口百分比") {
      # Define palettes
      pal <- colorNumeric("YlOrRd", merge_map()$Values)
      labs <- sprintf(
        "<strong>%s</strong><br>%g%%", merge_map()$CountyTown, merge_map()$Values
      ) %>%
        lapply(HTML)
      
      # Map plotting
      leaflet(merge_map()) %>%
        setView(121, 23.5, 7) %>%
        addTiles() %>%
        addPolygons(weight = 2, color = "white", dashArray = 3,
                    fillColor = ~pal(Values), fillOpacity = 0.8,
                    highlightOptions = highlightOptions(
                      weight = 5, color = "#636363", bringToFront = TRUE
                    ),
                    label = labs,
                    labelOptions = labelOptions(
                      textsize = "15px",
                      style = list("font-weight" = "normal")
                    )) %>%
        addLegend(position = "bottomright",
                  pal = pal, values = ~Values, opacity = 0.8,
                  title = "老年人口百分比",
                  labFormat = labelFormat(suffix = "%"))
    }
    else {
      # Define palettes
      pal <- colorFactor(c("#2c7bb6", "#abd9e9", "#fdae61", "#d7191c"),
                         merge_map()$Values)
      labs <- sprintf(
        "<strong>%s</strong><br>%s", merge_map()$CountyTown, merge_map()$Values
      ) %>%
        lapply(HTML)
      
      # Map plotting
      leaflet(merge_map()) %>%
        setView(121, 23.5, 7) %>%
        addTiles() %>%
        addPolygons(weight = 2, color = "white", dashArray = 3,
                    fillColor = ~pal(Values), fillOpacity = 0.8,
                    highlightOptions = highlightOptions(
                      weight = 5, color = "#636363", bringToFront = TRUE
                    ),
                    label = labs,
                    labelOptions = labelOptions(
                      textsize = "15px",
                      style = list("font-weight" = "normal")
                    )) %>%
        addLegend(position = "bottomright",
                  pal = pal, values = ~Values, opacity = 0.8,
                  title = "高齡類型",
                  labFormat = labelFormat(
                    transform = function(vec) {
                      sapply(
                        vec,
                        function(x) {
                          if (x == "未達高齡化") {return("未達高齡化（< 7%）")}
                          else if (x == "高齡化") {return("高齡化（>= 7%, < 14%）")}
                          else if (x == "高齡") {return("高齡（>= 14%, < 20%）")}
                          else {return("超高齡（> 20%）")}
                        }
                      )
                    }
                  ))
    }
  })
  
  # Render data table
  output$districtdata <- renderDataTable({
    match_data()
  })
}

# Run the application 
shinyApp(ui = ui, server = server)
