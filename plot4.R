plot4 <- function() {
        #load the data
        data <- load_data()
        
        #create plot1
        #open the png device
        png(file = "plot4.png", width=480, height=480)
        
        #Place plots in a 2x2 grid
        par(mfrow=c(2,2))
        
        #first plot is plot2 with a change in title
        plot(data$Date_Time, data$Global_active_power, type="l", xlab="", ylab="Global Active Power")
        
        #second plot is voltage vs. datetime
        plot(data$Date_Time, data$Voltage, type="l", xlab="datetime", ylab="Voltage")
        
        #third plot is the third plot with a boxless legend
        plot(data$Date_Time, data$Sub_metering_1, type="l", xlab="", ylab="Global Active Power (kilowatts)")
        
        #overlay the other two sets of line
        lines(data$Date_Time, data$Sub_metering_2, col="red")
        lines(data$Date_Time, data$Sub_metering_3, col="blue")
        
        #add the legend
        legend("topright", legend=c("Sub_metering_1", "Sub_metering_2", "Sub_metering_3"), col=c("black", "red", "blue"), lty=1, bty="n")
        
        #4th plot is another line plot with a missing ylab
        #changed to a with cmd, to get the correct ylab.
        #Granted, could have just used ylab, too.
        with(data, plot(Date_Time, Global_reactive_power, type="l", xlab="datetime"))
        
        #close the device
        dev.off()
}

lload_data <- function() {
        #in this function we're going to load the data into a dataframe.
        #once in a data frame we're going to put the dates into R date
        #formats and change the ?s to NAs
        
        library(sqldf)
        
        #start off by checking for the data
        if (!dir.exists("./data") || !file.exists("./data/household_power_consumption.txt")) {
                print("Data needs to be downloaded")
                #create the directory
                if(!dir.exists("./data")) {
                        dir.create("./data")
                }
                
                #download the data
                if(!file.exists("./data/household_power_consumption.zip")) {
                        url <- "https://d396qusza40orc.cloudfront.net/exdata%2Fdata%2Fhousehold_power_consumption.zip"
                        download.file(url, "./data/household_power_consumption.zip", mode="wb")
                }
                
                #unzip downloaded file
                unzip(zipfile="./data/household_power_consumption.zip", exdir="./data")
        }
        else {
                print("Data is downloaded already")
        }
        
        #read only the dates you need, so that you don't have to hassle with subsetting
        #or make operations on large tables
        data <- read.csv.sql("./data/household_power_consumption.txt",header=TRUE, sep=";" ,
                             sql = "select * from file where (Date = '1/2/2007' or Date = '2/2/2007')", eol = "\n")
        
        #let's combine Date and Time into one column and cbind to the rest of data.
        data <- cbind(paste(data$Date, data$Time), subset(data, select = -c(Date, Time)))
        #need to rename the new column
        colnames(data)[1] <- "Date_Time"
        
        #convert the date_time to R-format Date
        data$Date_Time <- strptime(data$Date, format="%d/%m/%Y %H:%M:%S")
        
        data
}