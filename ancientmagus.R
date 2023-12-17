# Ancient Magus Bride

# https://magusbridemanga.com/manga/the-ancient-magus-bride-chapter-1/
# 
# First Story starts at:
# https://magusbridemanga.com/manga/the-ancient-magus-bride-chapter-1/
#
# This code starts at the first page of a manga
# and then crawls through it page by page to identify 
# the next page, then the manga images.

library(rvest)
library(dplyr)
library(xml2)
library(stringr)

PROJECT_DIR <- "c:/R/Webrip"
FILE_DIR    <- "c:/R/Webrip/ancientmagus"
dir.create(FILE_DIR, showWarnings = FALSE)  # Create directory if it doesn't exist

# First page of Manga
url <- 'https://magusbridemanga.com/manga/the-ancient-magus-bride-chapter-1/'
# url <- 'https://magusbridemanga.com/manga/the-ancient-magus-bride-chapter-25-5/'

rip_url <- function(url){
  chapter <- substr(url,67,nchar(url)-1)
  webpage <- read_html(url)
  next_xml <- xml_attrs(html_nodes(webpage,'a'))  
  next_url <- next_xml[[length(next_xml)-5]][2]
  image_xml <- xml_attrs(html_nodes(webpage,'.aligncenter'))
  images <- data.frame()
  for (i in seq(1,length(image_xml))){
      image <- as.character(image_xml[[i]][2])
      images <- rbind(images,data.frame(url,next_url,chapter,i,image,stringsAsFactors = F))
  }
  
  results = images
  return(results)
}

if (file.exists(paste0(PROJECT_DIR,"/ancientmagus.RData"))){
  load(paste0(PROJECT_DIR,"/ancientmagus.RData"))
} else {
  ancientmagus <- rip_url(url)  # Save the first page
}

# How many pages total?  91 chapters plus extras
for (i in seq(1:120)){
  tryCatch({
    url <- tail(ancientmagus$next_url,1)
    if (nchar(url)>0){
      print(paste("Iteration",i,"Looking up page",url))
      ancientmagus <- rbind(ancientmagus,rip_url(url))
    }
  })
}

ancientmagus <- unique(ancientmagus)
save(ancientmagus,file=paste0(PROJECT_DIR,"/ancientmagus.RData"))

# Copy the images
#Download the Images
for (i in 1:nrow(ancientmagus)){
  if (file.exists(paste0(FILE_DIR,"/chapter-",ancientmagus$chapter[i],"-",str_pad(ancientmagus$i[i],3,pad="0"),".jpg"))){
    print(paste("File",ancientmagus$chapter[i],"image #",ancientmagus$i[i],"already downloaded"))
  } else{
    print(paste("downloading Chapter",ancientmagus$chapter[i],"image #",ancientmagus$i[i]))
    download.file(ancientmagus$image[i],
                  paste0(FILE_DIR,"/chapter-",ancientmagus$chapter[i],"-",str_pad(ancientmagus$i[i],3,pad="0"),".jpg"),
                  quiet=TRUE, mode="wb")
  }
}

