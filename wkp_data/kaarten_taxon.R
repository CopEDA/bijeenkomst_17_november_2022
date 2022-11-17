library(tidyverse)
library(twn)
# library(HHSKwkl)
library(tictoc)
library(sf)
library(leaflet)

# theme_set(hhskthema_kaart())
ws_grenzen <- sf::st_read("data/AdministrativeUnits_ETRS89.gml", quiet = TRUE) %>% sf::st_transform(crs = 28992)
ws_grenzen_wgs <- sf::st_read("data/AdministrativeUnits_ETRS89.gml", quiet = TRUE) %>% sf::st_transform(crs = 4326)

wkp_bestanden <- list.files("data/IM-metingen/", full.names = TRUE)





tic()
data <-
  vroom::vroom(wkp_bestanden,
               col_types = cols(Begindatum = col_date(),
                                Begintijd = col_time(),
                                Numeriekewaarde = col_double(),
                                GeometriePunt.X_RD = col_double(),
                                GeometriePunt.Y_RD = col_double(),
                                .default = col_character()),
               locale = locale(decimal_mark = ",")) 
  
toc()

taxon <- "" 
data_sel <- data %>% filter(Biotaxon.naam %in% taxon)

# data_sel %>% 
#   filter(!is.na(GeometriePunt.X_RD)) %>% 
#   mutate(jaar = lubridate::year(Begindatum)) %>% 
#   sf::st_as_sf(coords = c("GeometriePunt.X_RD", "GeometriePunt.Y_RD"), crs = 28992, remove = FALSE) %>% 
#   ggplot() +
#   geom_sf(data = ws_grenzen, colour = "grey") +
#   geom_sf(alpha = 0.5) +
#   facet_wrap(~jaar) +
#   labs(title = taxon,
#        caption = "Bron: https://www.waterkwaliteitsportaal.nl/")



data_sel %>% 
  mutate(jaar = lubridate::year(Begindatum)) %>% 
  select(Meetobject.namespace, Meetobject.lokaalID, GeometriePunt.X_RD, GeometriePunt.Y_RD, jaar) %>% 
  distinct() %>% 
  filter(!is.na(GeometriePunt.X_RD)) %>% 
  sf::st_as_sf(coords = c("GeometriePunt.X_RD", "GeometriePunt.Y_RD"), crs = 28992, remove = FALSE) %>% 
  st_transform(crs = 4326) %>% 
  basiskaart(type = "cartolight") %>% 
  addPolylines(data = ws_grenzen_wgs, color = "grey", weight = 2) %>% 
  addCircleMarkers(radius = 6, fillOpacity = 1,  stroke = FALSE, label = ~Meetobject.lokaalID) 
  