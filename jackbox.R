# Generate and Test Jackbox Rooms

library(rvest)
library(dplyr)
library(xml2)

options(timeout= 4000000)

letters <- c('A','B','C','D','E','F','G','H','I','J','K','L','M','N','O','P','Q','R','S','T','U','V','W','X','Y','Z')

n <- 100

test <- 'Error'
counter <-0
while(substr(test,1,5) =='Error'){
  counter <- counter+1
  room <- paste(sample(letters,4,replace=TRUE),collapse="")
  url <- paste0('https://blobcast.jackboxgames.com/room/',room)
  test <- tryCatch(webpage <- read_html(url,options="RECOVER"),error=function(e){paste('Error for room',room)})
  if(substr(test,1,5) =='Error') {
    print(paste(counter,'Error for room',room))
  } else {
    webpage <- read_html(url,options="RECOVER")
    print(paste("Room",room,"is valid. URL =",url))
    print(paste0("Game URL is https://jackbox.tv/#/",room))
  } 
}

