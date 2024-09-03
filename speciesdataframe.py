import pandas as pd
from bidict import bidict
import numpy as np

#Make dataframe of species per site instead of observations

df = pd.read_csv("/Users/dri/Documents/TIIP/10s_fulldataframe.csv")
table = []

#loop through each site's observations, and for each species, create one row with total audio and visual count, mode hour of day, average and maximum confidence and loudness
for site in df.Site.unique():
    sitedf = df[df['Site'] == site]
    for species in sitedf.CommonName.unique():
        speciesdf = sitedf[sitedf['CommonName']==species]
        audioCount = len(speciesdf[speciesdf['Method']=='Audio'].VideoFileName.unique())
        visualCount = speciesdf[speciesdf['Method']=='Visual']['Count'].sum()
        modeHour = speciesdf['Hour'].mode()[0]
        maxConf = speciesdf['Confidence'].max()
        avgConf = speciesdf['Confidence'].mean()
        maxLoud = speciesdf['Loudness'].max()
        avgLoud = speciesdf['Loudness'].mean()
        obs = [site, species, audioCount, visualCount, modeHour, maxConf, avgConf, maxLoud, avgLoud]
        table.append(obs)

#Create dataframe from table
df1 = pd.DataFrame(table, columns = ['Site', 'CommonName', 'AudioCount', 'VisualCount', 'ModeHour', 'MaxConf', 'AvgConf', 'MaxLoud', 'AvgLoud'])

#Merge with Tobias traits and eBird codes
traits = pd.read_csv("/Users/dri/Documents/TIIP/species_lists/AVONET Supplementary dataset 1.csv")
traits = traits[['Species2', 'Habitat', 'Habitat.Density', 'Trophic.Level', 'Trophic.Niche', 'Primary.Lifestyle']]
traits.columns = ['BinomialName', 'Habitat', 'HabitatDensity', 'TrophicLevel', 'TrophicNiche', 'PrimaryLifestyle']
codes = pd.read_json("/Users/dri/Documents/TIIP/BirdNET-Analyzer/eBird_taxonomy_codes_2021E.json", orient = 'index', typ = 'frame')

codes.columns = ['SpeciesCode']
codes = codes[~codes.SpeciesCode.str.contains('_')]
codes = codes.reset_index(names = 'Name')
codes[['BinomialName', 'CommonName']] = codes['Name'].str.split('_', n=1, expand=True)
codes = codes.drop('Name', axis = 1)

df2 = codes.merge(traits, on = "BinomialName", how = 'inner')

df = df1.merge(df2, on = 'CommonName', how = "left")


#Mark unique species in each roof-ground pair
sitepairs = bidict({'BIO7F': 'BIO1F', 'FARM':'OMS1F', 'WZSROOF': 'WZS1F'})

unique = []

for ground in list(sitepairs.values()):
    roof = sitepairs.inv[ground]
    roof_species = df[df['Site'] == roof]['CommonName']
    ground_species = df[df['Site'] == ground]['CommonName']
    roof_unique = np.setdiff1d(roof_species, ground_species)
    ground_unique = np.setdiff1d(ground_species, roof_species)

    for species in roof_unique:
        unique.append([roof, species, 1])
    for species in ground_unique:
        unique.append([ground, species, 1])

uniquedf = pd.DataFrame(unique, columns = ['Site', 'CommonName', 'Unique'])

df3 = df.merge(uniquedf, on = ['Site', 'CommonName'], how = 'left')

df3['Unique'] = df3['Unique'].fillna(0)

df3['HabitatDensity'] = df3['HabitatDensity'].replace({1:'Dense habitats', 2: 'Semi-open habitats', 3:'Open habitats'})

native_df = pd.read_csv("/Users/dri/Documents/TIIP/Native_Introduced.csv")

df3 = df3.merge(native_df, on = 'CommonName', how = "left")

#Remove "Unsure" values 


df3.to_csv("/Users/dri/Documents/TIIP/10s_speciesdataframe.csv")
