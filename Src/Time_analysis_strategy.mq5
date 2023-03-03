//+------------------------------------------------------------------+
//|                                                      ProjectName |
//|                                      Copyright 2020, CompanyName |
//|                                       http://www.companyname.net |
//+------------------------------------------------------------------+

#property copyright "Copyright 2023, MetaQuotes Ltd."
#property version   "1.00"
#property strict


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

input group "RANGE 1"
input int Range1StartTime = 8;   // Range Start time
input int Range1EndTime = 10;  // Range End time
input bool testingrangevalidity = true; 
input ENUM_TIMEFRAMES rangetesting = PERIOD_CURRENT;
input group "TRADING TIME 1"
input int Trading1StartTime = 10;   //Trading start time
input int Trading1EndTime= 18;  // Trading end time

input group "Trade management"
input double Lots = 0.1; //Fixed Lot
input double riskpercentage =1.0; // Percentage risk
input int SlPoints = 30; // Stop Loss points
input double risktoreward = 3.0; //Risk to Reward
input int Magic = 234; // Add the magic number
input string Ordercomment = "Plutus"; // Order Comment

input group "AGGRESIVE TRAILING STOP";
input bool tslturnedon = true; 
input int tslpoints =10; // Trailing Stop Loss Points
input int tsltriggerpoints = 20; // Trailing Stop Trigger
input bool BEenabled = true; 
input double BElevel = 20;   
input int beadditionalpoints = 5; 
ulong buypos, sellpos;


// Converted time data
datetime Range1Start, Range1End;
datetime Trading1Start,Trading1End;


// Data of Asia range
double HighRange1=0;
double LowRange1 =0;
bool ValidRange1;

