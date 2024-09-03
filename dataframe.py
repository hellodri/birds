import os
from pydub import AudioSegment
import pandas as pd
import pathlib
import datetime

#Build dataframe of all audio results from BirdNET using segment.py output, extract site, species, confidence, sound information, date, time. 

src = "/Users/dri/Documents/TIIP/0730_0805"
method = "Audio"
table = []
datetimes = []
for site in os.listdir(src):
    #SEGMENTS SECTION
    # build the path to the segments folder
    total = 0 #to check total number of segments per site
    segments_path = os.path.join(src, site, "10s_segments")
    if os.path.isdir(segments_path):
        for species in os.listdir(segments_path):
            #build the path to the species folder
            species_path = os.path.join(segments_path, species)
            #print(species)
            if os.path.isdir(species_path):
                for file_name in os.listdir(species_path):
                    file_path = os.path.join(species_path, file_name)
                    # now you can apply any function assuming it is a file
                    # or double check it if needed as `os.path.isfile(file_path)`
                    sound = AudioSegment.from_file(file_path)
                    peak_amplitude = sound.max
                    loudness = sound.dBFS
                    video_filename = str(file_name)[8:17]
                    fixed_filename = video_filename.strip('_')  + ".MP4"
                    confidence = str(file_name)[:5]
                    total = total+1
                    segment = str(file_name)[17:-4].strip('_')
                    obs = [site, species, method, fixed_filename, segment, peak_amplitude, loudness, confidence]
                    table.append(obs)
                    #print(obs)
        #print(site, " total is ", total)
    #VIDEOFILE DATETIME SECTION: obtain date and time from video file names to add to dataframe
    video_path = os.path.join(src, site, "timescan")
    if os.path.isdir(video_path):
        for file_name in os.listdir(video_path):
            file_path = os.path.join(video_path, file_name)
            fname = pathlib.Path(file_path)
            mtime = datetime.datetime.fromtimestamp(fname.stat().st_mtime)
            date = str(mtime)[:10]
            time = str(mtime)[11:]
            obs = [site, file_name, date, time]
            datetimes.append(obs)
    video_path = os.path.join(src, site, "bird videos")
    if os.path.isdir(video_path):
        for file_name in os.listdir(video_path):
            file_path = os.path.join(video_path, file_name)
            fname = pathlib.Path(file_path)
            mtime = datetime.datetime.fromtimestamp(fname.stat().st_mtime)
            date = str(mtime)[:10]
            time = str(mtime)[11:]
            obs = [site, file_name, date, time]
            datetimes.append(obs)
    


#Turn lists from above loops into dataframes and merge

sdf = pd.DataFrame(table, columns = ["Site", "SpeciesCode", "Method", "VideoFileName", "Segment", "PeakAmplitude", "Loudness", "Confidence"])
dtdf = pd.DataFrame(datetimes, columns = ["Site", "VideoFileName", "Date", "Time"])
df = sdf.merge(dtdf, how = "left", on = ["Site", "VideoFileName"])

# Read json file matching eBird species codes to their binomial names

codes = pd.read_json("/Users/dri/Documents/TIIP/BirdNET-Analyzer/eBird_taxonomy_codes_2021E.json", orient = 'index', typ = 'frame')
#codes = codes.iloc[::2]
codes.columns = ['SpeciesCode']
codes = codes[~codes.SpeciesCode.str.contains('_')]
codes = codes.reset_index(names = 'Name')
codes[['BinomialName', 'CommonName']] = codes['Name'].str.split('_', n=1, expand=True)
codes = codes.drop('Name', axis = 1)
#codes['BinomialName'] = codes['BinomialName'].replace(' ', '_', regex=True)


#Read Tobias dataset of traits
traits = pd.read_csv("/Users/dri/Documents/TIIP/species_lists/AVONET Supplementary dataset 1.csv")
traits = traits[['Species2', 'Habitat', 'Habitat.Density', 'Trophic.Level', 'Trophic.Niche', 'Primary.Lifestyle']]
traits.columns = ['BinomialName', 'Habitat', 'HabitatDensity', 'TrophicLevel', 'TrophicNiche', 'PrimaryLifestyle']

#Merge eBird species codes and traits
df2 = codes.merge(traits, on = "BinomialName", how = 'inner')
#Merge above with birdNET results dataframe
df3 = df.merge(df2, on = 'SpeciesCode')

print(df3.isna().sum())

#Save to csv
df3.to_csv("/Users/dri/Documents/TIIP/10s_audio_dataframe.csv")

#Check missing values
missingvalues = df[df.isna().any(axis=1)]
print(missingvalues)


