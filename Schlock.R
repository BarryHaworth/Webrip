# Data Download
# Crawl through pages of Oppo Wallpaper site
# Start from 1st March 2015 and go to present
# Sample page
#  https://www.fonewalls.com/720x1528-wallpapers/720x1528-background-hd-wallpaper-021/
# https://www.fonewalls.com/wp-content/uploads/720x1528-Background-HD-Wallpaper-001-600x1273.jpg
# https://www.fonewalls.com/wp-content/uploads/720x1528-Background-HD-Wallpaper-027.jpg

library(rvest)
library(dplyr)

options(timeout= 4000000)

print("Program started")
timestamp()

PROJECT_DIR <- "c:/R/Webrip"
FILE_DIR    <- "c:/R/Webrip/Oppo"

# Find image names for a given date
jpg_rip <- function(d){
  url <-  paste0('https://www.fonewalls.com/wp-content/uploads/720x1528-Background-HD-Wallpaper-',sprintf("%03d", d),"-600x1273.jpg")
  return(url)
}

Oppo <- jpg_rip(1)

for (d in 2:10){
  print(paste("Extracting links number",d))
  Oppo <- rbind(Oppo,jpg_rip(d))
}

Oppo <- unique(Oppo)
save(Oppo,file=paste(PROJECT_DIR,"/Oppo.RData",sep=""))

#Download the Images
for (i in 1:nrow(Oppo)){
  print(paste("downloading file",Oppo[i]))
  print(paste(FILE_DIR,"/",strsplit(Oppo[i],"/")[[1]][6],sep=""))
  download.file(Oppo[i],
                paste(FILE_DIR,"/",strsplit(Oppo[i],"/")[[1]][6],sep=""),
                quiet=TRUE, mode="wb")
}

