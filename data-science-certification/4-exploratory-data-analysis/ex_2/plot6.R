# read data
NEI <- readRDS("summarySCC_PM25.rds")
SCC <- readRDS("Source_Classification_Code.rds")

# calculate SCC of motor vehicle sources
SCC.grep <- grep("vehicles", SCC$EI.Sector, ignore.case = TRUE)
SCC.motor <- SCC[SCC.grep, "SCC"]

# create a subset for motor vehicle sources in Baltimore City and 
# Los Angeles County
NEI.Balti.LosAng <- subset(NEI, (fips == "24510" | fips == "06037") 
                           & SCC %in% SCC.motor)

# create a factor variable for cities
NEI.Balti.LosAng$city <- factor(NEI.Balti.LosAng$fips, 
                                labels = c("Los Angeles County", 
                                           "Baltimore City"))

# create a plot to compare emissions from motor vehicle sources 
# in Baltimore City and in Los Angeles County
# to check which city has seen greater changes over time
NEI.Balti.LosAng <- ddply(NEI.Balti.LosAng, c("year", "city"), 
                          summarise, Emissions = sum(Emissions))
p <- qplot(factor(year), Emissions, fill = city, data = NEI.Balti.LosAng,            
           geom = "bar", stat = "identity", position = "dodge", xlab = "year",
           main = "Total  Motor Vehicle Emissions per year in Los Angeles 
           and Baltimore")

# save the the plot in a png file
ggsave(filename = "plot6.png", plot = p)

