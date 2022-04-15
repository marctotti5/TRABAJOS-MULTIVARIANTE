# Cargamos las librerías
library(tidyverse)
library(lubridate)
{
airbnb_data <- read.csv("./listings2.csv", encoding = "UTF-8") 

## Comprobamos el porcentaje de Na's en cada variable
sort(colMeans(is.na(airbnb_data)), decreasing = TRUE) # vemos que la variable con más na's es calendar_updated y bathrooms

## Eliminamos la columna calendar, porque no nos sirve de nada
airbnb_data$calendar_updated <- NULL

## Vamos a ver que le pasa a bathrooms
airbnb_data$bathrooms 
airbnb_data$bathrooms_text

## Eliminamos aquellos apartamentos donde aparecen valores no numéricos
no_numericos <- c("", "Half-bath", "Private half-bath", "Shared half-bath")
`%notin%` <- Negate(`%in%`)

airbnb_data <- filter(airbnb_data, bathrooms_text %notin% no_numericos)

airbnb_data$bathrooms <- as.numeric(unlist(regmatches(airbnb_data$bathrooms_text,
                             gregexpr("[[:digit:]]+\\.*[[:digit:]]*", airbnb_data$bathrooms_text))))

## Eliminamos las columnas innecesarias
variables_descartadas_apriori <- c("name", "listing_url", "last_scraped", "description", "neighborhood_overview", 
                                   "picture_url", "host_id", "host_url", "host_name", 
                                   "host_location", "host_about", "host_is_superhost", 
                                   "host_thumbnail_url", "host_picture_url", "neighbourhood", 
                                   "bathrooms_text", "minimum_minimum_nights", "maximum_minimum_nights", 
                                   "minimum_maximum_nights", "maximum_maximum_nights", "minimum_nights_avg_ntm", 
                                   "maximum_nights_avg_ntm", "calendar_last_scraped", "license")
airbnb_data <- select(airbnb_data, -variables_descartadas_apriori)


# First we substitute the strange values with NA's
patterns <- c("N/A", "-", "*", "[no name]", ".", "")

for(j in 1:ncol(airbnb_data)){
        for(i in 1:nrow(airbnb_data)){
                for(k in 1:length(patterns)){
                        if(airbnb_data[i, j] == patterns[k] & !is.na(airbnb_data[i, j])){
                                airbnb_data[i, j] <- NA
                        }
                }
        }
}

## Eliminamos los NA's, ya que seguimos quedandonos con un tamaño muestral grande
airbnb_data <- airbnb_data[complete.cases(airbnb_data), ]


## Ahora formateamos los datos
## Convertimos las variables categoricas en factor
lista_factores <- vector(mode = "list", length = ncol(airbnb_data))
for(j in 1:ncol(airbnb_data)){
        lista_factores[[j]] <- levels(as.factor(airbnb_data[, j]))
}

## Podemos comprobar que no hay na's ni valores raras

## Modificamos las variables amenities y host verifications para que sus atributos sean binarios

library(mgsub)
library(stringr)

host_verifications <- as.data.frame(mgsub(airbnb_data$host_verifications, c("\\[", "\\]", "\\,", "\\'") , c("", "", "", "")))
amenities <- as.data.frame(mgsub(airbnb_data$amenities, c("\\{", "\\}", "\\,", "\\'", "\\[", "\\]", "\"", "\\/") , c("", "", "  ", "", "", "", "", "")))

output_list_verifications <- list()
output_list_verifications_count <- list()
output_list_amenities <- list()
output_list_amenities_count <- list()
for(i in 1:nrow(host_verifications)){
        output_list_verifications[i] <- str_split(host_verifications[i, ], " ")[1]
        output_list_verifications_count[i] <- length(output_list_verifications[[i]])
        output_list_amenities[i] <- str_split(amenities[i, ], "  ")[1]
        output_list_amenities_count[i] <- length(output_list_amenities[[i]])
}

dummy_host_verifications_cols <- output_list_verifications[[which.max(output_list_verifications_count)]] # here we have the row with the most number of amenities, which we will use to create some dummy variables
dummy_host_verifications_df <- matrix(nrow = nrow(airbnb_data), ncol = length(dummy_host_verifications_cols)) %>% as.data.frame()
colnames(dummy_host_verifications_df) <- dummy_host_verifications_cols

dummy_amenities_cols <- output_list_amenities[[which.max(output_list_amenities_count)]] # here we have the row with the most number of amenities, which we will use to create some dummy variables
dummy_amenities_df <- matrix(nrow = nrow(airbnb_data), ncol = length(dummy_amenities_cols)) %>% as.data.frame()
colnames(dummy_amenities_df) <- dummy_amenities_cols

# Now we merge the new columns with the airbnb dataset and we fill them with Yes (1) or No (0)
airbnb_data <- cbind(airbnb_data, dummy_host_verifications_df, dummy_amenities_df)

# Ahora sustituimos por 1 si el apartamento tiene dicha amenidad o verificacion y por 0 si no la tiene
# Now we susbtitute the NA's with Yes(if the apartment has that verification or amenitie, and no if it doesn't)
for(l in 1:length(output_list_verifications)){
        for(j in 50:60){
                if(colnames(airbnb_data)[j] %in% output_list_verifications[[l]]){
                        airbnb_data[l, j] <- "true"
                } else{
                        airbnb_data[l, j] <- "false"
                }
        }
}

for(l in 1:length(output_list_amenities)){
        for(k in 61:ncol(airbnb_data)){
                if(colnames(airbnb_data)[k] %in% output_list_amenities[[l]]){
                        airbnb_data[l, k] <- "true"
                } else{
                        airbnb_data[l, k] <- "false"
                }
        }
}

airbnb_data$amenities <- NULL
airbnb_data$host_verifications <- NULL
airbnb_data$has_availability <- NULL
airbnb_data$is_business_travel_ready <- NULL
# Now I create variables that count the days since the host started, the days from the first review, and the days from the last review
airbnb_data$days_since_host <- (today() - as.Date(airbnb_data$host_since)) %>% as.numeric()
airbnb_data$days_since_first_review <- (today() - as.Date(airbnb_data$first_review)) %>% as.numeric()
airbnb_data$days_since_last_review <- (today() - as.Date(airbnb_data$last_review)) %>% as.numeric()
airbnb_data$host_since <- NULL
airbnb_data$first_review <- NULL
airbnb_data$last_review <- NULL
airbnb_data$host_response_time <- NULL
airbnb_data$host_listings_count <- NULL
airbnb_data$host_neighbourhood <- NULL
airbnb_data$scrape_id <- NULL

# Numeric columns with percentages 
for(i in c(2, 3)){
        airbnb_data[, i] <- as.numeric(gsub("%", "", airbnb_data[, i])) / 100
}


# Numeric columns with dollar sign
airbnb_data[, "price"] <- gsub("\\$", "", airbnb_data[, "price"]) # the dollar is a regular expression
airbnb_data[, "price"] <- gsub(",", "", airbnb_data[, "price"]) %>% as.numeric()

# Boolean columns
for(i in c("host_has_profile_pic", "host_identity_verified", "instant_bookable")){
        airbnb_data[, i] <- gsub("t", "true", airbnb_data[, i])
        airbnb_data[, i] <- gsub("f", "false", airbnb_data[, i])
}


# Agrupamos categorias en la variable tipo de propiedad (property_type)
airbnb_data$property_type <- as.factor(airbnb_data$property_type)
categorias_iniciales_property_type <- levels(airbnb_data$property_type)
property_type_ordered <- airbnb_data %>% count(property_type, sort = TRUE)
top7_categorias <- as.character(property_type_ordered[c(1:7), 1])
vector_booleano <- vector(length = length(top7_categorias))
categorias_finales_property_type <- vector(length = length(categorias_iniciales_property_type))

for(i in 1:length(categorias_iniciales_property_type)){
        for (j in 1:length(top7_categorias)){
                if(categorias_iniciales_property_type[i] == top7_categorias[j]){
                        vector_booleano[j] <- TRUE
                } else {
                        vector_booleano[j] <- FALSE
                }
                
                if(any(vector_booleano == TRUE)){
                        categorias_finales_property_type[i] <- top7_categorias[vector_booleano == TRUE]
                } else {
                        categorias_finales_property_type[i] <- "Other"
                }
        }
        vector_booleano <- vector(length = length(top7_categorias))
}

# Ahora sustituimos los levels y ya tendremos las variables agrupadas
levels(airbnb_data$property_type) <- categorias_finales_property_type
airbnb_data$property_type <- factor(airbnb_data$property_type, levels = c(top7_categorias, "Other")) 

# Eliminamos algunas variables más
eliminar_variables <- c("X.U.FEFF.id", "calculated_host_listings_count_entire_homes", 
                        "calculated_host_listings_count_entire_homes", "calculated_host_listings_count_private_rooms", 
                        "calculated_host_listings_count_shared_rooms", "jumio", 
                        "offline_government_id", "sent_id", 
                        "identity_manual", "Extra pillows and blankets", 
                        " Barbecue utensils", " Single level home", 
                        "email", "phone", 
                        " Portable fans", " Private patio or balcony",
                        " Backyard", " Window guards", 
                        " Outlet covers", " TV with standard cable",
                        " Table corner guards", " Hot water kettle", 
                        " Baking sheet", " Baking sheet", 
                        " Laundromat nearby", " Beach essentials", 
                        " dove", "body soap", 
                        " Children\\u2019s books and toys", " Outdoor furniture", 
                        " Cleaning before checkout", " Rice maker", 
                        " Safe", " Bluetooth sound system", " dove conditioner",
                        " Clothing storage: walk-in closet", " Shared gym nearby",
                        " Outdoor dining area", " Board games", 
                        "days_since_last_review", "days_since_host", "days_since_first_review",
                        "host_response_rate", "availability_60", 
                        "availability_365", "number_of_reviews_l30d", "calculated_host_listings_count")

airbnb_data <- select(airbnb_data, -eliminar_variables)
head(airbnb_data)

# Guardamos los datos en un csv
write_csv(airbnb_data, file = "datos_limpios.csv")
}