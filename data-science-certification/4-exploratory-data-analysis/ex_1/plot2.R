# call function getdata
house.data <- getdata()

# open device
png(file = "plot2.png", width = 480, height = 480)

# create plot
with(house.data, plot(Date.Time, Global_active_power,
                      xlab = "", ylab = "Global Active Power (kilowatts)", 
                      type = "l"))

# close device
dev.off()