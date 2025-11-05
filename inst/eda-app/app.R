# inst/app/app.R

# Load required libraries
library(shiny)
library(shinydashboard)
library(ggplot2)
library(dplyr)
library(DT)
library(plotly)
library(viridisLite)

# Load your dataset from your package
data("last_names", package = "SurNamExp")

# ---------- UI ----------
ui <- dashboardPage(
  dashboardHeader(title = "Most Common U.S. Surnames"),
  dashboardSidebar(
    sidebarMenu(
      menuItem("Controls", tabName = "controls", icon = icon("sliders")),
      hr(),

      # Sorting
      selectInput("sortOrder", "Sort Order:",
                  choices = c("Descending", "Ascending"),
                  selected = "Descending"),

      # Filters
      textInput("searchName", "Search surname (contains):", ""),
      numericInput("topN", "Show top N rows:", value = 21, min = 5, max = 100, step = 1),

      # ----- BAR COLORING CONTROLS -----
      radioButtons("colorMode", "Bar coloring:",
                   choices = c("Single color", "Palette"),
                   selected = "Single color"),

      conditionalPanel("input.colorMode == 'Single color'",
                       selectInput("singleColor", "Single color:",
                                   choices = c("Auto (neutral)", "Tomato", "Sky Blue",
                                               "Forest Green", "Purple", "Gray"),
                                   selected = "Auto (neutral)")
      ),
      conditionalPanel("input.colorMode == 'Palette'",
                       selectInput("paletteName", "Palette name:",
                                   choices = c("viridis", "plasma", "cividis", "Blues", "Greens", "Reds"),
                                   selected = "viridis")
      ),

      checkboxInput("showLabels", "Show value labels on bars (ggplot2)", value = TRUE),

      # Plot engine
      radioButtons("plotEngine", "Plot engine:",
                   choices = c("Static (ggplot2)" = "ggplot2",
                               "Interactive (plotly)" = "plotly"),
                   selected = "ggplot2"),

      # Zoom
      fluidRow(
        column(6, actionButton("zoom_in",  "+ Zoom")),
        column(6, actionButton("zoom_out", "- Zoom"))
      ),

      hr(),
      helpText("Tip: DATASET for sort/search/export. PLOTS for visuals (ggplot2 or plotly).")
    )
  ),
  dashboardBody(
    # ---- Custom styling (sidebar + basics) ----
    tags$head(
      tags$style(HTML("
        :root { --app-font-size: 14px; }
        body  { font-size: var(--app-font-size) !important; background: #f7f7f7; color: #1d1d1d; }
        .box  { border-radius: 10px; box-shadow: 0 2px 10px rgba(0,0,0,0.18); }
        div.dataTables_wrapper { width: 100%; overflow-x: auto; }

        /* ===== Sidebar colours — change these three to suit ===== */
        .main-sidebar, .left-side { background-color: #ffffff !important; }  /* sidebar bg */
        .sidebar-menu > li > a, .sidebar .sidebar-menu a { color: #333333 !important; } /* text */
        .sidebar-menu > li.active > a, .sidebar-menu > li > a:hover {
          background-color: #e9f2ff !important; color: #000000 !important; } /* active/hover */
        .main-sidebar { box-shadow: none !important; border-right: 1px solid #e5e5e5 !important; }
        .sidebar .header { color: #666666 !important; }
      "))
    ),

    # Top tabs
    tabsetPanel(id = "topTabs", type = "pills",
                tabPanel("DATASET",
                         br(),
                         fluidRow(
                           box(width = 12, title = "Surname Frequency Table", solidHeader = TRUE,
                               status = "primary",
                               p(class = "text-muted",
                                 "Use the sidebar to sort ascending/descending, search by name, choose top N, and export."),
                               DTOutput("surnameTable"))
                         )
                ),
                tabPanel("PLOTS",
                         br(),
                         fluidRow(
                           box(width = 12, title = "Surname Frequency (per 1,000)", solidHeader = TRUE,
                               status = "primary",
                               conditionalPanel("input.plotEngine == 'ggplot2'",
                                                plotOutput("surnamePlot", height = "520px")
                               ),
                               conditionalPanel("input.plotEngine == 'plotly'",
                                                plotlyOutput("surnamePlotly", height = "520px")
                               )
                           )
                         )
                )
    ),

    # Dynamic CSS for zoom (font scaling)
    uiOutput("dynamic_css"),

    # JS to change root font size (zoom)
    tags$script(HTML("
      Shiny.addCustomMessageHandler('setFontSize', function(px) {
        document.documentElement.style.setProperty('--app-font-size', px + 'px');
      });
    "))
  )
)

# ---------- Server ----------
server <- function(input, output, session) {
  # Zoom management
  font_px <- reactiveVal(14L)
  observeEvent(input$zoom_in,  { font_px(min(font_px() + 1L, 26L)) })
  observeEvent(input$zoom_out, { font_px(max(font_px() - 1L, 10L)) })
  observe({ session$sendCustomMessage("setFontSize", font_px()) })

  # ----- COLOR HANDLERS -----
  single_color <- reactive({
    if (input$singleColor == "Auto (neutral)" || is.null(input$singleColor)) {
      "#333333"  # neutral dark gray
    } else {
      switch(input$singleColor,
             "Tomato"       = "tomato",
             "Sky Blue"     = "skyblue",
             "Forest Green" = "forestgreen",
             "Purple"       = "purple",
             "Gray"         = "gray40",
             "#333333")
    }
  })

  palette_colors <- function(n, paletteName) {
    if (paletteName %in% c("viridis","plasma","cividis")) {
      if (paletteName == "viridis") return(viridis(n))
      if (paletteName == "plasma")  return(plasma(n))
      if (paletteName == "cividis") return(cividis(n))
    }
    if (paletteName == "Blues")  return(colorRampPalette(c("#cfe8ff","#084594"))(n))
    if (paletteName == "Greens") return(colorRampPalette(c("#c7e9c0","#006d2c"))(n))
    if (paletteName == "Reds")   return(colorRampPalette(c("#fcbba1","#99000d"))(n))
    colorRampPalette(c("#e0e0e0","#333333"))(n) # fallback
  }

  # Sorted/filtered data
  filtered_sorted <- reactive({
    df <- last_names
    if (nzchar(input$searchName)) {
      df <- df |> filter(grepl(input$searchName, Surname, ignore.case = TRUE))
    }
    df <- if (identical(input$sortOrder, "Ascending")) {
      df |> arrange(Per_1000_Americans)
    } else {
      df |> arrange(desc(Per_1000_Americans))
    }
    n <- suppressWarnings(as.integer(input$topN))
    if (!is.na(n) && n > 0) df <- head(df, n)
    df
  })

  # DATASET tab
  output$surnameTable <- renderDT({
    datatable(
      filtered_sorted(),
      rownames = FALSE,
      extensions = c("Buttons"),
      options = list(
        ordering   = TRUE,
        pageLength = 21,
        lengthMenu = list(c(10, 21, 50, 100, -1), c('10', '21', '50', '100', 'All')),
        dom        = "Bfrtip",
        buttons    = c("copy", "csv", "excel"),
        scrollX    = TRUE
      ),
      class = "stripe hover cell-border"
    )
  })

  # ---- PLOTS: ggplot2 ----
  output$surnamePlot <- renderPlot({
    df <- filtered_sorted()
    base_sz <- font_px()

    if (identical(input$colorMode, "Single color")) {
      p <- ggplot(df, aes(x = reorder(Surname, Per_1000_Americans),
                          y = Per_1000_Americans)) +
        geom_col(fill = single_color()) +
        coord_flip()
    } else {
      cols <- palette_colors(nrow(df), input$paletteName)
      p <- ggplot(df, aes(x = reorder(Surname, Per_1000_Americans),
                          y = Per_1000_Americans,
                          fill = Per_1000_Americans)) +
        geom_col() +
        scale_fill_gradientn(colors = cols, guide = "none") +
        coord_flip()
    }

    p +
      labs(
        title = "Most Common U.S. Surnames (per 1,000 people)",
        x = "Surname",
        y = "Per 1,000 people"
      ) +
      theme_minimal(base_size = base_sz) +
      theme(
        plot.title = element_text(face = "bold", size = base_sz + 2),
        axis.text  = element_text(size = base_sz - 1)
      ) +
      if (isTRUE(input$showLabels) && identical(input$colorMode, "Single color")) {
        geom_text(aes(label = Per_1000_Americans),
                  hjust = -0.1, size = (base_sz - 2) / 3.2)
      } else NULL
  })

  # ---- PLOTS: plotly ----
  output$surnamePlotly <- renderPlotly({
    df <- filtered_sorted()
    base_sz <- font_px()

    if (identical(input$colorMode, "Single color")) {
      plt <- plot_ly(
        data = df,
        x = ~Per_1000_Americans,
        y = ~reorder(Surname, Per_1000_Americans),
        type = "bar",
        orientation = "h",
        marker = list(color = single_color())
      )
    } else {
      cols <- palette_colors(nrow(df), input$paletteName)
      df <- df |> mutate(.rank = rank(Per_1000_Americans, ties.method = "first"))
      plt <- plot_ly(
        data = df,
        x = ~Per_1000_Americans,
        y = ~reorder(Surname, Per_1000_Americans),
        type = "bar",
        orientation = "h",
        marker = list(color = cols[df$.rank])
      )
    }

    plt |> layout(
      title = list(text = "Most Common U.S. Surnames (per 1,000 people)",
                   font = list(size = base_sz + 4)),
      xaxis = list(title = "Per 1,000 people",
                   tickfont = list(size = base_sz),
                   titlefont = list(size = base_sz + 2),
                   gridcolor = "#DDDDDD"),
      yaxis = list(title = "Surname",
                   tickfont = list(size = base_sz),
                   titlefont = list(size = base_sz + 2),
                   gridcolor = "#DDDDDD"),
      paper_bgcolor = "#FFFFFF",
      plot_bgcolor  = "#FFFFFF",
      font = list(size = base_sz)
    )
  })
}

# Run the Shiny app
shinyApp(ui, server)
