#
# This is the user-interface definition of a Shiny web application. You can
# run the application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
# 
#    http://shiny.rstudio.com/
#

library(shiny)
library(ggplot2)
library(dplyr)

  # Define UI for application that draws a histogram
  ui <- fluidPage(
    
    # Application title
    titlePanel("1980 Murders"),
    # Sidebar with a slider input for number of bins 
    sidebarLayout(
      sidebarPanel(
        checkboxGroupInput("Relationship",
                           "Choose Relationship:",
                           c('Aquaintance', 'Boyfriend', 'Boyfriend/Girlfriend', 'Brother', 'Common-Law Husband', 'Daughter', 'Ex-Wife', 'Family', 'Father', 'Friend', 'Girlfriend', 'Husband', 'In-Law', 'Mother', 'Neighbor', 'Son', 'Stranger', 'Wife', 'Unknown'),
                           selected = 'Wife'
        ),
        checkboxGroupInput("Sex",
                           "Sex:",
                           c("Male", "Female", "Unknown"),
                           selected = 'Male')
      ),
      
      # Show a plot of the generated distribution
      mainPanel(
        plotOutput("mainPlot"),
        tableOutput("results")
      )
    )
  )

