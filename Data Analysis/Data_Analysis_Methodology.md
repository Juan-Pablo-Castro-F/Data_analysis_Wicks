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
- Last we will create new columns which will have the size of the body of the candle (Open - Close) and the candle size (High - Low), since this data takes a different sign based on the direction of the market, we will also add some columns which will have the absolute value since our interest is to analyse the growth of the market not the direction of it. 

Now we are ready to proceed to Power Bi to make the analysis of our data. 

## Analysis

Before we start with the analysis, we have decided to add some more columns in the table but from the power BI platform. Since we want to be able to compare the growth of the candles, we will dive them inter-row and, in this way, see how much the candle has growth compare to the previous one. To do so we used the merging queries option of power BI, in future studies we will use DAX to do this operation for more complex problems. 
After doing so we are finally ready to start to analyse the data. The different Power BI documents can be found in the repository. 

All the images displayed in this document can also be found in the folder img in the repository. This analysis will be done with the currency pair EURUSD which contains the money exchange of Euro and United states Dollar.  The same process was conducted with another 2 assets, nonetheless we won’t explain them in this document and the analysis will only be added to the repository for any interested reader. 

### Change of price over time 
We will first start with the line chart. In this graphic you can see displayed the data of Average body size, average candle size and the spread. In first sight we can identify that there is a accelerated increase in the size of the candle and the body from 8:00 until 11:00 as we expected, as well we can see that there is another significative increase from 14:00 until 18:00. 
The most probable cause for these accelerated moves in the respective times is that at 8:00 is the opening time of the London exchange which trades most of the volume that influences the Euro, as well from 14:00 is when the exchange of New York starts to operate. We can also notice that the gap between candle size and body size widens since 9:00 and stays like this until the end of the day. This tells us that during those times price experience increased volatility and therefore the size of wicks (Difference between the extreme points and the open and close). 
One last thing that is important in this chart is that the spread price is always constant, which is a promising investment signal since that tells us we wont need to pay high commissions for trading. With this previous analysis we have answered a couple of the questions. We will now move to the missing ones related to the average of movement. 

![Change of price over time](./img/EURUSD_15m_Line_charts.png)


### Growth over time 

In this second chart we are able to see a different metric, the growth, this metric is taken by dividing the size of the current candle by the last candle size. In first sight this graphic seems completely random and unnecessary. Nonetheless if we take a deeper look there is plenty information which will help us to improve our previous opinions. 
The randomness that we see is a sign of itself, which tells us that the growth of the candles does not have a linear growth, but instead some peak times. Therefore, we should not expect that there will be continuous growing moves up and down as many people believes but instead a ranging characteristic. 
However, we can see that from 8:30 the peak growth of candle goes over the 8 level and stays in this way until 15:15 which means that during this time we can expect bigger candles compared to the previous ones. We can also see that these peaks are mostly formed by 4 different candles with increasing growths, which means that at the times of the peaks there was a linear growth during a whole hour.

![Change of growth over time](./img/EURUSD_15m_Growth.png)

### Tick Volume 
The last thing that we will analyse is the volume behaviour in the market. As we had expected the behaviour would be so like the candle size in the chart line. However, this is more precise in showing us at what time the different exchanges volume increases. We can identify 2 specific lapses, from 9:00 to 10:00 the most accelerated growth which is the possible zone we should take advantage of and the second one being from 14:30 to 15:30. 
With this last chart we have all the information we need to do a strategy proposal and see the usability of our performance in previous market behaviours. 

![Change of tick volumer over time](./img/EURUSD_15m_Tick_Volume.png)

## Interpretation

In the previous analysis sections, we have been able to identify the different possible behaviours of the market, now we will create certain rules which intend to take advantage of the predictable patterns of the market to take profitable trades. 
Since we found two-time sessions where price has considerable growth, increased size of candles and increased volatility we will trade during those times and by doing so we will be able to take advantage of considerable moves. Nonetheless we need to be able to choose the right direction, for this strategy development we have decided to use a theory based in the Asian range which states that price direction is decided at the extreme high and low points which took place during the Asian exchange times which are from 1:00 a.m. and 7:00. However, this two times are arbitrary and non-tested, therefore we will make an optimization to find the best values. 
With the research we have carry on we also found that we can expect the size of the candles to be above 6 and even 8 pips (Size measure in the markets) per candle, therefore we could expect that in a lapse of 1 hour we could make a total of 24 pips if all the candles go in the direction that we have chosen. With this information we will be able to establish the most appropriate stop loss and take profit levels. 
We have already decided a respectable number of parameters based on the analysis. Some others will be standard since are more related to the risk management like the risk per trade or fixed lot. 
The parameter that we have chosen arbitrarily will be optimized to find the most suitable configurations for our trading strategy. In this optimization we will try to identify patterns on the use of different values for different patterns, as well we will consider walk forward analysis, confidence levels and statistical significance. 

## Conclusions

In the randomness of the price action is possible to find some patterns which can improve our probability to profit from the market fluctuations. We have established some patterns which we will now employ in the development of a trading strategy to evaluate if is possible to take advantage of those to make profit in the market. 
In the Optimization section you will find the results of the strategy as well the following statistical models carried in order to improve the strategy and propose different variations in order to have the most suitable trading strategy. 


