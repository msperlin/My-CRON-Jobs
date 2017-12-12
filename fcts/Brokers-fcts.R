get.broker.info <- function(url.in) {
  
  require(methods)
  require(stringr)
  
  html.out <- readLines(url.in)
  
  # filter html code
  idx.1 <- which(str_detect(html.out, 'CNPJ'))
  idx.2 <- which(str_detect(html.out, 'src="/lumis-theme/br/com/bvmf/internet/theme/bvmf-internet/js/google/gmaps.js"'))
  html.out <- html.out[idx.1:idx.2]
  
  type.instrument <- c('Commodities', 'Moedas', 'Renda Fixa Privada e Pública', 'Juros',
                       'Renda Variável','Derivativos', 'Títulos Financeiros', 'Tesouro Direto')
  
  D.instruments <- sapply(type.instrument, function(x) any(str_detect(html.out,fixed(x)))) 
  
  type.services <- c('Adm. de clubes de investimentos', 'Análise e pesquisa financeira', 
                     'Carteira administrada', 'Carteira recomendada', 'Co-location (DMA 4)', 
                     'Empréstimo de ativos', 'Formador de mercado' , 'Gestão de carteira de investimento',
                     'Home broker', 'Mobile broker', 'Oferta de fundos de investimentos')
  
  D.services <- sapply(type.services, function(x) any(str_detect(html.out,fixed(x)))) 
  
  type.clients <- c('Investidor estrangeiro', 'Investidores institucionais', 
                    'Pessoa física', 'Pessoa jurídica')
  
  D.clients <- sapply(type.clients, function(x) any(str_detect(html.out,fixed(x)))) 
  
  #df.out <- data.frame(t(c(D.instruments, D.services, D.clients)))
  df.out <- data.frame(service.name = c(type.instrument, type.services, type.clients),
                       service.flag = c(D.instruments, D.services, D.clients), stringsAsFactors = FALSE)
  
  rownames(df.out) <- NULL
  #browser()
  return(df.out)
}
