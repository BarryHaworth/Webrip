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

# d1 <- as.Date("2000-06-12",origin="1970-01-01") # Start of Book 1: The Tub of Happiness 
# d1 <- as.Date("2001-11-11",origin="1970-01-01") # Start of Book 2: The Teraport Wars 
# d1 <- as.Date("2003-03-09",origin="1970-01-01") # Start of Book 3: Under New Management
# d1 <- as.Date("2003-08-24",origin="1970-01-01") # Start of Book 4: The Blackness Between
# d1 <- as.Date("2004-03-15",origin="1970-01-01") # Start of Book 5: The Scrapyard of Insufferable Arrogance
# d1 <- as.Date("2004-09-12",origin="1970-01-01") # Start of Book 6: Resident Mad Scientist
# d1 <- as.Date("2005-07-24",origin="1970-01-01") # Start of Book 7: Emperor Pius Dei
# d1 <- as.Date("2006-08-17",origin="1970-01-01") # Start of Book 8: The Sharp End of the Stick 
# d1 <- as.Date("2007-05-20",origin="1970-01-01") # Start of Book 9: The Body Politic
# d1 <- as.Date("2008-02-29",origin="1970-01-01") # Start of Book 10: The Longshoreman of the Apocalypse 
# d1 <- as.Date("2009-03-02",origin="1970-01-01") # Start of Book 11: Massively Parallel 
# d1 <- as.Date("2010-11-29",origin="1970-01-01") # Start of Book 12: Force Multiplication
# d1 <- as.Date("2011-11-13",origin="1970-01-01") # Start of Book 13: Random Access Memorabilia
# d1 <- as.Date("2013-01-01",origin="1970-01-01") # Start of Book 14: Broken Wind
# d1 <- as.Date("2014-03-16",origin="1970-01-01") # Start of Book 15: Delegates and Delegation
# d1 <- as.Date("2015-03-30",origin="1970-01-01") # Start of Book 16: Big, Dumb Objects
# d1 <- as.Date("2016-12-05",origin="1970-01-01") # Start of Book 17: A Little Immortality 
# d1 <- as.Date("2017-09-18",origin="1970-01-01") # Start of Book 18: Mandatory Failure
# d1 <- as.Date("2018-07-25",origin="1970-01-01") # Start of Book 19: A Function of Firepower
d1 <- as.Date("2019-06-16",origin="1970-01-01")  # Start of book 20: Sergeant in Motion
d2 <- Sys.Date()d2 <- Sys.Date()
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