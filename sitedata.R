#Calculations for species and niche diversity and insectivore ratios, bray-curtis dissimilarity and plotting multidimensional scaling

library(vegan)
library(labdsv)
setwd("/Users/dri/Documents/TIIP/dataframes")


df <- read.csv("10s_speciesdataframe.csv")
saudiodf <- as.data.frame(df[df$AudioCount>=1 & df$MaxConf > 0.2,])

#Diversity calculations
#Create community matrix
sdf <- matrify(saudiodf[c('Site', 'CommonName', 'AudioCount')]) #Create community matrix - each site is a row, each species is a column, with abundances
diversity(sdf, 'shannon')

tdf <- matrify(saudiodf[c('Site', 'TrophicNiche', 'AudioCount')]) #Community matrix based on niche abundances instead of species
diversity(tdf, 'shannon') #Shannon diversity of trophic niches per site

#Calculate and plot bray-curtis dissimilarities in species composition per site with multidimensional scaling
braycurtis <- vegdist(sdf, 'bray') #Calculate bray-curtis dissimilarity for each pair
wscale <- cmdscale(braycurtis, k=2) #Classic multidimensional scaling function (insufficient data for nmMDS)
pl <- ordiplot(wscale, cex = 2)


#Calculate trophic niche proportions per site
fulldf <- read.csv("10s_fulldataframe.csv")
audiodf <- as.data.frame(fulldf[fulldf$Method=='Audio'& fulldf$Confidence >= 0.2,])
audiodf <- audiodf[!duplicated(audiodf[c('Site', 'CommonName', 'VideoFileName')]),]

sites <- c('FarmRoof', "GreenRoof", "EmptyRoof", "Ground1", "Ground2", "Ground3")

for (site in sites) {
  total <- length(audiodf[audiodf$Site == site,"TrophicNiche"])
  inv <- length(audiodf[audiodf$Site == site & audiodf$TrophicNiche == 'Invertivore',"TrophicNiche"])
  omn <- length(audiodf[audiodf$Site == site & audiodf$TrophicNiche == 'Omnivore',"TrophicNiche"])
  invratio <- inv/total
  omnratio <- omn/total
  print(paste(site, invratio, inv, total))
}

