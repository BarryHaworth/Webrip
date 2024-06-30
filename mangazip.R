#  Manga Zip
#
# Takes the Manga images downloaded by the mangaonline program
# and zips them into cbz files
# Files are grouped into volumes of five chapters each

library(zip)
library(dplyr)
library(stringr)

PROJECT_DIR <- "c:/R/Webrip/Manga"
BOOK_DIR    <- "f:/books/comics/MangaRips"

mangazip <- function(filename,per_vol=5){
  FILE_DIR <- paste0(PROJECT_DIR,"/",filename)
  SAVE_DIR <- paste0(BOOK_DIR,"/",filename)
  dir.create(SAVE_DIR, showWarnings = FALSE)  # Create directory if it doesn't exist
  # Get list of files
  images = list.files(FILE_DIR)
  # Identify Chapters
  chapters = as.numeric(word(images,2,sep="-"))
  volumes = ceiling(chapters/per_vol)
  # Zip chapters into volumes based on the breaks
  for (volume in 1:max(volumes)){
    #zipfile <- paste0(filename,"-",str_pad(volume,2,pad="0"),".cbz")
    zipfile <- paste0(SAVE_DIR,"/",filename,"-",str_pad(volume,2,pad="0"),".cbz")
    print(paste(filename,"Volume",volume,"of",max(volumes),"file =",zipfile))
    zip::zip(zipfile,images[volumes==volume],root=FILE_DIR)
  }
}

mangazip('reincarnatedasaslime')
mangazip('soimaspider')
mangazip('chainsawman')
mangazip('madeinabyss')
mangazip('loveafter')
mangazip('notasupervillain')
mangazip('notthehero')
mangazip('villainess99')
mangazip('delicious',per_vol=7)
mangazip('flymetothemoon')
mangazip('mobpsycho')
mangazip('onepunchman')
mangazip('rangerreject')
mangazip('realisthero')
mangazip('reincarnatedasasword')
mangazip('spiritsbnb')
mangazip('yoshkaspaceprogram')
mangazip('banishedfromtheherosparty')
mangazip('gate')
mangazip('myheroacademia',per_vol=10)
mangazip('onepiece',per_vol=10)

mangazip('archdemonsdilemma')
mangazip('villainsdilemma')
mangazip('ghostline1')

mangazip('psme',per_vol=1)

mangazip('quintessential')

mangazip('invisiblepeople')

mangazip('liarprincess')
mangazip('monotoneblue')
mangazip('wizewizebeasts')
mangazip('girlfromtheotherside')

# One Shots
mangazip('untiltomorrow')
mangazip('manwolfandwolfgirl')
mangazip('midnightwaltz')

# Manga4Life zips
PROJECT_DIR <- "c:/R/Webrip/Manga4Life"
mangazip('Kumo-Desu-Ga-Nani-Ka')
