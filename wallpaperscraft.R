# WallpapersCraft
# Program to find all the pages on the https://wallpaperscraft.com/ web site
#
# Program works by first paging through the full 
# list of images (all) and harvesting file names,
# Then downloading the images in the specified resolution

library(rvest)
library(dplyr)
library(xml2)
library(stringr)

PROJECT_DIR <- "c:/R/Webrip"
#FILE_DIR    <- "c:/R/Webrip/wallpaperscraft"
FILE_DIR    <- "e:/wallpaperscraft"
dir.create(FILE_DIR,showWarnings = FALSE)

# Stage 1: Page through the list
# Pages of type: https://wallpaperscraft.com/all/page2

start <- 1
stop  <- 9298 # As at 17/06/2023

# Test URL
url <- 'https://wallpaperscraft.com/all/page2'

rip_url <- function(url){
  webpage  <- read_html(url)
  image_list  <- html_nodes(webpage,'.wallpapers__image')
  thumbs <- xml_attr(image_list,'src')
  return(data.frame(thumbnail=thumbs))
}

if (file.exists(paste0(PROJECT_DIR,"/wallpaperscraft.RData"))){
  load(paste0(PROJECT_DIR,"/wallpaperscraft.RData"))  # Load the data file if it exists
} else {
  wallpaperscraft <- rip_url('https://wallpaperscraft.com/all/page1')  # Initialise with  first page
}

for (i in start:stop){
  url <- paste0('https://wallpaperscraft.com/all/page',i)
  print(paste("Ripping page",i,"url",url))
  thumbs <- tryCatch({rip_url(url)},error=function(e){}) 
  wallpaperscraft <- rbind(wallpaperscraft,thumbs)
}

wallpaperscraft <- wallpaperscraft %>% unique()
save(wallpaperscraft,file=paste0(PROJECT_DIR,"/wallpaperscraft.RData"))

# Image Keywords
# Identify the three keywords for each image and prioritise 

keywords <- data.frame()
for (i in 1:nrow(wallpaperscraft)){
  image_name <- strsplit(wallpaperscraft$thumbnail[i],'[/]')
  image_name <- image_name[[1]][length(image_name[[1]])]
  keys <- strsplit(image_name,"_")[[1]]
  for (j in 1:(length(keys)-2)){
    keyword <- keys[j]
    #print(paste("Image",i,"Keyword",j,keyword))
    keywords<- rbind(keywords,data.frame(image_name,keyword))
  }
}
keywords <- keywords %>% unique()
save(keywords,file=paste0(PROJECT_DIR,"/keywords.RData"))

key_list <- keywords %>% select(keyword) %>% group_by(keyword) %>% mutate(n=n()) %>% unique()


#Resolution
# res <- "1080x1920"  # Phone Resolution
res <- "1920x1200"  # tablet resolution

# Download the files
for (i in 1:nrow(wallpaperscraft)){
  thumbnail <- wallpaperscraft$thumbnail[i]
  # Get the address for the resolution we want
  image_res <- paste0(strtrim(wallpaperscraft$thumbnail[i],nchar(wallpaperscraft$thumbnail[i])-11),res,".jpg")  
  image_name <- strsplit(image_res,'[/]')
  image_name <- image_name[[1]][length(image_name[[1]])]
  
  if (file.exists(paste0(FILE_DIR,"/",res,"/",image_name))){
    #print(paste("File",paste0(FILE_DIR,"/",image_name),"Already Exists"))
  } else{
    print(paste("downloading file",i,"of",nrow(wallpaperscraft),image_name))
    tryCatch({download.file(image_res,
                  paste0(FILE_DIR,"/",res,"/",image_name),
                  quiet=TRUE, mode="wb")},error=function(e){print('Remote File Does not Exist')})
  }
}
