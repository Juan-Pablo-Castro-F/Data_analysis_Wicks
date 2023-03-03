# Data analysis of time influence in the market. 
> In this section we will proceed to do the data analysis and in that way we will identify which patterns we could take advantage of to generate an strategy. 

## Table of Contents
* [Objectives](#objectives)
* [Data collection](#data-collection)
* [Data cleansing](#data-cleansing)
* [Analysis](#analysis)
* [Interpretation](#interpretation)
* [Conclusions](#conclusions)

## Objectives
As mentioned in the main description of the project we have some specific questions that we want to answer in this research. We intend to get a better understanding of the way time influence in the market price and volume, the following questions would help us to correctly perform the analysis: 

- What time does the market volume starts to increase.
- What is the average move during these times.
- What are the probabilities of such a move happening.
- How does the spread changes during this period of time and when is the movement concluded.


## Data collection

In order to make the analysis in the best way we have to ensure that we have reliable data so in that way the research has some significance. We have two different sources which we could employ to get proper data. 
The first option is with the program Quant Data manager, this program will provide us the dataset from reliable investment banks which have already done some type of cleansing of the data in order to diminish gaps and other unusual price action. 
The other method is to get the data directly from the broker you will use in the research. This is the model that we have applied in this research to guarantee that the model we are going to propose not only fits the market price but also the broker variables. 

We have multiple options to see the data. Since we are talking about the time series the most important factor to decide is the timeframe of the data we have decided 15 minutes candles since we find it relevant for the study and applicable to the possible strategies we will propose. 
The data is provided in one column which contains 7 different type of data. Date, time, opening price, highest price, lowest price, Close price, tick volume, Volume, Spread. We then take this data to SQL server to cleanse it and prepare it for our analysis. You can see the original data in the repository. 

## Data cleansing

For this stage we have done the following steps:

- We will first take out of our data set the columns that are not relevant for the study. Initially the Volume variable is not relevant since in the assets we are evaluating this info will always be 0, however we will keep the tick vol which actually tells us the actual volume. 
- Secondly, we will proceed to find if there is any row where the value of High, Low, Open or Close is 0 or some invalid value and then we will proceed to fill it with the value above. Additionally, we will also check if there is any duplicate in the times, to make sure that there is no unwanted candles.  
- We have already make sure that all the data that was provided has no gaps, errors or unwanted repetitions, we will then proceed to check if there is any unwanted outliers, to do so we can employ different methods, the one we use this time is to plot the data with python in order to find visually which data could be outliers and the remove them. In future studies we will make it inside the Power BI platform or directly in the Data provider visualization aid. Our data is taken from 2019 until 2023, as expected this data has so many outliers since the world has seen a lot of uncommon events. We have two periods which present a lot of difference compared to the average of the rest of the data, the start of Covid-19 in February 2020 – May 2020, and the start of the war in Ukraine from Feb 2022 – May 2022. These two periods have some unwanted outliers and therefore we will exclude them from the research.
- The creation of new columns we will use Dax in Power Bi because it eases the access to previous rows which is essential for the analysis we are making in this excercise. 

## Analysis

>The different Power BI documents can be found in the repository. 
>All the images displayed in this document can also be found in the folder img in the repository. This analysis will be done with the currency pair EURUSD which contains the money exchange of Euro and United states Dollar.  The same process was conducted with another 2 assets, nonetheless we won’t explain them in this document and the analysis will only be added to the repository for any interested reader. 

To understand better the type of analysis we are going to make we will first need to explain deeper our idea. We believe that price keeps moving in the direction of the last candle, therefore we want to test how much we move in the last direction candle. One candle has the information of a specific time range, in our analysis a range of 15 minutes. This candle would have the highest value that was achieved and as well the lowest. 
In the same way it would have a opening price and a closing price. If the opening price is less than the closing time, it means that the candle was bullish, which means that price increased in that lapse of 15 minutes. In the opposite case we would call it a bearish candle which means that price went down in that time lapse. 
For our analysis we will use these previous explained variables. To understand better we will make an example of the analysis, if the last candle was bullish then we want to find how much the current candle went above the previous candle high, the reason we compare the highs is because we are expecting a continuation of an upward move since the last candle was bullish. 
The same procedure would be done with a bearish candle, but the comparison would be made with the low values. 

### Wick size probability 
In this first chart we can see the probability of price crossing the previous candle extreme by different lengths. As we can see before the London and New York exchanges open we have a relative low length with over 50% of probability that the value didn’t cross the 2 pips of length. Once the London exchange opens we see a complete shift in the statistics with a sudden increase of the probability of it being over 4 pips, with an overwhelming 51% chance of the price going over 4 pips of length. 
We can also see in this chart that the probability of it being above 2 and below 4 pips is low, which shows us that price either has really low momentum which happens at the start of the day or a really high momentum during the main sessions, but never experiences a middle point with a mixed volatility. 
We can also see a fluctuation of this probability completely related to the session times, we can identify that this high momentum has only a peak until 10 a.m. then it lowers and stays low until the opening of New York. As well 3 hours after the opening of New York the momentum starts a fast decay and returns to under 20% levels. 

![Wick size probability ](https://github.com/Juan-Pablo-Castro-F/Data_analysis_Wicks/blob/b260bc2beeaf26022807cd51c57a1d8e563fa053/img/Wick_size_probability_chart.png)


### Trend continuation 

In this chart we can see the probability of price crossing the previous candle direction extreme against the probability of not crossing it. This chart is really enlightening since we can see that along the whole time there is a great probability of passing it, which is a characteristic that we could take advantage of. As well we can see that there is peaks during the opening and closing of session times which is a good lead for us to select our parameter in the optimization section. 

![Trend continuation ](https://github.com/Juan-Pablo-Castro-F/Data_analysis_Wicks/blob/b260bc2beeaf26022807cd51c57a1d8e563fa053/img/Trend_continuation_chart.png)

### Probability of target length 
This last chart was made having the development of the strategy more centralized. Knowing the previous stats, we can already conclude that this statistic could work. For this reason, we have decided to evaluate specific parameter value to see if it has great chance of succeeding. As we can see there is a considerable probability of reaching the desired target of approximately 70% for this reason, we believe we have all that I needed to jump to the strategy development section 

![Probability of target length ](https://github.com/Juan-Pablo-Castro-F/Data_analysis_Wicks/blob/b260bc2beeaf26022807cd51c57a1d8e563fa053/img/Required_level_chart.png)

## Interpretation

In the previous analysis sections, we have been able to identify the different possible behaviours of the market, now we will create certain rules which intend to take advantage of the predictable patterns of the market to take profitable trades. 
Since we found times where price has a higher probability of crossing the previous candle extremes we will trade during those times and by doing so we will be able to take advantage of considerable moves. 
With the research we have carry on we also found that we can expect the size of the candles to cross the previous candle extreme to be above a 4 pips with a considerable probability of returning a profitable trade, for this reason we will use this value as our take profit target. However there is no specific measure for our stop loss and therefore we will optimize this one with different values to find which value could suit us better. 
Based on our different length probabilities we might add some other risk and trade management tools which will make use of the analysis in order to protect the profit the positions along the price crosses different lengths. 
We have already decided a respectable number of parameters based on the analysis. Some others will be standard since are more related to the risk management like the risk per trade or fixed lot. 
The parameter that we have chosen arbitrarily will be optimized to find the most suitable configurations for our trading strategy. In this optimization we will try to identify patterns on the use of different values for different patterns, as well we will consider walk forward analysis, confidence levels and statistical significance.

## Conclusions

In the randomness of the price action is possible to find some patterns which can improve our probability to profit from the market fluctuations. We have established some patterns which we will now employ in the development of a trading strategy to evaluate if is possible to take advantage of those to make profit in the market. 
In the Optimization section you will find the results of the strategy as well the following statistical models carried in order to improve the strategy and propose different variations in order to have the most suitable trading strategy. 


