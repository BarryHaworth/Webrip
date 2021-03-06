# Data Download
# Download the MP# music files from OCRemix
# Link of form https://ocremix.org/remix/OCR04153 

library(rvest)
library(dplyr)
library(stringr)

options(timeout= 4000000)

print("Program started")
timestamp()

PROJECT_DIR <- "c:/R/Webrip"
FILE_DIR    <- "c:/R/Webrip/OCRemix"

start = 3846 # the next one that I don't have, 08/11/2020
stop  = 4153 # Latest file as at 8th November 2020


# for testing
d = start
url <- paste0('https://ocremix.org/remix/OCR',formatC(d,4,flag="0"))
#Reading the HTML code from the website
webpage  <- read_html(url)
mp3      <- html_nodes(webpage,'li') 
mp3_link <- mp3[grep("blueblue",mp3)]
link <- xml_attrs(xml_child(mp3_link, 1))[["href"]]
name <- word(link,-1,sep='/')

#Download the MP3
for (i in start:stop){
  url <- paste0('https://ocremix.org/remix/OCR',formatC(i,4,flag="0"))
  #Reading the HTML code from the website
  webpage  <- read_html(url)
  mp3      <- html_nodes(webpage,'li') 
  mp3_link <- mp3[grep("blueblue",mp3)]
  link <- xml_attrs(xml_child(mp3_link, 1))[["href"]]
  name <- word(link,-1,sep='/')
  print(paste("Downloading file number",i,name))
  download.file(link,paste0(FILE_DIR,"/",name),quiet=TRUE, mode="wb")
}

