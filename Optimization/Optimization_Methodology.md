# Data Optimization of time influence in the market. 
> In this section we will proceed to optimize the proposed strategy with a series of statistical tests and models in order to find the parameters that better suit the strategy. 

## Strategy description 
> The strategy we have chosen to employ the results of our research consist of taking a trade in the previous candle high if we a re in a bullish trend or take a sell in the previous low in a bearish trend. This strategy will be carried in the most suitable times which we found in the analysis as well will integrate other tools of trade management which will be triggered in the levels that our research advised as most suitable. 

## Parameters description
The algorithmic robot has multiple parameters which can be modified, however we will only mention the ones that will be used in this optimization. We will divide them in different categories to understand which will be the process with each of the parameters:
### Non-optimized variables
-	session times which we have found in our analysis results 
-	use a risk of 1 % per trade since this wont influence in the results of our trades.

### Optimizable variables
-	Filters to select the validity of the previous candles.
-	Trading end time 
-	Stop Loss and take profit 
-	Trailing stop parameters (Trade management options)
-	Breakeven parameters (Trade management options)

## Initial Optimization

>We are approaching the optimization of the strategy as we would be doing with a regression model. We have a function which has different coefficients (parameters) that describe the behaviour and we are trying to find the most suitable parameters. For this reason, we need to be mindful of the statistical significance of our tests, as well of the overfitting of data and the confidence level of the model. 

The metric that we have decided to use to evaluate the fitness of each parameter is the profit factor which divides the total profit with the total loss and is considered one of the best measures to see the fitness of a model. 
We run a first optimization with the different variables that we have chosen to optimize. Nonetheless keep in mind that this first optimization is only run to see if we can identify some trend in the configuration of the patterns and that way establish what could be in a generalized way the most appropriate settings for the trading system. 

### Candles Filters

We have evaluated in the optimization 3 different filter to improve our chances of getting profitable trades. The first filter assessed is a candle patterns filter, with this one we don’t find many differences between having it activated or not, however we decide to keep it on since some of the results seem to have better metrics than its homologues without it. Same situation we experience with the filter of inside bars, which is another pattern we wanted to try apart from the filter before. With this one the same result was gotten and therefore we decided to keep it on as well. 
The one that gave us most interesting results is the filter of last day direction as you can see in the image below. Clearly without the filter we would be missing out in too much profit since we would be taking too many trades which would cause us losses. For this reason, we will also keep this filter on so we have better results. 

![Last day filter ](https://github.com/Juan-Pablo-Castro-F/Data_analysis_Wicks/blob/8820748e2ec9e3513e8214755bb27d610d88c969/img/Filter_last_day_direction.png)

### Trade management

Regarding the stop loss and the take profit, we need to evaluate these two variables together since they are strictly correlated to each other so we need to know which are the patterns in the combinations of this parameter.
> We have decided to use the take profit values using the risk reward method which states that the take profit is put in a equidistant of the stop loss and multiply it by a coefficient which is the called RR. 

As we can see the results in the 3D image, we can see that so many combinations give satisfactory results, however our objective is not to find the peaks but to find the consistent valleys with profit. Due to the nature of the chart is quite hard to do this task however we can see that the most appropriate values for risk to reward are 3 and higher, therefore these will be the ones we will use in the forward test option. 
Regarding stop loss we cannot identify any specific behavior, therefore we won’t exclude it from the next stage and we will prove its validity after. 

![Stop Loss and Take profit chart ](https://github.com/Juan-Pablo-Castro-F/Data_analysis_Wicks/blob/8820748e2ec9e3513e8214755bb27d610d88c969/img/Stop_loss_RR_analysis.png)


Last thing we are interested in testing is one of the tools we mention for trade management, which is the trailing stop, this functionality enables the robot to keep modifying the stop loss as much as we are moving in the right direction in this way, we mitigate our losses and increase our winnings. This option could make us miss some profit but will ensure we reduce our losses the most. 
As we can see in the chart the use of the trailing stop is compulsory for our system, the results are extremely different when not using it and we need to make sure to use it in order to grant us better chances of success., therefore we will keep it on for the forward analysis and what we will do is to optimize the parameter within the trailing stop tool in order to get the most suitable combination. 

![Trailing Stop tool  ](https://github.com/Juan-Pablo-Castro-F/Data_analysis_Wicks/blob/8820748e2ec9e3513e8214755bb27d610d88c969/img/Trailing_stop_analysis.png)

We have analyzed all the variables we wanted to evaluate, now we will proceed to the next stage of the optimization. 


## Walk forward analisis

>Forward optimization is a practice to reduce the overfittings of data in a model in order to make it more reliable and robust. To do so the period of optimization is divided in two different sections. The in-sample period, which is the part where you optimize the data in order to find the parameters that fit better your requirements, after that you run the 10% of the best combination of parameters in the second part of data which is called the out-sample data. In this second part you are trying to see if the optimized variables would perform as good as they did in the optimization. 
The reason of the implementation of this model is that we are interested in making sure our model would be able to provide profit in longer period of times and in live market conditions and to make sure that is not only performing well in the statistical tests that we are making. 

We will perform our test in the last year price data. We will use the in-sample data from May until end of December, and the out-sample data will be from January to the end of February. This will give us a total of 8 months in data and 2 months out data to a forward ratio of 1:4. 
The results given by this method are two data files, first with the in sample run which can be found in the repository under the name Second_stage_optimization and the out-sample part Second_stage_forward. 

![Forward Results ](https://github.com/Juan-Pablo-Castro-F/Data_analysis_Wicks/blob/192d2e50e709dd6ec5427e8956a8b9fc7d05cfd7/img/Best_forward_results.png)

In the image above we can see the best 10 results from boths of the tests. As we can see in multiple cases the reliability of the model stands and the predictability of the model works. We will chose the first set of parameters since we believe that’s what adjust the best to the parameters conditions and as well it has a low drawdown which is a key in strategy development. 
We then proceed to run specific test of the model in the whole data set to see more qualities about the system and familiarize better with other metrics which will help us to understand better the system. 

![Final Equity Curve ](https://github.com/Juan-Pablo-Castro-F/Data_analysis_Wicks/blob/192d2e50e709dd6ec5427e8956a8b9fc7d05cfd7/img/Final_equity_curve.png)

The above pictured depicts the simulated equity curve if we would have used our trading strategy in the last year. In this equity curve we can see that along the whole time the price has healthy fluctuations. We see that the growth is constant which is great because it give more reliability on it lasting over long periods of time. 

## Conclusions

The use of data analysis, statistical tests and different data transformation techniques can improve the development of trading systems and guarantee a longer lasting result. When investing in the markets it is main priority to have an edge that increases the probabilities of succeeding and analysing the data in the way that we have performed can provide you a good insight in tools and knowledge which can then be employed in the real market. 
There is many more analysis which could be employed. However, with the ones that we have already done we have gotten a great model and a great set of parameters which are ready to be used in financial market analysis. 
The same analysis was carried out with other assets yielding considerable results which can be taken into account in future live market tests to be ready to use. 
