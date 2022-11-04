library(tidyverse)
library(twn)

#theme_set(HHSKwkl::hhskthema_kaart())

download.file("https://geodata.nationaalgeoregister.nl/hwh/eenheden/atom/v1_0/downloads/AdministrativeUnits.zip", "data/ws_grenzen.zip")
unzip("data/ws_grenzen.zip", exdir = "data")

ws_grenzen <- sf::st_read("data/AdministrativeUnits_ETRS89.gml") %>% 
  sf::st_transform(crs = 28992)

read_wkp <- function(filename, lazy = FALSE){
  read_csv2(filename, 
            col_types = cols(Begindatum = col_date(),
                                       Begintijd = col_time(),
                                       Numeriekewaarde = col_double(),
                                       GeometriePunt.X_RD = col_double(),
                                       GeometriePunt.Y_RD = col_double(),
                                       .default = col_character()),
            lazy = lazy)
}

kreeften_taxa <- twn_children("Astacidea", only_preferred = FALSE)

wkp_bestanden <- list.files("data/IM-metingen/", full.names = TRUE)

# 2 minuten
tictoc::tic("Kreeften not lazy")
kreeften <- 
  map(wkp_bestanden, ~read_wkp(.x) %>% filter(Biotaxon.naam %in% kreeften_taxa)) %>% 
  reduce(bind_rows)

tictoc::toc()

# 45 seconden maar erg geheugenintensief
# tictoc::tic("Kreeften lazy")
# kreeften <- 
#   map(wkp_bestanden, ~read_wkp(.x, lazy = TRUE) %>% filter(Biotaxon.naam %in% kreeften_taxa)) %>% 
#   reduce(bind_rows)
# 
# tictoc::toc()

# 13 seconden maar erg geheugenintensief
# tictoc::tic("Kreeften vroom")
# kreeften <- 
#   vroom::vroom(wkp_bestanden, 
#                col_types = cols(Begindatum = col_date(),
#                                 Begintijd = col_time(),
#                                 Numeriekewaarde = col_double(),
#                                 GeometriePunt.X_RD = col_double(),
#                                 GeometriePunt.Y_RD = col_double(),
#                                 .default = col_character()),
#                locale = locale(decimal_mark = ",")) %>% 
#   filter(Biotaxon.naam %in% kreeften_taxa) %>% 
#   tibble()
# 
# tictoc::toc()

kreeften %>% 
  filter(!is.na(GeometriePunt.X_RD)) %>% 
  mutate(jaar = lubridate::year(Begindatum)) %>% 
  sf::st_as_sf(coords = c("GeometriePunt.X_RD", "GeometriePunt.Y_RD"), crs = 28992, remove = FALSE) %>% 
  ggplot() +
  geom_sf(data = ws_grenzen, colour = "grey") +
  geom_sf(alpha = 0.5) +
  facet_wrap(~jaar)


