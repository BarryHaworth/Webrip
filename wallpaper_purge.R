# WallpapersCraft
# Program to manage wallpater files downloaded from 
# the https://wallpaperscraft.com/ web site
# and manage a subset of these files to load onto my table
# This program purges selected keywords from the downloaded files
# Context: I am not interested in car pictures

library(dplyr)
library(tidyr)
library(stringr)
library(data.table)

PROJECT_DIR <- "c:/R/Webrip"
PICTURE_DIR <- "e:/wallpaperscraft/1920x1200"
#PICTURE_DIR <- "e:/wallpaperscraft/1920x1200 subset"
#PICTURE_DIR <- "e:/wallpaperscraft/1920x1080"
#PICTURE_DIR <- "e:/wallpaperscraft/1080x1920"

dir_list <- c("e:/wallpaperscraft/1920x1200",
              "e:/wallpaperscraft/1920x1200 subset",
              "e:/wallpaperscraft/1920x1080",
              "e:/wallpaperscraft/1080x1920",
              "f:/Pictures/wallpaperscraft/1920x1200",
              "f:/Pictures/wallpaperscraft/1920x1200 subset",
              "f:/Pictures/wallpaperscraft/1920x1080",
              "f:/Pictures/wallpaperscraft/1080x1920")

for (PICTURE_DIR in dir_list){
  print(paste("Purging directory",PICTURE_DIR))
  # Read the contents of the full directory and the subset directory
  full_list <- data.frame(file=list.files(PICTURE_DIR))
  #  Identify Keywords in both directories, in particular those not in the subset
  full_keys <- full_list %>% separate(file,c("key1","key2","key3","key4","key5","key6","key7","key8","key9","key10"),sep="_")
  full_keys <- cbind(full_list,full_keys)
  full_melt  <- melt(full_keys,id=1,value.name="keyword",na.rm=TRUE) %>% 
    select(-"variable") %>% filter(keyword != "1920x1200.jpg") %>% arrange(file)
  
  full_key_count <- full_melt %>% count(keyword) %>% arrange(-n) %>% filter(n>1)
  
  # List of keywords to purge from the files
  keywords <- c("car","motorcycle","aston","martin","bmw","acura","sports","bike","porsche",
                "audi","lamborghini","motorcyclist","cars","ferrari","mercedes","nissan",
                "v8","auto","chevrolet","suv","mustang","toyota","honda","ford","mercedesbenz",
                "mclaren","volkswagen","jeep","sportscar","yamaha","mazda","dodge",
                "bentley","corvette","rdx","bugatti","benz","v12","maserati","lincoln",
                "plymouth","chevy","convertible","abarth","speedster","volvo","maybach","fiat",
                "etype","ftype","camaro")
  
  del_files <- full_melt %>% filter(keyword %in% keywords) %>% select(file) %>% unique() 
  
  del_list <- list.files(PICTURE_DIR)[list.files(PICTURE_DIR) %in% del_files$file]
  print(paste("Removing",length(del_list),"out of",nrow(full_list),"files"))
  file.remove(paste0(PICTURE_DIR,"/",del_list))
}
