#  Generalised Manga Online
# First Story starts at:
# https://ww7.mangakakalot.tv/chapter/manga-kv987430/chapter-1
#
# This code starts at the first page of a manga
# and then crawl through it page by page to identify 
# the next page, then the manga images.
#
# This code has been generalised into a function to scan and download a full manga,
# given its name and starting url

library(rvest)
library(dplyr)
library(xml2)
library(stringr)

rip_url <- function(url){
  chapter <- str_split_1(url,'/')[6]
  webpage <- read_html(url)
  next_xml <- xml_attrs(html_nodes(webpage,'.next'))
  if (length(next_xml)==2){
    next_url <- as.character(paste0('https://ww7.mangakakalot.tv',next_xml[[2]][1]))
  } else if (length(next_xml)==4) {
    next_url <- as.character(paste0('https://ww7.mangakakalot.tv',next_xml[[2]][1])) } else next_url <- ""
  images <- data.frame()
  image_xml <- xml_attrs(html_nodes(webpage,'.img-loading'))
  for (i in seq(1,999)){
    try({
      image <- as.character(image_xml[[i]][1])
      images <- rbind(images,data.frame(url,next_url,chapter,i,image,stringsAsFactors = F))
    },silent=TRUE)
  }
  
  results = images
  #  results = data.frame(url,next_url,image,image_name,stringsAsFactors = F)
  return(results)
}

mangarip <- function(filename,url){
  PROJECT_DIR <- "c:/R/Webrip/Manga"
  FILE_DIR    <- paste0(PROJECT_DIR,"/",filename)
  dir.create(FILE_DIR, showWarnings = FALSE)  # Create directory if it doesn't exist
  
  # Read the existing data frame if it exists
  if (file.exists(paste0(PROJECT_DIR,"/",filename,".RData"))){
    load(paste0(PROJECT_DIR,"/",filename,".RData"))
  } else {
    df <- rip_url(url)  # Save the first page
  }
  
  # remove records which have no Next URL to allow 
  df <- df %>% filter(next_url!="")
  df <- unique(df)
  
  continue=TRUE
  
  # Continue until no more rows added
  i=0
  while (continue==TRUE){
    rows = nrow(df)
    i<-i+1
    tryCatch({
      url <- tail(df$next_url,1)
      if (nchar(url)>0){
        print(paste("Manga",filename,"Iteration",i,"Looking up page",url))
        df <- rbind(df,rip_url(url))
        df <- unique(df)
        save(df,file=paste0(PROJECT_DIR,"/",filename,".RData"))
        if (nrow(df)==rows) continue <- FALSE
      }
    })
  }
  
  df <- unique(df)
  save(df,file=paste0(PROJECT_DIR,"/",filename,".RData"))
  
  # Copy the images
  #Download the Images
  for (i in 1:nrow(df)){
    if (file.exists(paste0(FILE_DIR,"/",df$chapter[i],"-",str_pad(df$i[i],3,pad="0"),".jpg"))){
      # print(paste(filename,df$chapter[i],"image #",df$i[i],"already downloaded"))
    } else{
      print(paste("downloading",filename,df$chapter[i],"image #",df$i[i]))
      try({download.file(df$image[i],
                         paste0(FILE_DIR,"/",df$chapter[i],"-",str_pad(df$i[i],3,pad="0"),".jpg"),
                         quiet=TRUE, mode="wb")},silent = TRUE)
    }
  }
  
}

# Rip a manga using the function
mangarip('villainess99','https://ww7.mangakakalot.tv/chapter/manga-ih985416/chapter-0')
mangarip('delicious','https://ww7.mangakakalot.tv/chapter/manga-vs951827/chapter-0')
mangarip('loveafter','https://ww7.mangakakalot.tv/chapter/manga-fs983301/chapter-1')

mangarip('notthehero','https://ww7.mangakakalot.tv/chapter/manga-nu990929/chapter-1')
mangarip('bluehole'  ,'https://ww7.mangakakalot.tv/chapter/manga-ep981550/chapter-0')
mangarip('gate','https://ww7.mangakakalot.tv/chapter/manga-qp952972/chapter-1')

mangarip('summerwars','https://ww7.mangakakalot.tv/chapter/manga-ok965693/chapter-1')
mangarip('planetes','https://ww7.mangakakalot.tv/chapter/manga-jf957462/chapter-1')
mangarip('astro','https://ww7.mangakakalot.tv/chapter/manga-lu960329/chapter-0')
mangarip('akira','https://ww7.mangakakalot.tv/chapter/manga-nn960522/chapter-1.1')

mangarip('yoshkaspaceprogram','https://ww7.mangakakalot.tv/chapter/manga-cx979606/chapter-1')
mangarip('banishedfromtheherosparty','https://ww7.mangakakalot.tv/chapter/manga-cu979429/chapter-1')
mangarip('reincarnatedasaslime','https://ww7.mangakakalot.tv/chapter/manga-ne990713/chapter-1')
mangarip('soimaspider','https://ww7.mangakakalot.tv/chapter/manga-zd976712/chapter-0')
mangarip('madeinabyss','https://ww7.mangakakalot.tv/chapter/manga-na952709/chapter-1')
mangarip('myheroacademia','https://ww7.mangakakalot.tv/chapter/manga-jq951973/chapter-0')

mangarip('onepiece','https://ww7.mangakakalot.tv/chapter/manga-aa951409/chapter-1.2')

mangarip('mobpsycho','https://ww7.mangakakalot.tv/chapter/manga-ln951470/chapter-1')
mangarip('chainsawman','https://ww7.mangakakalot.tv/chapter/manga-dn980422/chapter-1')
mangarip('rangerreject','https://ww7.mangakakalot.tv/chapter/manga-kd988138/chapter-1')

mangarip('flymetothemoon','https://ww7.mangakakalot.tv/chapter/manga-bf978740/chapter-0.1')

mangarip('reincarnatedasasword','https://ww7.mangakakalot.tv/chapter/manga-wg974263/chapter-1')

mangarip('blueworld','https://ww7.mangakakalot.tv/chapter/manga-rq994799/chapter-1')
mangarip('realisthero','https://ww7.mangakakalot.tv/chapter/manga-zb977136/chapter-1')

mangarip('ghostline1','https://ww7.mangakakalot.tv/chapter/manga-xf1000988/chapter-1')
mangarip('spiritsbnb','https://ww7.mangakakalot.tv/chapter/manga-bk979267/chapter-1')

mangarip('archdemonsdilemma','https://ww8.mangakakalot.tv/chapter/manga-bi978917/chapter-1')
mangarip('villainsdilemma','https://ww8.mangakakalot.tv/chapter/manga-ni991217/chapter-1')

mangarip('dukeofdeath','https://ww8.mangakakalot.tv/chapter/manga-av977730/chapter-0')

mangarip('onepunchman','https://ww7.mangakakalot.tv/chapter/manga-wd951838/chapter-1')
mangarip('notasupervillain','https://ww7.mangakakalot.tv/chapter/manga-og991741/chapter-1')
mangarip('psme','https://ww8.mangakakalot.tv/chapter/manga-je957461/chapter-0')
