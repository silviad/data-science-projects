# call function getdata
house.data <- getdata()

# open device
png(file = "plot1.png", width = 480, height = 480)

# create plot
hist(house.data$Global_active_power, col ="red", 
     xlab = "Global Active Power (kilowatts)", main = "Global Active Power")

# close device
dev.off()