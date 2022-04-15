# Cargamos las librerías y los datos

    library(tidyverse)

    ## -- Attaching packages --------------------------------------- tidyverse 1.3.1 --

    ## v ggplot2 3.3.5     v purrr   0.3.4
    ## v tibble  3.1.6     v dplyr   1.0.7
    ## v tidyr   1.1.4     v stringr 1.4.0
    ## v readr   2.1.1     v forcats 0.5.1

    ## -- Conflicts ------------------------------------------ tidyverse_conflicts() --
    ## x dplyr::filter() masks stats::filter()
    ## x dplyr::lag()    masks stats::lag()

    library(lubridate)

    ## 
    ## Attaching package: 'lubridate'

    ## The following objects are masked from 'package:base':
    ## 
    ##     date, intersect, setdiff, union

    airbnb_data <- read.csv("./listings2.csv", encoding = "UTF-8") 

Eliminamos la columna calendar, porque no nos sirve de nada:

    airbnb_data$calendar_updated <- NULL

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

    ## Note: Using an external vector in selections is ambiguous.
    ## i Use `all_of(variables_descartadas_apriori)` instead of `variables_descartadas_apriori` to silence this message.
    ## i See <https://tidyselect.r-lib.org/reference/faq-external-vector.html>.
    ## This message is displayed once per session.

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
                            "availability_365", "number_of_reviews_l30d")

    airbnb_data <- select(airbnb_data, -eliminar_variables)

    ## Note: Using an external vector in selections is ambiguous.
    ## i Use `all_of(eliminar_variables)` instead of `eliminar_variables` to silence this message.
    ## i See <https://tidyselect.r-lib.org/reference/faq-external-vector.html>.
    ## This message is displayed once per session.

    head(airbnb_data)

    ##   host_acceptance_rate host_total_listings_count host_has_profile_pic
    ## 1                 0.72                         1                 true
    ## 2                 0.00                         2                 true
    ## 5                 0.65                         1                 true
    ## 7                 0.98                        12                 true
    ## 8                 0.57                         1                 true
    ## 9                 1.00                         2                 true
    ##   host_identity_verified neighbourhood_cleansed neighbourhood_group_cleansed
    ## 1                   true         Hispanoamérica                    Chamartín
    ## 2                   true               Cármenes                       Latina
    ## 5                   true                Legazpi                   Arganzuela
    ## 7                   true               Justicia                       Centro
    ## 8                   true                   Goya                    Salamanca
    ## 9                   true               Justicia                       Centro
    ##   latitude longitude                    property_type       room_type
    ## 1 40.45724  -3.67688      Private room in rental unit    Private room
    ## 2 40.40381  -3.74130      Private room in rental unit    Private room
    ## 5 40.38975  -3.69018 Private room in residential home    Private room
    ## 7 40.41969  -3.69736               Entire rental unit Entire home/apt
    ## 8 40.42792  -3.67682       Entire condominium (condo) Entire home/apt
    ## 9 40.41884  -3.69655      Private room in rental unit    Private room
    ##   accommodates bathrooms bedrooms beds price minimum_nights maximum_nights
    ## 1            2       1.0        1    1    59              1           1125
    ## 2            1       1.0        1    1    31              4             40
    ## 5            1       1.0        1    1    29              2           1125
    ## 7            4       1.0        1    2    83              2            500
    ## 8            3       2.0        2    2    82             10            999
    ## 9            3       1.5        1    2    52              1             90
    ##   availability_30 availability_90 number_of_reviews number_of_reviews_ltm
    ## 1              10              59                81                     3
    ## 2               0               1                33                     0
    ## 5              11              69               154                     5
    ## 7               9              69               120                     2
    ## 8               0               7                55                     0
    ## 9              15              75               113                    34
    ##   review_scores_rating review_scores_accuracy review_scores_cleanliness
    ## 1                 4.88                   4.91                      4.82
    ## 2                 4.58                   4.72                      4.56
    ## 5                 4.68                   4.81                      4.92
    ## 7                 4.61                   4.72                      4.68
    ## 8                 4.83                   4.88                      4.86
    ## 9                 4.60                   4.83                      4.40
    ##   review_scores_checkin review_scores_communication review_scores_location
    ## 1                  4.80                        4.89                   4.78
    ## 2                  4.75                        4.82                   4.21
    ## 5                  4.79                        4.71                   4.71
    ## 7                  4.55                        4.86                   4.95
    ## 8                  4.86                        4.82                   4.90
    ## 9                  4.80                        4.88                   4.96
    ##   review_scores_value instant_bookable calculated_host_listings_count
    ## 1                4.85            false                              1
    ## 2                4.67            false                              2
    ## 5                4.72            false                              1
    ## 7                4.68             true                              9
    ## 8                4.78            false                              2
    ## 9                4.50             true                              2
    ##   reviews_per_month facebook reviews selfie government_id  Washer  Stove
    ## 1              0.57    false    true  false          true    true  false
    ## 2              0.38    false    true  false          true    true  false
    ## 5              1.09    false    true  false          true   false  false
    ## 7              0.87    false    true  false          true    true  false
    ## 8              0.41    false    true  false          true    true  false
    ## 9              2.59     true    true   true          true    true  false
    ##    Fire extinguisher  Dryer  Shampoo  Paid parking off premises
    ## 1              false  false     true                      false
    ## 2               true  false     true                      false
    ## 5              false  false     true                      false
    ## 7              false  false     true                       true
    ## 8              false  false     true                      false
    ## 9              false   true     true                      false
    ##    Dishes and silverware  First aid kit  Hot water  Shower gel
    ## 1                   true          false       true       false
    ## 2                   true           true       true       false
    ## 5                   true          false      false       false
    ## 7                   true          false       true        true
    ## 8                  false          false      false       false
    ## 9                   true           true       true       false
    ##    Free street parking  Air conditioning  Heating  Toaster  Host greets you
    ## 1                false              true     true    false            false
    ## 2                false              true     true    false            false
    ## 5                false             false     true    false             true
    ## 7                false              true     true    false            false
    ## 8                false              true     true    false             true
    ## 9                false             false     true    false            false
    ##    Luggage dropoff allowed  Smoke alarm  Pocket wifi  Dedicated workspace
    ## 1                    false        false         true                false
    ## 2                    false        false         true                 true
    ## 5                    false        false        false                false
    ## 7                     true        false        false                 true
    ## 8                    false        false        false                 true
    ## 9                    false        false         true                 true
    ##    Drying rack for clothing  Freezer  Room-darkening shades  Microwave  Iron
    ## 1                     false    false                  false      false  true
    ## 2                     false    false                  false       true  true
    ## 5                     false    false                  false      false false
    ## 7                     false    false                  false       true  true
    ## 8                     false    false                  false      false  true
    ## 9                     false    false                  false      false  true
    ##    Wine glasses  Coffee maker  Bed linens  Hangers  Wifi  Essentials
    ## 1         false         false        true     true  true        true
    ## 2         false          true        true     true  true        true
    ## 5         false         false        true     true  true        true
    ## 7         false          true        true     true  true        true
    ## 8         false          true       false     true  true        true
    ## 9         false         false       false     true  true        true
    ##    Dining table  Ethernet connection  Lock on bedroom door  Cleaning products
    ## 1         false                false                 false              false
    ## 2         false                false                  true              false
    ## 5         false                false                 false              false
    ## 7         false                false                 false              false
    ## 8         false                false                 false              false
    ## 9         false                false                 false              false
    ##    Cooking basics  Cable TV  Bathtub  Refrigerator  Elevator
    ## 1            true     false    false         false      true
    ## 2            true     false    false          true      true
    ## 5           false     false    false          true      true
    ## 7            true     false    false          true      true
    ## 8           false     false    false         false      true
    ## 9           false     false    false          true     false
    ##    Paid parking on premises  Breakfast  Oven  Carbon monoxide alarm
    ## 1                     false      false false                  false
    ## 2                     false      false  true                  false
    ## 5                     false      false false                  false
    ## 7                     false      false false                  false
    ## 8                      true      false false                  false
    ## 9                     false      false false                  false
    ##    Long term stays allowed  Hair dryer  Kitchen
    ## 1                     true        true     true
    ## 2                     true        true     true
    ## 5                     true        true    false
    ## 7                     true        true     true
    ## 8                     true        true     true
    ## 9                     true        true     true

    # Guardamos los datos en un csv
    write_csv(airbnb_data, file = "datos_limpios.csv")
