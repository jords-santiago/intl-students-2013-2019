-- copying contents of Raw table into another table while excluding Flag Codes column

SELECT [COUNTRY]
      ,[SEX]
      ,[ORIGIN]
      ,[EDUCATION_LEV]
      ,[YEAR]
      ,[Value]
INTO [IntlEducation_Stats].[dbo].[temp1]
FROM [IntlEducation_Stats].[dbo].[RAW_OECD_EDU_ENRL]

/*
--  Checking contents of the table
SELECT TOP(100) *
FROM [IntlEducation_Stats].[dbo].[temp1]

SELECT COUNT(*)
FROM [IntlEducation_Stats].[dbo].[temp1]
-- has 1372440 records
*/

-- Based on the contents of the table, as well as its display in the OECD site:
-- COUNTRY:       country in which the international student went to study
-- SEX:           international student's gender; 
-- ORIGIN:        international student's country of origin
-- EDUCATION_LEV: education level that the international student is pursuing (based on ISCED 2011 standard)
-- YEAR:          Year of enrollment
-- Value:         actual number of students based on the 

/*
-- Checking out the values for [SEX] column
SELECT DISTINCT [SEX]
FROM [IntlEducation_Stats].[dbo].[temp1]
*/

-- Values are F - female, M - male, _T - total
-- We don't need to distinguish on gender so we can just take those with SEX = '_T' to our new result table
SELECT [COUNTRY]
      ,[ORIGIN]
      ,[EDUCATION_LEV]
      ,[YEAR]
      ,[Value]
INTO [IntlEducation_Stats].[dbo].[temp2]
FROM [IntlEducation_Stats].[dbo].[temp1]
WHERE [SEX] = '_T'

/*
--  Checking contents of the table
SELECT TOP(100) *
FROM [IntlEducation_Stats].[dbo].[temp2]

SELECT COUNT(*)
FROM [IntlEducation_Stats].[dbo].[temp2]
-- now has 506496 records

-- Check the year values in the table
SELECT DISTINCT [YEAR]
FROM [IntlEducation_Stats].[dbo].[temp2]
ORDER BY [YEAR]
*/

-- Values were: 2005, 2010, 2011, 2012, 2013, 2014, 2015, 2016, 2017, 2018, 2019, 9999
-- Remove rows where Year = 9999 as well as 2005, 2010, 2011, 2012 since these year have limited values
DELETE FROM [IntlEducation_Stats].[dbo].[temp2]
WHERE [YEAR] in ('2005', '2010', '2011', '2012', '9999')

/*
SELECT COUNT(*)
FROM [IntlEducation_Stats].[dbo].[temp2]
-- now has 455047 records

-- Noticed that the Value column had a decimal point. In the site, they appeared as whole numbers rounded up.
-- This needs to be cleaned as there is no such thing as a "part of a person"
SELECT * FROM [IntlEducation_Stats].[dbo].[temp2] WHERE [Value] like '%.%'
*/

-- Altered the table to have the Value as float first
ALTER TABLE [IntlEducation_Stats].[dbo].[temp2]
ALTER COLUMN [Value] float;

-- Then, copied contents to a new table where Value is now truncated to a whole number
SELECT [COUNTRY]
      ,[ORIGIN]
      ,[EDUCATION_LEV]
      ,[YEAR]
      ,CAST([Value] AS INT) AS [VAL]
INTO [IntlEducation_Stats].[dbo].[temp3]
FROM [IntlEducation_Stats].[dbo].[temp2]

