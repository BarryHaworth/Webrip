# Yet Another Fantasy Gamer Comic
# https://www.yafgc.net/
# 
# First Story starts at:
# https://www.yafgc.net/comic/bob-meets-gren/
#
# This webcomic does not have a standardised naming convention.
# To copy, it will be necessary to start at the first page 
# and then crawl through the comics page by page to identify 
# the next page, then the story image.
# 
# Update:  Added code to create directories if they do not exist
# and to catch errors when ripping and downloading and continue.

library(rvest)
library(dplyr)
library(xml2)
library(stringr)

PROJECT_DIR <- "c:/R/Webrip"
FILE_DIR    <- "c:/R/Webrip/yafgc"
dir.create(FILE_DIR,showWarnings = FALSE)

# First page of site
url <- 'https://www.yafgc.net/comic/bob-meets-gren/'

rip_url <- function(url){
  webpage <- read_html(url)
  next_xml <- xml_attrs(html_nodes(webpage,'.navi-next'))
  next_url <- as.character(next_xml[[1]][1])
  
  image_xml <- xml_attrs(html_nodes(webpage,'img'))
  image <- as.character(image_xml[[5]][1])
  image <- strsplit(image,'[?]')[[1]][1]
  image_name <- strsplit(image,'[/]')
  image_name <- image_name[[1]][length(image_name[[1]])]
  
  results = data.frame(url,next_url,image,image_name,stringsAsFactors = F)
  return(results)
}

if (file.exists(paste0(PROJECT_DIR,"/yafgc.RData"))){
  load(paste0(PROJECT_DIR,"/yafgc.RData"))  # Load the data file if it exists
} else {
  yafgc <- rip_url(url)  # Initialise with  first page
}

# How many pages total?  3519 as at 18/06/2022
for (i in seq(1:4000)){
  url <- tail(yafgc$next_url,1)
  print(paste("Iteration",i,"Looking up page",url))
  tryCatch({yafgc <- rbind(yafgc,rip_url(url))},error=function(e){})
}

yafgc <- unique(yafgc)  # remove dupes
save(yafgc,file=paste0(PROJECT_DIR,"/yafgc.RData"))

# Download the Images
# Image name includes date, do not need to pad at start

for (i in 1:nrow(yafgc)){
  if (file.exists(paste0(FILE_DIR,"/",yafgc$image_name[i]))){
    print(paste("File",paste0(FILE_DIR,"/",yafgc$image_name[i]),"Already Exists"))
  } else{
    print(paste("downloading file",yafgc$image_name[i]))
    download.file(yafgc$image[i],
                  paste0(FILE_DIR,"/",yafgc$image_name[i]),
                  quiet=TRUE, mode="wb")
  }
}

