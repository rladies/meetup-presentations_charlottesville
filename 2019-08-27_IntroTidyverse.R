# R-Ladies Tutorial: Intro to the Tidyverse
# Author: Brigitte Hogan
# date: 8/27/2019

# This tutorial covers over the basics of
# - dplyr
# - tidyr
# - stringr
# - forcats
# - lubridate
# - purrr

# ________________________ -----------------------------------------------------
## Packages ----
library(here)
library(tidyverse)
library(lubridate)
library(nycflights13)

# ________________________------------------------------------------------------
## Data Wrangling with dplyr ----

## Read in data ####
#setwd(here()) # optional
nh <- read_csv(file="nhanes_modified.csv")
nh 

## Tibbles####
# - using the readr package read_csv() reads in csv as a tbl (tibble)
# - use as_tibble() to convert regular dataframes into tibbles

## Verbs
# - dplyr package functions are written as verbs for managing data
# - on their own they don't do anything that base R can't do
# - two types of verbs
#    1. single-table verbs (only work on a single table)
#    2. two-table verbs (used for joining data together) - later lesson

# single-table dplyr verbs
# - filter()
# - select() 
# - mutate() 
# - arrange() 
# - summarize() 
# - group_by() 

# all take a data frame or tibble as their input for the first argument
# all return a data frame or tibble as output

### filter() ####

# If you want to filter rows of the data where some condition is true, use the filter() function. 
# 1. The first argument is the data frame you want to filter, e.g. filter(mnha, ....
# 2. The second argument is a condition you must satisfy, e.g. filter(nh, Diabetes == "Yes"). If you want to satisfy *all* of multiple conditions, you can use the "and" operator, &. The "or" operator | (the pipe character, usually shift-backslash) will return a subset that meet *any* of the conditions.
# ==: Equal to
# !=: Not equal to
# >, >=: Greater than, greater than or equal to
# <, <=: Less than, less than or equal to

# Let's take a look at just the people in the NHanes survey with Diabetes.

# Look at just the people with Diabetes
filter(nh, Diabetes == "Yes")

# Optionally, bring that result up in a View window
View(filter(nh, Diabetes == "Yes"))

# Look at multiple Race categories
unique(nh$Race) #what race categories are there?
filter(nh, Race =="Asian" | Race =="Black")

# Look at people of or under age 30 whose income greater than or equal to 70K
filter(nh, Income >= 70000 & Age <= 30)

# YOUR TURN: How many people in the NHanes survey that meet the above two criteria are a racial minority (not white)?
filter(nh, Income >= 70000 & Age <= 30 & Race != "White")


### select() ####
# - filter() allows you to return only certain rows matching a condition
# - select() returns only certain columns
# - first argument is the data, and subsequent arguments are the columns you want.

# Select just the Pulse and Blood Pressure variables
select(nh, Pulse, BPSys, BPDia)

# Alternatively, just remove columns. Remove id, HomeRooms, & HomeOwn cols
select(nh, -id, -HomeRooms, -HomeOwn)

# Notice how the original data is unchanged - still have all 32 columns
nh


### mutate() ####
# - mutate() function adds new columns to the data
# - doesn't actually modify the data frame you're operating on
# - result is transient unless you assign it to a new object

# The HDL to Total Cholesterol value can be predictive for risk of heart disease. Let's mutate this data to add a new variable called "CholRatio" that is the HDLChol / TotChol.
mutate(phys, CholRatio=HDLChol / TotChol)


### arrange() ####
# - takes a data frame or tbl and arranges (or sorts) by column(s) of interest
# - first argument is the data, and subsequent arguments are columns to sort on
# - use the desc() function to arrange by descending

# arrange by Testosterone (default: increasing)
arrange(nh, Testosterone)
# arrange by Weight (descending)
arrange(nh, desc(Weight))


### summarize() ####
# - summarize() function summarizes multiple values to a single value
# - on its own the summarize() function doesn't seem to be all that useful
# - summarize takes a data frame and returns a data frame
#   (in this case it's a 1x1 data frame)

