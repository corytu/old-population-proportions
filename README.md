# Old-Population-Proportions
Shiny app showing proportions of older adults across districts in Taiwan

## v2.0 全新改版
- 本次地圖捨棄`ggplot2`的靜態表現，改用`leaflet`呈現互動式地圖。
- 使用者不再需要選定縣市別而可綜觀全臺灣資料。
- 上次使用`ggplot2::fortify`將sp物件（SpatialPolygonsDataFrame）轉為data frame，再`base::merge`鄉鎮市區邊界與老化資料；而本次則直接使用`sp::merge`將老化資料的data frame融合進sp物件。
- 語法主要參考[Leaflet for R - Choropleths](https://rstudio.github.io/leaflet/choropleths.html)，併以`shiny`套件呈現。
- 在PTT上[問過之後](https://www.ptt.cc/bbs/R_Language/M.1503326582.A.2EC.html)，發現並非單純為程式碼中產生地圖的過程編寫進度即可，物件呈現花的時間也不少，但最後這一步無法被寫進`shiny::withProgress`內（[issue #1](https://github.com/corytu/OldPopulationProportions/issues/1)）。

## 啟動方式
執行本程式的方法有二：

1. 直接點擊[臺灣各鄉鎮市區老化情形](https://corytu.shinyapps.io/old-population-proportions/)。此為[shinyapps.io](http://www.shinyapps.io)提供之免費方案，然因此版本所需運算量較大，執行速度不理想。
2. 有安裝R軟體者，可直接在本地端執行：

    ```r
    # 第一次使用需安裝套件
    install.packages(c("shiny", "magrittr", "maptools", "leaflet", "rgeos"))
    # 套件安裝完成後
    shiny::runGitHub("OldPopulationProportions", "corytu")
    ```

## 政府開放資料授權顯名聲明
- 內政部國土測繪中心 [2017] [[鄉鎮市區界線（TWD97經緯度）]](https://data.gov.tw/dataset/7441)
- 內政部戶政司 [2017] [[各村（里）戶籍人口統計月報表]](https://data.gov.tw/dataset/8411)
- 此開放資料依政府資料開放授權條款（Open Government Data License）進行公眾釋出，使用者於遵守本條款各項規定之前提下，得利用之。
- 政府資料開放授權條款：https://data.gov.tw/license
