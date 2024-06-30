# Manga4Life rips.
#
# Another online Manga web site is Manga4life
# Web site:  https://manga4life.com/
# Mangas:  https://manga4life.com/manga/Nausica-of-the-Valley-of-the-Wind
# Manga Pages: https://manga4life.com/read-online/Nausica-of-the-Valley-of-the-Wind-chapter-1-page-1.html
#
# Some issues: 
#   Some manga skip chapters (no Tonikaku Kawaii chapter 168)
#   Incrementing numbers misses special chapters (chapter n.5)
#   Different manga have different image host address.  Some have more than one.

library(rvest)
library(dplyr)
library(xml2)
library(stringr)
library(tidyRSS)

PROJECT_DIR <- "c:/R/Webrip/Manga4Life"
BOOK_DIR    <- "f:/books/comics/Manga4Life"

manga4rip <- function(manga){
  FILE_DIR    <- paste0(PROJECT_DIR,"/",manga)
  dir.create(PROJECT_DIR, showWarnings = FALSE)  # Create directory if it doesn't exist
  dir.create(FILE_DIR,    showWarnings = FALSE)  # Create directory if it doesn't exist
  
  homepage <- paste0('https://manga4life.com/manga/',manga)
  rss <- paste0('https://manga4life.com/rss/',manga,'.xml')
  feed <- tidyfeed(rss,parse_dates = FALSE)
  # Get the list of chapters from the feed
  chapters <- feed %>% 
    select(item_title,item_link) %>% 
    mutate(chapter = word(item_title,-1),
           chap_num=as.numeric(chapter)) %>%
    arrange(chap_num)
  # Identify downloaded Chapters
  images = list.files(FILE_DIR)
  saved = as.numeric(word(images,1,sep="-")) %>% unique()
  unsaved = chapters$chap_num[!(chapters$chap_num %in% saved)]
  # Filter against unsaved
  chapters <- chapters %>% filter(chap_num %in% unsaved)
  hosts <- c('hot.leanbox.us','official.lowee.us','scans-hot.leanbox.us','scans.lastation.us','temp.compsci88.com')
  if (nrow(chapters)>0){
    for (i in seq(1:nrow(chapters))){
      print(paste("Page #",i,"link=",chapters$item_link[i]))
      # Get list of chapters from web site
      chapter <- chapters$chapter[i]
      pad=""
      if(as.numeric(chapter) <1000) pad ="0"
      if(as.numeric(chapter) <100) pad ="00"
      if(as.numeric(chapter) <10) pad ="000"
      for (host in hosts){
        page <- 1
        last_page <- FALSE
        #Images have a standard URL structure - no need to read the page to find it out once the host is known
        while (last_page==FALSE){
          file_name <- paste0(pad,chapter,'-',str_pad(page,3,pad='0'),'.png')
          url <- paste0('https://',host,'/manga/',manga,'/',file_name)
          if (file.exists(paste0(FILE_DIR,"/",file_name))){
            # print(paste("File",file_name,"already exists"))
          } else {
            print(paste("Downloading",manga,"Chapter",chapter,"page",page))
            t <- try({download.file(url,
                                    paste0(FILE_DIR,"/",file_name),
                                    quiet=TRUE, mode="wb")}, silent = TRUE )
            if("try-error" %in% class(t)) last_page <- TRUE
          }
          if (page==1 & last_page) last_chapter <- TRUE 
          page <- page+1
        }
      }
    }
  }
  
  # Chapter check - check which chapters have been downloaded.
  images = list.files(FILE_DIR)
  # Identify downloaded Chapters
  saved = as.numeric(word(images,1,sep="-")) %>% unique()
  unsaved = chapters$chap_num[!(chapters$chap_num %in% saved)]
  if (length(unsaved)>0) print(paste("Chapters not downloaded:",unsaved))
  
}

manga4check <- function(manga){
  FILE_DIR    <- paste0(PROJECT_DIR,"/",manga)
  dir.create(PROJECT_DIR, showWarnings = FALSE)  # Create directory if it doesn't exist
  dir.create(FILE_DIR,    showWarnings = FALSE)  # Create directory if it doesn't exist
  rss <- paste0('https://manga4life.com/rss/',manga,'.xml')
  feed <- tidyfeed(rss,parse_dates = FALSE)
  # Get the list of chapters from the feed
  chapters <- feed %>% 
    select(item_title,item_link) %>% 
    mutate(chapter = word(item_title,-1),
           chap_num=as.numeric(chapter)) %>%
    arrange(chap_num)
  # Identify downloaded Chapters
  images = list.files(FILE_DIR)
  saved = as.numeric(word(images,1,sep="-")) %>% unique()
  unsaved = chapters$chap_num[!(chapters$chap_num %in% saved)]
  # Filter against unsaved
  chapters <- chapters %>% filter(chap_num %in% unsaved)
  if (length(unsaved)==0) print(paste("All Chapters of",manga,"have been downloaded"))
  if (length(unsaved)>0) paste(c("Chapters of",manga,"not downloaded:",unsaved),collapse=" ")
}

manga4zip <- function(manga,per_vol=5){
  FILE_DIR <- paste0(PROJECT_DIR,"/",manga)
  SAVE_DIR <- paste0(BOOK_DIR,"/",manga)
  dir.create(SAVE_DIR, showWarnings = FALSE)  # Create directory if it doesn't exist
  # Get list of files
  images = list.files(FILE_DIR)
  # Identify Chapters
  chapters = as.numeric(word(images,1,sep="-"))
  volumes = ceiling(chapters/per_vol)
  # Assign chapter 0 to volume 1
  volumes[volumes==0] <- 1
  # Zip chapters into volumes based on the breaks
  for (volume in 1:max(volumes)){
    zipfile <- paste0(SAVE_DIR,"/",manga,"-",str_pad(volume,2,pad="0"),".cbz")
    print(paste(manga,"Volume",volume,"of",max(volumes),"file =",zipfile))
    zip::zip(zipfile,images[volumes==volume],root=FILE_DIR)
  }
}

# Rip 'em
manga4rip('Kumo-Desu-Ga-Nani-Ka') # So I'm a Spider, so what
manga4rip('The-Invisible-Man-and-His-Soon-toBe-Wife')
manga4rip('Spy-X-Family')
manga4rip('Mahou-Tsukai-No-Yome') # The Ancient Magus Bride
manga4rip('Tonikaku-Kawaii')      # Fly Me to the Moon
manga4rip('One-Piece')

# Check 'em
manga4check('Kumo-Desu-Ga-Nani-Ka') # So I'm a Spider, so what
manga4check('The-Invisible-Man-and-His-Soon-toBe-Wife')
manga4check('Spy-X-Family')
manga4check('Mahou-Tsukai-No-Yome') # The Ancient Magus Bride
manga4check('Tonikaku-Kawaii')      # Fly Me to the Moon
manga4check('One-Piece')

# Zip 'em
manga4zip('Kumo-Desu-Ga-Nani-Ka') # So I'm a Spider, so what
manga4zip('The-Invisible-Man-and-His-Soon-toBe-Wife')
manga4zip('Spy-X-Family')
manga4zip('Mahou-Tsukai-No-Yome') # The Ancient Magus Bride
manga4zip('Tonikaku-Kawaii')      # Fly Me to the Moon
manga4zip('One-Piece')
