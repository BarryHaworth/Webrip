# Download the images from XKCD 
# Page links of form https://xkcd.com/2628/
# Updated to check what has been downloaded already and download to the latest file

library(rvest)
library(dplyr)
library(stringr)
library(xml2)

options(timeout= 4000000)

print("Program started")
timestamp()

PROJECT_DIR <- "c:/R/Webrip"
FILE_DIR    <- "c:/R/Webrip/XKCD"
dir.create(FILE_DIR,showWarnings = FALSE)

# for testing
#d = start
#url <- paste0('https://xkcd.com/',d)
##Reading the HTML code from the website
#webpage  <- read_html(url)
#image    <- html_nodes(webpage,'img') 
#img_link <- image[grep("//imgs.xkcd.com/comics/",image)]
#link <- xml_attrs(img_link)[[1]][1]
#name <- paste0(formatC(i,3,flag="0"),"_",word(link,-1,sep='/'))

start = 1 
stop  = 2831 # Latest comic as at 22/09/2023

#  Start and Stop

dir <- list.files(FILE_DIR)
last_file <- tail(dir,1)
start <- as.numeric(substr(last_file,1,4))+1

url <- paste0('https://xkcd.com/')
webpage  <- read_html(url)
links    <- html_nodes(webpage,'a') 
latest_link <- tail(links[grep("https://xkcd.com/",links)],1)
latest     <- xml_attrs(latest_link)[[1]][1]
stop  <- as.numeric(word(latest,-1,sep='/'))

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

