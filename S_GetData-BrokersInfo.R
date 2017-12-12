# runs web scraping script for Brokers data
#
# STEPS:
# 1) Install Docker: https://docs.docker.com/engine/installation/linux/docker-ce/ubuntu/
# 2) RUN AS SUDO: sudo docker run -d -p 4445:4444 selenium/standalone-firefox:2.53.1

#rm(list = ls())

#.libPaths('/home/msperlin/R/x86_64-pc-linux-gnu-library/3.4/')

library(RSelenium)
library(stringr)
library(methods) # for RScript run
library(rdrop2)

my.d <- '/home/msperlin/GitRepo/My-CRON-Jobs/'
setwd(my.d)

source('fcts/Brokers-fcts.R')

system('docker stop $(docker ps -aq)')
system('docker run -d -p 4445:4444 selenium/standalone-firefox:2.53.1')

# Run a server for example using Docker
# docker run -d -p 4445:4444 selenium/standalone-firefox:2.53.1
# Use a debug image with a VNC viewer if you wish to view the browser
# docker run -d -p 5901:5900 -p 127.0.0.1:4445:4444 --link http-server selenium/standalone-firefox-debug:2.53.1
# See Docker vignette for more detail or run a Selenium Server manually.

Sys.sleep(3)
remDr <- remoteDriver(port = 4445L)
remDr$open()

my.url <- 'http://www.bmfbovespa.com.br/pt_br/servicos/participantes/busca-de-corretoras/'
#my.url <- 'https://web.archive.org/web/20161023022043/http://www.bmfbovespa.com.br:80/pt_br/servicos/participantes/busca-de-corretoras/'

# wdman::phantomjs()
# pJS <- phantom()
# Sys.sleep(5) # give the binary a moment
#remDr <- remoteDriver(browserName = 'phantomjs')
#remDr$open()
remDr$navigate(my.url)
remDr$getCurrentUrl()
remDr$getTitle()
remDr$getStatus()

max.brokers = Inf

df.links <- data.frame()
df.brokers <- data.frame()  
while (TRUE) {
  
  cat('\nGetting Source')
  my.html <- remDr$getPageSource()[[1]]
  
  cat('\nExtracting links')
  temp <- str_extract_all(string = my.html, pattern = 'href=[\'"]?([^\'" >]+)')[[1]]
  temp <- temp[str_detect(temp, '.htm')]
  temp <- sapply(temp, function(x) str_split(x, fixed('.'))[[1]][2])
  links <- temp[nchar(temp) > 5]
  broker.url <- paste0(my.url, str_sub(links, 2, nchar(links)), '.htm')
  
  cat('\nExtracting names')
  webElems <- remDr$findElements("xpath", value = "//a[@href]")
  temp2 <- sapply(webElems, function(x) x$getElementText())
  temp2 <- unlist(temp2[str_detect(temp2, '-')])
  
  temp2 <- str_replace_all(temp2, fixed('.'), '')
  
  broker.id <- unlist(str_extract_all(temp2, pattern = '(\\d+)'))
  #broker.id <- as.numeric(sapply(temp2, function(x) str_split(x, '-')[[1]][2]))
  broker.name <- str_trim(sapply(temp2, function(x) str_split(x, '-')[[1]][1]))
  
  for (i.url in seq_along(broker.url)) {
    Sys.sleep(1)
    url.now <- broker.url[i.url]
    name.now <- broker.name[i.url]
    id.now <- broker.id[i.url]
    
    cat(paste0('\n\t', Sys.time(), ' - ', 'Reading info on ', name.now))
    
    df.out <- get.broker.info(url.now)
    
    df.out$broker.name <- name.now
    df.out$broker.id   <- id.now
    df.out$ref.date <- Sys.Date()
    df.out$ref.time <- Sys.time()
    
    df.brokers <- rbind(df.brokers, df.out)
    
  }
  
  
  do.stop <- TRUE
  try({
    my.xpath <- '//*[@id="Form_8A488AEB50447C8F0150489E91DF396A"]/section/div/div/div/div/div[2]/div[11]/div/ul/li[7]/a'
    webElem <- remDr$findElement("xpath", value = my.xpath)
    webElem$clickElement()
    
    do.stop <- FALSE
  })
  
  if (do.stop) break()
  
  #browser()
}

#save('df.links', file = 'BrokersLinks.RData')
my.file <- paste0('Brokers/BrokersInfo_', Sys.Date(), '.rds') 
saveRDS(object = df.brokers, file = my.file)
drop_upload(file = my.file, path = 'ODAFIN/Brokers', dtoken = token)

# stop all containers
system('docker stop $(docker ps -aq)')