# Get the mean expression for all genes
summarize(nh, mean(Weight, na.rm = TRUE))
# Use a more friendly name, e.g., meanWeight, or whatever you want to call it.
summarize(nh, meanWeight=mean(Weight, na.rm = TRUE))

### group_by() ####
# - group_by() also isn't that useful on its own
# - takes an existing data frame and coverts it into a grouped data frame
# - operations are performed by group

nh
group_by(nh, Race)
group_by(nh, Race, Diabetes)

# The real power comes in where group_by() and summarize() are used together

# Get the mean Weight for each race
# group_by(nh, Race)
summarize(group_by(nh, Race), meanWeight=mean(Weight, na.rm = TRUE))

# Get the mean Weight for each race and Diabetes status
# group_by(nh, Race, Diabetes)
summarize(group_by(nh, Race, Diabetes), meanWeight=mean(Weight, na.rm = TRUE))


## The pipe: %>% ####
# - dplyr imports functionality from the magrittr package
# - lets you "pipe" the output of one function to the input of another
# - avoids nesting functions

# These two commands are identical:
head(nh, 5)
nh %>% head(5)

# Let's use one of the dplyr verbs
filter(nh, SmokingStatus =="Current")
nh %>% filter(SmokingStatus =="Current")


# Exercises ####
# 1. Make a summary table of mean weight for each race and diabetes status (first filtering out Diabetes = NA). Then round the means to 2 digits and sort the results by the mean weight of each group

nh %>% 
  filter(Diabetes != "NA") %>%
  group_by(Race, Diabetes) %>% 
  summarize(meanWeight = mean(Weight, na.rm = TRUE)) %>% 
  mutate(meanWeight=round(meanWeight,2)) %>% 
  arrange(meanWeight)

# process  
# 1. Take the  nh dataset
# 2. then filter() it for Diabetes Yes/No (!= NA)
# 3. then group_by() the Race and Diabetes Status
# 4. then summarize() to get the mean Weight for each group 
# 5. then mutate() to round the result of the above calculation to two significant digits
# 6. then arrange() by the rounded mean weight above

# without the pipe, it gets ugly
arrange(mutate(summarize(group_by(filter(nh, Diabetes !="NA"), Race, Diabetes), meanWeight=mean(Weight, na.rm = TRUE)), meanWeight=round(meanWeight, 2)), meanWeight)


# 2. Show the BPSys, BPDia, and TotChol for minority people when Weight >= 100kg. Hint: 2 pipes: filter and select.

nh %>% 
  filter(Race != "White" & Weight >= 100) %>% 
  select(BPSys, BPDia, TotChol)

# 3. Show the four female, current smokers with the highest Testosterone values. Return these womens' Race, Pulse, and Weight. Hint: 4 pipes: filter, arrange, head, and select.

nh %>% 
  filter(Gender=="female" & SmokingStatus== "Current") %>% 
  arrange(desc(Testosterone)) %>% 
  head(4) %>% 
  select(Race, Pulse, Weight) 

# ________________________------------------------------------------------------
## tidyr ----

### Verbs
# - gather(): “gathers” multiple cols and convert into key-value pairs
# - spread(): take two cols and “spread” into multiple cols
# - separate(): helps separate single col into many cols
# - unite(): helps combine two or more cols into one

# gather & spread resolve one of two common problems:
# 1. One variable might be spread across multiple columns
# 2. One observation might be scattered across multiple rows


## gather ####
# gather() makes wide tables narrower and longer
# We need three parameters to use gather():
# - 1. the set of columns that represent values, not variables (1999 & 2000)
# - 2. the key: the variable whose values form the column names (year)
# - 3. the value: the variable whose values are spread over the cells (number of cases)

table4a # built-in data set
table4a %>% 
  gather(`1999`, `2000`, key = "year", value = "cases")

# note: backticks are needed because 1999 & 2000 don't start with a letter

table4b
table4b %>% 
  gather(`1999`, `2000`, key = "year", value = "population")

## spread ####
# the opposite problem
# spread() makes long tables shorter and wider
# only need two parameters:
# - 1. key: column that contains variable names (type)
# - 2. value: column that contains values from multiple variables (count)

