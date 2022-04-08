# Mare Internum
# https://www.marecomic.com/comic/intro-page-1/
# 
# First Story starts at:
# https://www.marecomic.com/comic/intro-page-1/
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
FILE_DIR    <- "c:/R/Webrip/internum"
dir.create(FILE_DIR, showWarnings = FALSE)  # Create directory if it doesn't exist

# First page of site
url <- 'https://www.marecomic.com/comic/intro-page-1/'

# Note:  Need to find the right list elements to save for the next_url and the image
rip_url <- function(url){
  webpage <- read_html(url)
  next_xml <- xml_attrs(html_nodes(webpage,'.comic-nav-next'))
  next_url <- as.character(next_xml[[1]][1])
  
  image_xml <- xml_attrs(html_nodes(webpage,'img'))
  image <- as.character(image_xml[[2]][1])
  image_name <- strsplit(image,'[/]')
  image_name <- image_name[[1]][length(image_name[[1]])]
  
  results = data.frame(url,next_url,image,image_name,stringsAsFactors = F)
  return(results)
}

internum <- rip_url(url)  # Save the first page

# How many pages total?  Erstwhile had 521.  internum has 1736.  This looks like 278
for (i in seq(1:285)){
  url <- tail(internum$next_url,1)
  print(paste("Iteration",i,"Looking up page",url))
  internum <- rbind(internum,rip_url(url))
}

internum <- unique(internum)
save(internum,file=paste0(PROJECT_DIR,"/internum.RData"))

# Copy the images
#Download the Images
for (i in 1:nrow(internum)){
  print(paste("downloading file",internum$image_name[i]))
  download.file(internum$image[i],
                paste0(FILE_DIR,"/MI",str_pad(i,3,pad="0"),"_",internum$image_name[i]),
                quiet=TRUE, mode="wb")
}

