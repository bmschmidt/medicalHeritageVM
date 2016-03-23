options("repos"="http://cran.rstudio.com") # set the cran mirror

packages <- c("devtools",
              "ggplot2",
              "tidyr",
              "dplyr",
              "stringr",
              "rstudio",
              "knitr",
              "rmarkdown",
              "XML",
              "rJava",
              "mallet",
              "igraph",
              "SnowballC",
              "NLP",
              "openNLP")
packages <- setdiff(packages, installed.packages()[, "Package"])
if (length(packages) != 0){
  (install.packages(packages))
}
update.packages(ask=FALSE)

# The unreleased Bookworm API package is previewed here, for now.
devtools::install_github("bmschmidt/edinburgh")
# And so is my word2vec package.
devtools::install_github("bmschmidt/wordVectors")
