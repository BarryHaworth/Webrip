# An experiment to download an Angel and May episode multiple times 
# This experiment did not improve the download counts

library(rvest)

PROJECT_DIR <- "c:/R/Webrip"
FILE_DIR    <- "c:/R/Webrip"

url  <- 'https://www.buzzsprout.com/447685/2262338-s1-e13-a-partridge-in-a-pear-tree.mp3'
name <- 's1-e13-a-partridge-in-a-pear-tree.mp3'
# download.file(url,paste0(FILE_DIR,"/",name),quiet=TRUE, mode="wb")

for (i in seq(1,100)){
  print(paste("Download number",i))
  download.file(url,paste0(FILE_DIR,"/",name),quiet=TRUE, mode="wb")
}

