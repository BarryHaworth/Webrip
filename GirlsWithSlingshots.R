# Girls with Slingshots
# Strip URLS
# Vol 1 https://www.girlswithslingshots.com/comic/gws1
# Vol 2 https://www.girlswithslingshots.com/comic/gws200
# Vol 3 https://www.girlswithslingshots.com/comic/gws402
# Vol 4 https://www.girlswithslingshots.com/comic/gws605
# Vol 5 https://www.girlswithslingshots.com/comic/gws-801
# Vol 6 https://www.girlswithslingshots.com/comic/gws-1001
# Vol 7 https://www.girlswithslingshots.com/comic/gws-1201
# Vol 8 https://www.girlswithslingshots.com/comic/gws-1401
# Vol 9 https://www.girlswithslingshots.com/comic/gws-1600
# Vol 10 https://www.girlswithslingshots.com/comic/gws-2004/

#  No hyphens 1-800, hyphens thereafter

library(rvest)
library(dplyr)
library(xml2)

options(timeout= 4000000)

print("Program started")
timestamp()

PROJECT_DIR <- "c:/R/Webrip"
FILE_DIR    <- "c:/R/Webrip/GWS"

# for testing
url <- paste('https://www.girlswithslingshots.com/comic/gws1')
url <- 'https://www.girlswithslingshots.com/comic/gws-1401'
#Reading the HTML code from the website
webpage <- read_html(url)
image <- html_nodes(webpage,'#cc-comic')

as.character(xml_attrs(image)[[1]][2])

# Find image names for a given page
page_rip <- function(p){
  if (p <= 800){
    url <-  paste0('https://www.girlswithslingshots.com/comic/gws',p)
  } else {
    url <-  paste0('https://www.girlswithslingshots.com/comic/gws-',p)
  }
  #Reading the HTML code from the website
  webpage <- read_html(url)
  node    <- html_nodes(webpage,'#cc-comic') 
  image   <- as.character(xml_attrs(node)[[1]][2])
  return(image)
}

GWS <- data.frame(page=1,url=page_rip(1))

p1 <- 1
#p2 <- 10    # for testing
p2 <- 1704  # Latest Strip as at 18/09/2021

for (p in p1:p2){
  print(paste("Extracting links for page",p))
  new <- data.frame(page=p,url=page_rip(p))
  GWS <- rbind(GWS,new)
}

GWS <- unique(GWS)
GWS$url <- as.character(GWS$url)
save(GWS,file=paste0(PROJECT_DIR,"/GWS.RData"))
write.table(GWS$url,file=paste0(PROJECT_DIR,"/GWS.txt"),row.names = F,col.names = F,quote=F)

#Download the Images
for (i in 1:nrow(GWS)){
  print(paste("downloading file",GWS$url[i]))
  download.file(GWS$url[i],
                paste0(FILE_DIR,"/gws-",formatC(GWS$page[i],4,flag="0"),".jpg"),
                quiet=TRUE, mode="wb")
}