table2 # an obs is a country in a year, but each obs is spread across 2 rows
table2 %>%
  spread(key = type, value = count)

## separate ####
table3  # one column (rate) that contains two variables (cases and population)

table3 %>% 
  separate(rate, into = c("cases", "population"))

# separate() defaults
# - splits values at a non-alphanumeric character
#   (to use a specific character, pass the character to the sep argument)
# - leaves the type of column as is
#   (use convert=TRUE to try to convert to a better type)

table3 %>% 
  separate(rate, into = c("cases", "population"), sep = "/", convert = TRUE)

# separate() will interpret integers passed to sep as positions
table3 %>% 
  separate(year, into = c("century", "year"), sep = 2)

## unite ####
# - combines multiple columns into a single column
# - default places underscore between columns

table5
table5 %>% 
  unite(new, century, year, sep="")

# ________________________------------------------------------------------------
## stringr ----

### verbs
# - str_sub(): extract substrings from a char vector
# - str_trim(): trim whitespace
# - str_length(): check length of the string
# - str_to_upper: converts the string into upper case
# - str_to_lower: converts the string into lower case

# R understands both ' and " as strings
string1 <- "This is a string"
string2 <- 'If I want to include a "quote" inside a string, I use single quotes'

# for a literal single or double quote
double_quote <- "\"" # or '"'
single_quote <- '\'' # or "'"
backslash <- "\\"

## Review of strings ####
# - concatenating strings & integers with c() converts integers to characters
# - by default, R converts objects to their lowest denomination
# - factors reduce to integers and integers reduce to characters
c(factor("a"), "b", "&", 1)
c(as.character(factor("a")), "b", "&", 1)

# Some data ####
movie_titles <- c("gold diggers of broadway", "gone baby gone", 
                  "gone in 60 seconds", "gone with the wind", "good girl, the", 
                  "good burger", "goodbye girl, the", "good bye lenin!", 
                  "goodfellas", "good luck chuck", "good morning, vietnam", 
                  "good night, and good luck.", "good son, the", 
                  "good will hunting")
strings <- c(" 219 733 8965", "329-293-8753 ", "banana", "595 794 7569",
             "387 287 6718", "apple", "233.398.9187  ", "482 952 3315", 
             "239 923 8115 and 842 566 4692", "Work: 579-499-7527", "$1000",
             "Home: 543.355.3679")
fruit <- c("apple", "banana", "pear", "pineapple")

## Basic String Operators
# - string operators are basic string manipulation functions
# - many of them have equivalent base R that are much slower and bulkier

# str_to_upper(string) ####
# - converts strings to uppercase
# - ex. Convert all movie_titles to uppercase and store them as movie_titles
movie_titles <- str_to_upper(movie_titles)
movie_titles

# str_to_lower(string) ####
# - converts strings to lowercase
# - ex. Convert all movie_titles back to lowercase and save as movie_titles
movie_titles <- str_to_lower(movie_titles)
movie_titles

# str_to_title(string) ####
# - converts strings to title case
# - ex. Convert all movie_titles to titlecase and store them as movie_titles
movie_titles <- str_to_title(movie_titles)
movie_titles

# str_length(string) ####
# - returns the string length
# - similar to base function nchar()
# - converts factors to strings and also preserves NA's
str_length(movie_titles)

nchar(NA)
str_length(NA)


## Extracting substrings ####

# str_sub()
# - str_sub(string, start, end) <- value
# - subsets text within a string or vector of strings by specifying start & end
# - base equivalent function is substr()
# - by default, end goes to the end of the word
fruit
str_sub(fruit, start = 3)


## White Space ####

# str_trim(): trim whitespace
# - str_trim(string, side = c("both", "left", "right"))
# - removes leading and trailing whitespaces
# - side argument defaults to "both"
# - ex. trim the whitespace from both sides of every string in "strings"
str_trim(strings)

