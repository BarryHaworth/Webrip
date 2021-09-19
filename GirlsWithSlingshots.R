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
# Turns out, Hyphenation is inconsistent.  No hyphens before 800, mostly has hyphens thereafter

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
  url1 <-  paste0('https://www.girlswithslingshots.com/comic/gws',p)
  url2 <-  paste0('https://www.girlswithslingshots.com/comic/gws-',p)
  #Reading the HTML code from the website
  webpage1 <- read_html(url1)
  node1    <- html_nodes(webpage1,'#cc-comic') 
  if (length(node1)>0) {
    image   <- as.character(xml_attrs(node1)[[1]][2])
  } else {
    webpage2 <- read_html(url2)
    node2   <- html_nodes(webpage2,'#cc-comic') 
    if (length(node2)>0) {
      image   <- as.character(xml_attrs(node2)[[1]][2])
    }
  }
  return(image)
}

#GWS <- data.frame(page=1,url=page_rip(1))  # Initialise GWS data frame

p1 <- 1
#p1 <- 295  # No page 294
#p2 <- 10    # for testing
p2 <- 2008  # Latest Strip as at 12/03/2015

page = seq(p1:p2)
GWS <- data.frame(page)
GWS$url <- ''

GWS <- GWS %>% filter(page != 294)  # There is no page 294
GWS <- GWS %>% filter(page != 1460)  # There is no page 294
GWS <- GWS %>% filter(page != 1461)  # There is no page 294
GWS <- GWS %>% filter(page != 1515)  # There is no page 294
GWS <- GWS %>% filter(page != 1616)  # There is no page 294
GWS <- GWS %>% filter(page != 1617)  # There is no page 294

# Extract the links.  
for (p in 1:length(GWS$page)){
  if ((GWS$url[p]=='')){  # Download links not downloaded yet
    print(paste("Extracting links for page",GWS$page[p]))
    GWS$url[p] <- page_rip(GWS$page[p])
  }
}

GWS <- unique(GWS)
length(unique(GWS$url))  # Check how many unique URLs
GWS$url <- as.character(GWS$url)
save(GWS,file=paste0(PROJECT_DIR,"/GWS.RData"))
write.table(GWS$url,file=paste0(PROJECT_DIR,"/GWS.txt"),row.names = F,col.names = F,quote=F)

#Download the Images
for (i in 1:nrow(GWS)){
  print(paste("downloading file",GWS$url[i]))
  download.file(GWS$url[i],
                paste0(FILE_DIR,"/GWS",formatC(GWS$page[i],4,flag="0"),".jpg"),
                quiet=TRUE, mode="wb")
}
