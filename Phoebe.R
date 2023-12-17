# Phoebe and her Unicorn
# http://freefall.purrsia.com/
# 
# First Story starts at:
# https://www.gocomics.com/phoebe-and-her-unicorn/2012/01/15
#
# This webcomic does not have a standardised naming convention.
# To copy, it will be necessary to start at the first page 
# and then crawl through the comics page by page to identify 
# the next page, then the story image.
#
# Problem that gocomics hides the image link.  Needs work

library(rvest)
library(dplyr)
library(xml2)
library(stringr)

PROJECT_DIR <- "c:/R/Webrip"
FILE_DIR    <- "c:/R/Webrip/phoebe"
dir.create(FILE_DIR, showWarnings = FALSE)  # Create directory if it doesn't exist

# First page of site
url <- 'https://www.gocomics.com/phoebe-and-her-unicorn/2012/01/15'
# image page for first comic.
url <- 'https://assets.amuniversal.com/2aec3430417901300e91001dd8b71c47'

rip_url <- function(url){
  webpage <- read_html(url)
  next_xml <- xml_attrs(html_nodes(webpage,'.sm'))
  next_url <- as.character(next_xml[[5]][2])
  next_url <- paste0('https://www.gocomics.com',next_url)
  
  image_xml <- xml_attrs(html_nodes(webpage,'img'))
  image <- as.character(image_xml[[1]][1])
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

