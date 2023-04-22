# Freefall Web Comic
# http://freefall.purrsia.com/
# 
# First Story starts at:
# http://freefall.purrsia.com/ff100/fv00001.htm
#
# This webcomic does not have a standardised naming convention.
# To copy, it will be necessary to start at the first page 
# and then crawl through the comics page by page to identify 
# the next page, then the story image.
#
# Copied from the code used for Namesake 
#  (Still needs some work)

library(rvest)
library(dplyr)
library(xml2)
library(stringr)

PROJECT_DIR <- "c:/R/Webrip"
FILE_DIR    <- "c:/R/Webrip/freefall"
dir.create(FILE_DIR, showWarnings = FALSE)  # Create directory if it doesn't exist

# First page of site
url <- 'http://freefall.purrsia.com/ff100/fv00001.htm'

rip_url <- function(url){
  webpage <- read_html(url)
  next_xml <- xml_attrs(html_nodes(webpage,'a'))
  next_url <- as.character(next_xml[[2]][1])
  
  image_xml <- xml_attrs(html_nodes(webpage,'img'))
  image <- as.character(image_xml[[1]][2])
  image_name <- strsplit(image,'[/]')
  image_name <- image_name[[1]][length(image_name[[1]])]
  
  results = data.frame(url,next_url,image,image_name,stringsAsFactors = F)
  return(results)
}

freefall <- rip_url(url)  # Save the first page

# How many pages total?  Erstwhile had 521.  freefall has 3658
for (i in seq(1:2000)){
  url <- tail(freefall$next_url,1)
  print(paste("Iteration",i,"Looking up page",url))
  freefall <- rbind(freefall,rip_url(url))
}

freefall <- unique(freefall)
save(freefall,file=paste0(PROJECT_DIR,"/freefall.RData"))

# Copy the images
#Download the Images
for (i in 1:nrow(freefall)){
  print(paste("downloading file",freefall$image_name[i]))
  download.file(freefall$image[i],
                paste0(FILE_DIR,"/NS",str_pad(i,4,pad="0"),"_",freefall$image_name[i]),
                quiet=TRUE, mode="wb")
}

