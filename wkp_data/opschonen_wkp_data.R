# Opschonen meetpuntbestanden en IM-metingenbestanden
# - De IM-metingbestanden bevatten nogal wat overbodige kolommen. Die worden verwijderd.
# - De meetpunten worden elk jaar opnieuw gerapporteerd. Het samenvoegen van meetpuntbestanden leidt tot dubbelingen.
# - Sommige IM-metingbestanden hebben extra "" in de velden. Die worden verwijderd.
# - Bij de IM-metingbestanden ontbreken de coordinaten van de meetpunten. Die informatie voeg ik toe.
# - Ik schrijf de opgeschoonde bestanden een voor een weg naar de map data/IM-metingen

library(tidyverse)


# Meetpunten opschonen ----------------------------------------------------

# NB ik lees de meetpuntbestanden in als 'character'. 
# Dit om te zorgen dat de types matchen en er geen onverwachte bewerkingen uitgevoerd worden.

files_mp <- list.files("data-raw/meetpunten/", full.names = TRUE)

meetpunten <- 
  tibble(pad = files_mp, bestandsnaam = basename(files_mp)) %>% 
    mutate(jaar = str_extract(bestandsnaam, "\\d{4}")) %>% 
    arrange(jaar) %>% 
    mutate(meetpuntinfo = map(pad, ~read_csv2(.x, col_types = cols(.default = col_character())))) %>% 
    unnest(meetpuntinfo) %>% 
  mutate( 
    Meetobject.namespace = case_when(
      !is.na(Meetobject.namespace) ~ Meetobject.namespace,
      !is.na(Namespace) ~ Namespace,
      !is.na(Waterbeheerder.code) ~ paste0("NL", Waterbeheerder.code),
      !is.na(sub_subident) ~ paste0("NL", sub_subident)),
    Meetobject.lokaalID = coalesce(Identificatie, Meetpunt.identificatie, mpn_mpnident),
    GeometriePunt.X_RD = coalesce(GeometriePunt.X_RD, mpn_mrfxcoor),
    GeometriePunt.Y_RD = coalesce(GeometriePunt.Y_RD, mpn_mrfycoor),
    Meetobject.Omschrijving = coalesce(Omschrijving, Meetpuntomschrijving, Meetpunt.omschrijving, mpn_mpnomsch)) %>% 
  select(Meetobject.namespace,
         Meetobject.lokaalID,
         Meetobject.Omschrijving,
         GeometriePunt.X_RD,
         GeometriePunt.Y_RD,
         bestandsnaam,
         jaar) %>% 
  mutate(across(where(is.character), ~str_remove_all(.x, '"'))) %>% 
  mutate(across(.cols = contains("GeometriePunt"), 
                .fns = ~parse_double(.x, locale = locale(decimal_mark = ".")))) %>% 
  distinct()
    
  # summarise(across(.fns = ~sum(is.na(.x))))

dir.create("data")
meetpunten %>% write_csv2("data/meetpunten_2011-2021.csv", na = "")


# Een aangepaste tabel met de meeste recente set coordinaten en zonder dummy coords.

meetpunten_clean <- 
  meetpunten %>% 
  filter(GeometriePunt.X_RD != 0, GeometriePunt.Y_RD != 0,
         GeometriePunt.X_RD != 123546, GeometriePunt.Y_RD != 456789) %>% 
  arrange(desc(jaar)) %>% 
  group_by(Meetobject.namespace, Meetobject.lokaalID) %>% 
  summarise(GeometriePunt.X_RD = first(GeometriePunt.X_RD),
            GeometriePunt.Y_RD = first(GeometriePunt.Y_RD),
            Meetobject.Omschrijving = first(Meetobject.Omschrijving)) %>% 
  ungroup()

meetpunten_clean %>% write_csv2("data/meetpunten_2011-2021_clean.csv", na = "")

# IM-meting bestanden opschonen -------------------------------------------

files_IM <- list.files("data-raw/IM-metingen/", full.names = TRUE)
dir.create("data/IM-metingen")

opschoon_fun <- function(filename){
  
  im_kolommen <- c(
    "Meetobject.namespace",
    "Meetobject.lokaalID",
    "MonsterCompartiment.code",
    "Begindatum",
    "Begintijd",
    "Typering.code",
    "Grootheid.code",
    "Parameter.groep",
    "Parameter.code",
    "Parameter.omschrijving",
    "Biotaxon.naam",
    "Eenheid.code",
    "Hoedanigheid.code",
    "Levensstadium.code",
    "Lengteklasse.code",
    "Geslacht.code",
    "Verschijningsvorm.code",
    "Levensvorm.code",
    "Gedrag.code",
    "Waardebewerkingsmethode.code",
    "Limietsymbool",
    "Numeriekewaarde",
    "Alfanumeriekewaarde",
    "AnalyseCompartiment.code",
    "Kwaliteitsoordeel.code")
  
  read_csv2(filename, 
            col_types = cols(Numeriekewaarde = col_number(), 
                             Begindatum = col_date(),
                             Begintijd = col_time(),
                             .default = col_character()),
            col_select = any_of(im_kolommen)) %>% 
    
    mutate(across(where(is.character), ~str_remove_all(.x, '"'))) %>% 
    left_join(meetpunten_clean, by = c("Meetobject.namespace", "Meetobject.lokaalID")) %>% 
    
    write_csv2(file.path("data/IM-metingen", basename(filename)),
               na = "")
}


walk(files_IM, opschoon_fun)





