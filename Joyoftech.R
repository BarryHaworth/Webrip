# Joy of Tech

# https://www.geekculture.com/joyoftech
# Start: https://www.geekculture.com/joyoftech/joyarchives/001.html

library(rvest)
library(dplyr)
library(stringr)

options(timeout= 4000000)

PROJECT_DIR <- "c:/R/Webrip"
FILE_DIR    <- "c:/R/Webrip/Joy"

start <- 1
start <- 2183
end   <- 2544 # as at 30/04/2019
images <- ""

# Get the list of image links

#url <- paste('https://www.geekculture.com/joyoftech/joyarchives/001.html')
#url <- paste('https://www.geekculture.com/joyoftech/joyarchives/2544.html')
for(i in start:end){
  # Convert number into a URL
  url <- paste0('https://www.geekculture.com/joyoftech/joyarchives/',str_pad(i,3,pad="0"),'.html')
  print(paste("Reading page",i))
  # print(paste("URL =",url))
  # read the Web page
  webpage <- read_html(url)
  # Find the image details
  image <- html_nodes(webpage,'img') 
  image <- grep("joyimages",image,value=TRUE)
  # Filter out the images we do not want
  image <- grep("thumb",image,invert=TRUE,value=TRUE)
  image <- grep("JoTnav",image,invert=TRUE,value=TRUE)
  image <- grep("amazon",image,invert=TRUE,value=TRUE)
  image <- grep("tipjar",image,invert=TRUE,value=TRUE)
  image <- gsub("\"","",image)
  image <- gsub(">","",image)
  image <- gsub("<","",image)
  image <- as.character(image)
  
  image <- gsub('src=..','https://www.geekculture.com/joyoftech',image)
  image <- grep("http",strsplit(image," ")[[1]],value=TRUE)
  
  images <- rbind(images,image)
}
images <- images[!(images=="")]

#Download the Images
for (i in 1:length(images)){
  print(paste("downloading file",images[i]))
  print(paste("Saving to",paste(FILE_DIR,"/",strsplit(images[i],"/")[[1]][6],sep="")))
  download.file(images[i],
                paste(FILE_DIR,"/",strsplit(images[i],"/")[[1]][6],sep=""),
                quiet=TRUE, mode="wb")
}
