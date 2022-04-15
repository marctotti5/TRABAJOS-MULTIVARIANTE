# Cargamos los datos 
library(tidyverse)
airbnb_data = read.csv("./datos_limpios.csv", encoding = "UTF-8")


# MAPAS
night_neighbourhood <- airbnb_data %>% group_by(neighbourhood_cleansed) %>% summarize(avg_night_price = mean(price), median_night_price = median(price), listings = n()) %>% arrange(desc(avg_night_price))
night_neighbourhood <- night_neighbourhood[-1, ] # first row is clearly an outlier

## Mapa barrios i el precio medio de cada un
neighbourhoods_geojson <- rgdal::readOGR("./neighbourhoods.geojson", encoding = "UTF-8")

neighbourhoods_geojson@data$neighbourhood <- as.factor(neighbourhoods_geojson@data$neighbourhood)

neighbourhoods_geojson@data <- left_join(neighbourhoods_geojson@data, night_neighbourhood[, c(1, 2, 4)]) %>% as.data.frame()

for(i in 1:nrow(neighbourhoods_geojson@data)){
        if(is.na(neighbourhoods_geojson@data[i, "avg_night_price"]) == TRUE){
                neighbourhoods_geojson@data[i, 3] <- mean(neighbourhoods_geojson@data[complete.cases(neighbourhoods_geojson@data), 3])
        } 
        
        if(is.na(neighbourhoods_geojson@data[i, "listings"]) == TRUE){
                neighbourhoods_geojson@data[i, 4] <- round(mean(neighbourhoods_geojson@data[complete.cases(neighbourhoods_geojson@data), 4]))
        }
}


# MAPA 1: 


library(leaflet)
pal <- colorNumeric(
        palette = "YlGnBu",
        domain = neighbourhoods_geojson@data$avg_night_price
)


price_per_neighbourhood <- leaflet(neighbourhoods_geojson) %>%
        addTiles() %>% setView(lng = 2.1734, lat = 41.3851, zoom = 12) %>%
        addPolygons(stroke = TRUE, fillColor = ~ pal(avg_night_price), fillOpacity = 0.8,
                    highlight = highlightOptions(weight = 2,
                                                 color = ~ pal(avg_night_price), 
                                                 fillOpacity = 1,
                                                 bringToFront = TRUE),
                    label = ~neighbourhood,
                    smoothFactor = 0.2,
                    popup = ~ paste(paste(neighbourhood,":"), "<br/>","<b/>", paste("Precio medio/noche: ", "$", round(avg_night_price)))) %>%
        addLegend("bottomright", pal = pal, values = ~avg_night_price, opacity = 1.0, 
                  title = "Precio medio por noche",
                  labFormat = labelFormat(prefix = "$"), na.label="")



# MAPA por grupos de tipo de vivienda

pal3 <- colorFactor(palette = c(
        "dodgerblue2", "#E31A1C", 
        "green4",
        "#6A3D9A", 
        "#FF7F00", 
        "black", "gold1",
        "skyblue2", "#FB9A99", 
        "palegreen2",
        "#CAB2D6", 
        "#FDBF6F", 
        "gray70", "khaki2",
        "maroon", "orchid1", "deeppink1", "blue1", "steelblue4",
        "darkturquoise", "green1"), 
        domain = airbnb_data$property_type)

# Ara creamos un dataset para cada grupo
typeofproperty <- list()
for (i in 1:length(levels(as.factor(airbnb_data$property_type)))) {
        typeofproperty[[i]] <- airbnb_data %>% dplyr::filter(property_type == levels(as.factor(airbnb_data$property_type))[i])
}
names(typeofproperty) <- levels(as.factor(airbnb_data$property_type))

typeofproperty_map <- leaflet() %>% addTiles() %>% setView(lng = 2.1734, lat = 41.3851, zoom = 13)

for (i in 1:length(levels(as.factor(airbnb_data$property_type)))) {
        typeofproperty_map <- typeofproperty_map %>% addCircles(data = typeofproperty[[i]], lat = ~latitude, 
                                                                lng = ~longitude, color = ~pal3(property_type), 
                                                                fillOpacity = 1, label = ~property_type, 
                                                                popup = ~price, group = levels(as.factor(airbnb_data$property_type))[i])
}

typeofproperty_map <- typeofproperty_map %>% addLegend(data = airbnb_data, "topleft", 
                                                       pal = pal3, values = ~property_type, title = "Tipo de propiedad", 
                                                       opacity = 1, group = "Legend")

groups <- c("Legend", levels(as.factor(airbnb_data$property_type)))
typeofproperty_map <- typeofproperty_map %>% addLayersControl(overlayGroups = groups, 
                                                              options = layersControlOptions(collapsed = TRUE)) 