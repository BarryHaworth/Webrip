#  Wallpapers Wide
# This looks like it would be amenable to the same tratment as wallpaperswide
# but with the advantage taht it includes a dual screen resolution (3840x1080)
# Need to write this.
# Sample wallpaper:
# https://wallpaperswide.com/download/mirror_of_the_mountains_lake_reflections-wallpaper-3840x1080.jpg

library(rvest)
library(dplyr)
library(xml2)
library(stringr)
library(tidyr)
library(data.table)

PROJECT_DIR <- "c:/R/Webrip"
#FILE_DIR    <- "c:/R/Webrip/wallpaperswide"
FILE_DIR    <- "h:/pictures/wallpaperswide"
dir.create(FILE_DIR,showWarnings = FALSE)

# Test URL
url <- 'https://wallpaperswide.com/page/2'
url <- 'https://wallpaperswide.com/3840x1080-wallpapers-r/page/2' # select the resolution wanted


rip_url <- function(url){
  webpage  <- read_html(url)
  image_list  <- html_nodes(webpage,'.thumb_img')
  thumbs <- xml_attr(image_list,'src')
  return(data.frame(thumbnail=thumbs))
}


#  Get list of image pages from Start to Stop

start <- 1
#stop  <- 10
stop  <- 840 # As at 12/12/2025 

if (file.exists(paste0(PROJECT_DIR,"/wallpaperswide.RData"))){
  load(paste0(PROJECT_DIR,"/wallpaperswide.RData"))  # Load the data file if it exists
} else {
  wallpaperswide <- rip_url('https://wallpaperswide.com/3840x1080-wallpapers-r/page/1')  # Initialise with  first page
}

cume <- 0

for (i in stop:start){
  before <- nrow(wallpaperswide)
  url <- paste0('https://wallpaperswide.com/page/',i)
  cat(paste("Ripping page",i,"url",url))
  thumbs <- tryCatch({rip_url(url)},error=function(e){}) 
  wallpaperswide <- rbind(wallpaperswide,thumbs) %>% unique() %>% arrange(thumbnail)
  after <- nrow(wallpaperswide)
  added <- after-before
  cume <- cume+added
  cat(paste(" Added",added,"images, cume",cume,'\n'))
}

save(wallpaperswide,file=paste0(PROJECT_DIR,"/wallpaperswide.RData"))


# Set D/L Resolution
res <- "3840x1080"   # Dual Screen Resolution

# Filter list for the desired resolution?

# Download
# Download the files 
for (i in 1:nrow(wallpaperswide)){
  dir.create(paste0(FILE_DIR,"/",res),showWarnings = FALSE)
  thumbnail <- wallpaperswide$thumbnail[i]
  # Get the address for the resolution we want
  #image_res <- paste0(strtrim(wall_filtered$thumbnail[i],nchar(wall_filtered$thumbnail[i])-11),res,".jpg")  
  image_res  <- thumbnail
  image_name <- strsplit(image_res,'[/]')[[1]][5]
  image_name <- sub('t1',res,image_name)
  image_res  <- paste0('https://wallpaperswide.com/download/',image_name)
  
  if (file.exists(paste0(FILE_DIR,"/",res,"/",image_name))){
    print(paste("File",paste0(FILE_DIR,"/",image_name),"Already Exists"))
  } else{
    cat(paste("downloading file",i,"of",nrow(wallpaperswide),image_name))
    tryCatch({download.file(image_res,
                            paste0(FILE_DIR,"/",res,"/",image_name),
                            quiet=TRUE, mode="wb")},error=function(e){cat(' - Remote File Does not Exist')})
    cat('\n')
  }
}
