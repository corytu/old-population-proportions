# Old-Population-Proportions
Shiny app showing proportions of older adults across districts in Taiwan

[臺灣各鄉鎮市區老化情形 @ shinyapps.io](https://corytu.shinyapps.io/old-population-proportions)。此為 [shinyapps.io](http://www.shinyapps.io) 提供之免費解決方案。

各版本更動細節請見 GitHub Releases。

## v2.1.1 效能優化（2026）
- 藉由 AI 協助判讀效能瓶頸、改寫程式，大幅提升地圖渲染效率，解決自 v2.0 起互動式地圖載入過慢的問題。
- 需要 R (>= 4.2.0)，因為使用了原生 pipe operator (`|>`) 和 argument placeholder (`_`)。

## v2.0 全新改版（2018）
- 本次地圖捨棄 `ggplot2` 的靜態表現，改用 `leaflet` 呈現互動式地圖。
- 使用者不再需要選定縣市別而可綜觀全臺灣資料。
- 雖然互動性提高了一些，但代價是圖形呈現的速度變慢了，目前還沒有找到方法加快、或是讓使用者知道執行進度。
    - 如果加上進度條，它會瞬間跑完，但地圖還是要至少十數秒後才會被呈現（[issue #1](https://github.com/corytu/OldPopulationProportions/issues/1)）。
    - 網路上有一些關於 `leaflet` 畫大型地圖的表現討論：
        - [Leaflet R performance issues with large map](https://stackoverflow.com/questions/40063663/leaflet-r-performance-issues-with-large-map)
        - [Shiny app runs significantly slower on Shiny Servers than it does locally](https://stackoverflow.com/questions/50307616/shiny-app-runs-significantly-slower-on-shiny-servers-than-it-does-locally/)
        - [Render large spatial datasets in shiny leaflet (ropensci/auunconf#38)](https://github.com/ropensci/auunconf/issues/38)

## 在 Google Cloud Platform 部署（2018）
我寫了[如何在 GCP 上部署 Shiny Server](setup/howto_deploy_onGCP.md) 的步驟教學，以及[部署時會用到的 shell script](setup/deploy_shiny_server.sh)，用來整理部署過程中遇到的困難及解決方法。

⚠️ 請注意：此專案/文件撰寫於 2018 年，主要用於整理當時遇到的困難及解決方法。由於 GCP 與 Shiny Server 歷經多次版本更新，相關設定可能已過時，請斟酌參考。

## 政府開放資料授權顯名聲明
- 內政部國土測繪中心 [2017] [[鄉鎮市區界線（TWD97經緯度）]](https://data.gov.tw/dataset/7441)
- 內政部戶政司 [2017] [[各村（里）戶籍人口統計月報表]](https://data.gov.tw/dataset/8411)
- 此開放資料依政府資料開放授權條款（Open Government Data License）進行公眾釋出，使用者於遵守本條款各項規定之前提下，得利用之。
- 政府資料開放授權條款：https://data.gov.tw/license
