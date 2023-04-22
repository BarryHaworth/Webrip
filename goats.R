# Goats Comic
# http://goats.com/
# 
# First Story starts at:
# https://goats.com/comic/2003/11/01/one-true-god/
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
FILE_DIR    <- "c:/R/Webrip/goats"
dir.create(FILE_DIR,showWarnings = FALSE)

# First page of site
url <- 'https://goats.com/comic/2003/11/01/one-true-god/'

rip_url <- function(url){
  webpage <- read_html(url)
  next_xml <- xml_attrs(html_nodes(webpage,'.fa-4x'))
  next_url <- as.character(next_xml[[2]][1])
  
  image_xml <- xml_attrs(html_nodes(webpage,'img'))
  image <- as.character(image_xml[[2]][1])
  # image <- strsplit(image,'[?]')[[1]][1]
  image_name <- strsplit(image,'[/]')
  image_name <- image_name[[1]][length(image_name[[1]])]
  
  results = data.frame(url,next_url,image,image_name,stringsAsFactors = F)
  return(results)
}

if (file.exists(paste0(PROJECT_DIR,"/goats.RData"))){
  load(paste0(PROJECT_DIR,"/goats.RData"))  # Load the data file if it exists
} else {
  goats <- rip_url(url)  # Initialise with  first page
}

# Drop the last record when rerunning
if (nrow(goats)>1) goats <- head(goats,nrow(goats)-1)

# How many pages total?  no idea.  In practice < 1200
for (i in seq(1:1200)){
  url <- tail(goats$next_url,1)
  print(paste("Iteration",i,"Looking up page",url))
  tryCatch({goats <- rbind(goats,rip_url(url))},error=function(e){})
}

goats <- unique(goats)  # remove dupes
save(goats,file=paste0(PROJECT_DIR,"/goats.RData"))

# Download the Images
# Include image number at the start of name.

n <- nrow(goats)
for (i in 1:nrow(n)){
  name <- paste0(formatC(i,3,flag="0"),"_",goats$image_name[i])
  if (file.exists(paste0(FILE_DIR,"/",name))){
    print(paste("File",paste0(FILE_DIR,"/",name),"Already Exists"))
  } else{
    print(paste("downloading file",i,"of",n,name))
    download.file(goats$image[i],
                  paste0(FILE_DIR,"/",name),
                  quiet=TRUE, mode="wb")
  }
}

