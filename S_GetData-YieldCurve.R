library(GetTDData)

cat('\nGetting Yield curve')

df.yield <- get.yield.curve()

f.out <- file.path(tempdir(), 'YieldCurve.csv')


write.csv(x = df.yield, file = f.out, row.names = F)

zip.out <- file.path('Yield Curve', 
                     paste0('YieldCurve_', df.yield$current.date[1],'.zip'))
zip(zipfile = zip.out, files = f.out, flags = '-j' ) 

