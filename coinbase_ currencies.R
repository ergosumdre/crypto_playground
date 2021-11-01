library("httr")
library("jsonlite")


# this script will return all crypto currencies known to CB.
coinbase_currencies_to_df <- function(){
  response <- GET(url = "https://api.exchange.coinbase.com/currencies")
  df <- jsonlite::fromJSON(httr::content(response, as= "text"))
  return(df)
}
