library(XML) 
library(stringr)
library(rdrop2)

cat('\nGetting Ibov composition')

# get list of ibovespa's tickers from wbsite (does NOT work)

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

drop_upload(file = zip.out, path = 'ODAFIN/IbovComposition', dtoken = token)
