# Namesake
# https://www.namesakecomic.com/
# 
# First Story starts at:
# https://www.namesakecomic.com/comic/the-journey-begins
#
# This webcomic does not have a standardised naming convention.
# To copy, it will be necessary to start at the first page 
# and then crawl through the comics page by page to identify 
# the next page, then the story image.
#
# Copied from the code used for Erstwhile 

library(rvest)
library(dplyr)
library(xml2)
library(stringr)

PROJECT_DIR <- "c:/R/Webrip"
FILE_DIR    <- "c:/R/Webrip/namesake"
dir.create(FILE_DIR, showWarnings = FALSE)  # Create directory if it doesn't exist

# First page of site
url <- 'https://www.namesakecomic.com/comic/the-journey-begins'

rip_url <- function(url){
  webpage <- read_html(url)
  next_xml <- xml_attrs(html_nodes(webpage,'.cc-next'))
  next_url <- as.character(next_xml[[1]][3])
  
  image_xml <- xml_attrs(html_nodes(webpage,'#cc-comic'))
  image <- as.character(image_xml[[1]][2])
  image_name <- strsplit(image,'[/]')
  image_name <- image_name[[1]][length(image_name[[1]])]
  
  results = data.frame(url,next_url,image,image_name,stringsAsFactors = F)
  return(results)
}

namesake <- rip_url(url)  # Save the first page

# How many pages total?  Erstwhile had 521.  Namesake has 1736
for (i in seq(1:1000)){
  url <- tail(namesake$next_url,1)
  print(paste("Iteration",i,"Looking up page",url))
  namesake <- rbind(namesake,rip_url(url))
}

namesake <- unique(namesake)
save(namesake,file=paste0(PROJECT_DIR,"/namesake.RData"))

# Copy the images
#Download the Images
for (i in 1:nrow(namesake)){
  print(paste("downloading file",namesake$image_name[i]))
  download.file(namesake$image[i],
                paste0(FILE_DIR,"/NS",str_pad(i,4,pad="0"),"_",namesake$image_name[i]),
                quiet=TRUE, mode="wb")
}

