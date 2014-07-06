# read data
NEI <- readRDS("summarySCC_PM25.rds")
SCC <- readRDS("Source_Classification_Code.rds")

# calculate SCC of motor vehicle sources
SCC.grep <- grep("vehicles", SCC$EI.Sector, ignore.case = TRUE)
SCC.motor <- SCC[SCC.grep, "SCC"]

# create a subset for Baltimore City and motor vehicle sources
NEI.motor <- subset(NEI, fips == "24510" & SCC %in% SCC.motor)

# open device
png(file = "plot5.png", width = 480, height = 480)

# create a plot to check how emissions from motor vehicle sources 
# have changed from 1999-2008 in Baltimore City
barplot(by(NEI.motor$Emissions, NEI.motor$year, sum), 
        col = "darkred", xlab = "year", ylab = "Emissions", 
        main = "Total Motor Vehicle Emissions per year in Baltimore City")

# close device
dev.off() 