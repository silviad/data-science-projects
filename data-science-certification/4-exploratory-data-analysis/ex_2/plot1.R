# read data
NEI <- readRDS("summarySCC_PM25.rds")

# open device
png(file = "plot1.png", width = 480, height = 480)

# create a plot showing the total emission from all sources 
# for each of the years 1999, 2002, 2005, and 2008
# to check if total emissions have decreased 
barplot(by(NEI$Emissions, NEI$year, sum), col = "blueviolet", xlab = "year", 
        ylab = "Emissions", main = "Total Emissions per year")

# close device
dev.off()