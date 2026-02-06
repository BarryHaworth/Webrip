# Program to output lists of links for downlaoding images

library(dplyr)

res <- "3440x1440"
load(paste0(PROJECT_DIR,"/wallpaperswide-",res,".RData"))  
links <- wallpaperswide %>% 
  separate(col=thumbnail,
           into = c("var1","var2","var3","var4","image_name"),
           sep="/") %>%
  mutate(image_name=sub('t1',res,image_name),
         link=paste0('https://wallpaperswide.com/download/',image_name) ) %>% select(link)

linklist <- function(keyword){
  selected <- subset(links, grepl(pattern= keyword, link))
  sel_n <- nrow(selected)
  print(paste("Keyword",keyword,"has",sel_n,"matches"))
  chunks <- ceiling(sel_n/200)
  for (i in 1:chunks){
    write.table(head(tail(selected,sel_n-200*(i-1)),200),paste0(PROJECT_DIR,'/links_',keyword,'_',i,'.txt'),col.names = F, row.names=F, quote=F)
  }
}

linklist("sunset")
linklist("tree")
linklist("nature")
linklist("forest")
linklist("mountain")
linklist("alien")

linklist("rose")
linklist("flower")
linklist("cat")
linklist("kitten")
linklist("rainbow")
