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
# Update 05/08/2024
#   Added check to only update cbz files if the images were newer than the file

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
  max_chap <- max(as.numeric(chapters$chapter))
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
            print(paste("Downloading",manga,"Chapter",chapter,"of",max_chap,"page",page))
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
  } else {
    print(paste("All Chapters of",manga,"have been downloaded"))
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
  setwd(FILE_DIR)
  images = list.files()
  images_ds <- file.info(images)
  # Identify Chapters
  chapters = as.numeric(word(images,1,sep="-"))
  volumes = ceiling(chapters/per_vol)
  # Assign chapter 0 to volume 1
  volumes[volumes==0] <- 1
  images_ds$chapter <- chapters
  images_ds$volume <- volumes
  # Zip chapters into volumes based on the breaks
  for (volume in 1:max(volumes)){
    image_date <- max(images_ds$mtime[images_ds$volume==volume])
    zipfile <- paste0(SAVE_DIR,"/",manga,"-",str_pad(volume,2,pad="0"),".cbz")
    if (file.exists(zipfile)){zip_date <- file.info(zipfile)$mtime} else {zip_date<-0}
    if (image_date>zip_date){
      print(paste("Zipping",manga,"Volume",volume,"of",max(volumes),"file =",zipfile))
      zip::zip(zipfile,images[volumes==volume],root=FILE_DIR)
    } else {
      #print(paste(manga,"Volume",volume,"of",max(volumes),"file =",zipfile,"Up to date"))
    }
  }
}

manga4life <- function(manga){
  manga4rip(manga)
  manga4zip(manga)
}


# Rip 'em
# Gotta Catch 'em all
#manga4life('Tengen-Toppa-Gurren-Lagann')
manga4life('Akuyaku-Reijou-Tensei-Oji-san')
manga4life('Boku-No-Hero-Academia')
manga4life('Bokurano')
manga4life('Bonnouji')
manga4life('Chainsaw-Man')
manga4life('Dungeon-Meshi')
manga4life('Gaikotsu-Kishi-sama-Tadaima')  # Skeleton Knight in Another World
manga4life('Handyman-Saitou-In-Another-World')
manga4life('I-Was-A-Sword-When-I-Reincarnated')
manga4life('Kaguya-Wants-To-Be-Confessed-To')  # Kaguya-sama  - Love is War
manga4life('Kekkon-Surutte-Hontou-desu-ka-365-Days-to-the-Wedding')
manga4life('Kill-La-Kill')
manga4life('Kimi-No-Na-Wa')  # Your Name
manga4life('Kumo-Desu-Ga-Nani-Ka') # So I'm a Spider, so what
manga4life('Kumo-Desu-ga-Nani-ka-Daily-Life-of-the-Four-Spider-Sisters')
manga4life('Look-Back')
manga4life('Lv2-kara-Cheat-datta-Moto-Yuusha-Kouho-no-Mattari-Isekai-Life')
manga4life('Made-In-Abyss')
manga4life('Mahou-Tsukai-No-Yome') # The Ancient Magus Bride
manga4life('Mob-Psycho100')
manga4life('Monster-8')  # Kaiju No 8
manga4life('Moon-Led-Journey-Across-Another-World')  # Moonlit Fantasy
manga4life('Neon-Genesis-Evangelion')
manga4life('One-Piece')
manga4life('Onepunch-Man')
manga4life('Planetes')
manga4life('Reincarnated-as-a-Sword-Another-Wish')
manga4life('Re-Zero-Kara-Hajimeru-Isekai-Seikatsu-Daiisshou-Outo-No-Ichinichi-Hen') # Re Zero Chapter 1
manga4life('Re-Zero-Kara-Hajimeru-Isekai-Seikatsu')                                 # Re Zero Chapter 2
manga4life('Re-Zero-Kara-Hajimeru-Isekai-Seikatsu-Daisanshou-Truth-Of-Zero')        # Re Zero Chapter 3
manga4life('ReZero-kara-Hajimeru-Isekai-Seikatsu-Daiyonshou-Seiiki-to-Gouyoku-no-Majou') # Re Zero Chapter 4
manga4life('ReZERO-Starting-Life-in-Another-World-The-Frozen-Bond')
manga4life('Solo-Leveling')
manga4life('Solo-Leveling-Ragnarok')
manga4life('Solo-Leveling-Volume-Version')
manga4life('Spy-X-Family')
manga4life('Steins-Gate')
manga4life('The-Invisible-Man-and-His-Soon-toBe-Wife')
manga4life('The-Reason-Why-Raeliana-Ended-Up-at-the-Dukes-Mansion')
manga4life('Tongari-Booshi-No-Atorie') # Witch Hat Atelier
manga4life('Tonikaku-Kawaii')          # Fly Me to the Moon
manga4life('Uzumaki')
manga4life('Villainess-Level-99')

# Update the remote Books
system2("C:/Program Files/FreeFileSync/Bin/FreeFileSync_x64.exe",
        "C:/Users/barry/Documents/Book_sync.ffs_batch",
        wait=FALSE, invisible=FALSE)
