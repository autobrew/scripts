url <- 'https://api.github.com/search/code?q=autobrew+in:file+filename:configure+user:cran'
repos <- jsonlite::fromJSON(url)
pkgs <- sort(unique(repos$items$repository$name))
print(pkgs)

# Install binary packages + dependencies
install.packages(pkgs, type = "binary")

# Install packages from source
results <- sapply(pkgs, function(pkg){
  try(remove.packages(pkg), silent = TRUE)
  install.packages(pkg, type = 'source')
  tryCatch({
    find.package(pkg)
    TRUE
  }, error = function(e){
    FALSE
  })
})

# Check if everything is installed
if(any(!results)){
	stop("Packages failed to install:", paste(names(which(!results))), collapse = ", ")
}
print("Great success!")
print(pkgs)
