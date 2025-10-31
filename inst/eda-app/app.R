# Load required libraries
library(shiny)
library(shinydashboard)
library(ggplot2)
library(dplyr)

# Load your dataset from your package
data("last_names", package = "SurNamExp")

# Define UI
ui <- dashboardPage(
  dashboardHeader(title = "Most Common U.S. Surnames"),

  dashboardSidebar(
    sidebarMenu(
      menuItem("Dashboard", tabName = "dashboard", icon = icon("bar-chart")),
      hr(),

      selectInput(
        "sortOrder",
        "Sort Order:",
        choices = c("Descending", "Ascending"),
        selected = "Descending"
      ),

      selectInput(
        "palette",
        "Color Palette:",
        choices = c("Tomato", "Sky Blue", "Forest Green", "Purple", "Gray"),
        selected = "Tomato"
      ),

      radioButtons(
        "theme",
        "Theme:",
        choices = c("Light", "Dark"),
        selected = "Light"
      )
    )
  ),

  dashboardBody(
    # Theme styles
    tags$head(
      tags$style(HTML("
        body.light-mode {
          background-color: #f9f9f9;
          color: #222;
        }
        body.dark-mode {
          background-color: #121212;
          color: #f0f0f0;
        }
        .box {
          border-radius: 10px;
          box-shadow: 0px 2px 10px rgba(0,0,0,0.2);
        }
      "))
    ),

    tabItems(
      tabItem(tabName = "dashboard",
              fluidRow(
                box(
                  title = "Surname Frequency",
                  width = 12,
                  solidHeader = TRUE,
                  plotOutput("surnamePlot", height = "500px")
                )
              )
      )
    ),

    # JavaScript for theme toggle
    tags$script(HTML("
      Shiny.addCustomMessageHandler('toggleTheme', function(theme) {
        document.body.className = theme === 'Dark' ? 'dark-mode' : 'light-mode';
      });
    "))
  )
)

# Define server logic
server <- function(input, output, session) {

  # Update theme dynamically
  observe({
    session$sendCustomMessage("toggleTheme", input$theme)
  })

  # Reactive dataset for sorting
  sorted_data <- reactive({
    data <- last_names

    if (input$sortOrder == "Ascending") {
      data <- data %>% arrange(Per_1000_Americans)
    } else {
      data <- data %>% arrange(desc(Per_1000_Americans))
    }

    data
  })

  # Render plot
  output$surnamePlot <- renderPlot({
    data <- sorted_data()

    # Map color palette
    color_map <- switch(input$palette,
                        "Tomato" = "tomato",
                        "Sky Blue" = "skyblue",
                        "Forest Green" = "forestgreen",
                        "Purple" = "purple",
                        "Gray" = "gray40")

    ggplot(data, aes(x = reorder(Surname, Per_1000_Americans), y = Per_1000_Americans)) +
      geom_col(fill = color_map) +
      coord_flip() +
      labs(
        title = "Most Common U.S. Surnames (per 1,000 Americans)",
        x = "Surname",
        y = "Per 1,000 Americans"
      ) +
      theme_minimal(base_size = 14) +
      theme(
        plot.title = element_text(face = "bold", size = 16),
        axis.text = element_text(size = 12)
      )
  })
}

# Run the Shiny app
shinyApp(ui, server)
