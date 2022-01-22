suppressMessages(library(raster, warn.conflicts = FALSE, quietly=TRUE ))
library(ggplot2)
library(gridExtra)
suppressMessages(library(factoextra, warn.conflicts = FALSE, quietly=TRUE))
suppressMessages(library(optparse, warn.conflicts = FALSE, quietly=TRUE))
options(warn=-1)

#Argument parser
option_list = list(
  make_option(c("-i", "--input"), type="character", default=NULL,
              help="path to input image", metavar="character"),
  make_option(c("-o", "--output"),type="character", default=NULL,
              help="output file path", metavar="character"),
  make_option(c("-k", "--k"), type="integer", default=5, 
              help="k number of clusters. default to 5", metavar="integer")
) 

opt_parser = OptionParser(option_list=option_list);
opt = parse_args(opt_parser);

r <- stack(opt$input)
names(r) <- c('red', 'blue', 'green', 'NIR')

coords <- coordinates(r)

r.df <- data.frame(
  x = coords[,1],#rep(1:dim(manha1ir)[2], each = dim(manha1ir)[1]),
  y = coords[,2],#rep(dim(manha1ir)[1]:1, dim(manha1ir)[2]),
  R = as.vector(r$red),
  G = as.vector(r$green),
  B = as.vector(r$blue),
  NIR = as.vector(r$NIR)
)

r.df <- r.df[which(r.df$R != 0 & r.df$G != 0 & r.df$B != 0 ),]

set.seed(99)
model <- kmeans(r.df[c("R", "G", "B", "NIR")], centers = opt$k)

r.df$cluster <- model$cluster

#colour palette
pal <- c("burlywood4", "darkorange", "firebrick", "dodgerblue", "lightsalmon")

r.df$R <- NULL
r.df$G <- NULL
r.df$B <- NULL

r <- rasterFromXYZ(r.df)
writeRaster(r, opt$output, format='GTiff', overwrite=T)
print("Done : raster written")
