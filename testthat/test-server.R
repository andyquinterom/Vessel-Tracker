
# Test behaviour for dropdowns. They should return NULL if the value
# of dropdown is empty.
testServer(dropdown_server, args = list(choices = reactive({"Example"})), {
  session$setInputs(dropdown = "")
  expect_equal(session$returned(), NULL)

  session$setInputs(dropdown = "Example")
  expect_equal(session$returned(), "Example")
})

# This test will itereate over every ship type and vessel and determine if
# the plot and the info card are generate. This will not evualuate how the
# plot looks since it is out of the scope of this project.
testServer(expr = {

  tests <- purrr::map(
    ship_types(),
    function(ship_type) {
      session$setInputs(`shiptype-dropdown` = ship_type)
      # The reactive selected_type should react to the change in the input
      expect_equal(selected_type(), ship_type)
      purrr::map(
        vessels(),
        function(vessel) {
          session$setInputs(`vessel-dropdown` = vessel)
          # The reactive selected_vessel should react to the change in the input
          expect_equal(selected_vessel(), vessel)
          # By referencing the outputs we test for warnings and errors
          output$map_plot
          output$info_card
        }
      )
    }
  )

})
