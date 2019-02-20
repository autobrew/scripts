url <- 'https://api.github.com/search/code?q=autobrew+in:file+filename:configure+user:cran'
repos <- jsonlite::fromJSON(url)
pkgs <- sort(repos$items$repository$name)
install.packages(pkgs, type = 'source')
