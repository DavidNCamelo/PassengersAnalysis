# Importing data through R

# base URL
base_url <- "https://www.datos.gov.co/resource/eh75-8ah6.csv"

# Current year to reference data updates until
# the mmoment where this code will be runned
current_year <- lubridate::year(Sys.Date())

# empty list to save files
dataframes <- list()

# Iterating from 2019 until current date
for (year in 2019:current_year) {
  # Rebuilding the url, based on API documentation
  year_url <- paste0(
    base_url,
    "?$where=fecha_despacho%20between%20%27",
    year,
    "-01-01T00:00:00%27%20and%20%27",
    year,
    "-12-31T00:00:00%27",
    "&$limit=100000000"
  )

  # Read directly the file
  df <- readr::read_csv(year_url, show_col_types = FALSE)

  # Append into the main list
  dataframes[[as.character(year)]] <- df
}

# Joining in a single datafram
cols_fix <- c(
  "municipio_origen_ruta",
  "municipio_destino_ruta"
)

data <- dataframes |>
  purrr::keep(~ nrow(.x) > 0) |>
  purrr::map(
    ~ dplyr::mutate(
      .x,
      dplyr::across(dplyr::all_of(cols_fix), as.character)
    )
  ) |>
  dplyr::bind_rows()

# Upper the column names
names(data) <- toupper(names(data))

# Vista previa
print(utils::head(data))
