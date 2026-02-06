#  HDQ Wallpapers 
# Another wallpapers ripper, this time of the HDQ Walls web site.
# Writing this one so as to get wallapers for my phone (resolution 1080x2400)
# This looks like it would be amenable to the same treatment as wallpaperscraft and wallpaperswide
# 
# Sample wallpaper:
# https://images.hdqwalls.com/download/superman-icon-of-justice-kn-1080x2400.jpg
#
# Does not work - get "Forbidden (HTTP 403)" error.
# Would it work in Python?

library(rvest)
library(httr)
library(dplyr)
library(xml2)
library(stringr)
library(tidyr)
library(data.table)

PROJECT_DIR <- "c:/R/Webrip"
FILE_DIR    <- "h:/pictures/wallpapers"
dir.create(FILE_DIR,showWarnings = FALSE)

# Test URL
url <- 'https://hdqwalls.com/1080x2400-resolution-wallpapers/page/2'

# Set D/L Resolution
res <- "1080x2400"   # Oppo a96/ Ulephone 30 Pro Resolution.  

rip_url <- function(url){
  x <- GET(url, add_headers('user-agent' = 'Private use data scraper'))
  webpage  <- read_html(x)
  image_list  <- html_nodes(webpage,'.wallpapers_container')
  thumbs <- xml_attr(image_list,'src')
  return(data.frame(thumbnail=thumbs))
}

#  Get list of image pages from Start to Stop

start <- 1
#stop  <- 10
#stop  <- 126 # Total for A96 
#stop  <- 840 # for dual screen As at 12/12/2025 
stop <- 6939 # for res = 1080x2400

if (file.exists(paste0(PROJECT_DIR,"/wallpaperswide-",res,".RData"))){
  load(paste0(PROJECT_DIR,"/wallpaperswide-",res,".RData"))  # Load the data file if it exists
} else {
  #  wallpaperswide <- rip_url('https://wallpaperswide.com/3840x1080-wallpapers-r/page/1')  # Initialise with  first page
  wallpaperswide <- rip_url(paste0('https://wallpaperswide.com/',res,'-wallpapers-r/page/1'))  # Initialise with  first page
}

cume <- 0

for (i in start:stop){
  before <- nrow(wallpaperswide)
  #  url <- paste0('https://wallpaperswide.com/page/',i)
  url <- paste0('https://wallpaperswide.com/',res,'-wallpapers-r/page/',i)
  cat(paste("Ripping page",i,"of",stop,"url",url))
  thumbs <- tryCatch({rip_url(url)},error=function(e){}) 
  wallpaperswide <- rbind(wallpaperswide,thumbs) %>% unique() %>% arrange(thumbnail)
  after <- nrow(wallpaperswide)
  added <- after-before
  cume <- cume+added
  cat(paste(" Added",added,"images, cume",cume,'\n'))
}

save(wallpaperswide,file=paste0(PROJECT_DIR,"/wallpaperswide-",res,".RData"))

# Filter list for the desired resolution?

# create image links
links <- wallpaperswide %>% 
  separate(col=thumbnail,
           into = c("var1","var2","var3","var4","image_name"),
           sep="/") %>%
  mutate(image_name=sub('t1',res,image_name),
         link=paste0('https://wallpaperswide.com/download/',image_name) ) %>% select(link)

keywords <- "(moon|earth|space|rocket|star|planet|mars|robot|scifi|frog)"

selected <- subset(links, grepl(pattern= keywords, link))

write.table(selected,paste0(PROJECT_DIR,'/wallpaperswidesubset.txt'),col.names = F, row.names=F, quote=F)

# Download
# Download the files 
for (i in 1:nrow(wallpaperswide)){
  dir.create(paste0(FILE_DIR,"/",res),showWarnings = FALSE)
  thumbnail <- wallpaperswide$thumbnail[i]
  # Get the address for the resolution we want
  image_name <- strsplit(thumbnail,'[/]')[[1]][5]
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

# Purge the Downloaded files for those that are too small

filelist <- list.files(path = paste0(FILE_DIR,"/",res), full.names = TRUE )
summary(file.size(filelist))
hist(file.size(filelist))

smallfiles <- filelist[file.size(filelist) < 120000]
# file.remove(smallfiles)
