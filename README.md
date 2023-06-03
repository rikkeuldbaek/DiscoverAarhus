# **DiscoverAarhus - A Shiny Application**
## **Cultural Data Science - Spatial Analytics** 
#### Authors: Rikke Uldbæk (202007501) and Louise Brix Pilegaard Hansen (202006093) 
#### Date: 7th of June 2023

<br>

## **1. The DiscoverAarhus Application**

This repository contains the DiscoverAarhus application, which has been designed to motivate citizens and tourists of Aarhus to gain more knowledge of the cultural and nature activities in their environment and offer a solution on how to explore these. The following link is a link to the DiscoverAarhus application developed by [Louise Brix Pilegaard Hansen](https://github.com/louisebphansen) and [Rikke Uldbæk](https://github.com/rikkeuldbaek) in the course Spatial Analytics at Aarhus University (F23.147201U022.A):

> https://w4odxi-rikke0uldb0k.shinyapps.io/DiscoverAarhus/

The application has a limited availability of 25 hours per months, so if you experience any challenges with opening the application please contact [Rikke Uldbæk](https://github.com/rikkeuldbaek) on 202007501@post.au.dk or [Louise Brix Pilegaard Hansen](https://github.com/louisebphansen) on 202006093@post.au.dk. 

<br> 


## **2. Repository Structure**

|Folder name|Description|Content|
|---|---|---|
|```src```|data preprocessing script |```data_preprocessing.Rmd```|
|```data```|data files in .csv, .xlsx, and .geojson format|```DiscoverAarhusData.csv```, ```collected_data.xlsx```,```geojson_files``` |
|```app```|the DiscoverAarhus application|```app.R```|

The raw data used in the ```data_preprocessing.Rmd``` script are located in the ```data``` folder. The ```data_preprocessing.Rmd``` script located in ```src``` produces clean data, which are saved in the ```data``` folder as ```DiscoverAarhusData.csv```.  The ```DiscoverAarhusData.csv``` data are loaded in to the ```app.R```(the DiscoverAarhus application) which produces a pop up window with the app running. 

<br>

## **3 Usage and Reproducibility**
### **3.1 Prerequisites** 
In order for the user to be able to run the code locally, please make sure to have ```R``` (>= 4.0.2) and ```Rstudio```  (>=1.3.1073) installed on the used device. The code has been written and tested on a macOS version 13.0 operating system. In order to run the provided code of the repository, please follow the instructions below.

<br>

### **3.2 Setup Instructions** 
**3.2.1 Clone the repository**
```python
https://github.com/rikkeuldbaek/DiscoverAarhus.git
 ```

 **3.2.2 Change directory** <br>
```python
cd DiscoverAarhus
```

<br>

### **3.3 Run the scripts locally** 
Firstly, in order to preprocess the data please open ```Rstudio``` and run the entire ```data_preprocessing.Rmd``` file, as stated previously this will generate a clean .csv file of the data (```DiscoverAarhusData.csv```). Secondly, in order to run the DiscoverAarhus application please open the ```app.R``` file in ```Rstudio``` and run the entire file. The app will automatically open in a an external plot R-window.  

<br>

## **4. License** 
The project of this repository is licensed under the MIT License. 

