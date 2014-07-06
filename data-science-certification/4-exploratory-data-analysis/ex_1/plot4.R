# call function getdata
house.data <- getdata()

# open device
png(file = "plot4.png", width = 480, height = 480)

# create plot
par(mfcol = c(2, 2))
with(house.data, {
  
    # upper left plot
    plot(Date.Time, Global_active_power,
         xlab = "", ylab = "Global Active Power", type = "l")
  
    # bottom left plot
    plot(Date.Time, Sub_metering_1, 
         xlab = "", ylab = "Energy sub metering", type ="n")
    lines(Date.Time, Sub_metering_1)
    lines(Date.Time, Sub_metering_2, col = "red")
    lines(Date.Time, Sub_metering_3, col = "blue")
    legend("topright", lty = 1, col = c("black", "red", "blue"), 
           legend = c("Sub_metering_1", "Sub_metering_2" , "Sub_metering_3"),
           cex = 0.8, bty = "n")  
  
    # upper right plot
    plot(Date.Time, Voltage,
         xlab = "datetime", ylab = "Voltage", type = "l")  
  
    # bottom right plot
    plot(Date.Time, Global_reactive_power,
         xlab = "datetime", ylab = "Global_reactive_power", type = "l")  
})

# close device
dev.off()
