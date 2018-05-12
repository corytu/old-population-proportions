# Old-Population-Proportions
Shiny app showing proportions of older adults across districts in Taiwan

## v2.0 全新改版
- 本次地圖捨棄`ggplot2`的靜態表現，改用`leaflet`呈現互動式地圖。
- 使用者不再需要選定縣市別而可綜觀全臺灣資料。
- 上次使用`ggplot2::fortify`將sp物件（SpatialPolygonsDataFrame）轉為data frame，再`base::merge`鄉鎮市區邊界與老化資料；而本次則直接使用`sp::merge`將老化資料的data frame融合進sp物件。
- 語法主要參考[Leaflet for R - Choropleths](https://rstudio.github.io/leaflet/choropleths.html)，併以`shiny`套件呈現。
- 雖然互動性提高了一些，但代價是圖形呈現的速度變慢了，目前還沒有找到方法加快、或是讓使用者知道執行進度（[issue #1](https://github.com/corytu/OldPopulationProportions/issues/1)）。

## 啟動方式
執行本程式的方法有三：

1. 造訪[臺灣各鄉鎮市區老化情形 @ shinyapps.io](https://corytu.shinyapps.io/old-population-proportions/)。此為[shinyapps.io](http://www.shinyapps.io)提供之免費解決方案。
2. 造訪[臺灣各鄉鎮市區老化情形 @ Google Compute Engine](http://104.199.205.203:3838/OldPopulationProportions/)。此為[Google Cloud Platform](https://cloud.google.com)提供的免費試用額度（該額度用完時我會把這個連結關掉）。順帶一題，我寫了一篇[如何在GCP上佈署Shiny Server](howto_deploy_onGCP.md)的步驟教學，以及[佈署時會用到的shell script](deploy_shiny_server.sh)，以整理佈署過程中遇到的困難及解決方法。
3. 有安裝R軟體者，可直接在本地端執行：

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
