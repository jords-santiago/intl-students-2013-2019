# Internation Student Enrollment 2013-2019: Trends and Outlook
## TLDR
## Introduction
### Background
### Objectives
## Methodology
### Data Sources

#### International Students

For the International Students data, this can be acquired from the Organisation for Economic Cooperation and Development (OECD) online library.  This has an online Education Statistics database gathered from educational institutions.  The dataset specifically acquired from this library is the [Enrollment of international students by origin](https://stats.oecd.org/viewhtml.aspx?datasetcode=EDU_ENRL_MOBILE&lang=en).  This data mainly contains information from 2013 to 2019.  The [full dataset in CSV format](https://github.com/jords-santiago/intl-students-2013-2019/blob/main/01_DataSource/01_Raw/01_OECD/EDU_ENRL_MOBILE-en.csv.zip) was downloaded as shown below.

![alt text](https://github.com/jords-santiago/intl-students-2013-2019/blob/main/99_Pictures/OECD_data_download.png "Downloading OECD dataset")  

#### World Development Indicators

For the World Development Indicators data, this can be found in the World Bank Open Data site.  From its [World Development Indicators DataBank](https://databank.worldbank.org/source/world-development-indicators#), specified indicators can be queried for a given set of countries across a period of time as shown below.  Since the OECD data covers years 2013 to 2019, the [data extract in CSV format](https://github.com/jords-santiago/intl-students-2013-2019/blob/main/01_DataSource/01_Raw/02_WORLD_BANK/Data_Extract_From_World_Development_Indicators.zip) from this databank covers that time period as well.

![alt text](https://github.com/jords-santiago/intl-students-2013-2019/blob/main/99_Pictures/World_Bank_data_download.png "Downloading World Bank dataset")  

#### ISO 3166 Country Codes

Upon checking the datasets for International Students and World Development Indicators, country codes were also given.  These were 2-character (alpha-2) or 3-character (alpha-3) codes for the countries in compliance of [ISO 3166](https://www.iso.org/iso-3166-country-codes.html).  However, the country names themselves don't match between the 2 datasets.  Therefore, a [CSV file](https://github.com/jords-santiago/intl-students-2013-2019/blob/main/01_DataSource/01_Raw/03_ISO3166/ISO_3166_COUNTRY_CODES.csv) was created for the ISO 3166 country codes to be able to join the datasets for further analysis.

### Resources Used
### EDA
## Results and Analysis
## Conclusions


