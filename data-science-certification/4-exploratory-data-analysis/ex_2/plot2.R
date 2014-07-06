# read data
NEI <- readRDS("summarySCC_PM25.rds")

# create a subset for Baltimore City
NEI.Baltimore <- subset(NEI, fips == "24510")

# open device
png(file = "plot2.png", width = 480, height = 480)

# create a plot showing the total emission from all sources 
# for each of the years 1999, 2002, 2005, and 2008 in Baltimore City
# to check if total emissions have decreased
barplot(by(NEI.Baltimore$Emissions, NEI.Baltimore$year, sum), 
        col = "darkturquoise", xlab = "year", ylab = "Emissions", 
        main = "Total Emissions per year in Baltimore City")

# close device
dev.off()