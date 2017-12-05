rm(list=ls())

my.d <- '~/GitRepo/My-CRON-Jobs'

setwd(my.d)
library(GetTDData)

df.yield <- get.yield.curve()

f.out <- file.path(tempdir(), 'YieldCurve.csv')


write.csv(x = df.yield, file = f.out, row.names = F)

zip.out <- file.path('Yield Curve', 
                     paste0('YieldCurve_', df.yield$current.date[1],'.zip'))
zip(zipfile = zip.out, files = f.out, flags = '-j' )


library(ggplot2)

p <- ggplot(df.yield, aes(x=ref.date, y = value) ) +
  geom_line(size=1) + geom_point() + facet_grid(~type, scales = 'free') + 
  labs(title = paste0('The current Brazilian Yield Curve '),
       subtitle = paste0('Date: ', df.yield$current.date[1]))     

#print(p) 

