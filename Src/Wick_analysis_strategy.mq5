//+------------------------------------------------------------------+
//|                                           Sessions liquidity.mq5 |
//|                                  Copyright 2023, MetaQuotes Ltd. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2023, MetaQuotes Ltd."
#property link      "https://www.mql5.com"
#property version   "1.00"


//---

#include <Trade/Trade.mqh>

int bars;
int bars1;
double bidprice;
double dailybars, dailybars1;

// Specs for Taking trades 
double lots;
CTrade trade;

//Close at time 
ulong position;  

input group "TRADING TIME 1"
input int Trading1StartTime = 9;   //Trading start time
input int Range1minutesstarttime = 0;   // Trading minutes start
input int Trading1EndTime= 12;  // Trading end time
input int range1minutesendtime = 0; // Trading minutes end

input ENUM_TIMEFRAMES timeframe = PERIOD_CURRENT;

input group "STRATEGY FILTERS"
input bool filtercandlepatterns = true;// Filter candle patterns 
input bool filterinsidebars = true; // Filter of inside bars
input bool filtertradingtime = true; // Trading time filter
input bool filterlastdaydirection = false; // Filter direction

input group "Trade management"
input double Lots = 0.1; //Fixed Lot 
input double riskpercentage =2.0; // Percentage risk
input int SlPoints = 10; // Stop Loss Points
input double risktoreward = 5.0; //Risk to Reward 
input int magic = 789; // Magic Number
input string Ordercomment = "EYES TRADER "; // Order Comment


input group "AGGRESIVE TRAILING STOP";
input bool trailingon = true; // Aggresive trailing? 
input int tslpoints =10; // Trailing Stop Loss Points
input int tsltriggerpoints = 10; // Trailing Stop Trigger
input bool BEenabled = true; 
input double BElevel = 10;   
input int beadditionalpoints = 5; 

ulong buypos, sellpos; 


// Converted time data 
datetime Trading1Start ,Trading1End;

//Strategy usage
bool validdailyhighlevel = true; 
bool validdailylowlevel = true;
double initialdaybalance; 
//---
double dailyprofit;

int OnInit(){

   if(Trading1StartTime>Trading1EndTime){
      printf("The Start time needs to be earlier than the end time.");
      return INIT_PARAMETERS_INCORRECT;
   }
   if(riskpercentage == 0 && Lots >= SymbolInfoDouble(_Symbol,SYMBOL_VOLUME_MAX)) {
      printf("Fixed lot is higher than the allowed in your account.");
      return INIT_PARAMETERS_INCORRECT;
   }
   
   trade.SetExpertMagicNumber(magic);
   if(!trade.SetTypeFillingBySymbol(_Symbol))
     {
      trade.SetTypeFilling(ORDER_FILLING_RETURN);
     }

   for(int i = PositionsTotal()-1; i >= 0; i--){
      CPositionInfo pos;
      if(pos.SelectByIndex(i)){
         if(pos.Magic() != magic)
            continue;
         if(pos.Symbol() != _Symbol)
            continue;
         if(pos.PositionType() == POSITION_TYPE_BUY)
            buypos = pos.Ticket();
         if(pos.PositionType() == POSITION_TYPE_SELL)
            sellpos = pos.Ticket();
      }
   }

   for(int i = OrdersTotal()-1; i >= 0; i--){
      COrderInfo order;
      if(order.SelectByIndex(i)){
         if(order.Magic() != magic)
            continue;
         if(order.Symbol() != _Symbol)
            continue;
         if(order.OrderType() == ORDER_TYPE_BUY_STOP)
            buypos = order.Ticket();
         if(order.OrderType() == ORDER_TYPE_SELL_STOP)
            sellpos = order.Ticket();
      }
   }
   
   
return(INIT_SUCCEEDED);
}


void OnDeinit(const int reason){

}


