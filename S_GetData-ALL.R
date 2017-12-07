rm(list=ls())

my.d <- '~/GitRepo/My-CRON-Jobs'
setwd(my.d)

system('git pull')

try(source('S_GetData-IbovComposition.R'))
try(source('S_GetData-YieldCurve.R'))

system('git add .')
system(paste0('git commit -m "', 'CRON BOT: ', Sys.time(), '"'))
system('git push')
