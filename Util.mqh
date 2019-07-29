//+------------------------------------------------------------------+
//|                                                         Util.mqh |
//|                        Copyright 2019, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2019, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property strict
//+------------------------------------------------------------------+
//| defines                                                          |
//+------------------------------------------------------------------+
// #define MacrosHello   "Hello, world!"
// #define MacrosYear    2010
//+------------------------------------------------------------------+
//| DLL imports                                                      |
//+------------------------------------------------------------------+
// #import "user32.dll"
//   int      SendMessageA(int hWnd,int Msg,int wParam,int lParam);
// #import "my_expert.dll"
//   int      ExpertRecalculate(int wParam,int lParam);
// #import
//+------------------------------------------------------------------+
//| EX5 imports                                                      |
//+------------------------------------------------------------------+
// #import "stdlib.ex5"
//   string ErrorDescription(int error_code);
// #import
//+------------------------------------------------------------------+

struct Order {
   string symbol;
   int ticket;
   int order_type;
   double open_price;
   double sl;
   double tp;
   string comment;
   int magic_number;
   double commission;
   double swap;
   double profit; 
   int order_mode;
   double price;
   double lots;
}; 

enum ORDER_FIND_TYPE{
   FIND_ALL = 0,
   FIND_BY_COMMENT = 1,
   FIND_BY_MAGIC = 2,
   FIND_BY_SYMBOL = 3
};

enum ANGLE_PRICE_TYPE{
   ANGLE_PRICE_CLOSE = 0,
   ANGLE_BOLINGER_UPPER = 1,
   ANGLE_BOLINGER_LOWER = 2
};

int Price(double _value,string _symbol = "")
{ 
   int result = 0;
   _symbol = (_symbol == "") ? Symbol() : _symbol;  
   string _value_str = DoubleToStr(_value,(int)MarketInfo(_symbol,MODE_DIGITS));
   StringReplace(_value_str,".",""); 
   return (int)_value_str; 
}
 
int OpenOrder(string _symbol, int cmd, double lot,string comment = "",int magicNumber = 0)
{ 
    double price = 0;
    if (cmd == OP_BUY) price = MarketInfo(_symbol, MODE_ASK); else price = MarketInfo(_symbol, MODE_BID);
    int iSuccess = -1;
    int count = 0;

    while (iSuccess < 0)
    {  
        iSuccess = OrderSend(_symbol, cmd, lot, price, 10, 0.0, 0.0, comment, magicNumber, 0, clrGreen);  
        if (iSuccess > -1)
        {
            return iSuccess;
        }

        if (count == 5)
        {
            return 0;
        }
        count++;
    }
    int fnError = GetLastError();
    if(fnError > 0){
      Print("Error function OpenOrder: ",fnError);
      ResetLastError();
    }
    return 0;
}
 
int OpenOrderWithSLTP(string _symbol, int cmd, double lot,double tp,double sl,string comment = "",int magicNumber = 0)
{  
    double price = 0;
    if (cmd == OP_BUY) price = MarketInfo(_symbol, MODE_ASK); else price = MarketInfo(_symbol, MODE_BID);
    int iSuccess = -1;
    int count = 0; 
    double _symbol_Point = MarketInfo(_symbol,MODE_POINT);
    int _symbol_Digits = ((int)MarketInfo(_symbol,MODE_DIGITS));
    double Arr_SLTP[]; 
    while (iSuccess < 0)
    {  
        iSuccess = OrderSend(_symbol, cmd, lot, price, 5, sl, tp, comment, magicNumber, 0, clrGreen);  
        if (iSuccess > -1)
        {
            return iSuccess;
        }

        if (count == 5)
        {
            return 0;
        }
        count++;
    }
    int fnError = GetLastError();
    if(fnError > 0){
      Print("Error function OpenOrder: ",fnError);
      ResetLastError();
    }
    return 0;
}


bool CloseOrder(int ticket)
{
        bool iSuccess = false;
    if (OrderSelect(ticket, SELECT_BY_TICKET))
    {
        int mode = 0;
        if (OrderType() == OP_SELL)
        {
            mode = MODE_ASK;
        }
        else
        {
            mode = MODE_BID;
        }
        ;
        int i = 0;
        while (!iSuccess)
        {
           // if(i == 6){
           //    iSuccess = true;
           // }
            
            iSuccess = OrderClose(OrderTicket(), OrderLots(), MarketInfo(OrderSymbol(), mode), 10, clrRed);
            i++;
        } 
        Sleep(300);
    }
    int fnError = GetLastError();
    if(fnError > 0){
      Print("Error function closeOrder: ",fnError," Ticket: ",ticket);
      ResetLastError();
    }
    return iSuccess;
}


