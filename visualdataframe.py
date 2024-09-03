import pandas as pd

#Merge audio results with visual observations

#Read and clean Tobias traits and eBird species codes files to merge later
traits = pd.read_csv("/Users/dri/Documents/TIIP/species_lists/AVONET Supplementary dataset 1.csv")
codes = pd.read_json("/Users/dri/Documents/TIIP/BirdNET-Analyzer/eBird_taxonomy_codes_2021E.json", orient = 'index', typ = 'frame')
codes.columns = ['SpeciesCode']
codes = codes[~codes.SpeciesCode.str.contains('_')]
codes = codes.reset_index(names = 'Name')
codes[['BinomialName', 'CommonName']] = codes['Name'].str.split('_', n=1, expand=True)
codes = codes.drop('Name', axis = 1)
traits = traits[['Species2', 'Habitat', 'Habitat.Density', 'Trophic.Level', 'Trophic.Niche', 'Primary.Lifestyle']]
traits.columns = ['BinomialName', 'Habitat', 'HabitatDensity', 'TrophicLevel', 'TrophicNiche', 'PrimaryLifestyle']

#Read dataframe of audio results and visual observations
audiodf = pd.read_csv("/Users/dri/Documents/TIIP/10s_audio_dataframe.csv")
visualdf = pd.read_csv("/Users/dri/Documents/TIIP/VisualObservations.csv")

#merge species codes with Tobias traits
df2 = codes.merge(traits, on = "BinomialName", how = 'inner')

#Merge with visual observations (to add species codes and traits to visual observations)
df3 = visualdf.merge(df2, on = 'CommonName', how = "left")

#Add visual observations to audio observations
df = pd.concat([audiodf, df3], axis = 0)

#Extract "hour" from time information for histograms later
df['Hour'] = df['Time'].apply(lambda x: int(x[:2].strip(':')))

df = df[df.CommonName != "Unsure"]

#Add native/introduced column
native_df = pd.read_csv("/Users/dri/Documents/TIIP/Native_Introduced.csv")
df = df.merge(native_df, on = 'CommonName', how = "left")

#Rename habitat density information for plotting later
df['HabitatDensity'] = df['HabitatDensity'].replace({1:'Dense habitats', 2: 'Semi-open habitats', 3:'Open habitats'})

print(df[df['Origin'].isna()])

#Save file
df.to_csv("/Users/dri/Documents/TIIP/10s_fulldataframe.csv")