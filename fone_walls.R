#  Fone Walls
# Copying code from fonewalls
# Sample Page:
# https://www.fonewalls.com/1080x2400-wallpapers/2/
# Sample wallpaper:
# https://www.fonewalls.com/wp-content/uploads/2019/09/Phone-Background-Wallpaper-1080x2400-9.jpg
# https://www.fonewalls.com/wp-content/uploads/2019/09/Beautiful-Feather-Wallpaper.jpg

library(rvest)
library(dplyr)
library(xml2)
library(stringr)
library(tidyr)
library(data.table)

PROJECT_DIR <- "c:/R/Webrip"
FILE_DIR    <- "h:/pictures/wallpapers"
dir.create(FILE_DIR,showWarnings = FALSE)

# Test URL
url <- 'https://www.fonewalls.com/1080x2400-wallpapers/2/'

# Set D/L Resolution
res <- "1080x2400"   # Oppo a96/ Ulefone Resolution
#res <- "3840x1080"   # Dual Screen Resolution
#res <- "3440x1440"

rip_url <- function(url){
  webpage  <- read_html(url)
  image_list  <- html_nodes(webpage,'.size-thumbnail')
  thumbs <- xml_attr(image_list,'src')
  return(data.frame(thumbnail=thumbs))
}

#  Get list of image pages from Start to Stop

start <- 1
#stop  <- 5
stop  <- 62 # Total for 1080x2400

if (file.exists(paste0(PROJECT_DIR,"/fonewalls-",res,".RData"))){
  load(paste0(PROJECT_DIR,"/fonewalls-",res,".RData"))  # Load the data file if it exists
} else {
  fonewalls <- rip_url(paste0('https://fonewalls.com/categories/all/1080x2400/popular?page=1'))  # Initialise with  first page
}

cume <- 0

for (i in start:stop){
  before <- nrow(fonewalls)
  url <- paste0('https://www.fonewalls.com/',res,'-wallpapers/',i,'/')
  cat(paste("Ripping page",i,"of",stop,"url",url))
  thumbs <- tryCatch({rip_url(url)},error=function(e){}) 
  fonewalls <- rbind(fonewalls,thumbs) %>% unique() %>% arrange(thumbnail)
  after <- nrow(fonewalls)
  added <- after-before
  cume <- cume+added
  cat(paste(" Added",added,"images, cume",cume,'\n'))
}

save(fonewalls,file=paste0(PROJECT_DIR,"/fonewalls-",res,".RData"))

# Download the files 
for (i in 1:nrow(fonewalls)){
  dir.create(paste0(FILE_DIR,"/",res),showWarnings = FALSE)
  link <- str_remove(fonewalls$thumbnail[i],'-300x667')
  # Get the name of the image being downloaded
  image_name <- tail(strsplit(link,'[/]')[[1]],1)

  if (file.exists(paste0(FILE_DIR,"/",res,"/",image_name))){
    print(paste("File",paste0(FILE_DIR,"/",image_name),"Already Exists"))
  } else{
    cat(paste("downloading file",i,"of",nrow(fonewalls),image_name))
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
