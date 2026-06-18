library(sf)
library(rmapshaper)

# 讀取原始 shapefile
mymap <- st_read("data/mapdata201701120616/TOWN_MOI_1051214.shp", quiet = TRUE)

# 簡化邊界節點，保留 5% 的節點
# 若視覺上邊界過於粗糙，可調高至 keep = 0.1 或 keep = 0.2
mymap_simplified <- ms_simplify(mymap, keep = 0.05, keep_shapes = TRUE) |>
  st_transform(crs = 4326)  # TWD97 轉 WGS84，避免 leaflet 座標系統不一致的警告

# 存成 GeoJSON，供 app.R 讀取
st_write(mymap_simplified, "data/taiwan_simplified.geojson", delete_dsn = TRUE)

message("完成：data/taiwan_simplified.geojson")