page_grid <- grid_template(
  default = list(
    areas = rbind(
      c("header", "header", "header"),
      c("selection", "selection", "selection"),
      c("info_card", "plot", "plot")
    ),
    cols_width = c("30%", "35%", "35%"),
    rows_height = c("75px", "100px", "auto")
  )
)

side_by_side <- grid_template(
  default = list(
    areas = data.frame("left", "right"),
    rows_height = "auto",
    cols_width = c("50%", "50%")
  )
)

semanticPage(
  tags$head(
    tags$link(rel = "stylesheet", type = "text/css", href = "custom.css")
  ),
  title = "Vessel Tracker",
  grid(
    page_grid,
    # Animated SVG header logo
    header = div(
      class = "ui",
      includeHTML("www/logo.svg")
    ),
    info_card = uiOutput("info_card"),
    plot = div(
      class = "ui raised segment",
      style = "height: 95%;",
      leafletOutput(
        outputId = "map_plot",
        height = "100%"
      )
    ),
    selection = div(
      class = "ui raised segment",
      grid(
        side_by_side,
        left = dropdown_ui(
          "shiptype",
          NULL,
          NULL,
          title = "Ship type"
        ),
        right = dropdown_ui(
          "vessel",
          NULL,
          NULL,
          title = "Vessel"
        )
      )
    )
  )
)
