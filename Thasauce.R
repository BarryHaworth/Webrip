# Data Download
# Download the MP# music files from Thasauce Remix
# Each MP# has a page similar to https://remix.thasauce.net/song/RTS0325/

library(rvest)
library(dplyr)
library(stringr)

options(timeout= 4000000)

print("Program started")
timestamp()

PROJECT_DIR <- "c:/R/Webrip"
FILE_DIR    <- "c:/R/Webrip/Thasauce"

start = 251 # This is the first file I do not have
stop  = 325 # Latest file as at 08/12/2021


# for testing
d = start
url <- paste0('https://remix.thasauce.net/song/RTS',formatC(d,3,flag="0"))
#Reading the HTML code from the website
webpage  <- read_html(url)
mp3      <- html_nodes(webpage,'.downloadLink') 
mp3_link <- mp3[[1]]
link <- xml_attrs(mp3_link)[["href"]]
name <- word(link,-1,sep='/')

#Download the MP3
for (i in start:stop){
  url <- paste0('https://remix.thasauce.net/song/RTS',formatC(i,3,flag="0"))
  #Reading the HTML code from the website
  webpage  <- read_html(url)
  mp3      <- html_nodes(webpage,'.downloadLink') 
  mp3_link <- mp3[[1]]
  link <- xml_attrs(mp3_link)[["href"]]
  name <- word(link,-1,sep='/')
  print(paste("Downloading file number",i,name))
  download.file(link,paste0(FILE_DIR,"/",name),quiet=TRUE, mode="wb")
}

