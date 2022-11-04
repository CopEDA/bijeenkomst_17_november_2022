# https://www.waterkwaliteitsportaal.nl/oppervlaktewaterkwaliteit


# Download ----------------------------------------------------------------

# Databestanden met biologie van 2011 tot 2021

urls <- 
  c(
"https://waterkwaliteitsportaal.overheidsbestanden.nl/Oppervlaktewaterkwaliteit/MeetgegevensPerJaar/IM_Metingen_2021.zip",
"https://waterkwaliteitsportaal.overheidsbestanden.nl/Oppervlaktewaterkwaliteit/MeetgegevensPerJaar/IM_Metingen_2020.zip",
"https://waterkwaliteitsportaal.overheidsbestanden.nl/Oppervlaktewaterkwaliteit/MeetgegevensPerJaar/IM_Metingen_2019.zip",
"https://waterkwaliteitsportaal.overheidsbestanden.nl/Oppervlaktewaterkwaliteit/MeetgegevensPerJaar/IM_Metingen_2018.zip",
"https://waterkwaliteitsportaal.overheidsbestanden.nl/Oppervlaktewaterkwaliteit/MeetgegevensPerJaar/IM_Metingen_2017.zip",
"https://waterkwaliteitsportaal.overheidsbestanden.nl/Oppervlaktewaterkwaliteit/MeetgegevensPerJaar/IM_Metingen_2016.zip",
"https://waterkwaliteitsportaal.overheidsbestanden.nl/Oppervlaktewaterkwaliteit/Limno/Meetgegevens/IM_Metingen_Biologie_2016-maand01_totenmet_04.zip",
"https://waterkwaliteitsportaal.overheidsbestanden.nl/Oppervlaktewaterkwaliteit/Limno/Meetgegevens/IM_Metingen_Biologie_2016-maand05_totenmet_07.zip",
"https://waterkwaliteitsportaal.overheidsbestanden.nl/Oppervlaktewaterkwaliteit/Limno/Meetgegevens/IM_Metingen_Biologie_2016-maand_08totenmet_12.zip",
"https://waterkwaliteitsportaal.overheidsbestanden.nl/Oppervlaktewaterkwaliteit/Limno/Meetgegevens/IM_Metingen_Biologie_2015.zip",
"https://waterkwaliteitsportaal.overheidsbestanden.nl/Oppervlaktewaterkwaliteit/Limno/Meetgegevens/IM_Metingen_Biologie_2014.zip",
"https://waterkwaliteitsportaal.overheidsbestanden.nl/Oppervlaktewaterkwaliteit/Limno/Meetgegevens/IM_Metingen_Biologie_2013.zip",
"https://waterkwaliteitsportaal.overheidsbestanden.nl/Oppervlaktewaterkwaliteit/Limno/Meetgegevens/IM_Metingen_Biologie_2012.zip",
"https://waterkwaliteitsportaal.overheidsbestanden.nl/Oppervlaktewaterkwaliteit/Limno/Meetgegevens/IM_Metingen_Biologie_2011.zip")

#url_limnodata <- "https://waterkwaliteitsportaal.overheidsbestanden.nl/Oppervlaktewaterkwaliteit/Limno/Meetgegevens/Limnodata-export.zip"
#url_piscaria <- "https://waterkwaliteitsportaal.overheidsbestanden.nl/Oppervlaktewaterkwaliteit/Limno/Meetgegevens/Piscaria-export.zip"


urls_meetpunten <- 
  c(
    "https://waterkwaliteitsportaal.overheidsbestanden.nl/Oppervlaktewaterkwaliteit/Basisgegevens/Meetlocaties_2021.zip",
    "https://waterkwaliteitsportaal.overheidsbestanden.nl/Oppervlaktewaterkwaliteit/Basisgegevens/Meetlocaties_2020.zip",
    "https://waterkwaliteitsportaal.overheidsbestanden.nl/Oppervlaktewaterkwaliteit/Basisgegevens/Meetlocaties_2019.zip",
    "https://waterkwaliteitsportaal.overheidsbestanden.nl/Oppervlaktewaterkwaliteit/Basisgegevens/Meetlocaties_2018.zip",
    "https://waterkwaliteitsportaal.overheidsbestanden.nl/Oppervlaktewaterkwaliteit/Basisgegevens/Meetlocaties_2017.zip",
    "https://waterkwaliteitsportaal.overheidsbestanden.nl/Oppervlaktewaterkwaliteit/Basisgegevens/Meetlocaties_2016.zip",
    "https://waterkwaliteitsportaal.overheidsbestanden.nl/Oppervlaktewaterkwaliteit/Basisgegevens/Meetlocaties_2015.zip",
    "https://waterkwaliteitsportaal.overheidsbestanden.nl/Oppervlaktewaterkwaliteit/Basisgegevens/Meetlocaties_2014.zip",
    "https://waterkwaliteitsportaal.overheidsbestanden.nl/Oppervlaktewaterkwaliteit/Basisgegevens/Meetlocaties_2013.zip",
    "https://waterkwaliteitsportaal.overheidsbestanden.nl/Oppervlaktewaterkwaliteit/Basisgegevens/Meetlocaties_2012.zip",
    "https://waterkwaliteitsportaal.overheidsbestanden.nl/Oppervlaktewaterkwaliteit/Basisgegevens/Meetlocaties_2011.zip",
    "https://waterkwaliteitsportaal.overheidsbestanden.nl/Oppervlaktewaterkwaliteit/Limno/Basisgegevens/Meetlocaties_Biologie_2015.zip",
    "https://waterkwaliteitsportaal.overheidsbestanden.nl/Oppervlaktewaterkwaliteit/Limno/Basisgegevens/Meetlocaties_Biologie_2014.zip",
    "https://waterkwaliteitsportaal.overheidsbestanden.nl/Oppervlaktewaterkwaliteit/Limno/Basisgegevens/Meetlocaties_Biologie_2013.zip",
    "https://waterkwaliteitsportaal.overheidsbestanden.nl/Oppervlaktewaterkwaliteit/Limno/Basisgegevens/Meetlocaties_Biologie_2012.zip",
    "https://waterkwaliteitsportaal.overheidsbestanden.nl/Oppervlaktewaterkwaliteit/Limno/Basisgegevens/Meetlocaties_Biologie_2011.zip"
  )

dir.create("data-raw")
purrr::walk2(urls, paste0("data-raw/", basename(urls)), download.file)
purrr::walk2(urls_meetpunten, paste0("data-raw/", basename(urls_meetpunten)), download.file)
# download.file(url_limnodata, paste0("data-raw/", basename(url_limnodata)))
# download.file(url_piscaria, paste0("data-raw/", basename(url_piscaria)))

# Extract -----------------------------------------------------------------





files <- list.files("data-raw", pattern = "^IM_Metingen", full.names = TRUE)
# dir.create("data-raw/IM-metingen")
purrr::walk(files, .f = ~unzip(.x, exdir = "data-raw/IM-metingen"))


files_meetpunten <- list.files("data-raw", pattern = "^Meetlocaties", full.names = TRUE)
purrr::walk(files_meetpunten, .f = ~unzip(.x, exdir = "data-raw/meetpunten"))

