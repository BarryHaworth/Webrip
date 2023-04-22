# Skin Horse Comic
# https://skin-horse.com/
# 
# First Story starts at:
# https://skin-horse.com/comic/tip-wore-white/
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
FILE_DIR    <- "c:/R/Webrip/skinhorse"
dir.create(FILE_DIR,showWarnings = FALSE)

# First page of site
url <- 'https://skin-horse.com/comic/tip-wore-white/'

rip_url <- function(url){
  webpage <- read_html(url)
  next_xml <- xml_attrs(html_nodes(webpage,'.comic-nav-next'))
  next_url <- as.character(next_xml[[1]][1])
  
  image_xml <- xml_attrs(html_nodes(webpage,'img'))
  image <- as.character(image_xml[[2]][1])
  # image <- strsplit(image,'[?]')[[1]][1]
  image_name <- strsplit(image,'[/]')
  image_name <- image_name[[1]][length(image_name[[1]])]
  
  results = data.frame(url,next_url,image,image_name,stringsAsFactors = F)
  return(results)
}

if (file.exists(paste0(PROJECT_DIR,"/skinhorse.RData"))){
  load(paste0(PROJECT_DIR,"/skinhorse.RData"))  # Load the data file if it exists
} else {
  skinhorse <- rip_url(url)  # Initialise with  first page
}

# Drop the last record when rerunning
if (nrow(skinhorse)>1) skinhorse <- head(skinhorse,nrow(skinhorse)-1)

# How many pages total?  5253 in total
for (i in seq(1:5260)){
  url <- tail(skinhorse$next_url,1)
  print(paste("Iteration",i,"Looking up page",url))
  tryCatch({skinhorse <- rbind(skinhorse,rip_url(url))},error=function(e){})
}

skinhorse <- unique(skinhorse)  # remove dupes
save(skinhorse,file=paste0(PROJECT_DIR,"/skinhorse.RData"))

# Download the Images
# Include image number at the start of name.

n <- nrow(skinhorse)
for (i in 1:n){
  name <- paste0(formatC(i,3,flag="0"),"_",skinhorse$image_name[i])
  if (file.exists(paste0(FILE_DIR,"/",name))){
    print(paste("File",paste0(FILE_DIR,"/",name),"Already Exists"))
  } else{
    print(paste("downloading file",i,"of",n,name))
    download.file(skinhorse$image[i],
                  paste0(FILE_DIR,"/",name),
                  quiet=TRUE, mode="wb")
  }
}

