# Spy x Family
# https://kissmanga.in/kissmanga/24356767/chapter-1/
# 
# First Story starts at:
# https://kissmanga.in/kissmanga/24356767/chapter-1/
#
# This code starts at the first page of a manga
# and then crawl through it page by page to identify 
# the next page, then the manga images.
#
# It would be possible to generalise this for any manga on kissmanga.

library(rvest)
library(dplyr)
library(xml2)
library(stringr)

PROJECT_DIR <- "c:/R/Webrip"
FILE_DIR    <- "c:/R/Webrip/spyxfamily"
dir.create(FILE_DIR, showWarnings = FALSE)  # Create directory if it doesn't exist

# First page of Manga
url <- 'https://kissmanga.in/kissmanga/24356767/chapter-1/'
#url <- 'https://kissmanga.in/kissmanga/24356767/chapter-91/'

rip_url <- function(url){
  chapter <- str_split_1(url,'/')[6]
  webpage <- read_html(url)
  next_xml <- xml_attrs(html_nodes(webpage,'.next_page'))
  if (length(next_xml)==2)  next_url <- as.character(next_xml[[1]][1]) else next_url <- ""
  images <- data.frame()
  for (i in seq(0,100)){
    try({
      image_xml <- xml_attrs(html_nodes(webpage,paste0('#image-',i)))
      image <- as.character(image_xml[[1]][2])
      image <- gsub("\n","",image)
      image <- gsub("\t","",image)
      images <- rbind(images,data.frame(url,next_url,chapter,i,image,stringsAsFactors = F))
    },silent=TRUE)
  }
  
  results = images
#  results = data.frame(url,next_url,image,image_name,stringsAsFactors = F)
  return(results)
}

if (file.exists(paste0(PROJECT_DIR,"/spyxfamily.RData"))){
  load(paste0(PROJECT_DIR,"/spyxfamily.RData"))
} else {
  spyxfamily <- rip_url(url)  # Save the first page
}

# How many pages total?  91 chapters plus extras
for (i in seq(1:120)){
  tryCatch({
    url <- tail(spyxfamily$next_url,1)
    if (nchar(url)>0){
      print(paste("Iteration",i,"Looking up page",url))
      spyxfamily <- rbind(spyxfamily,rip_url(url))
    }
  })
}

spyxfamily <- unique(spyxfamily)
save(spyxfamily,file=paste0(PROJECT_DIR,"/spyxfamily.RData"))

# Copy the images
#Download the Images
for (i in 1:nrow(spyxfamily)){
  if (file.exists(paste0(FILE_DIR,"/",spyxfamily$chapter[i],"-",str_pad(spyxfamily$i[i],3,pad="0"),".jpg"))){
    print(paste("File",spyxfamily$chapter[i],"image #",spyxfamily$i[i],"already downloaded"))
  } else{
    print(paste("downloading",spyxfamily$chapter[i],"image #",spyxfamily$i[i]))
    download.file(spyxfamily$image[i],
                paste0(FILE_DIR,"/",spyxfamily$chapter[i],"-",str_pad(spyxfamily$i[i],3,pad="0"),".jpg"),
                quiet=TRUE, mode="wb")
  }
}

