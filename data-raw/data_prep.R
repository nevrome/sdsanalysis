library(magrittr)

#### get meta data ####
variables <- data.table::fread("https://raw.githubusercontent.com/nevrome/sdsmeta/master/variable_list.csv")
variable_values <- data.table::fread("https://raw.githubusercontent.com/nevrome/sdsmeta/master/variable_values_list.csv")

#### create hash tables ####

# create variable hash table: number -> unified name
var_hash <- base::split(
  variables, 
  variables$form_sheet_number
) %>%
  lapply( 
    function(x) {
      hash::hash(x$variable_number, x$name_unified_de)
    }
  ) %>%
  hash::hash()

# create variable hash table: number -> r data type
var_hash_type <- base::split(
  variables, 
  variables$form_sheet_number
) %>%
  lapply( 
    function(x) {
      hash::hash(x$variable_number, x$r_data_type)
    }
  ) %>%
  hash::hash()

# create attribute hash table
variable_values %<>%
  dplyr::left_join(
    variables %>% dplyr::select(variable_number, form_sheet_number, name_unified_de), 
    by = c("variable_number", "form_sheet_number")
  )
attr_hash <- base::split(
  variable_values, 
  variable_values$name_unified_de
) %>%
  lapply( 
    function(x) {
      hash::hash(as.character(x$attribute_number), x$attribute_name)
    }
  ) %>%
  hash::hash()

#### store internal data (hash tables) ####
devtools::use_data(
  var_hash,
  var_hash_type,
  attr_hash, 
  internal = TRUE, overwrite = TRUE, pkg = "."
)