void CloseOrders(ORDER_FIND_TYPE find_by = 0,string _value = "")
{ 
   for (int i = 0; i < OrdersTotal(); i++)
   { 
       if (OrderSelect(i, SELECT_BY_POS) == true)
       {   
           bool isCuccess = false;
           int mode = 0;
           if (OrderType() == OP_SELL)
           {
               mode = MODE_ASK;
           }
           else
           {
               mode = MODE_BID;
           }
           
          if(find_by == FIND_ALL && (OrderType() == OP_BUY || OrderType() == OP_SELL)){
            isCuccess = OrderClose(OrderTicket(), OrderLots(), MarketInfo(OrderSymbol(), mode), 10);
          } 
          
          if(find_by == FIND_BY_COMMENT && (OrderType() == OP_BUY || OrderType() == OP_SELL)){
            if(OrderComment() == _value){  
               isCuccess = OrderClose(OrderTicket(), OrderLots(), MarketInfo(OrderSymbol(), mode), 10);
            }
          } 
          
          if(find_by == FIND_BY_MAGIC && (OrderType() == OP_BUY || OrderType() == OP_SELL)){
            if(IntegerToString(OrderMagicNumber()) == _value){  
               isCuccess = OrderClose(OrderTicket(), OrderLots(), MarketInfo(OrderSymbol(), mode), 10);
            }
          } 
          
          if(find_by == FIND_BY_SYMBOL && (OrderType() == OP_BUY || OrderType() == OP_SELL)){
            if(OrderSymbol() == _value){    
               isCuccess = OrderClose(OrderTicket(), OrderLots(), MarketInfo(OrderSymbol(), mode), 10);
            }
          }  
       }
   }    
}


int TotalOrders(ORDER_FIND_TYPE find_by = 0,string _value = ""){
   int result = 0;
   for (int i = 0; i < OrdersTotal(); i++)
   { 
       if (OrderSelect(i, SELECT_BY_POS) == true)
       {   
          if(find_by == FIND_ALL){
             if(OrderType() == OP_BUY){ 
               result++;
             }
             if(OrderType() == OP_SELL){ 
               result++;
             } 
          } 
          
          if(find_by == FIND_BY_COMMENT){
            if(OrderComment() == _value){ 
                if(OrderType() == OP_BUY){ 
                  result++;
                }
                if(OrderType() == OP_SELL){ 
                  result++;
                } 
            }
          } 
          
          if(find_by == FIND_BY_MAGIC){
            if(IntegerToString(OrderMagicNumber()) == _value){ 
                if(OrderType() == OP_BUY){ 
                  result++;
                }
                if(OrderType() == OP_SELL){ 
                  result++;
                } 
            }
          } 
          
          if(find_by == FIND_BY_SYMBOL){
            if(OrderSymbol() == _value){ 
                if(OrderType() == OP_BUY){ 
                  result++;
                }
                if(OrderType() == OP_SELL){ 
                  result++;
                } 
            }
          }  
       }
   }    
   return result;
}


