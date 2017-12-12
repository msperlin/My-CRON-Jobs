rm(list=ls())

max.tries <- 5

my.d <- '/home/msperlin/GitRepo/My-CRON-Jobs'
setwd(my.d)

token <- readRDS("/home/msperlin/droptoken.rds")

#system('git pull')

try(source('S_GetData-IbovComposition.R') )

try(source('S_GetData-YieldCurve.R') )

try(source('S_GetData-BrokersInfo.R') )

#system('git add .')
#system(paste0('git commit -m "', 'CRON BOT: ', Sys.time(), '"'))
#system('git push')
