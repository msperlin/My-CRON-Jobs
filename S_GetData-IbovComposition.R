rm(list=ls())

my.d <- '~/GitRepo/My-CRON-Jobs'

setwd(my.d)

rm(list = ls())

library(XML) 
library(stringr)

save.df <- TRUE

my.name <-'IbovComp'
last.date <- Sys.Date()
first.date <- last.date - 5*365
first.date <- as.Date('2010-01-01')

# get list of ibovespa's tickers from wbsite (does NOT work)

#myUrl <- 'http://www.infomoney.com.br/ibovespa/composicao'

myUrl <- 'http://bvmf.bmfbovespa.com.br/indices/ResumoCarteiraTeorica.aspx?Indice=IBOV&idioma=pt-br'
df.ibov.comp <- readHTMLTable(myUrl)[[1]]

names(df.ibov.comp) <- c('ticker', 'ticker.desc', 'type.stock', 'quantity', 'percentage.participation')

df.ibov.comp$quantity <- as.numeric(str_replace_all(df.ibov.comp$quantity, fixed('.'), ''))
df.ibov.comp$percentage.participation <- as.numeric(str_replace_all(df.ibov.comp$percentage.participation, 
                                                              fixed(','), '.'))

df.ibov.comp$ref.date <- Sys.Date()

f.out <- file.path(tempdir(), 'IbovComp.csv')

write.csv(x = df.ibov.comp, file = f.out, row.names = F)

zip.out <- file.path('Ibov Composition', 
                     paste0('IbovComp_', Sys.Date(),'.zip'))
zip(zipfile = zip.out, files = f.out, flags = '-j' )