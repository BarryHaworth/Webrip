#  Delicious in Dungeon
# First Story starts at:
# https://ww7.mangakakalot.tv/chapter/manga-ih985416/chapter-0
#
# This code starts at the first page of a manga
# and then crawl through it page by page to identify 
# the next page, then the manga images.
#
# It would be possible to generalise this for any manga on Manga Online

library(rvest)
library(dplyr)
library(xml2)
library(stringr)

PROJECT_DIR <- "c:/R/Webrip"
FILE_DIR    <- "c:/R/Webrip/delicious"
dir.create(FILE_DIR, showWarnings = FALSE)  # Create directory if it doesn't exist

# First page of Manga
url <- 'https://ww7.mangakakalot.tv/chapter/manga-vs951827/chapter-0'

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
if (file.exists(paste0(PROJECT_DIR,"/delicious.RData"))){
  load(paste0(PROJECT_DIR,"/delicious.RData"))
} else {
  delicious <- rip_url(url)  # Save the first page
}

# remove records which have no Next URL to allow 
delicious <- delicious %>% filter(next_url!="")

# How many pages total?  97 chapters plus extras
for (i in seq(1:30)){
  tryCatch({
    url <- tail(delicious$next_url,1)
    if (nchar(url)>0){
      print(paste("Iteration",i,"Looking up page",url))
      delicious <- rbind(delicious,rip_url(url))
    }
  })
}

delicious <- unique(delicious)
save(delicious,file=paste0(PROJECT_DIR,"/delicious.RData"))

# Copy the images
#Download the Images
for (i in 1:nrow(delicious)){
  if (file.exists(paste0(FILE_DIR,"/",delicious$chapter[i],"-",str_pad(delicious$i[i],3,pad="0"),".jpg"))){
    print(paste("File",delicious$chapter[i],"image #",delicious$i[i],"already downloaded"))
  } else{
    print(paste("downloading",delicious$chapter[i],"image #",delicious$i[i]))
    download.file(delicious$image[i],
                  paste0(FILE_DIR,"/",delicious$chapter[i],"-",str_pad(delicious$i[i],3,pad="0"),".jpg"),
                  quiet=TRUE, mode="wb")
  }
}

# save to CBR files
# Get list of files
images = list.files(FILE_DIR)

# Identify Chapters
chapters = as.numeric(word(images,2,sep="-"))

# Group Chapters into Volumes
volume01 <- images[chapters<8]
volume02 <- images[ 8 <= chapters & chapters < 15]
volume03 <- images[15 <= chapters & chapters < 22]
volume04 <- images[22 <= chapters & chapters < 29]
volume05 <- images[29 <= chapters & chapters < 36]
volume06 <- images[36 <= chapters & chapters < 43]
volume07 <- images[43 <= chapters & chapters < 50]
volume08 <- images[50 <= chapters & chapters < 57]
volume09 <- images[57 <= chapters & chapters < 63]
volume10 <- images[63 <= chapters & chapters < 70]
volume11 <- images[70 <= chapters & chapters < 77]
volume12 <- images[77 <= chapters & chapters < 86]
volume13 <- images[86 <= chapters & chapters < 93]
volume14 <- images[93 <= chapters ]

# zip images into volumes and rename to cbz
# This does not work
zip(zipfile=paste0(PROJECT_DIR,"/delicious01.cbz"),files=file.path(FILE_DIR,volume01), flags = "-cf", zip= Sys.getenv("R_ZIPCMD","tar.exe"))