void OnTick(){
   if(trailingon){
      processpos(buypos);
      processpos(sellpos);   
   }
   if(BEenabled){
      Breakeven();
      checkingpos(buypos);
      checkingpos(sellpos);
   }


   dailybars = iBars(_Symbol,PERIOD_D1);
   if(dailybars != dailybars1){
      dailybars1 = dailybars;
      closeallpositions();
      calculateranges();
      initialdaybalance = AccountInfoDouble(ACCOUNT_BALANCE);
   }
   
   bars = iBars(_Symbol,timeframe);
   
   if((filtertradingtime && TimeCurrent() > Trading1Start && TimeCurrent() < Trading1End && bars != bars1) || (!filtertradingtime && bars != bars1) ){
      bars1 = bars;
      closeonlyorders();      
      setDayorders();   
   }
   
   if(TimeCurrent() == Trading1End){
      closeallpositions();
   }   
}

double calclots (double riskpercent, double slpoints){
   double ticksize = SymbolInfoDouble(_Symbol,SYMBOL_TRADE_TICK_SIZE);
   double tickvalue = SymbolInfoDouble(_Symbol,SYMBOL_TRADE_TICK_VALUE);
   double lotstep = SymbolInfoDouble(_Symbol,SYMBOL_VOLUME_STEP);
   if(ticksize == 0 || tickvalue == 0 || lotstep == 0){
      return 0;
   }   
   double riskmoney = AccountInfoDouble(ACCOUNT_BALANCE) * riskpercent / 100;
   double moneylotstep = (slpoints / ticksize) * tickvalue * lotstep;   
   if(moneylotstep == 0 ){
      return 0;
   }
   double lots = MathFloor(riskmoney / moneylotstep) * lotstep;  
   lots = MathMin(lots,SymbolInfoDouble(_Symbol,SYMBOL_VOLUME_MAX));
   lots = MathMax(lots,SymbolInfoDouble(_Symbol,SYMBOL_VOLUME_MIN));
 
   return lots;
}

void setDayorders(){
   double previousdayhigh = iHigh(_Symbol,timeframe,1);
   double previousdaylow = iLow(_Symbol,timeframe,1);
   validdailyhighlevel=true;
   validdailylowlevel=true; 
   if(filtercandlepatterns){ 
      int signal = gethammersignal(0.15,0.5); 
      if(signal == -1){
         validdailylowlevel = false;
      } else if (signal == 1){
         validdailyhighlevel = false;
      } else if (signal == 0){
         validdailyhighlevel = true;
         validdailylowlevel = true;
      }
   } 
   
   if(filterinsidebars){
      bool signalinsidebars = insidebars(timeframe);
      if(signalinsidebars){
         validdailyhighlevel=false;
         validdailylowlevel=false;
      }
   } 
   
   if(filterlastdaydirection){
      double candle1open = iOpen(_Symbol,timeframe,1);
      double candle1close = iClose(_Symbol,timeframe,1);      
      if(candle1open < candle1close){
         validdailylowlevel = false; 
      } else if (candle1close < candle1open){
         validdailyhighlevel = false; 
      }
   }
   double candle0high = iHigh(_Symbol,timeframe,0);
   double candle0low = iLow(_Symbol,timeframe,0);
   
   
   if(validdailyhighlevel && candle0high<previousdayhigh)executeBuy(previousdayhigh);
   if(validdailylowlevel && candle0low>previousdaylow)executeSell(previousdaylow);

}

bool insidebars(ENUM_TIMEFRAMES timeframe){
   double candle1high = iHigh(_Symbol,timeframe,1);
   double candle1low = iLow(_Symbol,timeframe,1);
   double candle2high  = iHigh(_Symbol,timeframe,2);
   double candle2low  = iLow(_Symbol,timeframe,2);
   
   if(candle2high> candle1high && candle2low<candle1low){
      return true;      
   } else {
      return false; 
   }
}



