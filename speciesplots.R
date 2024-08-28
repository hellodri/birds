#Plots for unique species in roof/ground pairs (audio and visual separate), visual species richness by trophic niche, and combined audio/visual species richness (in poster)

setwd("/Users/dri/Documents/TIIP/dataframes")

library(ggplot2)
library(dplyr)
library(ggpattern) #Allows us to add patterns to ggplot graphs
library(ggh4x) #Allows us to add color to site groupings with facet_wrap2 function

df <- read.csv("10s_speciesdataframe.csv") 
df <- df[df$MaxConf > 0.2,]

areas <- c('Empty', 'Green', 'Farm')

#Recode site names for graphing purposes - so that sites can be grouped by area and just labeled "Roof" and "Ground"
df <- df %>% mutate(Site = recode(Site, "EmptyRoof" = "Roof", "Ground1" = "Ground", "GreenRoof" = "Roof", "Ground2" = "Ground", "FarmRoof"="Roof", "Ground3"="Ground"))
df <- df %>% mutate(Area = recode(Area, '1' = "Empty", '2' = "Green", '3' = "Farm"))
df$Area <- factor(df$Area, levels = areas)

#Color palette for areas/sites
areaColors <- c("#A1A1A1", "#94B58C", "#B58CB5")
names(areaColors) <- areas
areaScale <- scale_fill_manual(name = areas,values = areaColors)


#Unique audio vocalizations
unique_audiodf <- as.data.frame(df[df$Unique==1 & df$AudioCount>=1,])
unique_audiodf$Site <- factor(unique_audiodf$Site, levels = sites)
ggplot(unique_audiodf, aes(x=Site, fill = CommonName)) + 
  geom_bar() +
  ggtitle("Unique Species Richness (10s Vocalizations)") +
  scale_x_discrete(drop=FALSE) +
  theme_classic() 
ggsave("Plots/SpeciesRichness/Unique Species Richness (Audio).png", plot = last_plot())


svisualdf <- as.data.frame(df[df$VisualCount>=1,])
ggplot(svisualdf, aes(x=Site, fill = Origin)) + 
  geom_bar() +
  ggtitle("Species Origins (Visual)") +
  scale_x_discrete(drop=FALSE) +
  theme_classic() 

#NOTE ABOUT INSECTIVORE/INVERTIVORE NICHES
#Tobias (2022) data uses "Invertivore" not ""insectivore". 
#I CROSS CHECKED all detected invertivores and reclassified Black-Collared Starling, Javan Myna as omnivores according to Starlings & Mynas by Craig & Feare (2010)
#I confirmed that the Barn Swallow, Black Drongo, Plain Prinia, and White Wagtail were insectivores, following Kwok & Cortlett (1999), Ryan (2006), and Tyler (2004).
#See citations: https://docs.google.com/document/d/1yQOmMVuznbBHJeT47TCYOm4x9GMuCzrnAOSOTXp-aSI/edit#heading=h.q9ctvi5emc01

#Set color palette for niches 
niches <- c("Aquatic predator", "Frugivore", "Granivore", "Invertivore", "Omnivore") 
nicheColors <- c("#8EBACDFF", "#ec8f7f", "#D9C4A7FF", "#F8CD50FF", "#B19377")
names(nicheColors) <- niches
nicheScale <- scale_fill_manual(name = "niches",values = nicheColors)

svisualdf$TrophicNiche <- factor(svisualdf$TrophicNiche, levels = niches)
ggplot(svisualdf, aes(x=Site, fill = TrophicNiche)) + 
  geom_bar() +
  ggtitle("Trophic Niches by Species Richness (Visual)") +
  ylab("# Species Observed") +
  nicheScale +
  theme_classic()+
  scale_x_discrete(drop=FALSE) +
  #facet_wrap( ~ Area, strip.position = "bottom", scales = "free_x") +
  theme(panel.spacing = unit(0, "lines"), 
        strip.background = element_blank(),
        strip.placement = "outside", strip.text.x = element_blank(), axis.text.x = element_text(angle=20, vjust=1, hjust=1)) 
ggsave("Plots/TrophicNiches/VisualObsTrophicNiches.png", plot = last_plot())


#Creating "Method" column based on whether species was detected via audio only, visual only, or both
df$MethodV <- as.numeric(df$VisualCount > 0) #Converts VisualCount column to binary: 0 if VisualCount = 0, 1 if VisualCount is more than 0. 
df$MethodA <- as.numeric(df$AudioCount > 0) * 2 #Converts AudioCount column to binary and multiplies by 2: 0 if AudioCount = 0, 2 if AudioCount is more than 0. 
df$Method <- df$MethodV + df$MethodA #By adding these columns together, we have 1 = visual only (1 + 0), 2 = audio only (0 + 2), and 3 = both (1 + 2)

df$Method <- factor(df$Method, levels = 1:3, labels = c("Visual", "Audio", "Both")) 
df$Method <- factor(df$Method, levels = c("Visual", "Both", "Audio"))


#Plot ALL species richness, audio/visual/both colored by pattern
ggplot(df, aes(x=Site, fill = Area, alpha = Site, pattern = Method)) + 
  geom_bar_pattern(position = "stack",
                   color = "gray", 
                   pattern_fill = "black",
                   #pattern_color = "black",
                   pattern_angle = 45,
                   pattern_density = 0.05,
                   pattern_spacing = 0.1,
                   pattern_key_scale_factor = 0.2) + 
  scale_pattern_manual(values = c(Visual = "stripe", Both = "crosshatch", Audio = "none")) +
  ggtitle("Species Richness") +
  scale_x_discrete(drop=FALSE) +
  guides(alpha = "none", fill = "none", pattern = guide_legend(override.aes = list(fill = "white", color = "black"))) +
  ylab("# Species Observed") +
  facet_wrap2( ~ Area, 
               strip = strip_themed(background_x = elem_list_rect(fill=areaColors, linewidth=c(0,0,0))), 
               strip.position = "bottom",
               scales = "free_x") +
  theme_classic() +
  theme(panel.spacing = unit(4, "mm"),
        strip.placement = "outside", 
        legend.direction = "horizontal",
        legend.position = c(0.7,0.95),
        legend.title = element_blank(),
        text=element_text(family="Optima", size=24), #change font size of all text
        axis.text=element_text(size=22), #change font size of axis text
        axis.title.x=element_blank(), #change font size of axis titles
        axis.title.y=element_text(size=24),
        plot.title=element_text(size=32), #change font size of plot title
        strip.text.x=element_text(size=20),
        legend.text=element_text(size=24), #change font size of legend text
        ) +
  scale_alpha_manual(values = c(0.6,1)) +
  areaScale


#Saving just all detected species, for poster citations & data page
specieslist <- df[!duplicated(df['CommonName']), c('CommonName', 'BinomialName', 'TrophicNiche')]
write.csv(specieslist, "specieslist.csv")
