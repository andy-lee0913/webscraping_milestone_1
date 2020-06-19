#
# This is a Shiny web application. You can run the application by clicking
# the 'Run App' button above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#
library(dplyr)
library(ggplot2)
library(stringr)
library(shiny)

# Define UI for application that draws a histogram
ui <- fluidPage(

    # Application title
    titlePanel("The prediction of cpi value for Austria"),

    # Sidebar with a slider input for number of bins 
    sidebarLayout(
        sidebarPanel(
            numericInput("year",
                         label=h4("please enter the year and month you want to predict,for example, 202008 for the August in 2020"),
                         value = 202007),
        ),
        sidebarPanel(
            h3('The predicted cpi is: '),
            h4(textOutput("predict"))
        ),
    ),
    
    mainPanel(
        h3('The line graph for the quadratic model'),
        plotOutput("model",)
    )
)

# Define server logic required to draw a histogram
server <- function(input, output) {

    
    df <- read.csv("clean_cpi.csv")
    
    df$TIME <- str_replace_all(df$TIME, '-', '')
    df$TIME <- as.numeric(df$TIME)
    aut <- filter(df ,LOCATION=="AUT")
    time = aut$TIME
    value = aut$Value
    y <- value 
    x1 <- time
    x2 <- x1^2
    model <- lm(value ~ x1 + x2)
    
    x3 <- reactive({input$year})
    
    output$predict <- renderText({
        predict(model, data.frame(x1 = x3(), x2 = x3()^2))
    })
    
    output$model <- renderPlot({
        ggplot(aut, aes(x=TIME , y=Value)) + 
            geom_point(aes(color = LOCATION)) +
            geom_line(aes(y = predict(model)))
    })
}

# Run the application 
shinyApp(ui = ui, server = server)
