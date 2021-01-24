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

# Volume 1: Chapter  1 - 14 Page    1 -  304
# Volume 2: Chapter 15 - 22 page  305 -  569
# Volume 3: Chapter 23 - 31 page  570 -  843
# Volume 4: Chapter 32 - 41 page  844 - 1177
# Volume 5: Chapter 42 - 49 page 1178 - 1463
# Volume 6: Chapter 50 - 59 page 1464 - 1752
# Volume 7: Chapter 60 - 68 page 1753 - 2062
# Volume 8: Chapter 69 - 74 page 2063 - 2269

# start = 1752 
# start = 2207 # the next one that I don't have, 19/08/2020.
# start = 2378 # the next one that I don't have, 18/01/2021.
start = 1 
stop  = 2397 # End of Chapter 78


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

