#
# This is the server logic of a Shiny web application. You can run the 
# application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
# 
#    http://shiny.rstudio.com/
#
library(shiny)
library(dplyr)
# This is the server logic of a Shiny web application.

murders<- read.csv("murders1980.csv")
# check stucture of the data
print(str(murders))
short <- murders %>%
  select(Perpetrator.Sex, Relationship)
print(str(short))
colnames(short)<-c("Perpetrator.Sex", "Relationship")
# Define server logic required to draw a histogram
shinyServer(function(input, output) {
  
  output$mainPlot <- renderPlot({
    filtered <- 
      short %>%
      filter(Perpetrator.Sex ==input$Sex,
             Relationship == input$Relationship
      )
    print(glimpse(filtered))
    ggplot(filtered, aes(Perpetrator.Sex, Relationship)) +
    geom_count(col="tomato3", show.legend=T) 
  })
})