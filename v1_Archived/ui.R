library(shiny)

# Define UI for application that draws a histogram
shinyUI(fluidPage(
  titlePanel("臺灣各縣市老化情形"),
  sidebarLayout(
    sidebarPanel(
      selectInput("county", "請選擇縣市：",
                  c("臺北市", "新北市", "基隆市", "桃園市", "新竹縣", "新竹市",
                    "苗栗縣", "臺中市", "彰化縣", "雲林縣", "嘉義縣", "嘉義市",
                    "臺南市", "高雄市", "屏東縣", "南投縣", "宜蘭縣", "花蓮縣",
                    "臺東縣", "澎湖縣", "金門縣", "連江縣")),
      radioButtons("type", "請選擇欲觀看資料型別：",
                   c("老年人口百分比", "高齡類型")),
      radioButtons("times", "請選擇欲呈現之資料時間：",
                   c("105年12月", "104年12月至105年12月")),
      helpText(HTML("區鄉鎮市對照請參考<a href=\"http://www.319.com.tw/custompage/show/45\">臺灣鄉鎮對照地圖</a>")),
      helpText(HTML("區域邊界資料來源：<a href=\"http://data.gov.tw/node/7441\">政府資料開放平臺 內政部國土測繪中心 [2015] [鄉（鎮、市、區）界線（TWD97經緯度）]</a>")),
      helpText(HTML("老化資料提供：Yung-Hung Chang")),
      helpText(HTML("系統建置暨維護：涂玉臻")),
      helpText("最後更新：106年3月")
    ),
    mainPanel(
       plotOutput("distPlot"),
       dataTableOutput("districtdata")
    )
  )
))
