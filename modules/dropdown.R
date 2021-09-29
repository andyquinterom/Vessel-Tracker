dropdown_ui <- function(id, choices, value, title) {

  ns <- NS(id)

  tagList(
    div(
      style = "
        display: flex;
        align-items: left;
        justify-content: center;
      ",
      if (!missing(title)) {
        div(
          h4(
            style = "
              position: relative;
              top: 50%;
              margin: 0 10px;
              transform: translateY(-50%);
              white-space: nowrap;
            ",
            title
          ),
        )
      },
      dropdown_input(
        ns("dropdown"),
        choices = choices,
        value = value
      )
    )
  )
}

dropdown_server <- function(id, choices) {
  ns <- NS(id)

  moduleServer(
    id = id,
    module = function(input, output, session) {

      # Reactive that return the value of the dropdown when it is not empty.
      # I return NULL when empty so the dependencies don't react for empty
      # values.
      selected <- reactive(
        if (input$dropdown == "") {
          return(NULL)
        } else {
          return(input$dropdown)
        }
      )

      observe({
        update_dropdown_input(
          input_id = "dropdown",
          session = session,
          choices = choices()
        )
      }) %>%
        bindEvent(choices())

      return(selected)

    }
  )
}
