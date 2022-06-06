# Data Download
# Download the images from XKCD 
# Page links of form https://xkcd.com/2628/

library(rvest)
library(dplyr)
library(stringr)
library(xml2)

options(timeout= 4000000)

print("Program started")
timestamp()

PROJECT_DIR <- "c:/R/Webrip"
FILE_DIR    <- "c:/R/Webrip/XKCD"

start = 1 
stop  = 2628 # Latest comic as at 06/06/2022

# for testing
d = start
url <- paste0('https://xkcd.com/',d)
#Reading the HTML code from the website
webpage  <- read_html(url)
image    <- html_nodes(webpage,'img') 
img_link <- image[grep("//imgs.xkcd.com/comics/",image)]
link <- xml_attrs(img_link)[[1]][1]
name <- paste0(formatC(i,3,flag="0"),"_",word(link,-1,sep='/'))


#Download the images
for (i in start:stop){
  url <- paste0('https://xkcd.com/',i)
  #Reading the HTML code from the website
  webpage  <- read_html(url)
  image    <- html_nodes(webpage,'img') 
  img_link <- image[grep("//imgs.xkcd.com/comics/",image)]
  tryCatch({link <- xml_attrs(img_link)[[1]][1]
  link <- paste0("https:",link)
  name <- paste0(formatC(i,3,flag="0"),"_",word(link,-1,sep='/'))
  print(paste("Downloading file number",i,name))
  download.file(link,paste0(FILE_DIR,"/",name),quiet=TRUE, mode="wb")},error=function(e){})
}

