library(shiny)
library(DT)
library(sf)
library(leaflet)
library(dplyr)

# 讀取已簡化的地圖（由 preprocess_map.R 預先產生）
mymap <- st_read("data/taiwan_simplified.geojson", quiet = TRUE)
mymap$CountyTown <- paste0(mymap$COUNTYNAME, mymap$TOWNNAME)

# 讀取人口資料（由 preprocess_data.R 預先產生）
clean_data <- read.csv("data/OldRateStatus.csv", fileEncoding = "UTF-8", stringsAsFactors = FALSE)
clean_data <- clean_data %>%
  mutate(across(ends_with("_status"),
                ~factor(., levels = c("未達高齡化", "高齡化", "高齡", "超高齡"))))

# 地圖與人口資料合併一次，之後不再重複合併
base_map <- left_join(mymap, clean_data, by = "CountyTown")

# 準備時間點向量
timepoints_en <- names(clean_data) |> grep("^Y\\d+M\\d+$", x = _, value = TRUE)
timepoints_ch <- c("104年12月",
                   sprintf("%d年%d月",
                           rep(105:200, each = 2, length.out = (ncol(clean_data)-2)/2),
                           rep(c(6,12), each = 1, length.out = (ncol(clean_data)-2)/2)))

# UI
ui <- fluidPage(
  titlePanel("臺灣各鄉鎮市區老化情形"),
  sidebarLayout(
    sidebarPanel(
      selectInput("selecttime", "請選擇時間點：", rev(timepoints_ch)),
      radioButtons("datatype", "請選擇欲觀看資料型別：", c("老年人口百分比", "高齡類型")),
      # submitButton 已移除，改由 debounce 控制更新時機
      helpText(HTML("區域邊界資料來源：<a href=\"http://data.gov.tw/dataset/7441\">內政部國土測繪中心 [2017] 鄉鎮市區界線（TWD97經緯度）</a>")),
      helpText(HTML("老化人口資料來源：<a href=\"https://data.gov.tw/dataset/8411\">內政部戶政司 [2017] 各村（里）戶籍人口統計月報表</a>")),
      helpText(HTML("此開放資料依<a href=\"https://data.gov.tw/license\">政府資料開放授權條款（Open Government Data License）</a>進行公眾釋出，使用者於遵守本條款各項規定之前提下，得利用之。")),
      helpText(HTML("老化數據資料整理：張永泓<br>系統建置暨維護：涂玉臻")),
      helpText("最後更新：115年6月"),
      helpText(HTML("在<a href=\"https://github.com/corytu/old-population-proportions\">GitHub</a>上查看原始碼"))
    ),
    mainPanel(
      leafletOutput("mapplot", height = 700),
      br(),
      DTOutput("districtdata")
    )
  )
)

# Server
server <- function(input, output) {

  # col 與 datatype 一起包進同一個 reactive 再 debounce
  # 確保兩者永遠同步更新，避免 colorNumeric 收到 factor 導致 crash
  selected_raw <- reactive({
    match_time <- timepoints_en[match(input$selecttime, timepoints_ch)]
    list(
      col      = if (input$datatype == "高齡類型") paste(match_time, "status", sep = "_") else match_time,
      datatype = input$datatype
    )
  })
  selected <- selected_raw %>% debounce(500)

  # 建立底圖，只執行一次，不含任何資料層
  output$mapplot <- renderLeaflet({
    leaflet() %>%
      setView(121, 23.5, 7) %>%
      addTiles()
  })

  # 使用者切換選項時，只更新資料層，底圖與縮放位置保留
  observe({
    params   <- selected()
    col      <- params$col
    datatype <- params$datatype
    values   <- base_map[[col]]

    if (datatype == "老年人口百分比") {
      pal  <- colorNumeric("YlOrRd", values)
      labs <- sprintf("<strong>%s</strong><br>%g%%",
                      base_map$CountyTown, values) %>% lapply(HTML)

      leafletProxy("mapplot", data = base_map) %>%
        clearShapes() %>%
        clearControls() %>%
        addPolygons(
          weight = 2, color = "white", dashArray = 3,
          fillColor = ~pal(values), fillOpacity = 0.8,
          highlightOptions = highlightOptions(
            weight = 5, color = "#636363", bringToFront = TRUE
          ),
          label = labs,
          labelOptions = labelOptions(
            textsize = "15px",
            style = list("font-weight" = "normal")
          )
        ) %>%
        addLegend(
          position = "bottomright",
          pal = pal, values = values, opacity = 0.8,
          title = "老年人口百分比",
          labFormat = labelFormat(suffix = "%")
        )

    } else {
      pal  <- colorFactor(c("#2c7bb6", "#abd9e9", "#fdae61", "#d7191c"), values)
      labs <- sprintf("<strong>%s</strong><br>%s",
                      base_map$CountyTown, values) %>% lapply(HTML)

      leafletProxy("mapplot", data = base_map) %>%
        clearShapes() %>%
        clearControls() %>%
        addPolygons(
          weight = 2, color = "white", dashArray = 3,
          fillColor = ~pal(values), fillOpacity = 0.8,
          highlightOptions = highlightOptions(
            weight = 5, color = "#636363", bringToFront = TRUE
          ),
          label = labs,
          labelOptions = labelOptions(
            textsize = "15px",
            style = list("font-weight" = "normal")
          )
        ) %>%
        addLegend(
          position = "bottomright",
          pal = pal, values = values, opacity = 0.8,
          title = "高齡類型",
          labFormat = labelFormat(
            transform = function(vec) {
              sapply(vec, function(x) {
                if      (x == "未達高齡化") "未達高齡化（< 7%）"
                else if (x == "高齡化")     "高齡化（>= 7%, < 14%）"
                else if (x == "高齡")       "高齡（>= 14%, < 20%）"
                else                        "超高齡（> 20%）"
              })
            }
          )
        )
    }
  })

  # 資料表：從 base_map 直接取對應欄位
  output$districtdata <- renderDT({
    params    <- selected()
    col       <- params$col
    col_label <- if (params$datatype == "老年人口百分比") "老年人口百分比" else "高齡類型"
    base_map %>%
      st_drop_geometry() %>%
      select(CountyTown, all_of(col)) %>%
      setNames(c("鄉/鎮/市/區", col_label))
  })
}

shinyApp(ui = ui, server = server)