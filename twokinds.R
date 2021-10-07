# Two kinds:  
# https://twokinds.keenspot.com/comic/1/
# 
# First Story starts at:
# https://twokinds.keenspot.com/comic/1/
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
FILE_DIR    <- "c:/R/Webrip/twokinds"
dir.create(FILE_DIR)

# First page of site
url <- 'https://twokinds.keenspot.com/comic/1/'

rip_url <- function(url){
  webpage <- read_html(url)
  next_xml <- xml_attrs(html_nodes(webpage,'.navnext'))
  next_url <- paste0('https://twokinds.keenspot.com',as.character(next_xml[[1]][1]))
  
  image_xml <- xml_attrs(html_nodes(webpage,'img'))
  image <- as.character(image_xml[[5]][1])
  image <- strsplit(image,'[?]')[[1]][1]
  image_name <- strsplit(image,'[/]')
  image_name <- image_name[[1]][length(image_name[[1]])]
  
  results = data.frame(url,next_url,image,image_name,stringsAsFactors = F)
  return(results)
}

twokinds <- rip_url(url)  # Save the first page

# How many pages total?  1157 as at 07/10/2021
for (i in seq(1:1200)){
  url <- tail(twokinds$next_url,1)
  print(paste("Iteration",i,"Looking up page",url))
  twokinds <- rbind(twokinds,rip_url(url))
}

twokinds <- unique(twokinds)  # remove dupes
save(twokinds,file=paste0(PROJECT_DIR,"/twokinds.RData"))

# Download the Images
# Image name includes date, do not need to pad at start

for (i in 1:nrow(twokinds)){
  if (file.exists(paste0(FILE_DIR,"/",twokinds$image_name[i]))){
    print(paste("File",paste0(FILE_DIR,"/",twokinds$image_name[i]),"Already Exists"))
  } else{
    print(paste("downloading file",twokinds$image_name[i]))
    download.file(twokinds$image[i],
                  paste0(FILE_DIR,"/",twokinds$image_name[i]),
                  quiet=TRUE, mode="wb")
  }
  
}

