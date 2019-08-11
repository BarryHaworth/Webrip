# Pitch Meetings - read the file list and get the correct names from Youtube
# For this program I have ripped the contents of the Pitch Meetings channel
# Files have been samved with a name that includes the Youtube file reference
# This program reads the list of mp3 file names and uses this to loop up
# the video pages to retrieve the video name, then writes a command to
# rename the mp3 files.

library(rvest)
library(dplyr)
library(stringr)

options(timeout= 4000000)

PROJECT_DIR <- "c:/R/Webrip"


# Get the list of image links

pitch <- read.table(paste0(PROJECT_DIR,"/pitch.txt"),stringsAsFactors = F)
pitch$ID <- substr(pitch$V4,3,13)
pitch$link <- paste0("https://www.youtube.com/watch?v=",pitch$ID)

# Find image names for a given date
name_rip <- function(url){
  #Reading the HTML code from the website
  webpage <- read_html(url)
  name <- html_nodes(webpage,'title') 
  name <- substring(as.character(name),8)
  name <- substring(as.character(name),1,nchar(name)-19)
  return(name)
}

name_rip(pitch$link[8])

pitch$name <- ""

#Download the Images
for (i in 1:length(pitch$name)){
  pitch$name[i] <- name_rip(pitch$link[i])
}

pitch$ren <- ""

for (i in 1:length(pitch$name)){
  pitch$ren[i] <- paste0("ren ",pitch$V4[i]," ",str_replace_all(pitch$name[i]," ","_"),".mp3")
}

write.table(pitch$ren,"ren.bat",quote=FALSE,col.names=FALSE,row.names = FALSE)
