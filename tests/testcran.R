# Find cran packages with an autobrew script
# You can set a GITHUB_PAT in travis settings


begin <- function (txt){
  cat(sprintf('::group::%s\n', txt))
}
end <- function(){
  cat('::endgroup::\n')
}

options(repos = 'https://cloud.r-project.org')
install.packages(c("jsonlite", "curl"))
avail <- row.names(available.packages())

search_autobrew_repos <- function(){
  h <- curl::new_handle(verbose=T)
  curl::handle_setheaders(h,
    "Accept" = "application/vnd.github+json",
    "X-GitHub-Api-Version" = "2022-11-28",
    "Authorization" = paste("Bearer", Sys.getenv('GITHUB_PAT')))
  url <- 'https://api.github.com/search/code?per_page=100&q=autobrew+user:cran+filename:configure'
  req <- curl::curl_fetch_memory(url, handle = h)
  stopifnot(req$status != 300)
  res <- jsonlite::fromJSON(rawToChar(req$content))
  res$items$repository$name
}

# Find CRAN packages with autobrew script
pkgs <- search_autobrew_repos()
pkgs <- sort(intersect(pkgs, avail))
print(pkgs)

# Broken packages that are not mine
#skiplist <- c("rpg")
#pkgs <- setdiff(pkgs, skiplist)

# Install binary packages + dependencies
begin('preparing')
install.packages(pkgs, type = "binary")
end()

# Install packages from source
results <- sapply(pkgs, function(pkg){
  begin(pkg)
  try(remove.packages(pkg), silent = TRUE)
  install.packages(pkg, type = 'source')
  tryCatch({
    find.package(pkg)
    TRUE
  }, error = function(e){
    FALSE
  }, finally = function(e){
    end()
  })
})

# Check if everything is installed
if(any(!results)){
	stop("Packages failed to install: ", paste(names(which(!results)), collapse = ", "))
}
print("Great success!")
print(pkgs)
