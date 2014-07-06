# call function getdata
house.data <- getdata()

# open device
png(file = "plot3.png", width = 480, height = 480)

# create plot
with(house.data, {
    plot(Date.Time, Sub_metering_1, 
         xlab = "", ylab = "Energy sub metering", type ="n")
    lines(Date.Time, Sub_metering_1)
    lines(Date.Time, Sub_metering_2, col = "red")
    lines(Date.Time, Sub_metering_3, col = "blue")
    legend("topright", lty = 1, col = c("black", "red", "blue"), 
           legend = c("Sub_metering_1", "Sub_metering_2" , "Sub_metering_3"),
           cex = 0.8)
})

# close device
dev.off()