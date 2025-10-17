library(readr)
library(dplyr)


#set working directory
CombinedData <- read_csv("CombinedData.csv")
trendDfFull <- read_csv("googleTrendData.csv")


#Format for CombinedData
#first column date in M/D/YYYY ordered from most recent to least recent
#all additional columns are the stock price for that day with column name
# "Average_"{NAME} "Stock Price History"

#Format for trendDfFull 
#first column has 1:N for every row, 
#Second column is the day in M/D/YYYY format
#all additional columns are google trends data with format "NAME":"UNITED STATES" 

#removing repeated data (1:31)
trendDfFull <- trendDfFull[,-1]

#maxing the rows align (stock data had the rows in reverse order)
stockDf <- CombinedData[nrow(CombinedData):1, ]

{
#removing amazon (since there is no good google trends info for it)
stockDf <- subset(stockDf, select = 
                      -`Average_Amazon.com Stock Price History`)

#dropping walmart :)
stockDf <- subset(stockDf, select = 
                    -`Average_Walmart Stock Price History`)
}

#aligning the columns for future easy of use
stockDf <- stockDf[ , c(1, order(names(stockDf)[-1]) + 1)]
trendDfFull <- trendDfFull[ , c(1, order(names(trendDfFull)[-1]) + 1)]


#renaming column
names(stockDf)[1] <- "Day"

#getting rid of rows which don't share dates
trendDf <- trendDfFull %>%
  filter(Day %in% stockDf$Day)

#getting a clean list of the column names
longnames <- colnames(trendDf[-1])

newnames <- lapply(longnames, function(x) substr(x, 1, nchar(x) -17))
names(trendDf)[-1] <- newnames

longnames <- colnames(stockDf[-1])
newnames <- lapply(longnames, function(x) paste(substr(x, 9, 
  nchar(x) -20), "Average Price"))
names(stockDf)[-1] <- newnames

#combining data frames to use in ggplot
alldf <- merge(stockDf, trendDf, by = "Day")

#removing remnant variables
rm(CombinedData)
rm(newnames)
rm(stockDf)
rm(trendDf)
rm(trendDfFull)
rm(longnames)

write.csv(alldf, "finalData.csv")


