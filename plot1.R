plot1 <- function() {
        #load the data
        data <- load_data()
        
        #create plot1
        #open the png device
        png(file = "plot1.png", width=480, height=480)
        
        #create the plot
        hist(data$Global_active_power, col="red", xlab="Global Active Power (kilowatts)", main="Global Active Power")
        
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