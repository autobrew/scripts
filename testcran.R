# Find cran packages with an autobrew script
# You can set a GITHUB_PAT in travis settings
options(repos = 'https://cloud.r-project.org')
res <- gh::gh('/search/code?q=autobrew+in:file+filename:configure+user:cran')
pkgs <- vapply(res$items, function(x){x$repository$name}, "")
pkgs <- sort(unique(pkgs))
print(pkgs)

# Broken packages that are not mine
skiplist <- c("rpg")
pkgs <- setdiff(pkgs, skiplist)

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
	stop("Packages failed to install: ", paste(names(which(!results)), collapse = ", "))
}
print("Great success!")
print(pkgs)