void executeBuy(double entry){
   entry = NormalizeDouble(entry,_Digits);
//---
   double bid = SymbolInfoDouble(_Symbol,SYMBOL_BID);
   double ask = SymbolInfoDouble(_Symbol,SYMBOL_ASK);
   int stoplevel = (int) SymbolInfoInteger(_Symbol,SYMBOL_TRADE_STOPS_LEVEL);
   int spread = (int)SymbolInfoInteger(_Symbol,SYMBOL_SPREAD);   
   if(entry - ask < (stoplevel + spread) * _Point) return;
//--- 
   double sl = entry - SlPoints * _Point;
   sl = NormalizeDouble(sl,_Digits);
   double slpoints = entry - sl;
   slpoints = NormalizeDouble(slpoints,_Digits);
   double tp = entry + slpoints * risktoreward;
   tp = NormalizeDouble(tp, _Digits);
   if(sl > 0 && entry - sl < (stoplevel + spread) * _Point){
      sl = sl - (stoplevel + spread)*_Point;
      tp = entry + (entry - sl)*risktoreward;
   }
   if(tp > 0 && tp - entry < (stoplevel + spread) * _Point) tp = entry + (entry - sl)*risktoreward;
   
//---
   lots = Lots;
   if(riskpercentage > 0) lots = calclots(riskpercentage, entry-sl);   
   lots = (int)(lots/SymbolInfoDouble(Symbol(),SYMBOL_VOLUME_STEP)) * SymbolInfoDouble(_Symbol,SYMBOL_VOLUME_STEP);
   lots = MathMax(lots,SymbolInfoDouble(Symbol(),SYMBOL_VOLUME_MIN));
   lots = MathMin(lots,SymbolInfoDouble(Symbol(),SYMBOL_VOLUME_MAX));
   double max_volume= SymbolInfoDouble (_Symbol, SYMBOL_VOLUME_LIMIT );
   double current_lots=getAllVolume();
   if (max_volume> 0 && max_volume-current_lots-lots<= 0 ){
      Print(__FUNCTION__,"Exceeded maximum allowed volume, resizing lot ");
      lots = max_volume-current_lots;
   }
   current_lots=getAllVolume();
   if (max_volume> 0 && max_volume-current_lots-lots<= 0 ){
      Print(__FUNCTION__,"Exceeded maximum allowed volume, resizing lot ");
      return;
   }   
   double margin;
   if(OrderCalcMargin(ORDER_TYPE_BUY,_Symbol,lots,entry,margin) && margin > AccountInfoDouble(ACCOUNT_MARGIN_FREE)){ 
      Print(__FUNCTION__ ," Insuficient funds to open the trade. Check margin requirements.");
      return;
   }
   trade.BuyStop(lots,entry,_Symbol,sl,tp,0,0,Ordercomment);

   buypos = trade.ResultOrder();
}

void executeSell(double entry){
   entry = NormalizeDouble(entry,_Digits);
//---
   double bid = SymbolInfoDouble(_Symbol,SYMBOL_BID);
   double ask = SymbolInfoDouble(_Symbol,SYMBOL_ASK);
   int stoplevel = (int) SymbolInfoInteger(_Symbol,SYMBOL_TRADE_STOPS_LEVEL);
   int spread = (int)SymbolInfoInteger(_Symbol,SYMBOL_SPREAD);   
   if(bid-entry < (stoplevel + spread) * _Point) return;
//--- 
   double sl = entry + SlPoints * _Point;
   sl = NormalizeDouble(sl,_Digits);
   double slpoints = sl-entry;
   slpoints = NormalizeDouble(slpoints,_Digits);
   double tp = entry - slpoints * risktoreward;
   tp = NormalizeDouble(tp, _Digits);
   if(sl > 0 && entry - sl < (stoplevel + spread) * _Point) {
      sl = sl + (stoplevel + spread)*_Point;
      tp = entry - (sl-entry) * risktoreward ;
   }
   if(tp > 0 && tp - entry < (stoplevel + spread) * _Point) tp = entry - (sl-entry) * risktoreward ;

//---
   lots = Lots;
   if(riskpercentage > 0) lots = calclots(riskpercentage, sl-entry);
   
   lots = (int)(lots/SymbolInfoDouble(Symbol(),SYMBOL_VOLUME_STEP)) * SymbolInfoDouble(_Symbol,SYMBOL_VOLUME_STEP);
   lots = MathMax(lots,SymbolInfoDouble(Symbol(),SYMBOL_VOLUME_MIN));
   lots = MathMin(lots,SymbolInfoDouble(Symbol(),SYMBOL_VOLUME_MAX));
   double max_volume= SymbolInfoDouble (_Symbol, SYMBOL_VOLUME_LIMIT );
   double current_lots=getAllVolume();
   if (max_volume> 0 && max_volume-current_lots-lots<= 0 ){
      Print(__FUNCTION__,"Exceeded maximum allowed volume, resizing lot ");
      lots = max_volume-current_lots;
   }
   current_lots=getAllVolume();
   if (max_volume> 0 && max_volume-current_lots-lots<= 0 ){
      Print(__FUNCTION__,"Exceeded maximum allowed volume, resizing lot ");
      return;
   }

   
   double margin;
   if(OrderCalcMargin(ORDER_TYPE_SELL,_Symbol,lots,entry,margin) && margin > AccountInfoDouble(ACCOUNT_MARGIN_FREE)){
      Print(__FUNCTION__ ," Insuficient funds to open the trade. Check margin requirements.");
      return;
   }
   trade.SellStop(lots,entry,_Symbol,sl,tp,0,0,Ordercomment);
   sellpos = trade.ResultOrder();
}

