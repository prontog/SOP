repos <- "https://cloud.r-project.org"

# Somehow ICUDT could not be downloaded from the stringi installer. So
# we download it before calling this script. For more info on this see
# https://github.com/gagolews/stringi/blob/master/INSTALL
install.packages("rmarkdown", repos = repos)
install.packages("devtools", repos = repos)
library(devtools)
install_github("prontog/multifwf")
#install.packages("XLConnect", repos = repos)

install.packages("plyr", repos = repos)
#install.packages("googleVis", repos = repos)
#install.packages("tidyr", repos = repos)
#install.packages("ggplot2", repos = repos)

#install_github("ramnathv/rCharts")