bool Range1Calculated = false;

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int OnInit()
  {

   if(Trading1StartTime>Trading1EndTime)
     {
      printf("The Start time needs to be earlier than the end time.");
      return INIT_PARAMETERS_INCORRECT;
     }
   if(Trading1StartTime<Range1EndTime)
     {
      printf("The Range time needs to end earlier than the trading start time.");
      return INIT_PARAMETERS_INCORRECT;
     }
   if(riskpercentage == 0 && Lots >= SymbolInfoDouble(_Symbol,SYMBOL_VOLUME_MAX)) return INIT_PARAMETERS_INCORRECT;

   trade.SetExpertMagicNumber(Magic);
   if(!trade.SetTypeFillingBySymbol(_Symbol))
     {
      trade.SetTypeFilling(ORDER_FILLING_RETURN);
     }

   for(int i = PositionsTotal()-1; i >= 0; i--)
     {
      CPositionInfo pos;
      if(pos.SelectByIndex(i))
        {
         if(pos.Magic() != Magic)
            continue;
         if(pos.Symbol() != _Symbol)
            continue;
         if(pos.PositionType() == POSITION_TYPE_BUY)
            buypos = pos.Ticket();
         if(pos.PositionType() == POSITION_TYPE_SELL)
            sellpos = pos.Ticket();
        }
     }

   for(int i = OrdersTotal()-1; i >= 0; i--)
     {
      COrderInfo order;
      if(order.SelectByIndex(i))
        {
         if(order.Magic() != Magic)
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


void OnDeinit(const int reason)
  {

  }

void OnTick()
  {
   if(tslturnedon){
      processpos(buypos);
      processpos(sellpos);  
   }
   if(BEenabled){
      Breakeven();
      checkingpos(buypos);
      checkingpos(sellpos);
   }

   dailybars = iBars(_Symbol,PERIOD_D1);
   if(dailybars != dailybars1)
     {
      dailybars1 = dailybars;
      Range1Calculated = false;
      ObjectDelete(0,"Range 1");
      calculateranges();
     }

   if(TimeCurrent() == Trading1Start && !Range1Calculated)
     {
      calculaterange1();
      Range1Calculated = true;
     }

   if(TimeCurrent() == Trading1End)
     {
      closeallpositions();
     }

//   double currentequity = AccountInfoDouble(ACCOUNT_EQUITY) ;
//   if( PositionsTotal() == 0 ){
//      dailyprofit =AccountInfoDouble(ACCOUNT_BALANCE)-initialdaybalance; /*((currentequity-initialdaybalance)/initialdaybalance)*100;*/
//   }
//   // commenting zone
//   Comment(StringFormat("Show daily results\ninitial Balance = %G\nCurrent equity = %G\nprofit percentage = %d",initialdaybalance,currentequity,dailyprofit));
//
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double calclots(double riskpercent, double slpoints)
  {
   double ticksize = SymbolInfoDouble(_Symbol,SYMBOL_TRADE_TICK_SIZE);
   double tickvalue = SymbolInfoDouble(_Symbol,SYMBOL_TRADE_TICK_VALUE);
   double lotstep = SymbolInfoDouble(_Symbol,SYMBOL_VOLUME_STEP);
   if(ticksize == 0 || tickvalue == 0 || lotstep == 0)
     {
      return 0;
     }
   double riskmoney = AccountInfoDouble(ACCOUNT_BALANCE) * riskpercent / 100;
   double moneylotstep = (slpoints / ticksize) * tickvalue * lotstep;
   if(moneylotstep == 0)
     {
      return 0;
     }
   lots = MathFloor(riskmoney / moneylotstep) * lotstep;
   return lots;
   
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void calculaterange1()
  {
   int starting = iBarShift(_Symbol,PERIOD_CURRENT,Range1Start);
   int ending = iBarShift(_Symbol,PERIOD_CURRENT,Range1End);
   int length = (starting - ending) + 1;
   int HighestRange1 = iHighest(_Symbol,PERIOD_CURRENT,MODE_HIGH,length,ending);
   int LowestRange1  = iLowest(_Symbol,PERIOD_CURRENT,MODE_LOW,length,ending);
   HighRange1 = iHigh(_Symbol,PERIOD_CURRENT,HighestRange1);
   LowRange1 = iLow(_Symbol,PERIOD_CURRENT,LowestRange1);
   double testhigh,testlow;
   if(testingrangevalidity){
      testhigh = iHigh(_Symbol,rangetesting,1);
      testlow = iLow(_Symbol,rangetesting,1);
   } else {
      testhigh = SymbolInfoDouble(_Symbol,SYMBOL_ASK);
      testlow = SymbolInfoDouble(_Symbol,SYMBOL_BID);
   }
   if(testhigh < HighRange1 && testlow > LowRange1)
     {
      Print("The range is valid ");
      ValidRange1 = true;
      ObjectDelete(0,"Range 1");
      ObjectCreate(0,"Range 1",OBJ_RECTANGLE,0,Range1Start,HighRange1,Range1End,LowRange1);
      ObjectSetInteger(0,"Range 1",OBJPROP_COLOR,clrPowderBlue);
      ObjectSetInteger(0,"Range 1",OBJPROP_FILL,true);
      executeBuy(HighRange1);
      executeSell(LowRange1);
     }
   else
     {
      ValidRange1 = false;
      Print("The range is invalid");
     }
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

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void executeBuy(double entry)
  {
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
//---
   double slpoints = entry - sl;
   slpoints = NormalizeDouble(slpoints,_Digits);
   double tp = entry + slpoints * risktoreward;
   tp = NormalizeDouble(tp, _Digits);
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
   
   double margin;
   if(OrderCalcMargin(ORDER_TYPE_BUY,_Symbol,lots,entry,margin) && margin > AccountInfoDouble(ACCOUNT_MARGIN_FREE)){ 
      Print(__FUNCTION__ ," Insuficient funds to open the trade. Check margin requirements.");
      return;
   }
   trade.BuyStop(lots,entry,_Symbol,sl,tp,0,0,Ordercomment);

   buypos = trade.ResultOrder();
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void executeSell(double entry)
  {
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
//---
   double slpoints = sl-entry;
   slpoints = NormalizeDouble(slpoints,_Digits);
   double tp = entry - slpoints * risktoreward;
   tp = NormalizeDouble(tp, _Digits);
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
   
   double margin;
   if(OrderCalcMargin(ORDER_TYPE_SELL,_Symbol,lots,entry,margin) && margin > AccountInfoDouble(ACCOUNT_MARGIN_FREE)){
      Print(__FUNCTION__ ," Insuficient funds to open the trade. Check margin requirements.");
      return;
   }
   trade.SellStop(lots,entry,_Symbol,sl,tp,0,0,Ordercomment);
   sellpos = trade.ResultOrder();
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void calculateranges()
  {
// to be run every new day
// Range 1
   string initialtime = (string)Range1StartTime+ ":00";
   string finaltime = (string)Range1EndTime + ":00";
   Range1Start = StringToTime(initialtime);
   Range1End = StringToTime(finaltime);
//Trading 1
   initialtime = (string)Trading1StartTime+ ":00";
   finaltime = (string)Trading1EndTime + ":00";
   Trading1Start = StringToTime(initialtime);
   Trading1End = StringToTime(finaltime);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void closeallpositions()
  {
// close at specific time
   for(int i = PositionsTotal()-1 ; i>=0 ; i--)
     {
      position = PositionGetTicket(i);
      if(PositionSelectByTicket(position))
        {
         trade.PositionClose(position);
        }
     }
   for(int i = OrdersTotal()-1 ; i>=0 ; i--)
     {
      position = OrderGetTicket(i);
      if(OrderSelect(position))
        {
         trade.OrderDelete(position);
        }
     }
  }

//AGGRESIVE TRADING MODE
void processpos(ulong &posTicket)
  {
// add in the place where you take trades the next line
// buypos = trade.resultorder();
// or sellpos = trade.resultorder();
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
               sl = bid - (stoplevel + spread);
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
                  sl = sl + (stoplevel + spread);
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



  
//+------------------------------------------------------------------+

// to correct lots size 
// lots = (int)(lots/SymbolInfoDouble(_Symbol,SYMBOL_VOLUME_STEP)) * SymbolInfoDouble(_Symbol,SYMBOL_VOLUME_STEP);
//lots = MathMax(lots,SymbolInfoDouble(_Symbol,SYMBOL_VOLUME_MIN));
//lots = MathMin(lots,SymbolInfoDouble(_Symbol,SYMBOL_VOLUME_MAX));
//---
// Valid prices Buy entry 
//double bid = SymbolInfoDouble(_Symbol,SYMBOL_BID);
//double ask = SymbolInfoDouble(_Symbol,SYMBOL_ASK);
//int stoplevel = (int) SymbolInfoInteger(_Symbol,SYMBOL_TRADE_STOPS_LEVEL);
//int spread = (int)SymbolInfoInteger(_Symbol,SYMBOL_SPREAD);
//if(entry - ask < (stoplevel + spread) * _Point) return; 
//if(sl > 0 && entry - sk < (stoplevel + spread) * _Point) return;
//if(tp > 0 && tp - entry < (stoplevel + spread) * _Point) return;
//--- 
// Valid prices Sell entry 
//double bid = SymbolInfoDouble(_Symbol,SYMBOL_BID);
//double ask = SymbolInfoDouble(_Symbol,SYMBOL_ASK);
//int stoplevel = (int) SymbolInfoInteger(_Symbol,SYMBOL_TRADE_STOPS_LEVEL);
//int spread = (int)SymbolInfoInteger(_Symbol,SYMBOL_SPREAD);
//
//if(bid - entry < (stoplevel + spread) * _Point) return; 
//if(sl > 0 && entry - sk < (stoplevel + spread) * _Point) return;
//if(tp > 0 && tp - entry < (stoplevel + spread) * _Point) return;
//---
