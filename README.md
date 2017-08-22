# Old-Population-Proportions
Shiny app showing proportions of older adults across districts in Taiwan.

## v2.0 全新改版
- 本次地圖捨棄`ggplot2`的靜態表現，改用`leaflet`呈現互動式地圖。
- 使用者不再需要選定縣市別而可綜觀全臺灣資料。
- 上次使用`ggplot2::fortify`將sp物件（SpatialPolygonsDataFrame）轉為data frame，再`base::merge`鄉鎮市邊界與老化資料；而本次則直接使用`sp::merge`將老化資料的data frame融合進sp物件。
- 語法主要參考[Leaflet for R - Choropleths](https://rstudio.github.io/leaflet/choropleths.html)（其示範complete code複製於最下方），併以shiny套件呈現。

## 啟動方式
執行本程式的方法有二：
1. 直接點選[臺灣各鄉鎮市區老化情形](https://corytu.shinyapps.io/old_populations_dist/)。此為[shinyapps.io](http://www.shinyapps.io)提供之免費方案，然因此版本所需運算量較大，執行速度不甚理想。
2. 有安裝R軟體者，可直接在本地端執行（通常速度較快）：
    ```r
    # 第一次使用需安裝套件
    install.packages(c("shiny", "magrittr", "maptools", "leaflet", "rgeos"))
    # 套件安裝完成後
    shiny::runGitHub("Old-Population-Proportions", "corytu")
    ```

## 待完成
- 於shiny介面中加上進度條或對話視窗，告知使用者運算仍在進行中。

## Leaflet官網示範美國各州人口密度圖
```r
# From http://leafletjs.com/examples/choropleth/us-states.js
states <- geojsonio::geojson_read("json/us-states.geojson", what = "sp")

bins <- c(0, 10, 20, 50, 100, 200, 500, 1000, Inf)
pal <- colorBin("YlOrRd", domain = states$density, bins = bins)

labels <- sprintf(
  "<strong>%s</strong><br/>%g people / mi<sup>2</sup>",
  states$name, states$density
) %>% lapply(htmltools::HTML)

leaflet(states) %>%
  setView(-96, 37.8, 4) %>%
  addProviderTiles("MapBox", options = providerTileOptions(
    id = "mapbox.light",
    accessToken = Sys.getenv('MAPBOX_ACCESS_TOKEN'))) %>%
  addPolygons(
    fillColor = ~pal(density),
    weight = 2,
    opacity = 1,
    color = "white",
    dashArray = "3",
    fillOpacity = 0.7,
    highlight = highlightOptions(
      weight = 5,
      color = "#666",
      dashArray = "",
      fillOpacity = 0.7,
      bringToFront = TRUE),
    label = labels,
    labelOptions = labelOptions(
      style = list("font-weight" = "normal", padding = "3px 8px"),
      textsize = "15px",
      direction = "auto")) %>%
  addLegend(pal = pal, values = ~density, opacity = 0.7, title = NULL,
    position = "bottomright")
```
