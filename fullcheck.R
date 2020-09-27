# Find cran packages with an autobrew script
# You can set a GITHUB_PAT in travis settings
options(Ncpus = parallel::detectCores())
options(repos = 'https://cloud.r-project.org')
install.packages("gh")
res <- gh::gh('/search/code?q=autobrew+in:file+filename:configure+user:cran')
pkgs <- vapply(res$items, function(x){x$repository$name}, "")
pkgs <- sort(unique(pkgs))
print(pkgs)

# Broken packages that are not mine
skiplist <- c("rpg")
pkgs <- setdiff(pkgs, skiplist)

# Install all packages + dependencies 
# Note depends=TRUE omits LinkingTo for binary packages
deps <- tools::package_dependencies(pkgs, which = c("Depends", "Imports", "LinkingTo", "Suggests"))
pkgdeps <- sort(unique(unlist(deps, use.names = FALSE)))
install.packages(pkgdeps, type = "binary")

# Check all the packages
dir.create(pkgdir <- tempfile())
download.packages(pkgs, pkgdir)
tools::check_packages_in_dir(pkgdir, check_args = '--no-manual --no-build-vignettes')

# Get outputs
df <- tools::check_packages_in_dir_details(pkgdir)
failures <- df$Status %in% c("WARNING", "ERROR")
if(any(failures)){
  cat("\n\n=======\n\n")
  print(df[failures,])
  stop("Failed checks: ", paste(df$Package[failures], collapse = ', '))
}

cat("Great success!\n")
print(df$Package)
