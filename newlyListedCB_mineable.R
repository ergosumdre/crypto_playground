

# This script will identify newly listed CB coins on
# Coinbase Pro and determine if these coins are
# Proof of Work or Proof of Stake


library("httr")
library("dplyr")
library("stringr")
# product endpoint
# https://api.exchange.coinbase.com/products

base_url <- "https://api.exchange.coinbase.com/products"

response <- GET(url = base_url)
df <- jsonlite::fromJSON(httr::content(response, as= "text"))

usd <- df %>% filter(stringr::str_detect(id, pattern = "USD$"))
# there are a total of 115 coins-usd tradeable on pro.coinbase.com

usd_strings <- usd$base_currency

# see algo of each coin and determine if coin is mineable
Sys.setenv("CMC_PRO_API_KEY" = "XXXXXXXXXXXX") # set API Key here
cmc_base <- "https://pro-api.coinmarketcap.com/v1/cryptocurrency/info?CMC_PRO_API_KEY="
urls <- paste0(cmc_base,
               Sys.getenv("CMC_PRO_API_KEY"),
               "&symbol=",
               usd_strings)



# GET calls with rate limits of 2 seconds between each call
library(purrr)
slow_GET <- slowly(GET, rate = rate_delay(2))
result <- lapply(urls, slow_GET)
content_cmc <- lapply(result, content)



# search mineable/PoW(proof of work) coins
library("rlist")
mineable <- list.search(content_cmc, grepl('PoW', .), 'character')
mineable <- t(mineable)

# get proof of stake coins
library("rlist")
mineable <- list.search(content_cmc, grepl('PoS', .), 'character')
mineable <- t(mineable)
