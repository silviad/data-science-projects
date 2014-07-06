## Introduction

The overall goal of this assignment is to explore the National Emissions Inventory database and see what it says about fine particulate matter pollution in the United states over the 10-year period 1999 to 2008.

Fine particulate matter ($PM_{2.5}$) is an ambient air pollutant for which there is strong evidence that it is harmful to human health. In the United States, the Environmental Protection Agency (EPA) is tasked with setting national ambient air quality standards for fine PM and for tracking the emissions of this pollutant into the atmosphere.

Approximatly every 3 years, the EPA releases its database on emissions of $PM_{2.5}$. This database is known as the National Emissions Inventory (NEI).

You can read more information about the NEI at the EPA National Emissions Inventory web site.

For each year and for each type of PM source, the NEI records how many tons of $PM_{2.5}$ were emitted from that source over the course of the entire year. The data that you will use for this assignment are for 1999, 2002, 2005, and 2008.

Data for this Project is available at: https://d396qusza40orc.cloudfront.net/exdata%2Fdata%2FNEI_data.zip.

The zip file contains two files: summarySCC_PM25.rds and Source_Classification_Code.rds.

The first file contains the following data:
- fips: A five-digit number (represented as a string) indicating the U.S.county
- SCC: The name of the source as indicated by a digit string (see source code classification table) 
- Pollutant: A string indicating the pollutant 
- Emissions: Amount of PM2.5 emitted, in tons 
- type: The type of source (point, non-point, on-road, or non-road) 
- year: The year of emissions recorded

The file Source_Classification_Code.rds provides a mapping from the SCC digit-strings in the Emissions-table to the actual name of the $PM_{2.5}$ source.The sources are categorized in a few different ways from more general to more specific and you may choose to explore whatever categories that one might think are most useful. For example: "source 1010011" is known as: Ext Comb / Electric Gen / Anthracite Coal / Pulverized Coal.


## Questions

The Assignment consists in creating six plots in individual R_code files in order to answer the following questions:

1. Have total emissions from $PM_{2.5}$ decreased in the United States from 1999 to 2008? Using the base plotting system, make a plot showing the total $PM_{2.5}$ emission from all sources for each of the years 1999, 2002, 2005, and 2008.

2. Have total emissions from $PM_{2.5}$ decreased in the Baltimore City, Maryland (fips == "24510") from 1999 to 2008? Use the base plotting system to make a plot answering this question.

3. Of the four types of sources indicated by the type (point, nonpoint, onroad, nonroad) variable, which of these four sources have seen decreases in emissions from 1999-2008 for Baltimore City? Which have seen increases in emissions from 1999-2008? Use the ggplot2 plotting system to make a plot answer this question.

4. Across the United States, how have emissions from coal combustion-related sources changed from 1999-2008?

5. How have emissions from motor vehicle sources changed from 1999-2008 in Baltimore City?

6. Compare emissions from motor vehicle sources in Baltimore City with emissions from motor vehicle sources in Los Angeles County, California (fips == "06037"). Which city has seen greater changes over time in motor vehicle emissions?


