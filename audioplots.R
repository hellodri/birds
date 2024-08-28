#Plots for audio temporal histograms, loudness histograms, species trophic niche abundances (in poster), and introduced/native species abundances

setwd("/Users/dri/Documents/TIIP/dataframes")
library(ggplot2)
library(dplyr)
library(ggh4x) #Allows us to add color to site groupings with facet_wrap2 function

#Load dataframe of all audio (BirdNET results) and video observations
fulldf <- read.csv("10s_fulldataframe.csv")

#Filter for just audio results, with BirdNET confidence above 0.2 
audiodf <- as.data.frame(fulldf[fulldf$Method=='Audio' & fulldf$Confidence >= 0.2,])

#Group by unique video files
audiodf1 <- audiodf[!duplicated(audiodf[c('Site', 'CommonName', 'VideoFileName')]),]

#Recode site names for graphing purposes - so that sites can be grouped by area and just labeled "Roof" and "Ground"
audiodf1 <- audiodf1 %>% mutate(Site = recode(Site, "EmptyRoof" = "Roof", "Ground1" = "Ground", "GreenRoof" = "Roof", "Ground2" = "Ground", "FarmRoof"="Roof", "Ground3"="Ground"))
audiodf1 <- audiodf1 %>% mutate(Area = recode(Area, '1' = "Empty", '2' = "Green", '3' = "Farm"))
audiodf1$Area <- factor(audiodf1$Area, levels = areas)

#Color palette for areas/sites
areaColors <- c("#A1A1A1", "#94B58C", "#B58CB5")
names(areaColors) <- areas


#Histogram of hour of day for each site
for (site in unique(audiodf$Site)) { #Loop through all sites
  sitedf <- as.data.frame(audiodf[audiodf$Site == site,]) #Select all observations from that site
  title <- paste(site, "Vocalizations per Hour (10s)", sep = " ")
  xaxis <- 4:20 #since we recorded from 4am to 8pm only
  ggplot(sitedf, aes(x=Hour)) + 
    geom_bar() +
    ggtitle(title) +
    theme_classic() +
    scale_x_continuous("Hour", labels = as.character(xaxis), breaks=xaxis)
  filename <- paste("Plots/TimeHist/Audio/", title, ".png", sep = "")
  ggsave(filename, plot = last_plot()) #Save all histograms
}

#Plot vocalizations per hour for all sites on one histogram
xaxis <- 4:20
ggplot(audiodf, aes(x=Hour, fill =Site)) + #Observations will be colored by site
  geom_histogram(bins = 16) +
  ggtitle("Vocalizations per Hour - All Sites (10s)") +
  scale_x_continuous("Hour", labels = as.character(xaxis), breaks=xaxis) +
  theme_classic()
ggsave("Plots/TimeHist/Audio/10s Vocalizations per Hour All Sites.png", plot = last_plot())


#Plot loudness histogram for all sites on one histogram
ggplot(audiodf, aes(x=Loudness, fill = Site)) +
  geom_histogram(position = "identity", bins = 50) +
  ggtitle("Loudness across all sites (10s)") +
  xlab("Loudness (dBFS)") +
  fillScale +
  theme_classic()
ggsave("Plots/Sound/Loudness distribution all sites (10s).png", plot = last_plot())


#Set color palette for niches 
niches <- c("Aquatic predator", "Frugivore", "Granivore", "Invertivore", "Omnivore") 
#Tobias (2022) data uses "Invertivore" not ""insectivore". 
#I CROSS CHECKED all detected invertivores and reclassified Black-Collared Starling, Javan Myna, and Oriental Magpie-Robin as omnivores according to Starlings & Mynas by Craig & Feare (2010)
#I confirmed that the Barn Swallow, Black Drongo, Plain Prinia, and White Wagtail were insectivores, following Kwok & Cortlett (1999), Ryan (2006), and Tyler (2004).
#See citations: https://docs.google.com/document/d/1yQOmMVuznbBHJeT47TCYOm4x9GMuCzrnAOSOTXp-aSI/edit#heading=h.q9ctvi5emc01

nicheColors <- c("#8EBACDFF", "#ec8f7f", "#D9C4A7FF", "#F8CD50FF", "#B19377")
names(nicheColors) <- niches

#Plot species abundance per site colored by niches
ggplot(audiodf1, aes(x=Site, fill = TrophicNiche)) + 
  geom_bar() +
  ggtitle("Species Trophic Niches") +
  ylab("Relative Abundance") +
  scale_x_discrete(drop=FALSE) +
  scale_fill_manual(name = "niches", values = nicheColors, 
                    labels = c("Aquatic p.", "Frugivore", "Granivore", "Insectivore", "Omnivore")) + #NOTE!!!!! label changed to Insectivore after checking species, see above. 
  guides(fill=guide_legend(label.position="bottom")) +
  facet_wrap2( ~ Area, 
               strip = strip_themed(background_x = elem_list_rect(fill=areaColors, linewidth=c(0,0,0))), 
               strip.position = "bottom",
               scales = "free_x") + #Group sites by area (Empty, Green, Farm) and color those areas
  theme_classic() +
  theme(
    legend.position = 'top',
    legend.title = element_blank(),
    legend.margin = margin(t=1, unit='mm'),
    legend.box.spacing = unit(1,'mm'),
    legend.key.height=unit(5,'mm'),
    strip.placement = "outside",
    panel.spacing = unit(4, "mm"),
    text=element_text(family="Optima", size=24), #change font size of all text
    axis.text.x=element_text(size=22), #change font size of axis text
    axis.text.y=element_text(size=22),
    axis.title.x=element_blank(), #change font size of axis titles
    axis.title.y=element_text(size=24),
    plot.title=element_text(size=32), #change font size of plot title
    strip.text.x=element_text(size=24),
    legend.text=element_text(size=20)
    ) +
  scale_alpha_manual(values = c(0.6,1)) 


#Plot native vs introduced abundance per site
ggplot(audiodf1, aes(x=Site, fill = Origin)) + 
  geom_bar() +
  ggtitle("Species Origins") +
  ylab("Relative Abundance") +
  scale_x_discrete(drop=FALSE) +
  guides(fill=guide_legend(label.position="bottom")) +
  facet_wrap2( ~ Area, 
               strip = strip_themed(background_x = elem_list_rect(fill=areaColors, linewidth=c(0,0,0))), 
               strip.position = "bottom",
               scales = "free_x") +
  theme_classic() +
  theme(
    legend.position = 'top',
    legend.title = element_blank(),
    legend.margin = margin(t=1, unit='mm'),
    legend.box.spacing = unit(1,'mm'),
    legend.key.height=unit(5,'mm'),
    strip.placement = "outside",
    panel.spacing = unit(4, "mm"),
    text=element_text(family="Optima", size=24), #change font size of all text
    axis.text.x=element_text(size=22), #change font size of axis text
    axis.text.y=element_text(size=22),
    axis.title.x=element_blank(), #change font size of axis titles
    axis.title.y=element_text(size=24),
    plot.title=element_text(size=32), #change font size of plot title
    strip.text.x=element_text(size=24),
    legend.text=element_text(size=20)
  ) +
  scale_alpha_manual(values = c(0.6,1)) 