# str_pad(string, width, side = c("left", "both", "right"), pad = " ")
# - pads strings with whitespace to make them a certain length
# - width argument lets users specify the width of the padding
# - Side argument defaults to "left"
# - ex. pad "movie_titles" with whitespace such that each title is 30 chars long
str_pad(movie_titles, side = "right", 30)


## Detecting Patterns ####

# str_detect()
# - detectes whether a pattern is present in a string vector 
# - this function is a wraper of grepl()
head(state.name)
str_detect(state.name, pattern = "New")

# count the total matches by wrapping with sum
sum(str_detect(state.name, pattern = "New"))


# Locating Patterns ####

# 1. Locate First Match: str_locate()
#    - locates the position of the first occurrence
#    - provides the starting & ending position of the first match found
x <- c("abcd", "a22bc1d", "ab3453cd46", "a1bc44d")
str_locate(x, "[0-9]+") # find 1st sequence of 1 or more consecutive numbers

# 2. Locate All Matches: tr_locate_all()
#    - locates the positions of all pattern matches
#    - provides a list the same length as the number of elements in the vector
#    - each list item provides the start & end positions for each pattern match 
str_locate_all(x, "[0-9]+") # find all sequences of 1+ consecutive numbers

# ________________________------------------------------------------------------
## forcats ----

# main functions
# - fct_reorder(): reorder a factor by another variable
# - fct_infreq(): reorder by the frequency of values
# - fct_relevel(): change order of a factor by hand
# - fct_lump(): collapse least/ most frequent values of a factor into “other”

# imagine that a variable that records month
x1 <- c("Dec", "Apr", "Jan", "Mar")

# Using a string to record this variable has two problems:
# - there are only 12 possible months & nothing saves you from typos:
# - doesn’t sort in a useful way
x2 <- c("Dec", "Apr", "Jam", "Mar")
sort(x1)

# Factors fix both of these problems with a factor
# - start by creating a list of the valid levels
# - then create the factor
month_levels <- c("Jan", "Feb", "Mar", "Apr", "May", "Jun", 
                  "Jul", "Aug", "Sep", "Oct", "Nov", "Dec")
y1 <- factor(x1, levels = month_levels)
y1
sort(y1)

# Values not in the set are silently converted to NA:
y2 <- factor(x2, levels = month_levels)
y2

# If you omit the levels, they’re taken in alphabetical order:
factor(x1)

# access the set of valid levels directly with levels():
levels(f2)

## Modifying factor order ####
# - reserve fct_reorder() for factors whose levels are arbitrarily ordered
# - fct_reorder() takes three arguments:
#    1. f, the factor whose levels you want to modify
#    2. x, a numeric vector that you want to use to reorder the levels
#    3. fun (optional), a function used for each value of f when there are multiple values; default value is median

relig_summary <- gss_cat %>%
  group_by(relig) %>%
  summarise(
    age = mean(age, na.rm = TRUE),
    tvhours = mean(tvhours, na.rm = TRUE),
    n = n())

relig_summary %>%
  ggplot(aes(tvhours, relig)) +
  geom_point()

relig_summary %>%
  mutate(relig = fct_reorder(relig, tvhours)) %>%
  ggplot(aes(tvhours, relig)) +
  geom_point()

rincome_summary <- gss_cat %>%
  group_by(rincome) %>%
  summarise(age = mean(age, na.rm = TRUE),
            tvhours = mean(tvhours, na.rm = TRUE),
            n = n())

rincome_summary %>%
  ggplot(aes(age, fct_reorder(rincome, age))) + 
  geom_point()

## fct_relevel() ####
# - takes a factor, f, and any number of levels you want moved to the front
# - pull “Not applicable” to the front 
rincome_summary %>%
  mutate(rincome = fct_relevel(rincome, "Not applicable")) %>%
  ggplot(aes(age, rincome)) +
  geom_point()

## fct_infreq() ####
# - reorder by the frequency of values
gss_cat %>%
  mutate(marital = marital %>% fct_infreq()) %>%
  ggplot(aes(marital)) +
  geom_bar()

## fct_lump() ####
# - collapse least/ most frequent values of a factor into “other"
# - lump together all the small groups to make a plot or table simpler
gss_cat %>%
  mutate(relig = fct_lump(relig)) %>%
  count(relig)


