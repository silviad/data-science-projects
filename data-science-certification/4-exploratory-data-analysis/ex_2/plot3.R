# read data
NEI <- readRDS("summarySCC_PM25.rds")

# create a subset for Baltimore City
NEI.Baltimore <- subset(NEI, fips == "24510")

# create a plot showing of the four types of sources (point, nonpoint, 
# onroad, nonroad), which of these have seen decreases in emissions 
# from 1999-2008 for Baltimore City and which of these have seen increases
NEI.Baltimore <- ddply(NEI.Baltimore, c("type","year"), 
                       summarise, Emissions = sum(Emissions))
p <- qplot(factor(year), Emissions, fill = type, data = NEI.Baltimore,        
           geom = "bar", stat = "identity", xlab = "year",
           main = "Total Emissions per year and source in Baltimore City")

# save the plot in a png file
ggsave(filename = "plot3.png", plot = p)
