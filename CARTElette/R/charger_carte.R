#' @title Charger la couche cartographique adaptée à vos données
#' @name charger_carte
#' @description Charger la couche cartographique adaptée à vos données en indiquant l'année du code officiel géographique (COG) ainsi que le niveau géographique (communal ou supra-communal) souhaités
#' @param destfile indique le "path" où sera enregistrée la couche cartographique téléchargée (4 fichiers shp,shx,prj et dbf). Par défaut vaut tempfile() (répertoire temporaire)
#' @param COG indique l'année de COG de la table communale considérée. (exemple 2017). Années possibles : de 2015 à 2019. Par défaut, vaut annee_ref.
#' @param nivsupra est une chaîne de caractères qui indique le nom du niveau supra-communale souhaité. Plus précisément :
#' - "DEP" : départements
#' - "REG" : régions
#' - "EPCI" : EPCI au 01/01/20XX
#' - "ARR" : arrondissements au 01/01/20XX
#' - "CV" : cantons-villes au 01/01/20XX
#' - "ZE2010" : zones d'emploi 2010
#' - "UU2010" : unités urbaines 2010
#' - "AU2010" : aires urbaines 2010
#' - "BV2012" : bassins de vie 2012
#' @param enlever_PLM vaut TRUE si on souhaite enlever de la carte les arrondissements municipaux de Paris, Lyon et Marseille si nivsupra="COM (fonctionne pour les millésimes postérieurs à 2019 en raison de modification des fichiers IGN). Par défaut, vaut annee_ref.
#' @param donnees_insee vaut TRUE si les données manipulées sont produites par l'Insee. En effet, quelques rares modifications communales (la défusion des communes Loisey et Culey au 1er janvier 2014 par exemple) ont été prises en compte dans les bases de données communales de l'Insee plus tard que la date officielle.
#' @details
#' La fonction renvoie une couche cartographique de type "sf"
#'
#' Le code officiel géographique le plus récent du package est actuellement celui au 01/01/2019. \cr
#'
#' Les millésimes des COG qui peuvent être utilisés sont à ce stade les suivants : 2015, 2016, 2017, 2018 et 2019. \cr
#' @references
#' \itemize{
#' \item{\href{http://professionnels.ign.fr/adminexpress}{couches cartographiques Admin-Express (IGN)}}
#' \item{\href{http://professionnels.ign.fr/geofla}{couches cartographiques GEOFLA (IGN)}}}
#' @export
#' @examples
#' ## Exemple 1
#' \dontrun{
#' ## Traitement long a tourner (telecharge les fichiers dans tempdir())
#'  reg_sf <- charger_carte(COG=2016,nivsupra="REG")
#'  par(mar=c(0,0,0,0))
#'  plot(sf::st_geometry(reg_sf))
#' }
#'
#' #' ## Exemple 2
#' \dontrun{
#' ## Traitement long a tourner (telecharge les fichiers dans tempdir())
#'  com_sf_sansPLM <- charger_carte(COG=2019,nivsupra="COM",enlever_PLM=TRUE)
#'  com_sf_avecPLM <- charger_carte(COG=2019,nivsupra="COM",enlever_PLM=FALSE)
#'  par(mar=c(0,0,0,0))
#'  library(sf)
#'  library(dplyr)
#'  plot(st_geometry(com_sf_sansPLM %>% filter(substr(INSEE_COM,1,2)%in%c("75")) ))
#'  plot(st_geometry(com_sf_avecPLM %>% filter(substr(INSEE_COM,1,2)%in%c("75")) ))
#' }
#'
#' @encoding UTF-8
#' @importFrom dplyr %>% filter
#' @importFrom utils download.file
#'


charger_carte <- function(destfile=tempdir(),COG=annee_ref,nivsupra,enlever_PLM=TRUE,donnees_insee=F){
  shpOrigin="IGN"
  string_insee <- ifelse(donnees_insee & COG==2015 & nivsupra=="COM","_insee","")
  url <- paste0("https://raw.githubusercontent.com/antuki/CARTElette/master/couches_carto/",shpOrigin,"/COG",COG,"/")
  download.file(paste0(url,nivsupra,"_",COG,string_insee,"_CARTElette.dbf"),destfile = paste0(destfile,"/",nivsupra,"_",COG,"_CARTElette.dbf"),method="auto",mode="wb")
  download.file(paste0(url,nivsupra,"_",COG,string_insee,"_CARTElette.prj"),destfile = paste0(destfile,"/",nivsupra,"_",COG,"_CARTElette.prj"),method="auto",mode="wb")
  download.file(paste0(url,nivsupra,"_",COG,string_insee,"_CARTElette.shp"),destfile = paste0(destfile,"/",nivsupra,"_",COG,"_CARTElette.shp"),method="auto",mode="wb")
  download.file(paste0(url,nivsupra,"_",COG,string_insee,"_CARTElette.shx"),destfile = paste0(destfile,"/",nivsupra,"_",COG,"_CARTElette.shx"),method="auto",mode="wb")
  
  
  couche <- sf::st_read(dsn=paste0(destfile,"/",nivsupra,"_",COG,"_CARTElette.shp"),stringsAsFactors = F)
  
  
  if(nivsupra=="COM" & enlever_PLM & COG>=2019){
      if(COG>=2019){
        couche <- couche %>%
          filter(substr(INSEE_COM,1,3)!="751" & substr(INSEE_COM,1,4)!="6938" & substr(INSEE_COM,1,3)!="132")
      }
    }

    return(couche)

  }

