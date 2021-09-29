function(input, output, session) {

  # I have setup this as a reactive rather than a simple vector
  # in case retrieving data from a database is in the plans for the future.
  # If it were to be confirmed that all data would be pre-processed then
  # this could be replaced with simpler process.
  ship_types <- reactive({
    ship_data %>%
      distinct(ship_type) %>%
      arrange(ship_type) %>%
      pull()
  })

  # The module for the dropdown return a reactive with the selected value.
  selected_type <- dropdown_server(id = "shiptype", ship_types)

  # We use the selected ship_type to filter out the ships that can be selected
  # in the dropdown.
  vessels <- reactive({
    ship_data %>%
      filter(ship_type == selected_type()) %>%
      distinct(SHIPNAME) %>%
      arrange(SHIPNAME) %>%
      pull()
  }) %>%
    bindEvent(selected_type())

  selected_vessel <- dropdown_server(id = "vessel", vessels)

  # Since calculating the distance between the different coordinates
  # can be a little slow, it is only applied to the subset (filtered by
  # ship_type and name).
  map_data <- reactive({
    filter(ship_data, SHIPNAME == selected_vessel()) %>%
      rowwise() %>%
      mutate(distance = distGeo(c(LON, LAT), c(LON_LAST, LAT_LAST))) %>%
      ungroup()
  }) %>%
    bindEvent(selected_vessel())

  output$map_plot <- renderLeaflet({

    # This subset is done to identify the Longitude and Latitude of the
    # first and last observations in the dataset.
    first_observation <- map_data() %>%
      head(1) %>%
      select(DATETIME, LON, LAT)
    
    last_observation <- map_data() %>%
      tail(1) %>%
      select(DATETIME, LON, LAT)
    
    start_marker <- first_observation %>%
      add_row(last_observation)

    # We retrieve the maximum distance between two consecutive observations
    # We use the function tail in order to return the latest possible
    # observation since the dataset it arranged by DATETIME from the start.
    dist_marker <- map_data() %>%
      filter(distance == max(distance, na.rm = TRUE)) %>%
      tail(1)

    # A data.frame with the data for the maximum distance observation.
    # This is done to then plot it into the map.
    dist_data <- data.frame(
      LON = c(dist_marker$LON_LAST, dist_marker$LON),
      LAT = c(dist_marker$LAT_LAST, dist_marker$LAT)
    )

    # The creation of the map
    leaflet(map_data()) %>%
      addProviderTiles(providers$CartoDB.Positron) %>%
      addPolylines(
        ~LON,
        ~LAT
      ) %>%
      addPopups(
        data = start_marker,
        ~LON,
        ~LAT,
        popup = c("First observation", "Last observation")
      ) %>%
      addCircleMarkers(
        data = dist_data,
        ~LON,
        ~LAT,
        color = "red",
        opacity = 1
      ) %>%
      addPolylines(
        data = dist_data,
        ~LON,
        ~LAT,
        opacity = 1,
        label = paste(
          "Maximum distance beween consecutive observations:",
          round(dist_marker$distance, digits = 0) %>%
            format(decimal.mark = ",", big.mark = "."),
          "Metres"),
        color = "red"
      ) %>%
      addLegend(
        position = "bottomleft",
        colors = c("red", "blue"),
        labels = c(
          "Longest path between two consecutive observations",
          "Trajectory of the vessel"
        )
      ) %>%
      addScaleBar(
        position = "bottomright",
        options = scaleBarOptions(metric = TRUE, maxWidth = 300)
      )
  }) %>%
    bindEvent(map_data())

  # Render UI for info card about the selected vessel
  output$info_card <- renderUI({
    # Simple summary to extract data about the vessel
    card_data <- map_data() %>%
      group_by(SHIPNAME) %>%
      summarise(
        max_distance = max(distance, na.rm = TRUE),
        start_date = min(DATETIME, na.rm = TRUE),
        end_date = max(DATETIME, na.rm = TRUE),
        flag = first(FLAG),
        total_distance = sum(distance, na.rm = TRUE),
        port = last(port),
        length = max(LENGTH),
        width = max(WIDTH)
      )

    # UI for the info card
    card(
      style = "width: 95%",
      # Missing flags are found as NaN in the dataset.
      if (card_data$flag != "NaN") {
        div(
          class = "ui",
          # API for retrieving flags. I find it to be a nice detail to add.
          img(
            class = "ui centered image",
            src = paste0(
              "https://www.countryflags.io/",
              card_data$flag,
              "/flat/64.png"
            )
          )
        )
      },
      div(
        class = "content",
        div(class = "header", selected_vessel()),
        div(class = "meta", selected_type()),
        tags$ul(
          tags$li(
            tags$b("Assigned port:"),
            card_data$port %>%
              format(decimal.mark = ",", big.mark = ".")
          ),
          tags$li(
            tags$b("Vessel length:"),
            card_data$length %>%
              format(decimal.mark = ",", big.mark = "."),
            "Metres"
          ),
          tags$li(
            tags$b("Vessel width:"),
            card_data$width,
            "Metres"
          ),
          tags$li(
            tags$b("First observation:"),
            card_data$start_date
          ),
          tags$li(
            tags$b("Final observation:"),
            card_data$end_date
          ),
          tags$li(
            tags$b("Maximum distance between observations:"),
            round(card_data$max_distance, digits = 0) %>%
              format(decimal.mark = ",", big.mark = "."),
            "Metres"
          ),
          tags$li(
            tags$b("Total distance travelled:"),
            round(card_data$total_distance, digits = 0) %>%
              format(decimal.mark = ",", big.mark = "."),
            "Metres"
          )
        )
      )
    )

  }) %>%
    bindEvent(map_data())
  
}
