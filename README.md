# International Student Enrollment 2013-2019: Trends and Outlook
## TLDR
## Introduction
### Background

International Education, especially post-secondary education, has been a popular opinion for quite a while now.  It has been a source of income to countries providing education while giving the international students credentials that can separate them from peers.  However, it seems that there are select countries that attract more of these students to their educational institutions.  On the other hand, there are also some countries that consider international education more than others.

### Objectives

* Identify the top countries that provide international education and those that opt for studying abroad along with trends related to those.
* Identify if some specific factors/conditions of a given country relate to the number of international students they have.
* Predict the amount of international students for a given country given those factors.

## Methodology
### Data Sources

#### International Student Enrollment

For the International Students data, this can be acquired from the Organisation for Economic Cooperation and Development (OECD) online library.  This has an online Education Statistics database gathered from educational institutions.  The dataset specifically acquired from this library is the [Enrollment of international students by origin](https://stats.oecd.org/viewhtml.aspx?datasetcode=EDU_ENRL_MOBILE&lang=en).  This dataset mainly contains international student enrollment for post-secondary education (tertiary level or higher) from 2013 to 2019.  The [full dataset in CSV format](https://github.com/jords-santiago/intl-students-2013-2019/blob/main/01_DataSource/01_Raw/01_OECD/EDU_ENRL_MOBILE-en.csv.zip) was downloaded as shown below.

![alt text](https://github.com/jords-santiago/intl-students-2013-2019/blob/main/99_Pictures/OECD_data_download.png "Downloading OECD dataset")  

#### World Development Indicators

For the World Development Indicators data, this can be found in the World Bank Open Data site.  From its [World Development Indicators DataBank](https://databank.worldbank.org/source/world-development-indicators#), specified indicators can be queried for a given set of countries across a period of time as shown below.  Since the OECD data covers years 2013 to 2019, the [data extract in CSV format](https://github.com/jords-santiago/intl-students-2013-2019/blob/main/01_DataSource/01_Raw/02_WORLD_BANK/Data_Extract_From_World_Development_Indicators.zip) from this databank covers that time period as well.

![alt text](https://github.com/jords-santiago/intl-students-2013-2019/blob/main/99_Pictures/World_Bank_data_download.png "Downloading World Bank dataset") 

The indicators gathered were the following:

| Indicator Code | Description |
| --- | --- |
| NY.GDP.MKTP.KD.ZG	| GDP growth (annual %) |
| NY.GDP.PCAP.CD| GDP per capita (current US$) |
| NY.GDP.MKTP.CD | GDP (current US$) |
| SP.POP.TOTL | Population, total |
| SE.XPD.CTER.ZS | Current education expenditure, tertiary (% of total expenditure in tertiary public institutions) |
| SE.XPD.TERT.PC.ZS	| Government expenditure per student, tertiary (% of GDP per capita) |
| SE.XPD.TERT.ZS | Expenditure on tertiary education (% of government expenditure on education) |
| EN.POP.DNST | Population density (people per sq. km of land area) |
| SL.UEM.ADVN.ZS | Unemployment with advanced education (% of total labor force with advanced education) |
| SP.POP.GROW | Population growth (annual %) |
| SP.URB.GROW | Urban population growth (annual %) |
| NY.GDP.PCAP.KD.ZG	| GDP per capita growth (annual %) |
| SP.RUR.TOTL.ZG | Rural population growth (annual %) |

#### ISO 3166 Country Codes

Upon checking the datasets for International Students and World Development Indicators, country codes were also given.  These were 2-character (alpha-2) or 3-character (alpha-3) codes for the countries in compliance of [ISO 3166](https://www.iso.org/iso-3166-country-codes.html).  However, the country names themselves don't match between the 2 datasets.  Therefore, a [CSV file](https://github.com/jords-santiago/intl-students-2013-2019/blob/main/01_DataSource/01_Raw/03_ISO3166/ISO_3166_COUNTRY_CODES.csv) was created for the ISO 3166 country codes to be able to join the datasets for further analysis.

### Data Preparation/Cleaning

On checking the 3 CSV files, the data from the World Bank needed to be arranged where World Development Indicators per year had its own column.  Unpivot was performed using **Google Sheets** to have the year specified as a row.  The transformed dataset was extracted as a new [CSV file](https://github.com/jords-santiago/intl-students-2013-2019/blob/main/01_DataSource/01_Raw/02_WORLD_BANK/WORLD_BANK_SELECTED_WDI_2013_2019.zip) to be loaded with the other 2 datasets.

![alt text](https://github.com/jords-santiago/intl-students-2013-2019/blob/main/99_Pictures/World_Bank_WDI_prep.png "Unpivot the World Bank dataset") 

The 3 datasets were imported into **Microsoft SQL Server** to prepare the data for analysis:

| Input CSV file name | Input Table Name |
|-------------|-----------|
| EDU_ENRL_MOBILE-en.csv | \[IntlEducation_Stats].\[dbo].\[RAW_OECD_EDU_ENRL] |
| WORLD_BANK_SELECTED_WDI_2013_2019.csv |  \[IntlEducation_Stats].\[dbo].\[WORLD_BANK_SELECTED_WDI_2013_2019] |
| ISO_3166_COUNTRY_CODES.csv | \[IntlEducation_Stats].\[dbo].\[ISO_3166_COUNTRY_CODES] | 

As expected, data needs to be cleaned especially as these come from different sources.  The script/code can be found [here](https://github.com/jords-santiago/intl-students-2013-2019/blob/main/02_SourceCodes/01_SQL/script_OECD_EDU_ENRL.sql).

![alt text](https://github.com/jords-santiago/intl-students-2013-2019/blob/main/99_Pictures/Coding_MS_SQL_Server.png "Coding in MS SQL Server")  

In summary, the following were performed:

* Filtered out data to only include total number of students (excluded numbers separating males and females)
* Filtered out invalid years as well as outside of 2013-2019 period
* Rounded down/truncated values as number of students should be specified as whole numbers
* Converted country codes into actual country names (using ISO 3166 country codes dataset)
* Remove redundant values regarding Education Level
* Included Kosovo in processing as Kosovo is not currently recognized by ISO 3166
* Joined Population data from World Bank dataset into International Students data

Using SQL has yielded 3 output tables which have been extracted into CSV format:

| Output Table Name | Output CSV File | Description |
| --- | --- | --- |
| \[IntlEducation_Stats].\[dbo].\[OECD_EDU_ENRL_2013_2019] | [OECD_Intl_Student_Enrollment_2013_2019.csv](https://github.com/jords-santiago/intl-students-2013-2019/blob/main/01_DataSources/02_Cleaned/OECD_Intl_Student_Enrollment_2013_2019.csv) | International Students' Enrollment 2013-2019 | 
| \[IntlEducation_Stats].\[dbo].\[INTL_STUDENTS_PER_POPULATION] | [Intl_Students_Per_Population_2013_2019.csv](https://github.com/jords-santiago/intl-students-2013-2019/blob/main/01_DataSources/02_Cleaned/Intl_Students_Per_Population_2013_2019.csv) | International Students' Enrollment 2013-2019 with Population |
| \[IntlEducation_Stats].\[dbo].\[INTL_STUDENT_ORIGIN_2013_2019] | [Intl_Student_Origin_2013_2019.csv](https://github.com/jords-santiago/intl-students-2013-2019/blob/main/01_DataSources/02_Cleaned/Intl_Student_Origin_2013_2019.csv) | International Students' Countries of Origin 2013-2019 |

## Analysis and Results
## Conclusions


