#Plots for per-site statistics: species diversity, niche diversity, and ratio of insectivores

library(ggplot2)
library(dplyr)
library(ggh4x)
setwd("/Users/dri/Documents/TIIP/dataframes")

sitedf <- read.csv("sitedata.csv") #Load site statistics calculated in sitedata.R

#Recode site names for graphing purposes - so that sites can be grouped by area and just labeled "Roof" and "Ground"
sitedf <- sitedf %>% mutate(Site = recode(Site, "EmptyRoof" = "Roof", "Ground1" = "Ground", "GreenRoof" = "Roof", "Ground2" = "Ground", "FarmRoof"="Roof", "Ground3"="Ground"))
sitedf <- sitedf %>% mutate(Area = recode(Area, '1' = "Empty", '2' = "Green", '3' = "Farm"))

#Color palette for areas/sites
areas <- c('Empty', 'Green', 'Farm')
areaColors <- c("#A1A1A1", "#94B58C", "#B58CB5")
names(areaColors) <- areas
areaScale <- scale_fill_manual(name = areas,values = areaColors)
sitedf$Area <- factor(sitedf$Area, levels = areas)


#Plot diversity across sites
ggplot(sitedf, aes(x=Site, y = Diversity, fill = Area, alpha = Site)) + 
  geom_col() +
  ggtitle("Species Diversity (Audio)") +
  ylab("Shannon Diversity Index") +
  facet_wrap2( ~ Area, 
               strip = strip_themed(background_x = elem_list_rect(fill=areaColors, linewidth=c(0,0,0))), 
               strip.position = "bottom",
               scales = "free_x") +
  theme_classic() +
  theme(panel.spacing = unit(4, "mm"),
        strip.placement = "outside", 
        legend.position = "none",
        text=element_text(family="Optima", size=24), #change font size of all text
        axis.text=element_text(size=22), #change font size of axis text
        axis.title.x=element_blank(), #change font size of axis titles
        axis.title.y=element_text(size=24),
        plot.title=element_text(size=32), #change font size of plot title
        strip.text.x=element_text(size=24)) +
  scale_alpha_manual(values = c(0.6,1)) +
  areaScale

#Plot niche diversity across sites
ggplot(sitedf, aes(x=Site, y = NicheDiv, fill = Area, alpha = Site)) + 
  geom_col() +
  ggtitle("Niche Diversity") +
  ylab("Shannon Diversity Index") +
  facet_wrap2( ~ Area, 
               strip = strip_themed(background_x = elem_list_rect(fill=areaColors, linewidth=c(0,0,0))), 
               strip.position = "bottom",
               scales = "free_x") +
  theme_classic() +
  theme( panel.spacing = unit(3, "mm"),
         strip.placement = "outside", 
         legend.position = "none",
         text=element_text(family="Optima", size=24), #change font size of all text
         axis.text=element_text(size=22), #change font size of axis text
         axis.title.x=element_blank(), #change font size of axis titles
         axis.title.y=element_text(size=24),
         plot.title=element_text(size=32), #change font size of plot title
         strip.text.x=element_text(size=24)) +
  scale_alpha_manual(values = c(0.6,1)) +
  areaScale

#Plot insectivore ratios
ggplot(sitedf, aes(x=Site, y = InvRatio, fill = Area, alpha = Site)) + 
  geom_col() +
  ggtitle("Percent insectivores per site") +
  ylab("Relative Abundance/Total") +
  scale_y_continuous(limits = c(0, 1)) +
  facet_wrap2( ~ Area, 
               strip = strip_themed(background_x = elem_list_rect(fill=areaColors, linewidth=c(0,0,0))), 
               strip.position = "bottom",
               scales = "free_x") +
  theme_classic() +
  theme(  panel.spacing = unit(4, "mm"),
          strip.placement = "outside", 
          legend.position = "none",
          text=element_text(family="Optima", size=24), #change font size of all text
          axis.text.x=element_text(size=22), #change font size of axis text
          axis.text.y=element_text(size=20),
          axis.title.x=element_blank(), #change font size of axis titles
          axis.title.y=element_text(size=24),
          plot.title=element_text(size=32), #change font size of plot title
          strip.text.x=element_text(size=24) #change font size of legend text
    ) +
  scale_alpha_manual(values = c(0.6,1)) +
  areaScale