# ________________________------------------------------------------------------
## lubridate ----


# Main functions
# - Date-times: ymd(), dmy(), myd(), etc.
# - Components: year(), month(), mday(), hour(), minute(), second()
# - Time zones: with_tz(), force_tz()

# system time ####
today()
now()

# Creating a date/time:
# 1. from a string
# 2. from individual date-time components
# 3. from an existing date/time object

# lubridate helpers automatically work out the format once you specify the order
# - identify the order in which year, month, and day appear in your dates
# - arrange “y”, “m”, and “d” in the same order
# - order is the name of the lubridate function that will parse your date

## helpers ####
ymd("2017-01-31")
mdy("January 31st, 2017")
dmy("31-Jan-2017")
ymd(20170131) # also takes unquoted dates

## create a date-time ####
# add an underscore and one or more of “h”, “m”, and “s” to the name
ymd_hms("2017-01-31 20:11:59")
mdy_hm("01/31/2017 08:01")

# force the creation of a date-time from a date by supplying a timezone:
ymd(20170131, tz = "UTC")

## Getting components ####
# - pull out individual parts of the date with the accessor functions
# - year(), month(), mday() (day of the month), yday() (day of the year), wday() (day of the week), hour(), minute(), and second()

datetime <- ymd_hms("2016-07-08 12:34:56")
year(datetime)
month(datetime)
mday(datetime)
yday(datetime)
wday(datetime)

# label = TRUE returns the abbreviated name of the month or day of the week
# abbr = FALSE returns the full name
month(datetime, label = TRUE)
wday(datetime, label = TRUE, abbr = FALSE)

## Timezones ####
# - Unless otherwise specified, lubridate always uses UTC
# - complete list of all time zone names with OlsonNames():
Sys.timezone()
head(OlsonNames())

# timezones are an attribute of the date-time
# - only controls printing
# - these three objects represent the same instant in time:
(x1 <- ymd_hms("2015-06-01 12:00:00", tz = "America/New_York"))
(x2 <- ymd_hms("2015-06-01 18:00:00", tz = "Europe/Copenhagen"))
(x3 <- ymd_hms("2015-06-02 04:00:00", tz = "Pacific/Auckland"))

# verify:
x1 - x2
x1 - x3

## Change the time zone in two ways:

# 1. Keep the instant in time the same but change how it’s displayed
#    (use when the instant is correct, but you want a more natural display)
x4 <- c(x1, x2, x3)
x4a <- with_tz(x4, tzone = "Australia/Lord_Howe")
x4a

# 2. Change the underlying instant in time
#    (use when an instant has the incorrect time zone you need to fix)
x4b <- force_tz(x4, tzone = "Australia/Lord_Howe")
x4b

# ________________________------------------------------------------------------
# Sources ----
# - Wickham, H & Grolemund, G. 2016. R for Data Science. O'Reilly Media.
# - Jones, M. 2017. Pipes and Plotting for RLadies MeetUp. 12/4/2017. [ManipulatingData_dplyr.Rmd]
# - Espinoza, B. 2016. Advanced R Workshop: An Introduction to Stringr [An Introduction to Stringr.Rmd].
# - Boehmke, B. Regex Functions in Stringr. (https://bradleyboehmke.github.io/tutorials/stringr_regex_functions)
# - Harvard Chan Informatics Biocore. Introduction to R. HBC Training. (https://hbctraining.github.io/Intro-to-R/lessons/tidyverse_data_wrangling.html)
# - Analytics Vidhya Content Team. 2019l A Beginner's Guide to Tidyverse: the Most Powerful Collection of R Packages for Data Science. (https://www.analyticsvidhya.com/blog/2019/05/beginner-guide-tidyverse-most-powerful-collection-r-packages-data-science/)
# - Frigaard. 2017. Getting Started with tidyverse in R. (http://www.storybench.org/getting-started-with-tidyverse-in-r/)
# - RStudio. Tidyverse. (https://lubridate.tidyverse.org)
