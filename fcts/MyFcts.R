get.all.spot.tickers <- function() {
  
  # get list of ibovespa's tickers
  myUrl <- 'http://bvmf.bmfbovespa.com.br/suplemento/ExecutaAcaoDownload.asp?arquivo=Titulos_Negociaveis.zip&server=L'
  destfile <- file.path(tempdir(),'Titulos_Negociaveis.zip')
  
  download.file(myUrl, destfile = destfile, mode = 'wb',quiet = T)
  unzip(zipfile = destfile, exdir = tempdir() )
  
  
  textFile <- file.path(tempdir(), 'TITULOS_NEGOCIAVEIS.TXT')
  
  my.width <- c(2,12,4,3,60,12,12,03,03,15,07,10,10)
  my.cols <- c("Tipo", 
               "CodigoPapel", 
               "CodigoEmpresa",
               'CodigoBDI','descBDI','isin_papel','isin_objeto','num','CodigoMercado',
               'DescMercado','num_serie','spec1','datavenc')
  dfOut <- read.fwf(file = textFile, 
                    widths = my.width, 
                    header = F, 
                    col.names = my.cols,
                    skip = 1, fileEncoding = 'ISO 8859-1')
  
  dfOut$CodigoBDI <- as.character(dfOut$CodigoBDI)
  
  dfOut <- dplyr::filter(dfOut, CodigoBDI == '002')
  
  tickers <- as.character(dfOut$CodigoPapel)
  tickers <- stringr::str_trim(tickers)
  
  return(tickers)
}


write.fct <- function(df.in, folder.name) {
  if (!dir.exists(folder.name)) dir.create(folder.name)
  f.out <- file.path(folder.name, paste0(df.in$asset.code[1], '.csv'))
  write.csv(x = df.in, 
            file = f.out, row.names = FALSE, append = TRUE)
  return(TRUE)
}
