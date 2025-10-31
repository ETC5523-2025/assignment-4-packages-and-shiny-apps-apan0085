## code to prepare `last_names` dataset goes here

last_names <- data.frame(
  Surname = c(
    "Smith", "Johnson", "Williams", "Brown", "Jones",
    "Garcia", "Rodriguez", "Miller", "Martinez", "Davis",
    "Hernandez", "Lopez", "Gonzalez", "Wilson", "Anderson",
    "Thomas", "Taylor", "Lee", "Moore", "Jackson", "Perez"
  ),
  Per_1000_Americans = c(
    8.0, 6.3, 5.3, 4.7, 4.7,
    4.1, 3.8, 3.7, 3.7, 3.6,
    3.4, 2.9, 2.8, 2.7, 2.6,
    2.5, 2.4, 2.4, 2.4, 2.3, 2.3
  )
)


usethis::use_data(last_names, overwrite = TRUE)
