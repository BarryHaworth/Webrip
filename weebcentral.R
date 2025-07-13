# Manga4Life rips.
#
# Another online Manga web site is Manga4life
# Web site:  https://manga4life.com/
# New WEb site https://weebcentral.com/
# Mangas:  https://manga4life.com/manga/Nausica-of-the-Valley-of-the-Wind
# Manga Pages: https://manga4life.com/read-online/Nausica-of-the-Valley-of-the-Wind-chapter-1-page-1.html
#
# Some issues: 
#   Some manga skip chapters (no Tonikaku Kawaii chapter 168)
#   Incrementing numbers misses special chapters (chapter n.5)
#   Different manga have different image host address.  Some have more than one.
# Update 05/08/2024
#   Added check to only update cbz files if the images were newer than the file
# Update 04/02/2025
#   Web site has changed.  Will have to redo this.
# New web site:  https://weebcentral.com/

library(rvest)
library(dplyr)
library(xml2)
library(stringr)
library(tidyRSS)

PROJECT_DIR <- "c:/R/Webrip/Manga4Life"
BOOK_DIR    <- "g:/books/comics/Manga4Life"

# test
manga <-'Spy-X-Family'
home <-'https://weebcentral.com/series/01J76XYCYJ0P680SKX3QZ0NQD7'

