# This script will check to see if there are new listings on coinbase pro, 
# then send an email to a user.
# This script is best ran repeatedly non-interactive. 

setwd("Downloads/coinbase_listings")

library("httr")
library("dplyr")
library("stringr")
library("data.table")
library("gmailr")

# product endpoint
# https://api.exchange.coinbase.com/products
#
# API Calls
base_url <- "https://api.exchange.coinbase.com/products"
response <- GET(url = base_url)
df <- jsonlite::fromJSON(httr::content(response, as= "text"))

# Filter on USD Tradable options
usd <- df %>% filter(stringr::str_detect(id, pattern = "USD$"))
# Save current listings
write.csv(usd, paste0(Sys.time(), "_","coinbasePro_listings.csv"))

# get newest file in DIR (noted above)
tmpshot <- fileSnapshot(".")
newCSV <- rownames(tmpshot$info[which.max(tmpshot$info$mtime),])
cb <- data.table::fread(newCSV)

# gmail auth to send email
gm_auth_configure(path = "XXXXXXXXX")

library("gmailr")
if(nrow(usd) != nrow(cb)){ # Check if there are new records
  # if new records exist, what are they
  new_listings <- usd$base_currency[(is.na(match(usd$base_currency, cb$base_currency)) == TRUE)]
  # send email to myself
  text_msg <- gm_mime() %>%
    gm_to("XXXXXX@gmail.com") %>%
    gm_from("XXXXXX@gmail.com") %>%
    gm_text_body(paste0("NEW LISTING! ", new_listings))
  gm_send_message(text_msg)
}else( # if no new records do nothing
  print("No new listing")
  )
