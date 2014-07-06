# this function retrieves data from the file household_power_consumption.txt
# reads only the records with date between 2007-02-01 and 2007-02-02
# creates a new variable datetime with the date and time variables 

getdata <- function() {
    # read data
    house.data <- read.table("household_power_consumption.txt", header = TRUE,
                         sep = ";", na.strings = "?", nrows = 100)
    classes <- sapply(house.data, class)
    house.data <- read.table("household_power_consumption.txt", header = TRUE,
                         sep = ";", na.strings = "?", colClasses = classes,
                         nrows = 2075300)
    
    # filter data on date variable
    date.begin <- as.Date("01/02/2007", "%d/%m/%Y")
    date.end <- as.Date("02/02/2007", "%d/%m/%Y")
    period.time = as.Date(house.data$Date, "%d/%m/%Y") >= date.begin &
                  as.Date(house.data$Date, "%d/%m/%Y") <= date.end
    house.data <- subset(house.data, period.time)
    
    # create datetime variable
    house.data$Date.Time = strptime(paste(house.data$Date, house.data$Time), 
                                format = "%d/%m/%Y %H:%M:%S") 
    # return the data set
    house.data
}