void calculateranges(){
      // to be run every new day 
      //Trading 1
      string initialtime = (string)Trading1StartTime + ":" + (string)Range1minutesstarttime;
      string finaltime = (string)Trading1EndTime + ":" + (string)range1minutesendtime;
      Trading1Start = StringToTime(initialtime);
      Trading1End = StringToTime(finaltime);
      //---
      
         
}

void closeallpositions(){
   // close at specific time 
   for (int i = PositionsTotal()-1 ; i>=0 ; i--){
      position = PositionGetTicket(i);
      if(PositionSelectByTicket(position)){
         trade.PositionClose(position);
      }  
   }
   for (int i = OrdersTotal()-1 ; i>=0 ; i--){
      position = OrderGetTicket(i);
      if(OrderSelect(position)){
         trade.OrderDelete(position);
      }  
   }
}

void closeonlyorders(){
   for (int i = OrdersTotal()-1 ; i>=0 ; i--){
      position = OrderGetTicket(i);
      if(OrderSelect(position)){
         trade.OrderDelete(position);
      }  
   }
}


//---

void processpos(ulong &posTicket)
  {
   if(posTicket <= 0)
      return;
   if(OrderSelect(posTicket))
      return;
   CPositionInfo pos;
   if(!pos.SelectByTicket(posTicket))
     {
      posTicket = 0;
      return;
     }
   else
     {
      if(pos.PositionType() == POSITION_TYPE_BUY)
        {
         double bid = SymbolInfoDouble(_Symbol,SYMBOL_BID);
         if(bid > pos.PriceOpen()+tsltriggerpoints * _Point)
           {
            double sl= bid - tslpoints * _Point;
            sl = NormalizeDouble(sl,_Digits);
            //---
            int stoplevel = (int) SymbolInfoInteger(_Symbol,SYMBOL_TRADE_STOPS_LEVEL);
            int spread = (int)SymbolInfoInteger(_Symbol,SYMBOL_SPREAD);            
            if(sl > 0 && bid - sl < (stoplevel + spread) * _Point){
               sl = sl/*bid*/ - (stoplevel + spread);
            }
            //---
                        
            if(sl > pos.StopLoss())
              {
               trade.PositionModify(pos.Ticket(),sl,pos.TakeProfit());
              }
           }
        }
      else
         if(pos.PositionType() == POSITION_TYPE_SELL)
           {
            double ask = SymbolInfoDouble(_Symbol,SYMBOL_ASK);
            if(ask < pos.PriceOpen() - tsltriggerpoints * _Point)
              {
               double sl= ask + tslpoints * _Point;
               sl = NormalizeDouble(sl,_Digits);
               //---
               int stoplevel = (int) SymbolInfoInteger(_Symbol,SYMBOL_TRADE_STOPS_LEVEL);
               int spread = (int)SymbolInfoInteger(_Symbol,SYMBOL_SPREAD);            
               if(sl > 0 && sl - ask  < (stoplevel + spread) * _Point){
                  sl = /*ask*/sl + (stoplevel + spread);
               }
               //---
              
               if(sl < pos.StopLoss() || pos.StopLoss() == 0)
                 {
                  trade.PositionModify(pos.Ticket(),sl,pos.TakeProfit());
                 }
              }
           }
     }
  }
  

