# Download the images from Lackadaisy Cats
# Page links of form https://www.lackadaisycats.com/comic.php?comicid=1
# Updated to check what has been downloaded already and download to the latest file

library(rvest)
library(dplyr)
library(stringr)
library(xml2)

options(timeout= 4000000)

print("Program started")
timestamp()

PROJECT_DIR <- "c:/R/Webrip"
FILE_DIR    <- "c:/R/Webrip/lackadaisy"
dir.create(FILE_DIR,showWarnings = FALSE)

# for testing
d = start
url <- paste0('https://www.lackadaisycats.com/comic.php?comicid=',d)
##Reading the HTML code from the website
webpage  <- read_html(url)
image    <- html_nodes(webpage,'img') 
img_link <- image[1]
link <- xml_attrs(img_link)[[1]][1]
name <- paste0(formatC(i,3,flag="0"),"_",word(link,-1,sep='/'))

start = 1 
stop  = 175 # Latest comic as at 21/01/2023

#  Start and Stop

dir <- list.files(FILE_DIR)
last_file <- tail(dir,1)
start <- as.numeric(substr(last_file,1,4))+1

#Download the images
for (i in start:stop){
  url <- paste0('https://www.lackadaisycats.com/comic.php?comicid=',i)
  #Reading the HTML code from the website
  webpage  <- read_html(url)
  image    <- html_nodes(webpage,'img') 
  img_link <- image[1]
  tryCatch({link <- xml_attrs(img_link)[[1]][1]
  name <- paste0(formatC(i,3,flag="0"),"_",word(link,-1,sep='/'))
  print(paste("Downloading file number",i,name))
  download.file(link,paste0(FILE_DIR,"/",name),quiet=TRUE, mode="wb")},error=function(e){})
}