double TotalProfitOrders(ORDER_FIND_TYPE find_by = 0,string _value = ""){
   double result = 0;
   for (int i = 0; i < OrdersTotal(); i++)
   { 
       if (OrderSelect(i, SELECT_BY_POS) == true)
       {   
          if(find_by == FIND_ALL){
             if(OrderType() == OP_BUY){ 
               result += NormalizeDouble(OrderProfit() + OrderSwap() + OrderCommission(),2); 
             }
             if(OrderType() == OP_SELL){ 
               result += NormalizeDouble(OrderProfit() + OrderSwap() + OrderCommission(),2); 
             } 
          } 
          
          if(find_by == FIND_BY_COMMENT){
            if(OrderComment() == _value){ 
                if(OrderType() == OP_BUY){ 
                  result += NormalizeDouble(OrderProfit() + OrderSwap() + OrderCommission(),2); 
                }
                if(OrderType() == OP_SELL){ 
                  result += NormalizeDouble(OrderProfit() + OrderSwap() + OrderCommission(),2); 
                } 
            }
          } 
          
          if(find_by == FIND_BY_MAGIC){
            if(IntegerToString(OrderMagicNumber()) == _value){ 
                if(OrderType() == OP_BUY){ 
                  result += NormalizeDouble(OrderProfit() + OrderSwap() + OrderCommission(),2); 
                }
                if(OrderType() == OP_SELL){ 
                  result += NormalizeDouble(OrderProfit() + OrderSwap() + OrderCommission(),2); 
                } 
            }
          } 
          
          if(find_by == FIND_BY_SYMBOL){
            if(OrderSymbol() == _value){ 
                if(OrderType() == OP_BUY){ 
                  result += NormalizeDouble(OrderProfit() + OrderSwap() + OrderCommission(),2); 
                }
                if(OrderType() == OP_SELL){ 
                  result += NormalizeDouble(OrderProfit() + OrderSwap() + OrderCommission(),2); 
                } 
            }
          }  
       }
   }    
   return result;
}

int Space(double _value1,double _value2,string _symbol = ""){
   int result = 0;
   result = MathAbs(Price(_value1,_symbol)-Price(_value2,_symbol));
   return result;
}


int Space(int _value1,int _value2){
   int result = 0;
   result = MathAbs(_value1 - _value2);
   return result;
}

 
void Split(string text,string split,string & results[]){
   StringSplit(text,StringGetCharacter(split,0),results); 
}

int OpenPrice(int ticket){
  int result = 0;
  if(OrderSelect(ticket, SELECT_BY_TICKET))
  {  
      result = Price(OrderOpenPrice(),OrderSymbol()); 
  }
  return result;
}


int SLPrice(int ticket){
  int result = 0;
  if(OrderSelect(ticket, SELECT_BY_TICKET))
  {   
      result = Price(OrderStopLoss(),OrderSymbol()); 
  }
  return result;
}
 
int TPPrice(int ticket){
  int result = 0;
  if(OrderSelect(ticket, SELECT_BY_TICKET))
  {  
      result = Price(OrderTakeProfit(),OrderSymbol()); 
  }
  return result;
}

/*

int OrderPrifitPrice(int ticket){
  int result = 0;
  if(OrderSelect(ticket, SELECT_BY_TICKET))
  {  
      result = Price(OrderProfit(),OrderSymbol()) + Price(OrderSwap(),OrderSymbol()) + Price(OrderCommission(),OrderSymbol()); 
  }
  return result;
}

*/
double OrderPrifitPrice(int ticket){
  double result = 0;
  if(OrderSelect(ticket, SELECT_BY_TICKET))
  {  
      result = NormalizeDouble(OrderProfit() + OrderSwap() + OrderCommission(),2); 
  }
  return result;
}
  
bool IsNewBar(int period)
{  

   static datetime lastbar;
   datetime curbar = (datetime)SeriesInfoInteger(Symbol(),period,SERIES_LASTBAR_DATE);
   if(lastbar != curbar)
   {
      lastbar = curbar;
      return true;
   }
   return false;
}    
    
double Angle(string _symbol,int shift = 1,int length = 1,int period = PERIOD_CURRENT, ANGLE_PRICE_TYPE angle_price_type = ANGLE_PRICE_CLOSE){
   double result = -999;
   if(shift == 0) return result;
   
   datetime from_date = iTime(_symbol,period,shift);
   datetime to_date = iTime(_symbol,period,(shift-length));
   double from_price = 0;
   double to_price = 0;
   if(angle_price_type == ANGLE_PRICE_CLOSE){ 
        from_price = iClose(_symbol,period,shift); 
        to_price = iClose(_symbol,period,(shift-length));
   } 
   
   if(angle_price_type == ANGLE_BOLINGER_LOWER)
   { 
      from_price = iBands(_symbol,period,20,2,0,PRICE_CLOSE,MODE_LOWER,shift);
      to_price = iBands(_symbol,period,20,2,0,PRICE_CLOSE,MODE_LOWER,(shift-length));
   }
   
   if(angle_price_type == ANGLE_BOLINGER_UPPER){ 
      from_price = iBands(_symbol,period,20,2,0,PRICE_CLOSE,MODE_UPPER,shift);
      to_price = iBands(_symbol,period,20,2,0,PRICE_CLOSE,MODE_UPPER,(shift-length));
   }
   
   if(from_price > 0){
      int from_x = 0;
      int from_y = 0;
      int to_x = 0;
      int to_y = 0;
      if(ChartTimePriceToXY(0,0,from_date,from_price,from_x,from_y) 
      && ChartTimePriceToXY(0,0,to_date,to_price,to_x,to_y)){
         //Print("FROM : "+from_date+" / "+from_price+" / "+from_x+" / "+from_y+" - TO "+to_date+" / "+to_price+" / "+to_x+" / "+to_y);
         double deltaX = to_x - from_x;
         double deltaY = to_y - from_y;
         double slope = deltaY/deltaX;
         double angle = MathArctan(slope)*(360/(2*M_PI));
         if(angle > 0){  
            result = angle - (angle *(double)2);
         }
         if(angle < 0){ 
            result = MathAbs(angle);
         } 
      }   
   } 
   return NormalizeDouble(result,2);
}



