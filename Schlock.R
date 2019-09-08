# Data Download
# Crawl through pages of Schlock Mercenary and save images
# Start from 1st March 2015 and go to present

library(rvest)
library(dplyr)

options(timeout= 4000000)

print("Program started")
timestamp()

PROJECT_DIR <- "c:/R/Webrip"
FILE_DIR    <- "c:/R/Webrip/Schlock"

# for testing
url <- paste('https://www.schlockmercenary.com/',d,sep='')
#Reading the HTML code from the website
# webpage <- read_html(url)

# Find image names for a given date
date_rip <- function(d){
  url <-  paste('https://www.schlockmercenary.com/',d,sep='')
  #Reading the HTML code from the website
  webpage <- read_html(url)
  image <- html_nodes(webpage,'img') 
  image <- image[grep("schlock",image)]
  images=rep("",length(image))
  for(i in 1:length(image)){
    images[i] <- strsplit(as.character(image[i]),"src=")[[1]][2]
    images[i] <- strsplit(as.character(images[i]),"v=")[[1]][1]
  }
  images <- gsub("\"","",images)
  images <- gsub('?','',images,fixed=TRUE)
  for(i in 1:length(images)){
    images[i] <- paste('https://www.schlockmercenary.com',images[i],sep='') # convert to full URL
  }
  images <- data.frame(images,stringsAsFactors = FALSE)
  names(images) <- "url"
  return(images)
}

# d1 <- as.Date("2015-03-01",origin="1970-01-01")
# d1 <- as.Date("2018-07-01",origin="1970-01-01")
# d1 <- as.Date("2018-12-01",origin="1970-01-01")
d1 <- as.Date("2019-05-01",origin="1970-01-01")
# d2 <- as.Date("2015-03-05",origin="1970-01-01")
d2 <- Sys.Date()
Schlock <- date_rip(d1)

for (d in as.numeric(d1):as.numeric(d2)){
  print(paste("Extracting links for date",format.Date(as.Date(d,origin="1970-01-01"),"%d/%m/%y")))
  Schlock <- rbind(Schlock,date_rip(as.Date(d,origin="1970-01-01")))
}

Schlock <- unique(Schlock)
save(Schlock,file=paste(PROJECT_DIR,"/Schlock.RData",sep=""))
write.table(Schlock$url,file=paste(PROJECT_DIR,"/Schlock.txt",sep=""),row.names = F,col.names = F,quote=F)
# Schlock <- as.character(Schlock)

#Download the Images
for (i in 1:nrow(Schlock)){
  print(paste("downloading file",Schlock$url[i]))
  download.file(Schlock$url[i],
                paste(FILE_DIR,"/",strsplit(Schlock$url[i],"/")[[1]][7],sep=""),
                quiet=TRUE, mode="wb")
}

