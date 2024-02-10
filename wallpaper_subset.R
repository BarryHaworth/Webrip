# WallpapersCraft
# Program to manage wallpaper files downloaded from 
# the https://wallpaperscraft.com/ web site
# and manage a subset of these files to load onto my tablet

library(dplyr)
library(tidyr)
library(stringr)
library(data.table)

PROJECT_DIR <- "c:/R/Webrip"
FULL_DIR    <- "e:/wallpaperscraft/1920x1200"
SUB_DIR     <- "e:/wallpaperscraft/1920x1200 subset"

# Read the contents of the full directory and the subset directory

full_list <- data.frame(file=list.files(FULL_DIR))
sub_list  <- data.frame(file=list.files(SUB_DIR))

#  Identify Keywords in both directories, in particular those not in the subset

full_keys <- full_list %>% separate(file,c("key1","key2","key3","key4","key5","key6","key7","key8","key9","key10"),sep="_")
full_keys <- cbind(full_list,full_keys)
full_melt  <- melt(full_keys,id=1,value.name="keyword",na.rm=TRUE) %>% 
              select(-"variable") %>% filter(keyword != "1920x1200.jpg") %>% arrange(file)

sub_keys  <- sub_list %>% separate(file,c("key1","key2","key3","key4","key5","key6","key7","key8","key9","key10"),sep="_")
sub_keys  <- cbind(sub_list,sub_keys)
sub_melt  <- melt(sub_keys,id=1,value.name="keyword",na.rm=TRUE) %>% 
             select(-"variable") %>% filter(keyword != "1920x1200.jpg") %>% arrange(file)

full_key_count <- full_melt %>% count(keyword) %>% arrange(-n) %>% filter(n>1)
sub_key_count  <- sub_melt  %>% count(keyword) %>% arrange(-n) %>% filter(n>1)

compare <- full_key_count %>% rename(full_n=n) %>% 
           full_join(sub_key_count %>% rename(sub_n=n)) %>% 
           replace(is.na(.), 0) %>%
           mutate(delta=full_n-sub_n, sub_pct=sub_n/full_n) %>%
           arrange(delta,desc=TRUE) %>%
           filter(full_n>1)  

# Identify a list of keywords to copy.
# There are 92838 files in total, and so far I have 13724 (4.2 GB)
# Want to increase to 10GB => 32,000 files (another ~19,000)

# Partial

fraction <- 0.699
compare %>% filter(sub_pct<1 & sub_pct>fraction)
keywords <- compare %>% filter(sub_pct<1 & sub_pct>fraction) %>% select(keyword)
keywords <- as.vector(keywords$keyword)

# Given a list of keywords, copy files from full to subset
#keywords <- c("trees","tree","forest","mountains","flowers","bouquet","sky","sunset")
#keywords <- c("stars","planet","kaleidoscope","planets","satellite","eclipse","asteroids")
# keywords <- c("rose","flower","mountain","coffee","abstraction","blur")
# keywords <- c("sea","flower","leaves")
# keywords <- c("future","koala","koalas","lines","line")
# keywords <- c("sun","sunny","sunrise","sunlight")

new_files <- full_melt %>% filter(keyword %in% keywords) %>% select(file) %>% unique() %>% anti_join(sub_list)

new_list <- list.files(FULL_DIR)[list.files(FULL_DIR) %in% new_files$file]

file.copy(from=paste0(FULL_DIR,"/",new_list),to=paste0(SUB_DIR,"/"))