double Util_DivideDigit(string _symbol){
   string multiple = "1";
   int digits =  (int)MarketInfo(_symbol,MODE_DIGITS);
   for(int i = 0;i<digits; i++){
      multiple += "0"; 
   }
   return StrToDouble(multiple);
}

void AddOrder(Order &arr_Ords[]){
   Order ord;
   ord.symbol = OrderSymbol();
   ord.ticket = OrderTicket();
   ord.order_type = OrderType();
   ord.sl = OrderStopLoss();
   ord.tp = OrderTakeProfit();
   ord.open_price = OrderOpenPrice(); 
   ord.comment = OrderComment();
   ord.magic_number = OrderMagicNumber();
   ord.lots = OrderLots(); 
    
   ord.commission = OrderCommission();
   ord.swap = OrderSwap();
   ord.profit = OrderProfit(); 
   if (OrderType() == OP_SELL)   
   {
       ord.order_mode = MODE_ASK; 
   }
   else
   {
       ord.order_mode = MODE_BID;
   }   
   ArrayResize(arr_Ords,ArraySize(arr_Ords)+1);
   arr_Ords[ArraySize(arr_Ords)-1] = ord;
}



void RebindOrders(Order &arr_Ords[],ORDER_FIND_TYPE find_by = 0,string _value = "")
{ 
   ArrayFree(arr_Ords);
   for (int i = 0; i < OrdersTotal(); i++)
   { 
       if (OrderSelect(i, SELECT_BY_POS) == true)
       {    
          if(find_by == FIND_ALL && (OrderType() == OP_BUY || OrderType() == OP_SELL)){
               AddOrder(arr_Ords);
          } 
          
          if(find_by == FIND_BY_COMMENT && (OrderType() == OP_BUY || OrderType() == OP_SELL)){
            if(OrderComment() == _value){   
               AddOrder(arr_Ords);
            }
          } 
          
          if(find_by == FIND_BY_MAGIC && (OrderType() == OP_BUY || OrderType() == OP_SELL)){
            if(IntegerToString(OrderMagicNumber()) == _value){  
               AddOrder(arr_Ords);
            }
          } 
          
          if(find_by == FIND_BY_SYMBOL && (OrderType() == OP_BUY || OrderType() == OP_SELL)){
            if(OrderSymbol() == _value){    
               AddOrder(arr_Ords);
            }
          }  
       }
   }    
}

double OrdersProfit(Order &arr_Ords[]){
   double total_profit = 0;
   for(int i = 0; i < ArraySize(arr_Ords);i++){
      total_profit += (double)arr_Ords[i].profit + (double)arr_Ords[i].commission + (double)arr_Ords[i].swap;
      //Print((double)arr_Ords[i].profit +" + "+ (double)arr_Ords[i].commission +" + "+ (double)arr_Ords[i].swap);
   }
   //Print("total_profit = "+total_profit);
   return total_profit;
}


double OrdersLots(Order &arr_Ords[]){
   double total_lots = 0;
   for(int i = 0; i < ArraySize(arr_Ords);i++){
      total_lots += (double)arr_Ords[i].lots;
      //Print((double)arr_Ords[i].profit +" + "+ (double)arr_Ords[i].commission +" + "+ (double)arr_Ords[i].swap);
   }
   //Print("total_profit = "+total_profit);
   return total_lots;
}