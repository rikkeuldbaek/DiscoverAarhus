# **DiscoverAarhus - A Shiny Application**
## **Cultural Data Science - Spatial Analytics** 
#### Authors: Rikke Uldbæk (202007501) and Louise Brix Pilegaard Hansen (202006093) 
#### Date: 7th of June 2023

<br>

## **1. The DiscoverAarhus Application**

This repository contains the DiscoverAarhus application, which has been designed to motivate citizens and tourists of Aarhus to gain more knowledge of the cultural and nature activities in their environment and offer a solution on how to explore these. The following link is a link to the DiscoverAarhus application developed by [Louise Brix Pilegaard Hansen](https://github.com/louisebphansen) and [Rikke Uldbæk](https://github.com/rikkeuldbaek) in the course Spatial Analytics at Aarhus University (F23.147201U022.A):

https://w4odxi-rikke0uldb0k.shinyapps.io/DiscoverAarhus/

The application has a limited availability of 25 hours per months, so if you experience any challenges with opening the application please contact [Rikke Uldbæk](https://github.com/rikkeuldbaek) on 202007501@post.au.dk or [Louise Brix Pilegaard Hansen](https://github.com/louisebphansen) on 202006093@post.au.dk. 

<br> 


<br>


# **2. Repository Structure**

|Folder name|Description|Content|
|---|---|---|
|```src```|data preprocessing script |```data_preprocessing.Rmd```|
|```data```|data files in .csv, .xlsx, and .geojson format|```DiscoverAarhusData.csv```, ```collected_data.xlsx```,```geojson_files``` |
|```app```|the DiscoverAarhus application|```app.R```|

The raw data used in the ```data_preprocessing.Rmd``` script are located in the ```data``` folder. The ```data_preprocessing.Rmd``` script located in ```src``` produces clean data, which are saved in the ```data``` folder as ```DiscoverAarhusData.csv```.  The ```DiscoverAarhusData.csv``` data are loaded in to the ```app.R```(the DiscoverAarhus application) which produces a pop up window with the app running. 

<br>

# **3 Usage and Reproducibility**
## **3.1 Prerequisites** 
In order for the user to be able to run the code, please make sure to have bash and python 3 installed on the used device. The code has been written and tested with Python 3.9.2 on a Linux operating system. In order to run the provided code for this assignment, please follow the instructions below.

<br>

## **4.5.2 Setup Instructions** 
**1) Clone the repository**
```python
git clone https://github.com/rikkeuldbaek/assignment-4-using-finetuned-transformers-rikkeuldbaek
 ```

 **2) Setup** <br>
Setup virtual environment (```LA4_env```) and install required packages.
```python
bash setup.sh
```

<br>

## **4.5.3 Run the script** 
In order to run the three emotion classification scripts, please run the following command in the terminal after setting up. Please note that the three scripts take quite some time to run. 
```python
bash run.sh
```


<br>


# **4.6 Results**
The results of the emotion classification of *all* the data's headlines, only *fake* news headlines, and only *real* news headlines are visualized using barplots. The barplots show the distribution of counts across seven emotions. Every emotion is colour coded appropriately to reflect a mapping between emotion and colour. The three plots show same distributional tendencies, with the vast majority of headlines being classified as *neutral*. The only visible change in the distribution occurs between *sadness* and *disgust* in the *fake* news headlines, other than that there are not much difference between the plots. One could maybe expect *fake* news to have a more negative emotion distribution (i.e, a larger count frequency of *anger*, *fear*, *sadness*, and *disgust* ), however this seems not to be the case. This could indicate that emotions might not be as strong of a predictor of *fake* or *real* news. However, a statistical test should be conducted in order to conclude whether or not there is a difference in the emotion distributions. 

<br>

|All news headlines|Fake news headlines|Real news headlines|
|---|---|---|
|![plot](out/emotion_distribution_all.png)|![plot](out/emotion_distribution_fake.png)| ![plot](out/emotion_distribution_real.png)|

<br>

# **Resources**
[HuggingFace - Emotion classifier](https://huggingface.co/j-hartmann/emotion-english-distilroberta-base)

[Data - Fake or Real News](https://www.kaggle.com/datasets/jillanisofttech/fake-or-real-news)
