# Data Download
# Download the images from The Meek 
# Image links of form https://www.meekcomic.com/comics/TM_web_101a.jpg
# Actually used the Excel links method for this one instead


library(rvest)
library(dplyr)

options(timeout= 4000000)

print("Program started")
timestamp()

PROJECT_DIR <- "c:/R/Webrip"
FILE_DIR    <- "c:/R/Webrip/Meek"

start = 1 
#start = 2207 # the next one that I don't have, 19/08/2020.
stop  = 100 # End of Chapter 77


# for testing
d = start
meek <- paste0('https://www.meekcomic.com/comics/TM_web_1',formatC(d,2,flag="0"),'a.jpg')
#Reading the HTML code from the website
# webpage <- read_html(url)


#Download the Images
for (i in start:stop){
  meek <- paste0('https://www.meekcomic.com/comics/TM_web_1',formatC(i,1,flag="0"),'a.jpg')
  print(paste("downloading file",meek))
  download.file(meek,
                paste0(FILE_DIR,"/TM_web_1",formatC(i,7,flag="0"),'.jpg'),
                quiet=TRUE, mode="wb")
}