/*
SELECT TOP(100) * FROM [IntlEducation_Stats].[dbo].[temp3]

SELECT COUNT(*)
FROM [IntlEducation_Stats].[dbo].[temp3]
-- now has 455047 records

-- Check out the [COUNTRY] column, these values seem to resemble 3-character code (alpha-3)
SELECT DISTINCT [COUNTRY] FROM [IntlEducation_Stats].[dbo].[temp3]

-- Check out the [ORIGIN] column, these values seem to resemble ISO 3166 2-character code (alpha-2)
SELECT DISTINCT [ORIGIN] FROM [IntlEducation_Stats].[dbo].[temp3]

-- Checking the [ORIGIN] values against table of ISO 3166 country codes
-- However, there are some values here that don't represent countries but 3 digit numbers.
-- Based on the site, these represent a region/continent which we can remove
SELECT DISTINCT [ORIGIN] 
FROM [IntlEducation_Stats].[dbo].[temp3]
WHERE [ORIGIN] NOT IN (SELECT [2_DIGIT_CODE] FROM [IntlEducation_Stats].[dbo].[ISO_3166_COUNTRY_CODES])
*/

-- Aside from the 3 digit numbers there is the value 'XK' which stands for Kosovo but is not recognized by ISO 3166
-- So we move contents to a new temp table excluding those but including Kosovo
SELECT * INTO [IntlEducation_Stats].[dbo].[temp4]
FROM [IntlEducation_Stats].[dbo].[temp3]
WHERE [ORIGIN] IN (SELECT [2_DIGIT_CODE] FROM [IntlEducation_Stats].[dbo].[ISO_3166_COUNTRY_CODES]) OR [ORIGIN] ='XK'

/*
SELECT COUNT(*)
FROM [IntlEducation_Stats].[dbo].[temp4]
-- now has 426752 records

-- Checking the [COUNTRY] values that were not in IS0 3166
SELECT DISTINCT [COUNTRY] FROM [IntlEducation_Stats].[dbo].[temp4]
WHERE [COUNTRY] NOT IN (SELECT [3_DIGIT_CODE] FROM [IntlEducation_Stats].[dbo].[ISO_3166_COUNTRY_CODES])
*/

-- values yielded OEU, TOT, OTO
-- These stand for TOTAL OECD-Europe, Total and OECD-Total in the site
-- Thus these can be removed for our analysis
DELETE FROM [IntlEducation_Stats].[dbo].[temp4]
WHERE [COUNTRY] NOT IN (SELECT [3_DIGIT_CODE] FROM [IntlEducation_Stats].[dbo].[ISO_3166_COUNTRY_CODES])

/*
SELECT COUNT(*)
FROM [IntlEducation_Stats].[dbo].[temp4]
-- now has 404582 records

-- Now, cleaning up the column for Education Level
SELECT DISTINCT EDUCATION_LEV FROM [IntlEducation_Stats].[dbo].[temp4]

-- Values are ISCED11_5, ISCED11_54, ISCED11_55, ISCED11_5T8, ISCED11_6, ISCED11_7, ISCED11_8
-- On checking ISCED11_5 = ISCED11_54 + ISCED11_55
-- Classification on education level:
-- ISCED11_5 - Short cycle tertiary education
-- ISCED11_5T8 - Tertiary education 
-- ISCED11_6 - Bachelor's or equivalent
-- ISCED11_7 - Master's or equivalent
-- ISCED11_8 - Doctoral or equivalent
*/

-- We can remove ISCED11_54 and ISCED11_55 as we can use ISCED11_5
DELETE FROM [IntlEducation_Stats].[dbo].[temp4]
WHERE EDUCATION_LEV in ('ISCED11_54', 'ISCED11_55')

/*
SELECT TOP(100) * FROM [IntlEducation_Stats].[dbo].[temp4]

SELECT COUNT(*)
FROM [IntlEducation_Stats].[dbo].[temp4]
-- now has 289077 records
*/

-- Create a new country codes table to include Kosovo; 2 digit code is XK while 3 digit code is KSV
SELECT * INTO [IntlEducation_Stats].[dbo].[ISO_3166_COUNTRY_CODES_W_KSV]
FROM [IntlEducation_Stats].[dbo].[ISO_3166_COUNTRY_CODES]

