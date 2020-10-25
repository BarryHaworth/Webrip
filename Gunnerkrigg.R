# Data Download
# Download the images from Gunnerkrigg Court
# Image links of form http://www.gunnerkrigg.com/comics/00001752.jpg

library(rvest)
library(dplyr)

options(timeout= 4000000)

print("Program started")
timestamp()

PROJECT_DIR <- "c:/R/Webrip"
FILE_DIR    <- "c:/R/Webrip/Gunnerkrigg"

# start = 1752 
start = 2207 # the next one that I don't have, 19/08/2020.
stop  = 2377 # End of Chapter 77


# for testing
d = start
Gunnerkrigg <- paste0('https:///www.gunnerkrigg.com/comics/',formatC(d,7,flag="0"),'.jpg')
#Reading the HTML code from the website
# webpage <- read_html(url)


#Download the Images
for (i in start:stop){
  Gunnerkrigg <- paste0('https://www.gunnerkrigg.com/comics/',formatC(i,7,flag="0"),'.jpg')
  print(paste("downloading file",Gunnerkrigg))
  download.file(Gunnerkrigg,
                paste0(FILE_DIR,"/",formatC(i,7,flag="0"),'.jpg'),
                quiet=TRUE, mode="wb")
}