//---


int gethammersignal (double maxratioshortshadow , double minratiolongshadow){
   datetime time = iTime(_Symbol,timeframe,1);   
   double high = iHigh(_Symbol,timeframe,1);
   double low = iLow(_Symbol,timeframe,1);
   double open  = iOpen(_Symbol,timeframe,1);
   double close = iClose(_Symbol,timeframe,1);   
   double candlesize = high - low ;
   
   //green hammer buy formation
   if(open < close){
      if(high - close <candlesize * maxratioshortshadow){
         if(open - low > candlesize * minratiolongshadow){
            return 1;          
         }      
      }   
   }      
   //red hammer sell formation
   if(close < open){
      if(close - low < candlesize * maxratioshortshadow){
         if(high - open > candlesize * minratiolongshadow){
            return 1;          
         }      
      }   
   }   
   return 0; 
}

void checkingpos(ulong &posTicket){
   if(posTicket <= 0)
      return;
   if(OrderSelect(posTicket))
      return;
   CPositionInfo pos;
   if(!pos.SelectByTicket(posTicket)){
      posTicket = 0;
      return;
   }
}


void Breakeven (){
   for(int i = PositionsTotal()-1; i>=0 ; i--){
      ulong posticket = PositionGetTicket(i);      
      if(PositionSelectByTicket(posticket)){
         if(PositionGetString(POSITION_SYMBOL)== _Symbol){            
            double posopenprice = PositionGetDouble(POSITION_PRICE_OPEN); 
            double posSL = PositionGetDouble(POSITION_SL);
            double posTP = PositionGetDouble(POSITION_TP);           
            double bid = SymbolInfoDouble(_Symbol,SYMBOL_BID);
            double ask= SymbolInfoDouble(_Symbol,SYMBOL_ASK);
            
            if(PositionGetInteger(POSITION_TYPE) == POSITION_TYPE_BUY){
               if(bid > posopenprice+(BElevel*_Point) && posSL < posopenprice ){
                  double sl = posopenprice + beadditionalpoints*_Point; 
                  if(trade.PositionModify(posticket,sl,posTP)){
                     Print(__FUNCTION__, " Pos # ", posticket," Was put in BE");                                            
                  }                  
               }                           
            } else if (PositionGetInteger(POSITION_TYPE)==POSITION_TYPE_SELL){            
               if(ask < (posopenprice-(BElevel*_Point)) && posSL > posopenprice){
                  double sl = posopenprice-beadditionalpoints*_Point;
                  if(trade.PositionModify(posticket,sl,posTP)){
                     Print(__FUNCTION__, " Pos # ", posticket," Was put in BE");                                            
                  }                  
               }             
            }        
         }
      }  
   }
}


double getAllVolume()
     {
       int itotal= PositionsTotal ();
       ulong uticket=- 1 ;
       double dVolume= 0 ;

       for ( int i=itotal- 1 ;i>= 0 ;i--)
        {
         if (!(uticket= PositionGetTicket (i))) continue ;
         if ( PositionGetString ( POSITION_SYMBOL )==_Symbol)
            dVolume+= PositionGetDouble ( POSITION_VOLUME );
        }

      itotal= OrdersTotal ();

       for ( int i=itotal- 1 ;i>= 0 ;i--)
        {
         if (!(uticket= OrderGetTicket (i))) continue ;
         if ( OrderGetString ( ORDER_SYMBOL )==_Symbol)
            dVolume+= OrderGetDouble ( ORDER_VOLUME_CURRENT );
        }
       return dVolume;
     }