INSERT INTO [IntlEducation_Stats].[dbo].[ISO_3166_COUNTRY_CODES_W_KSV]
VALUES ('Kosovo', 'XK', 'KSV')

-- Update Country Code to their actual names
SELECT
	B.COUNTRY AS COUNTRY_OF_SCHOOL
	,A.ORIGIN
	,A.[EDUCATION_LEV]
	,A.[YEAR]
	,A.[VAL]
INTO [IntlEducation_Stats].[dbo].[temp5]
FROM [IntlEducation_Stats].[dbo].[temp4] A
LEFT JOIN
[IntlEducation_Stats].[dbo].[ISO_3166_COUNTRY_CODES_W_KSV] B
ON A.COUNTRY = B.[3_DIGIT_CODE]

/*
SELECT COUNT(*)
FROM [IntlEducation_Stats].[dbo].[temp5]
-- now has 289077 records
*/

SELECT
	A.COUNTRY_OF_SCHOOL
	,B.COUNTRY AS COUNTRY_OF_ORIGIN
	,A.[EDUCATION_LEV] AS EDUCATION_LEVEL
	,A.[YEAR]
	,A.[VAL] AS NUM_OF_STUDENTS
INTO [IntlEducation_Stats].[dbo].[temp6]
FROM [IntlEducation_Stats].[dbo].[temp5] A
LEFT JOIN
[IntlEducation_Stats].[dbo].[ISO_3166_COUNTRY_CODES_W_KSV] B
ON A.ORIGIN = B.[2_DIGIT_CODE]

SELECT
	COUNTRY_OF_SCHOOL
	,COUNTRY_OF_ORIGIN
	,[YEAR]
	,SUM(NUM_OF_STUDENTS) AS TOTAL_INTL_STUDENTS
INTO [IntlEducation_Stats].[dbo].[OECD_EDU_ENRL_2013_2019]
FROM [IntlEducation_Stats].[dbo].[temp6]
GROUP BY COUNTRY_OF_SCHOOL,COUNTRY_OF_ORIGIN,[YEAR]

-- Table [IntlEducation_Stats].[dbo].[OECD_EDU_ENRL_2013_2019] will be exported to a CSV file
-- for further visualization on Tableau

/*
SELECT COUNT(*)
FROM [IntlEducation_Stats].[dbo].[temp6]
-- now has 289077 records

SELECT * FROM [IntlEducation_Stats].[dbo].[temp6]
WHERE [COUNTRY_OF_SCHOOL] IS NULL OR [COUNTRY_OF_ORIGIN] IS NULL
*/

-- Now, forming another table including the population from the World Bank

-- Data extracted from the World Bank Data Bank in a CSV file has been loaded into 
-- Table [IntlEducation_Stats].[dbo].[WORLD_BANK_SELECTED_WDI_2013_2019]

-- Before using that table, Country Codes are again needed to be able to join
-- OECD data with World Bank data

SELECT
	A.COUNTRY_OF_SCHOOL
	,B.COUNTRY AS COUNTRY_OF_ORIGIN
	,B.[3_DIGIT_CODE] AS ORIGIN_COUNTRY_CODE
	,A.[EDUCATION_LEV] AS EDUCATION_LEVEL
	,A.[YEAR]
	,A.[VAL] AS NUM_OF_STUDENTS
INTO [IntlEducation_Stats].[dbo].[temp7]
FROM [IntlEducation_Stats].[dbo].[temp5] A
LEFT JOIN
[IntlEducation_Stats].[dbo].[ISO_3166_COUNTRY_CODES_W_KSV] B
ON A.ORIGIN = B.[2_DIGIT_CODE]

SELECT 
	COUNTRY_OF_ORIGIN
	,ORIGIN_COUNTRY_CODE
	,[YEAR]
	,SUM(NUM_OF_STUDENTS) AS TOTAL_INT_STUDENTS
