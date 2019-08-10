# Maximumble.

library(rvest)
library(dplyr)
library(stringr)

options(timeout= 4000000)

PROJECT_DIR <- "c:/R/Webrip"
FILE_DIR    <- "c:/R/Webrip/Maxi"

# Get the list of image links

images <- read.table(paste0(PROJECT_DIR,"/maxi.txt"),stringsAsFactors = F)
images <- images[,1]

#Download the Images
for (i in 1:length(images)){
  print(paste("downloading file:",images[i]))
  print(paste("Saving to",paste(FILE_DIR,"/",strsplit(images[i],"/")[[1]][5],sep="")))
  download.file(images[i],
                paste(FILE_DIR,"/",strsplit(images[i],"/")[[1]][5],sep=""),
                quiet=TRUE, mode="wb")
}
