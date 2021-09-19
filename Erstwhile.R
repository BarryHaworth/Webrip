# Erstwhile Tales
# https://erstwhiletales.com
# 
# First Story starts at:
# https://erstwhiletales.com/comic/maid-maleen-pg01/
#
# This webcomic does not have a standardised naming convention.
# To copy, it will be necessary to start at the first page 
# and then crawl through the comics page by page to identify 
# the next page, then the story image.
# 

library(rvest)
library(dplyr)
library(xml2)

PROJECT_DIR <- "c:/R/Webrip"
FILE_DIR    <- "c:/R/Webrip/erstwhile"

# First page of site
url <- 'https://erstwhiletales.com/comic/maid-maleen-pg01/'

rip_url <- function(url){
  webpage <- read_html(url)
  next_xml <- xml_attrs(html_nodes(webpage,'.comic-nav-next'))
  next_url <- as.character(next_xml[[1]][1])
  
  image_xml <- xml_attrs(html_nodes(webpage,'img'))
  image <- as.character(image_xml[[3]][1])
  image <- strsplit(image,'[?]')[[1]][1]
  image_name <- strsplit(image,'[/]')
  image_name <- image_name[[1]][length(image_name[[1]])]
  
  results = data.frame(url,next_url,image,image_name,stringsAsFactors = F)
  return(results)
}

erstwhile <- rip_url(url)  # Save the first page

# How many pages total?  521
for (i in seq(1:520)){
  url <- tail(erstwhile$next_url,1)
  print(paste("Iteration",i,"Looking up page",url))
  erstwhile <- rbind(erstwhile,rip_url(url))
}

save(erstwhile,file=paste0(PROJECT_DIR,"/erstwhile.RData"))

# Copy the images
#Download the Images
for (i in 1:nrow(erstwhile)){
  print(paste("downloading file",erstwhile$image_name[i]))
  download.file(erstwhile$url[i],
                paste0(FILE_DIR,"/",erstwhile$image_name[i]),
                quiet=TRUE, mode="wb")
}

