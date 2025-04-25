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
library(tidyr)
library(data.table)

PROJECT_DIR <- "c:/R/Webrip"
#FILE_DIR    <- "c:/R/Webrip/wallpaperscraft"
FILE_DIR    <- "f:/pictures/wallpaperscraft"
dir.create(FILE_DIR,showWarnings = FALSE)

# Stage 1: Page through the list
# Pages of type: https://wallpaperscraft.com/all/page2

start <- 1
# stop  <- 9345 # As at 06/07/2023
# stop  <- 9840 # As at 26/06/2024
stop  <- 10042 # As at 23/04/2025

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

cume <- 0

for (i in stop:start){
  before <- nrow(wallpaperscraft)
  url <- paste0('https://wallpaperscraft.com/all/page',i)
  cat(paste("Ripping page",i,"url",url))
  thumbs <- tryCatch({rip_url(url)},error=function(e){}) 
  wallpaperscraft <- rbind(wallpaperscraft,thumbs) %>% unique()
  after <- nrow(wallpaperscraft)
  added <- after-before
  cume <- cume+added
  cat(paste(" Added",added,"images, cume",cume,'\n'))
}

save(wallpaperscraft,file=paste0(PROJECT_DIR,"/wallpaperscraft.RData"))

# Filter unwanted files
# Context: I am not interested in car pictures

file_names <- wallpaperscraft %>% 
  separate_wider_delim(thumbnail,delim="/",names=c("http","blank","url","image","single","file_name"),too_few="align_end") %>%
  select("file_name")
wall_names <- cbind(wallpaperscraft,file_names)

full_keys <- wall_names %>% separate_wider_delim(file_name,
                                                 delim="_",
                                                 names=c("key1","key2","key3","key4","key5","key6","key7","key8","key9","key10","key11","key12","image_id","res"),
                                                 too_few="align_end",too_many="drop")

full_melt  <- melt(full_keys %>% select(thumbnail:key12),id="thumbnail",value.name="keyword",na.rm=TRUE) %>% arrange(thumbnail)

full_key_count <- full_melt %>% count(keyword) %>% arrange(-n) %>% filter(n>1)

# List of keywords to purge from the files
keywords <- c("car","motorcycle","motorcycles","aston","martin","bmw","acura","sports","bike","porsche",
              "audi","lamborghini","motorcyclist","cars","ferrari","mercedes","nissan",
              "v8","auto","chevrolet","suv","mustang","toyota","honda","ford","mercedesbenz",
              "mclaren","volkswagen","jeep","sportscar","yamaha","mazda","dodge","gtr",
              "bentley","corvette","rdx","bugatti","benz","v12","maserati","lincoln",
              "concept","lexus","hyundai","mitsubishi",
              "plymouth","chevy","convertible","abarth","speedster","volvo","maybach","fiat",
              "etype","ftype","camaro")

del_files <- full_melt %>% filter(keyword %in% keywords) %>% select(thumbnail) %>% unique() 

wall_filtered <- wall_names %>% anti_join(del_files,by="thumbnail")

# Add image ID number and sort on this column
wall_filtered <- wall_filtered %>% 
  separate_wider_delim(file_name,delim="_",
                       names=c("key1","key2","key3","key4","key5","key6","key7","key8","key9","key10","key11","key12","image_id","res"),
                       too_few="align_end",too_many="drop") %>%
  mutate(image_id = as.numeric(image_id)) %>%
  arrange(image_id) %>%
  select(thumbnail,image_id)
  
# Resolution
res <- "1080x1920"  # Phone Resolution
# res <- "1920x1200"  # tablet resolution
# res <- "1920x1080"  # hi-res resolution
# res <- "2160x1620"  # iPad resolution

# Download the files (in reverse order to get the new ones first.)
for (i in nrow(wall_filtered):1){
  thumbnail <- wall_filtered$thumbnail[i]
  # Get the address for the resolution we want
  image_res <- paste0(strtrim(wall_filtered$thumbnail[i],nchar(wall_filtered$thumbnail[i])-11),res,".jpg")  
  image_name <- strsplit(image_res,'[/]')
  image_name <- image_name[[1]][length(image_name[[1]])]
  
  if (file.exists(paste0(FILE_DIR,"/",res,"/",image_name))){
    #print(paste("File",paste0(FILE_DIR,"/",image_name),"Already Exists"))
  } else{
    cat(paste("downloading file",i,"of",nrow(wall_filtered),image_name))
    tryCatch({download.file(image_res,
                  paste0(FILE_DIR,"/",res,"/",image_name),
                  quiet=TRUE, mode="wb")},error=function(e){cat(' - Remote File Does not Exist')})
    cat('\n')
  }
}
