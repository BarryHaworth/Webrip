#  Villainess 99
# First Story starts at:
# https://ww7.mangakakalot.tv/chapter/manga-ih985416/chapter-0
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
FILE_DIR    <- "c:/R/Webrip/villainess99"
dir.create(FILE_DIR, showWarnings = FALSE)  # Create directory if it doesn't exist

# First page of Manga
url <- 'https://ww7.mangakakalot.tv/chapter/manga-ih985416/chapter-0'
#url <- 'https://ww7.mangakakalot.tv/chapter/manga-ih985416/chapter-1'

rip_url <- function(url){
  chapter <- str_split_1(url,'/')[6]
  webpage <- read_html(url)
  next_xml <- xml_attrs(html_nodes(webpage,'.next'))
  if (length(next_xml)==2){
    next_url <- as.character(paste0('https://ww7.mangakakalot.tv',next_xml[[2]][1]))
    } else if (length(next_xml)==4) {
      next_url <- as.character(paste0('https://ww7.mangakakalot.tv',next_xml[[2]][1])) } else next_url <- ""
  images <- data.frame()
  image_xml <- xml_attrs(html_nodes(webpage,'.img-loading'))
  for (i in seq(1,100)){
    try({
      image <- as.character(image_xml[[i]][1])
      images <- rbind(images,data.frame(url,next_url,chapter,i,image,stringsAsFactors = F))
    },silent=TRUE)
  }
  
  results = images
  #  results = data.frame(url,next_url,image,image_name,stringsAsFactors = F)
  return(results)
}

# Read the existing data frame if it exists
if (file.exists(paste0(PROJECT_DIR,"/villainess99.RData"))){
  load(paste0(PROJECT_DIR,"/villainess99.RData"))
} else {
  villainess99 <- rip_url(url)  # Save the first page
}

# remove records which have no Next URL to allow 
villainess99 <- villainess99 %>% filter(next_url!="")

# How many pages total?  18 chapters plus extras
for (i in seq(1:30)){
  tryCatch({
    url <- tail(villainess99$next_url,1)
    if (nchar(url)>0){
      print(paste("Iteration",i,"Looking up page",url))
      villainess99 <- rbind(villainess99,rip_url(url))
    }
  })
}

villainess99 <- unique(villainess99)
save(villainess99,file=paste0(PROJECT_DIR,"/villainess99.RData"))

# Copy the images
#Download the Images
for (i in 1:nrow(villainess99)){
  if (file.exists(paste0(FILE_DIR,"/",villainess99$chapter[i],"-",str_pad(villainess99$i[i],3,pad="0"),".jpg"))){
    print(paste("File",villainess99$chapter[i],"image #",villainess99$i[i],"already downloaded"))
  } else{
    print(paste("downloading",villainess99$chapter[i],"image #",villainess99$i[i]))
    download.file(villainess99$image[i],
                  paste0(FILE_DIR,"/",villainess99$chapter[i],"-",str_pad(villainess99$i[i],3,pad="0"),".jpg"),
                  quiet=TRUE, mode="wb")
  }
}


