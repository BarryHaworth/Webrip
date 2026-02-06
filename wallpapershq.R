#  Wallpapers HQ
# Copying code from wallpaperswide
# Sample Page:
# https://wallpapershq.com/categories/all/1080x2400/popular?page=2
# Sample wallpaper:
# https://wallpapershq.com/wallpapers/8128_7d8ef9219addbe32b1157762b991a01a5e550564bbd5d144eb959b3530fbe8d8_cat-look/1080x2400/download
#
# https://images.wallpapershq.com/wallpapers/8128/wallpaper_8128_1080x2400.jpg
#
# 26/12/2025 UPDATE to make the common folder ~/pictures/wallpaper

library(rvest)
library(dplyr)
library(xml2)
library(stringr)
library(tidyr)
library(data.table)

PROJECT_DIR <- "c:/R/Webrip"
#FILE_DIR    <- "h:/pictures/wallpapershq"
FILE_DIR    <- "h:/pictures/wallpapers"
dir.create(FILE_DIR,showWarnings = FALSE)

# Test URL
url <- 'https://wallpapershq.com/categories/all/1080x2400/popular?page=2'

# Set D/L Resolution
res <- "1080x2400"   # Oppo a96/ Ulefone Resolution
#res <- "3840x1080"   # Dual Screen Resolution - not found
#res <- "3440x1440"

rip_url <- function(url){
  webpage  <- read_html(url)
  image_list  <- html_nodes(webpage,'img')
  thumbs <- xml_attr(image_list,'src')
  return(data.frame(thumbnail=thumbs))
}

#  Get list of image pages from Start to Stop

start <- 1
#stop  <- 10
stop  <- 252 # Total for 1080x2400

if (file.exists(paste0(PROJECT_DIR,"/wallpapershq-",res,".RData"))){
  load(paste0(PROJECT_DIR,"/wallpapershq-",res,".RData"))  # Load the data file if it exists
} else {
  wallpapershq <- rip_url(paste0('https://wallpapershq.com/categories/all/1080x2400/popular?page=1'))  # Initialise with  first page
}

cume <- 0

for (i in start:stop){
  before <- nrow(wallpapershq)
  #  url <- paste0('https://wallpapershq.com/page/',i)
  url <- paste0('https://wallpapershq.com/categories/all/',res,'/popular?page=',i)
  cat(paste("Ripping page",i,"of",stop,"url",url))
  thumbs <- tryCatch({rip_url(url)},error=function(e){}) 
  wallpapershq <- rbind(wallpapershq,thumbs) %>% unique() %>% arrange(thumbnail)
  after <- nrow(wallpapershq)
  added <- after-before
  cume <- cume+added
  cat(paste(" Added",added,"images, cume",cume,'\n'))
}

save(wallpapershq,file=paste0(PROJECT_DIR,"/wallpapershq-",res,".RData"))

# create image links
links <- wallpapershq %>% 
  separate(col=thumbnail,
           into = c("var1","var2","var3","var4","image_number"),
           sep="/") %>%
  mutate(link=paste0('https://images.wallpapershq.com/wallpapers/',
                     image_number,'/wallpaper_',image_number,'_',res,'.jpg') ) %>% 
  select(link)

# Download
# Download the files 
for (i in 1:nrow(links)){
  dir.create(paste0(FILE_DIR,"/",res),showWarnings = FALSE)
  link <- links$link[i]
  # Get the address for the resolution we want
  image_name <- strsplit(link,'[/]')[[1]][6]

  if (file.exists(paste0(FILE_DIR,"/",res,"/",image_name))){
    print(paste("File",paste0(FILE_DIR,"/",image_name),"Already Exists"))
  } else{
    cat(paste("downloading file",i,"of",nrow(wallpapershq),image_name))
    tryCatch({download.file(link,
                            paste0(FILE_DIR,"/",res,"/",image_name),
                            quiet=TRUE, mode="wb")},error=function(e){cat(' - Remote File Does not Exist')})
    cat('\n')
  }
}

# Purge the Downloaded files for those that are too small

filelist <- list.files(path = paste0(FILE_DIR,"/",res), full.names = TRUE )
summary(file.size(filelist))
hist(file.size(filelist))

smallfiles <- filelist[file.size(filelist) < 120000]
# file.remove(smallfiles)
