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

# Volume  1: Chapter  1 - 14 Page    1 -  304
# Volume  2: Chapter 15 - 22 page  305 -  569
# Volume  3: Chapter 23 - 31 page  570 -  843
# Volume  4: Chapter 32 - 41 page  844 - 1177
# Volume  5: Chapter 42 - 49 page 1178 - 1463
# Volume  6: Chapter 50 - 59 page 1464 - 1752
# Volume  7: Chapter 60 - 68 page 1753 - 2062
# Volume  8: Chapter 69 - 77 page 2063 - 2377
# Volume  9: Chapter 78 - 86 page 2378 - 2699
# Volume 10: Chapter 87 -    page 2700 - 

# start = 1752 
# start = 2207 # the next one that I don't have, 19/08/2020.
# start = 2378 # the next one that I don't have, 18/01/2021.
#start = 1 
#stop  = 2397 # End of Chapter 78
#start = 2378
#stop  = 2787  # Latest page 19 (as at 24/05/2022)
#start = 2788
#stop  = 2840  # Latest page 19 (as at 22/09/2023)
start= 2810
stop = 3113  # Latest as at 11/06/2025

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

# Extra Comics
# Annie in the Forest Part 1
# Annie in the Forest Part 2
# Traveller
# Coyote

#Download the Images
for (i in 0:100){
  Gunnerkrigg <- paste0('https://www.gunnerkrigg.com/extracomics/Annie in the Forest Part 1/',formatC(i,3,flag="0"),'.jpg')
  print(paste("downloading file",Gunnerkrigg))
  download.file(Gunnerkrigg,
                paste0(FILE_DIR,"/Annie1/",formatC(i,3,flag="0"),'.jpg'),
                quiet=TRUE, mode="wb")
}

for (i in 0:100){
  Gunnerkrigg <- paste0('https://www.gunnerkrigg.com/extracomics/Annie in the Forest Part 2/',formatC(i,3,flag="0"),'.jpg')
  print(paste("downloading file",Gunnerkrigg))
  download.file(Gunnerkrigg,
                paste0(FILE_DIR,"/Annie2/",formatC(i,3,flag="0"),'.jpg'),
                quiet=TRUE, mode="wb")
}

for (i in 0:100){
  Gunnerkrigg <- paste0('https://www.gunnerkrigg.com/extracomics/Coyote/',formatC(i,3,flag="0"),'.jpg')
  print(paste("downloading file",Gunnerkrigg))
  download.file(Gunnerkrigg,
                paste0(FILE_DIR,"/Coyote/",formatC(i,3,flag="0"),'.jpg'),
                quiet=TRUE, mode="wb")
}

for (i in 0:100){
  Gunnerkrigg <- paste0('https://www.gunnerkrigg.com/extracomics/Traveller/',formatC(i,3,flag="0"),'.jpg')
  print(paste("downloading file",Gunnerkrigg))
  download.file(Gunnerkrigg,
                paste0(FILE_DIR,"/Traveller/",formatC(i,3,flag="0"),'.jpg'),
                quiet=TRUE, mode="wb")
}