manga4rip <- function(manga,rss){
  FILE_DIR    <- paste0(PROJECT_DIR,"/",manga)
  dir.create(PROJECT_DIR, showWarnings = FALSE)  # Create directory if it doesn't exist
  dir.create(FILE_DIR,    showWarnings = FALSE)  # Create directory if it doesn't exist
  
  homepage <- home
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
  hosts <- c('hot.leanbox.us','official.lowee.us','scans-hot.leanbox.us',
             'scans.lastation.us','temp.compsci88.com','scans-hot.planeptune.us')
  urlstrings <- c('/','/Mag-Official/')
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
        for (urlstring in urlstrings){
          page <- 1
          last_page <- FALSE
          #Images have a standard URL structure - no need to read the page to find it out once the host is known
          while (last_page==FALSE){
            file_name <- paste0(pad,chapter,'-',str_pad(page,3,pad='0'),'.png')
            url <- paste0('https://',host,'/manga/',manga,urlstring,file_name)
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

manga4life <- function(manga,home){
  manga4rip(manga,home)
  manga4zip(manga)
}


# Rip 'em
# Gotta Catch 'em all

manga4life('Spy-X-Family','https://weebcentral.com/series/01J76XYCYJ0P680SKX3QZ0NQD7/rss')

manga4life('Akuyaku-Reijou-Tensei-Oji-san','https://weebcentral.com/series/01J76XYDV4HW5A58SY3V7X8CNJ/rss') # Middle Aged Villainess
manga4life('One-Piece','https://weebcentral.com/series/01J76XY7E9FNDZ1DBBM6PBJPFK/rss')

manga4life('Mahou-Tsukai-No-Yome','https://weebcentral.com/series/01J76XYA4AVQG9FK53NGCE8FW6/rss') # The Ancient Magus Bride
manga4life('Mob-Psycho100','https://weebcentral.com/series/01J76XY9WY1HW989FW5G9ZYE9G/rss')
manga4life('Made-In-Abyss','https://weebcentral.com/series/01J76XYC5Q6HXQV8A3W4A0KVKN/rss')
manga4life('Monster-8','https://weebcentral.com/series/01J76XYDNXNEJ72V8B63390CNT/rss')  # Kaiju No 8
manga4life('The-Invisible-Man-and-His-Soon-toBe-Wife','https://weebcentral.com/series/01J76XYG0GCHNTGDDNSQZPXKPT/rss')
manga4life('Tonikaku-Kawaii','https://weebcentral.com/series/01J76XYCFK6GNRF6H17BZTKH2K/rss')          # Fly Me to the Moon
manga4life('Zetman','https://weebcentral.com/series/01J76XY7FR7KTEF8CK9VY6VXGC/rss')
manga4life('Ratman','https://weebcentral.com/series/01J76XY7NM74C6R63XGB8Y8MFM/rss')
manga4life('Heroic-Complex','https://weebcentral.com/series/01J76XYE53DNAW4JQF40613HQP/rss')
manga4life('SHY','https://weebcentral.com/series/01J76XYDXQGMXT06B1923YPVFC/rss')
manga4life('Deadpool-Samurai','https://weebcentral.com/series/01J76XYECDYP63HB480B0RJS0D/rss')
manga4life('Zannen-Jokanbu-Black-General-san','https://weebcentral.com/series/01J76XYBZ42J830YYVAFHBQGQW/rss')
manga4life('Ranger-Reject','https://weebcentral.com/series/01J76XYED6E0G8RYGGFDQ4EZTG/rss')
manga4life('Boku-No-Hero-Academia','https://weebcentral.com/series/01J76XYAE4S59RVPJETN0MFRX5/rss')

manga4life('Chainsaw-Man','https://weebcentral.com/series/01J76XYCRVY3QGYAMRR3STW941/rss')
manga4life('Dandadan','https://weebcentral.com/series/01J76XYEMWA55C7XTZHP1HNARM/rss')
manga4life('Onepunch-Man','https://weebcentral.com/series/01J76XY7KT7J224EBK6J816Y1Q/rss')
manga4life('The-Reason-Why-Raeliana-Ended-Up-at-the-Dukes-Mansion','https://weebcentral.com/series/01J76XYDMXD0HR73A27J6ECMV1/rss')
manga4life('Tongari-Booshi-No-Atorie','https://weebcentral.com/series/01J76XYC2K8QWFZZRYYCZMN6EF/rss') # Witch Hat Atelier
manga4life('Villainess-Level-99','https://weebcentral.com/series/01J76XYE073B0B89TZEJ7GPBKB/rss')

manga4life('Re-Living-My-Life-with-a-Boyfriend-Who-Doesnt-Remember-Me','https://weebcentral.com/series/01J76XYHD3MGVE4MNGR8XENEJY/rss')

manga4life('Doctor-Elise-The-Royal-Lady-with-the-Lamp','https://weebcentral.com/series/01J76XYESG3PBRHZ3TQSVM9EBX/rss')
manga4life('Gate-Jietai-Kare-No-Chi-Nite-Kaku-Tatakeri','https://weebcentral.com/series/01J76XYA7P8A1RP79MW02JWWW8/rss')

manga4life('The-One-Within-the-Villainess','https://weebcentral.com/series/01J76XYGM7VD5ZCX1EQWN4Q9E3/rss')

manga4life('Jishou-Akuyaku-Reijou-Na-Konyakusha-No-Kansatsu-Kiroku','https://weebcentral.com/series/01J76XYCVKVN778QDA1N86GYW8/rss')

# manga4life('Bokurano')
# manga4life('Bonnouji')
# manga4life('Dungeon-Meshi')
# manga4life('Gaikotsu-Kishi-sama-Tadaima')  # Skeleton Knight in Another World
# manga4life('Handyman-Saitou-In-Another-World')
# manga4life('I-Was-A-Sword-When-I-Reincarnated')
# manga4life('Kaguya-Wants-To-Be-Confessed-To')  # Kaguya-sama  - Love is War
# manga4life('Kekkon-Surutte-Hontou-desu-ka-365-Days-to-the-Wedding')
# manga4life('Kill-La-Kill')
# manga4life('Kimi-No-Na-Wa')  # Your Name
# manga4life('Kumo-Desu-Ga-Nani-Ka') # So I'm a Spider, so what
# manga4life('Kumo-Desu-ga-Nani-ka-Daily-Life-of-the-Four-Spider-Sisters')
# manga4life('Look-Back')
# manga4life('Lv2-kara-Cheat-datta-Moto-Yuusha-Kouho-no-Mattari-Isekai-Life')
# manga4life('Moon-Led-Journey-Across-Another-World')  # Moonlit Fantasy
# manga4life('Neon-Genesis-Evangelion')
# manga4life('Planetes')
# manga4life('Reincarnated-as-a-Sword-Another-Wish')
# manga4life('Re-Zero-Kara-Hajimeru-Isekai-Seikatsu-Daiisshou-Outo-No-Ichinichi-Hen') # Re Zero Chapter 1
# manga4life('Re-Zero-Kara-Hajimeru-Isekai-Seikatsu')                                 # Re Zero Chapter 2
# manga4life('Re-Zero-Kara-Hajimeru-Isekai-Seikatsu-Daisanshou-Truth-Of-Zero')        # Re Zero Chapter 3
# manga4life('ReZero-kara-Hajimeru-Isekai-Seikatsu-Daiyonshou-Seiiki-to-Gouyoku-no-Majou') # Re Zero Chapter 4
# manga4life('ReZERO-Starting-Life-in-Another-World-The-Frozen-Bond')
# manga4life('S-rank-Monster-No-Behemoth-Dakedo')
# manga4life('Solo-Leveling')
# manga4life('Solo-Leveling-Ragnarok')
# manga4life('Solo-Leveling-Volume-Version')
# manga4life('Steins-Gate')
# manga4life('Uzumaki')
# 
# manga4life('Kimi-Ni-Todoke') # From Me to You
# manga4life('The-Dark-Magician-Transmigrates-After-66666-Years')
# 
# manga4life('Spider-Man')
# manga4life('Spider-Man-Fake-Red')
# manga4life('Star-Wars-The-Mandalorian')
# manga4life('Star-Wars-Visions-The-Manga-Anthology')
# 
# #manga4life('Seijo-no-Maryoku-wa-Bannou-Desu')
# #manga4life('The-Saints-Magic-Power-is-Omnipotent-The-Other-Saint')
# 
# manga4life('Tensei-Shitara-dai-Nana-Ouji-dattanode-Kimamani-Majutsu-o-Kiwamemasu')
# manga4life('The-Mage-Will-Master-Magic')
# 
# manga4life('Boku-Dake-Ga-Inai-Machi')

# Update the remote Books
system2("C:/Program Files/FreeFileSync/Bin/FreeFileSync_x64.exe",
        "C:/Users/barry/Documents/Book_sync.ffs_batch",
        wait=FALSE, invisible=FALSE)