INTO [IntlEducation_Stats].[dbo].[INTL_STUDENT_ORIGIN_2013_2019]
FROM [IntlEducation_Stats].[dbo].[temp7]
GROUP BY COUNTRY_OF_ORIGIN,ORIGIN_COUNTRY_CODE, [YEAR]
-- Table [IntlEducation_Stats].[dbo].[INTL_STUDENT_ORIGIN_2013_2019] will be exported to a CSV file
-- for further analysis using Python

/*
-- Check the Selected WDI table
SELECT DISTINCT SERIES_CODE, SERIES_NAME FROM [IntlEducation_Stats].[dbo].[WORLD_BANK_SELECTED_WDI_2013_2019]
*/

/*
-- SERIES values are as follows:
----------------------------------------------------------------------------------------------------------------------
SERIES_CODE	        | SERIES_NAME
----------------------------------------------------------------------------------------------------------------------
NY.GDP.MKTP.KD.ZG	| GDP growth (annual %)
NY.GDP.PCAP.CD	    | GDP per capita (current US$)
NY.GDP.MKTP.CD	    | GDP (current US$)
SP.POP.TOTL	        | Population, total
SE.XPD.CTER.ZS	    | Current education expenditure, tertiary (% of total expenditure in tertiary public institutions)
SE.XPD.TERT.PC.ZS	| Government expenditure per student, tertiary (% of GDP per capita)
SE.XPD.TERT.ZS	    | Expenditure on tertiary education (% of government expenditure on education)
EN.POP.DNST	        | Population density (people per sq. km of land area)
SL.UEM.ADVN.ZS	    | Unemployment with advanced education (% of total labor force with advanced education)
SP.POP.GROW	        | Population growth (annual %)
SP.URB.GROW	        | Urban population growth (annual %)
NY.GDP.PCAP.KD.ZG	| GDP per capita growth (annual %)
SP.RUR.TOTL.ZG	    | Rural population growth (annual %)
----------------------------------------------------------------------------------------------------------------------
*/

SELECT
	A.COUNTRY_OF_ORIGIN
	,A.ORIGIN_COUNTRY_CODE
	,A.[YEAR]
	,A.TOTAL_INT_STUDENTS
	,TRY_CAST(B.[VALUE] AS BIGINT) AS [POPULATION]
INTO [IntlEducation_Stats].[dbo].[temp8]
FROM [IntlEducation_Stats].[dbo].[FINAL_INTL_STUDENT_ORIGIN_2013_2019] A
INNER JOIN
(
SELECT * FROM [IntlEducation_Stats].[dbo].[WORLD_BANK_SELECTED_WDI_2013_2019]
WHERE SERIES_CODE = 'SP.POP.TOTL'
) B
ON A.ORIGIN_COUNTRY_CODE = B.[COUNTRY_CODE]
AND A.[YEAR] = B.[YEAR]

-- Checked that there were 0 population value for Eriteria as there was no value
-- for year 2013-2019
SELECT *
FROM [IntlEducation_Stats].[dbo].[temp8]
WHERE POPULATION=0

DELETE FROM [IntlEducation_Stats].[dbo].[temp8]
WHERE POPULATION=0

SELECT
	COUNTRY_OF_ORIGIN
	,[YEAR]
	,TOTAL_INT_STUDENTS
	,[POPULATION]
	,CAST(TOTAL_INT_STUDENTS AS FLOAT)/CAST([POPULATION] AS FLOAT)*100 AS PERCENT_POPULATION
INTO [IntlEducation_Stats].[dbo].[INTL_STUDENTS_PER_POPULATION]
FROM [IntlEducation_Stats].[dbo].[temp8]

-- Table [IntlEducation_Stats].[dbo].[INTL_STUDENTS_PER_POPULATION] will be exported to a CSV file
-- for further visualization on Tableau
SELECT * FROM [IntlEducation_Stats].[dbo].[INTL_STUDENTS_PER_POPULATION]



