# Mangafire.
# Program to rip a manga from Mangfile.to.
# Start with Archdemon's dilemma: how to love your elf bride
# https://mangafire.to/read/maou-no-ore-ga-dorei-elf-wo-yome-ni-shitanda-ga-dou-medereba-ii.2lv2/en/chapter-1
# This might be in the too hard basket - everything seems to be javascripts

library(rvest)
library(dplyr)
library(xml2)
library(stringr)

url <- 'https://mangafire.to/read/maou-no-ore-ga-dorei-elf-wo-yome-ni-shitanda-ga-dou-medereba-ii.2lv2/en/chapter-1'

rip_url <- function(url){
  chapter <- str_split_1(url,'/')[7]
  webpage <- read_html(url)
  next_xml <- xml_attrs(html_nodes(webpage,'.next'))
  if (length(next_xml)==2){
    next_url <- as.character(paste0('https://ww7.mangakakalot.tv',next_xml[[2]][1]))
  } else if (length(next_xml)==4) {
    next_url <- as.character(paste0('https://ww7.mangakakalot.tv',next_xml[[2]][1])) } else next_url <- ""
  images <- data.frame()
  image_xml <- xml_attrs(html_nodes(webpage,'.img-loading'))
  for (i in seq(1,100)){
    try({
      image <- as.character(image_xml[[i]][1])
      images <- rbind(images,data.frame(url,next_url,chapter,i,image,stringsAsFactors = F))
    },silent=TRUE)
  }
  
  results = images
  #  results = data.frame(url,next_url,image,image_name,stringsAsFactors = F)
  return(results)
}

mangafile <- function(filename,url){
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
      print(paste(filename,df$chapter[i],"image #",df$i[i],"already downloaded"))
    } else{
      print(paste("downloading",filename,df$chapter[i],"image #",df$i[i]))
      try({download.file(df$image[i],
                         paste0(FILE_DIR,"/",df$chapter[i],"-",str_pad(df$i[i],3,pad="0"),".jpg"),
                         quiet=TRUE, mode="wb")},silent = TRUE)
    }
  }
  
}


mangafire('elfbride','https://mangafire.to/read/maou-no-ore-ga-dorei-elf-wo-yome-ni-shitanda-ga-dou-medereba-ii.2lv2/en/chapter-1')