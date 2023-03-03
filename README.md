# Currencies wick analysis 
> Analysis of the momentum characteristic in the market and in selected assets and creation of algorithmic bots to take advantage of these behavioural patterns. 

## Table of Contents
* [General Info](#general-information)
* [Technologies Used](#technologies-used)
* [Setup](#setup)
* [Contact](#contact)
* [Terms of Use](#terms-of-use)
* [Disclaimer and Risk Warnings](#disclaimer-and-risk-warnings)
 

## General Information

The market has some intrinsic qualities which are known for every trader, one of those is the momentum, meaning the constant movement of the market in the last candles direction. Before any movement stops there has to be a turning point and with this research we plan on finding out all information we can about this turning point and how we could benefit from it. 

#### What?

Our objective is to find out any behavioural pattern of the momentum in 15m candles and identify characteristics of the turning point to develop a strategy which allow us to take advantage of it or a risk management technique which we could use in support to previously proposed strategies . To do so we intend to respond the following questions: 
- What is the probability of crossing the previous candle extreme.
- How many times did we cross the previous candles extremes
- What are the times when this probability increases
- How much does the wick crosses and what is the probability of each different length. 

Nonetheless is important to understand that every asset or currency is influenced by different parties, therefore a specific analysis must be carried for each asset in order to determine the hours for each specific asset as well the different values in growth or spread. 

#### Methodology
Initially we will make the data analysis of the set to find the answers to the questions stated in the previous section. Afterwards, we will be able to propose a trading strategy which take advantage of this characteristics and mitigate any risk that could come from it. Following, we will make some testing to see if the idea that we have proposed can have the desired outcomes in the future live market, as well we will make a data optimization to see how the parameters could be improved and which changes could enhance the functioning of the strategy. 

#### Why?
Investing in the financial markets is one of the oldest ways of profiting from price movements. However, the chances of succeeding in this activity are really low and only the best traders can profit in the long run. In order to increase the chances of having success over long periods we need to implement a probability-based investment plan where we consider risk management, rule-based entry criteria and an edge which increases the probability of being successful.   

## Technologies Used
- Power Bi. 
- Microsoft SQL server 18.
- Google collab (Python).
- Metatrader 5 (C++).
- Quant Data manager. 
- Quant Data analyzer. 

## Setup
You can find the finished strategy in the directory src. To use it you can copy the content of the text document to a Metaquotes 5 file (.mq5) compile and then use the executable version in the Metatrader 5 application.Is recommendable that you make some testing of your own to guarantee that the strategy has some good performance given your broken data and conditions (Read Disclaimer and risk warning). 

## Contact
Created by [@Juan-Pablo-Castro-F] - feel free to contact me!


## Terms of Use

By using this software, you understand and agree that we (company and author)
are not be liable or responsible for any loss or damage due to any reason.
Although every attempt has been made to assure accuracy,
we do not give any express or implied warranty as to its accuracy.
We do not accept any liability for error or omission.

You acknowledge that you are familiar with these risks
and that you are solely responsible for the outcomes of your decisions.
We accept no liability whatsoever for any direct or consequential loss arising from the use of this product.
You understand and agree that past results are not necessarily indicative of future performance.

Use of this software serves as your acknowledgement and representation that you have read and understand
these TERMS OF USE and that you agree to be bound by such Terms of Use ("License Agreement").

## Disclaimer and Risk Warnings

Trading any financial market involves risk.
All forms of trading carry a high level of risk so you should only speculate with money you can afford to lose.
You can lose more than your initial deposit and stake.
Please ensure your chosen method matches your investment objectives,
familiarize yourself with the risks involved and if necessary seek independent advice.

NFA and CTFC Required Disclaimers:
Trading in the Foreign Exchange market as well as in Futures Market and Options or in the Stock Market
is a challenging opportunity where above average returns are available for educated and experienced investors
who are willing to take above average risk.
However, before deciding to participate in Foreign Exchange (FX) trading or in Trading Futures, Options or stocks,
you should carefully consider your investment objectives, level of experience and risk appetite.
**Do not invest money you cannot afford to lose**.
