# read data
NEI <- readRDS("summarySCC_PM25.rds")
SCC <- readRDS("Source_Classification_Code.rds")

# calculate coal sources, create a subset of SCC data
# and merge it with NEI data
SCC.grep <- grep("coal", SCC$EI.Sector, ignore.case = TRUE)
SCC.coal <- SCC[SCC.grep, "SCC"] 

# create a subset for coal sources
NEI.coal <- subset(NEI, SCC %in% SCC.coal)

# open device
png(file = "plot4.png", width = 480, height = 480)

# create a plot to check how emissions from coal combustion-related sources 
# have changed from 1999-2008
barplot(by(NEI.coal$Emissions, NEI.coal$year, sum), 
        col = "lightgoldenrod1", xlab = "year", ylab = "Emissions", 
        main = "Total Coal Emissions per year")

# close device
dev.off()

        

