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

library(rvest)
library(dplyr)
library(xml2)
library(stringr)

PROJECT_DIR <- "c:/R/Webrip"
FILE_DIR    <- "c:/R/Webrip/yafgc"

# First page of site
url <- 'https://www.yafgc.net/comic/bob-meets-gren/'

rip_url <- function(url){
  webpage <- read_html(url)
  next_xml <- xml_attrs(html_nodes(webpage,'.navi-next'))
  next_url <- as.character(next_xml[[1]][1])
  
  image_xml <- xml_attrs(html_nodes(webpage,'img'))
  image <- as.character(image_xml[[3]][1])
  image <- strsplit(image,'[?]')[[1]][1]
  image_name <- strsplit(image,'[/]')
  image_name <- image_name[[1]][length(image_name[[1]])]
  
  results = data.frame(url,next_url,image,image_name,stringsAsFactors = F)
  return(results)
}

yafgc <- rip_url(url)  # Save the first page

# How many pages total?  3475 as at 07/10/2021
for (i in seq(1:4000)){
  url <- tail(yafgc$next_url,1)
  print(paste("Iteration",i,"Looking up page",url))
  yafgc <- rbind(yafgc,rip_url(url))
}

yafgc <- unique(yafgc)  # remove dupes
save(yafgc,file=paste0(PROJECT_DIR,"/yafgc.RData"))

# Download the Images
# Image name includes date, do not need to pad at start

for (i in 1:nrow(yafgc)){
  print(paste("downloading file",yafgc$image_name[i]))
  download.file(yafgc$image[i],
                paste0(FILE_DIR,"/",yafgc$image_name[i]),
                quiet=TRUE, mode="wb")
}

