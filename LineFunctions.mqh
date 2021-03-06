//+------------------------------------------------------------------+
//|                                             generalfunctions.mqh |
//|                                Copyright 2020, twitter@fx_miyabi |
//|                                       https://www.miyabi-fx.info |
//+------------------------------------------------------------------+
#property copyright "Copyright 2020, twitter@fx_miyabi"
#property link      "https://www.miyabi-fx.info"

#include <mql5common\\PriceRateFunctions.mqh>
#include <mql5common\\MathFunctions.mqh>

struct LineInformation {
   string name;
   datetime time;
   double price;
   int direction;
   double slope;
};

//+------------------------------------------------------------------+
//| Trend Line
//+------------------------------------------------------------------+

//ラインの設定
void SetLineVisual(string name, int colorname, int width, bool leftray, bool rightray){
   ObjectSetInteger(0, name, OBJPROP_COLOR, colorname);
   ObjectSetInteger(0, name, OBJPROP_WIDTH, width);
   ObjectSetInteger(0, name, OBJPROP_RAY_LEFT, leftray);
   ObjectSetInteger(0, name, OBJPROP_RAY_RIGHT, rightray);
}

void CreateTrendLine(string name, datetime time1, double price1, double direction, double slope){
   //time1 price1は引数にある
   datetime time2;
   double price2;
   slope = direction*slope;

   time2 = iTime(_Symbol, _Period, 300 + Bars(_Symbol, _Period, time1, iTime(_Symbol, _Period, 0)));
   price2 = price1-slope*300;

   ObjectCreate(0, name, OBJ_TREND, 0, time2, price2, time1, price1);
   SetLineVisual(name, clrRed, 2, true, true);
}


void CreateTrendLine(string name, datetime time1, double price1, double slope){
   //time1 price1は引数にある
   datetime time2;
   double price2;

   time2 = iTime(_Symbol, _Period, 300 + Bars(_Symbol, _Period, time1, iTime(_Symbol, _Period, 0)));
   price2 = price1-slope*300;

   ObjectCreate(0, name, OBJ_TREND, 0, time2, price2, time1, price1);
   SetLineVisual(name, clrRed, 2, true, true);
}


void CreateTrendLine(string name, datetime time1, int direction, double slope){
   double price1 = 0;
   price1 = iCloseByTime(time1);

   //time1 price1は引数にある
   datetime time2;
   double price2;
   slope = direction*slope;

   time2 = iTime(_Symbol, _Period, 300 + Bars(_Symbol, _Period, time1, iTime(_Symbol, _Period, 0)));
   price2 = price1-slope*300;

   ObjectCreate(0, name, OBJ_TREND, 0, time2, price2, time1, price1);
   SetLineVisual(name, clrRed, 2, true, true);
}

void CreateTrendLine(string name, datetime time1, double price1, double slope, color linecolor, int linewidth, bool leftray, bool rightray){
   //time1 price1は引数にある
   datetime time2;
   double price2;

   time2 = iTime(_Symbol, _Period, 100 + Bars(_Symbol, _Period, time1, iTime(_Symbol, _Period, 0)));
   price2 = price1-slope*100;

   ObjectCreate(0, name, OBJ_TREND, 0, time2, price2, time1, price1);
   SetLineVisual(name, linecolor, linewidth, leftray, rightray);
}

void CreateTrendLine(string name, datetime time1, double slope){
   double price1 = 0;
   price1 = iCloseByTime(time1);

   //time1 price1は引数にある
   datetime time2;
   double price2;

   time2 = iTime(_Symbol, _Period, 300 + Bars(_Symbol, _Period, time1, iTime(_Symbol, _Period, 0)));
   price2 = price1-slope*300;

   ObjectCreate(0, name, OBJ_TREND, 0, time2, price2, time1, price1);
   SetLineVisual(name, clrRed, 2, true, true);
}



void CreateTrendLine(LineInformation& LineInfo){
   string name = LineInfo.name;
   datetime time1 = LineInfo.time;
   double price1 = LineInfo.price;
   datetime time2;
   double price2;
   double slope = LineInfo.direction*LineInfo.slope;

   time2 = iTime(_Symbol, _Period, 300 + Bars(_Symbol, _Period, time1, iTime(_Symbol, _Period, 0)));
   price2 = price1-slope*300;

   ObjectCreate(0, name, OBJ_TREND, 0, time2, price2, time1, price1);
   SetLineVisual(name, clrRed, 2, true, true);
}


double LineGetLinePrice(datetime linestarttime, double linestartprice, double slopevalue, datetime linetime){
   double retprice = 0;
   int diff_bars = 0;

   if(linestarttime < linetime){
      diff_bars = Bars(_Symbol,_Period,linestarttime,linetime);
      retprice = linestartprice + slopevalue*diff_bars;
   }
   
   if(linestarttime > linetime){
      diff_bars = Bars(_Symbol,_Period,linetime,linestarttime);
      retprice = linestartprice - slopevalue*diff_bars;
   }
   
   if(linestarttime == linetime) retprice = linestartprice;

   return retprice;
}

double LineGetLinePrice(datetime linestarttime, double linestartprice, double slopevalue, int shift){
   double retprice = 0;
   int diff_bars = 0;
   datetime linetime = iTime(_Symbol,_Period,0);

   if(linestarttime < linetime){
      diff_bars = Bars(_Symbol,_Period,linestarttime,linetime);
      retprice = linestartprice + slopevalue*diff_bars;
   }
   
   if(linestarttime > linetime){
      diff_bars = Bars(_Symbol,_Period,linetime,linestarttime);
      retprice = linestartprice - slopevalue*diff_bars;
   }
   
   if(linestarttime == linetime) retprice = linestartprice;

   return retprice;
}

//+------------------------------------------------------------------+
//| 回帰トレンド計算用
//| 使用する配列は時系列配列である必要がある
//+------------------------------------------------------------------+

void AddElementForLinearRegression(double& value[], int count, double& denominator, double& numerator){
   int i;
   //double x_sigma;
   double y_sigma=0;
   double x_avr=0;
   double y_avr=0;
   
   //x平均
   x_avr = count/2;
   
   //y平均
   for(i=0;i<count;i++){
      y_sigma += value[i];
   }
   y_avr = y_sigma/count;

   //分子
   for(i=0;i<count;i++){
      numerator += (i - x_avr)*(value[count-1-i] - y_avr);
   }
   //分母
   for(i=0;i<count;i++){
      denominator += MathPow(i - x_avr, 2);
   }

}

double CalculateLinearRegressionIntercept(double y_avr, int count, double coefficient){
   double ret = 0;

   ret = y_avr - coefficient*count/2;

   return ret;
}


// 線形回帰を用いた角度計算
void CalculateLinearRegressionSlope(double& array[], double& coefficient, double& intercept){
   int bars;
   double denominator = 0;
   double numerator = 0;

   //とりあえず回帰直線ベースでも求める
   bars = ArraySize(array);

   AddElementForLinearRegression(array, bars, denominator, numerator);

   coefficient = numerator/denominator;
   
   intercept = CalculateLinearRegressionIntercept(CalculateArrayAverage(array), bars, coefficient);

   return;
}


double CalculateLinearRegressionSlope(datetime starttime, datetime endtime){
   double ret;
   int bars;
   double open[], close[], high[], low[];
   double denominator = 0;
   double numerator = 0;

   ArraySetAsSeries(open, true);
   ArraySetAsSeries(high, true);
   ArraySetAsSeries(low, true);
   ArraySetAsSeries(close, true);

   //とりあえず回帰直線ベースでも求める
   bars = Bars(_Symbol, _Period, starttime, endtime);

   CopyClose(_Symbol, _Period, starttime, endtime, close);
   CopyOpen(_Symbol, _Period, starttime, endtime, open);
   CopyHigh(_Symbol, _Period, starttime, endtime, high);
   CopyLow(_Symbol, _Period, starttime, endtime, low);

   AddElementForLinearRegression(close, bars, denominator, numerator);
   AddElementForLinearRegression(open, bars, denominator, numerator);
   AddElementForLinearRegression(high, bars, denominator, numerator);
   AddElementForLinearRegression(low, bars, denominator, numerator);

   ret = numerator/denominator;

   return ret;
}

double CalculateLinearRegressionSlope(int count, int shift){
   double ret;
   int bars;
   double open[], close[], high[], low[];
   double denominator = 0;
   double numerator = 0;

   ArraySetAsSeries(open, true);
   ArraySetAsSeries(high, true);
   ArraySetAsSeries(low, true);
   ArraySetAsSeries(close, true);

   //とりあえず回帰直線ベースでも求める
   bars = count;

   CopyClose(_Symbol, _Period, shift, count, close);
   CopyOpen(_Symbol, _Period, shift, count, open);
   CopyHigh(_Symbol, _Period, shift, count, high);
   CopyLow(_Symbol, _Period, shift, count, low);

   AddElementForLinearRegression(close, bars, denominator, numerator);
   AddElementForLinearRegression(open, bars, denominator, numerator);
   AddElementForLinearRegression(high, bars, denominator, numerator);
   AddElementForLinearRegression(low, bars, denominator, numerator);

   ret = numerator/denominator;

   return ret;
}

/*
void CreateRegressionLine(datetime starttime, datetime endtime){
   double slope;
   
   slope = CalculateLinearRegressionSlope(starttime, endtime);

   Createtren


}
*/


/*
double GetLineCrossRate(double slope){
   int direction = CFWave.GetDirection();
   datetime starttime = CFWave.GetStarttime();
   datetime endtime = CFWave.GetEndtime();
   double startprice = CFWave.GetStartprice();
   double endprice = CFWave.GetEndprice();
   
   datetime highertime = CFWave.GetHighertime();
   datetime lowertime = CFWave.GetLowertime();
   double higherprice = CFWave.GetHigherprice();
   double lowerprice = CFWave.GetLowerprice();

   double ret=0;

   if(endprice == higherprice) ret = higherprice - CalculateChannelHeight(starttime, startprice, endtime, endprice , 1, slope)/2;
   if(endprice == lowerprice) ret = lowerprice + CalculateChannelHeight(starttime, startprice, endtime, endprice , -1, slope)/2;

   return ret;
}
*/

double GetLineCrossRate(datetime time1, double price1, int direction1, double slope1, 
                        datetime time2, double price2, int direction2, double slope2){
   double ret = 0;


   return ret;
}

int JudgeLocationToLine(datetime linetime, double lineprice, int linedirection, double lineslope, datetime locationtime, double locationprice){
   double locationlineprice = 0;
   int x = 0;

   if(linetime < locationtime){
      x = Bars(_Symbol, _Period, linetime, locationtime);
      locationlineprice = lineprice + linedirection*lineslope*x;
   }

   if(linetime == locationtime) locationlineprice = lineprice;

   if(linetime > locationtime){
      x = Bars(_Symbol, _Period, locationtime, linetime);
      locationlineprice = lineprice - linedirection*lineslope*x;
   }

   if(locationprice > locationlineprice) return 1;
   else return -1;
}

int JudgeLocationToLine(LineInformation& LineInfo, datetime locationtime, double locationprice){
   datetime linetime = LineInfo.time;
   double lineprice = LineInfo.price;
   int linedirection = LineInfo.direction;
   double lineslope = LineInfo.slope;

   double locationlineprice = 0;
   int x = 0;

   if(linetime < locationtime){
      x = Bars(_Symbol, _Period, linetime, locationtime);
      locationlineprice = lineprice + linedirection*lineslope*x;
   }

   if(linetime == locationtime) locationlineprice = lineprice;

   if(linetime > locationtime){
      x = Bars(_Symbol, _Period, locationtime, linetime);
      locationlineprice = lineprice - linedirection*lineslope*x;
   }

   if(locationprice > locationlineprice) return 1;
   else return -1;
}


// ラインが到達したかどうかの判断
// 引数に達成時間の参照あり
// TODO 窓あきの時の計算修正必要
bool CheckLineAchieve(datetime wavestarttime, double wavestartprice, double slopevalue, datetime calcstarttime, datetime& achievetime, double& achieveprice){
   int calcbars = Bars(_Symbol,_Period,calcstarttime, iTime(_Symbol,_Period,0));
   int wavestartbars = Bars(_Symbol,_Period,wavestarttime, iTime(_Symbol,_Period,0));

   datetime time[];
   double close[], high[], low[];
   ArraySetAsSeries(time, true);
   ArraySetAsSeries(close, true);
   ArraySetAsSeries(high, true);
   ArraySetAsSeries(low, true);
   CopyTime(_Symbol, _Period, 0, wavestartbars, time);
   CopyClose(_Symbol, _Period, 0, wavestartbars+1, close);   
   CopyHigh(_Symbol, _Period, 0, wavestartbars, high);   
   CopyLow(_Symbol, _Period, 0, wavestartbars, low);

   double lineprice;

   for(int i=calcbars-1;i>=0;i--){
      lineprice = wavestartprice + slopevalue*(wavestartbars - i);

      // 窓あき無し高安に収まってる場合
      if(lineprice <= high[i] && lineprice >= low[i]){
         achievetime = time[i];
         achieveprice = lineprice;
         return true;      
      }
      
      // 窓あきある場合
      if(close[i+1] < close[i]){
         if(lineprice <= close[i] && lineprice >= close[i+1]){
            achievetime = time[i];
            achieveprice = lineprice;
            return true;
         }
      }
      else {
         if(lineprice >= close[i] && lineprice <= close[i+1]){
            achievetime = time[i];
            achieveprice = lineprice;
            return true;
         }
      }
   }

   achievetime = 0;
   return false;
}


// 角度指定し最も交点が多いラインを求める
// 返し値は最も交点が多いラインのうち最も左側の時間
datetime SearchMostCrossedLineTime(datetime starttime, datetime endtime, double slope, int linedirection){
   slope = MathAbs(slope);

   double open[], high[], low[], close[];
   ArraySetAsSeries(open, true);
   ArraySetAsSeries(high, true);
   ArraySetAsSeries(low, true);
   ArraySetAsSeries(close, true);
   
   CopyOpen(_Symbol, _Period, starttime, endtime, open);
   CopyHigh(_Symbol, _Period, starttime, endtime, high);
   CopyLow(_Symbol,_Period,starttime,endtime,low);
   CopyClose(_Symbol,_Period,starttime,endtime,close);

   int bars = Bars(_Symbol,_Period,starttime,endtime);
   int barstoendtime = Bars(_Symbol,_Period,endtime,iTime(_Symbol,_Period,0));

   int tmpcrosscount = 0;
   int maxcrosscount = 0;
   double lineprice;

   datetime rettime = 0;

   for(int i=bars-1;i>0;i--){
   
      tmpcrosscount = 0;
   
      for(int j=bars-1;j>=0;j--){
         lineprice = close[i] + linedirection*slope*(i-j);
         
         if(lineprice >= low[j] && lineprice <= high[j]) tmpcrosscount++;
      }   
      
      if(tmpcrosscount > maxcrosscount){
         maxcrosscount = tmpcrosscount;
         rettime = iTime(_Symbol,_Period,i+barstoendtime);
      }
   
   }

   return rettime;
}



//+------------------------------------------------------------------+
//|　Horizontal Line
//+------------------------------------------------------------------+




//+------------------------------------------------------------------+
//|　Vertical Line
//+------------------------------------------------------------------+

void CreateVerticalLine(string tempname, datetime time, string text, color colorname){
   ObjectCreate(0, tempname, OBJ_VLINE, 0, time, 0);
   ObjectSetString(0, tempname, OBJPROP_TEXT, text);
   ObjectSetInteger(0, tempname, OBJPROP_COLOR, colorname);
   ObjectSetInteger(0, tempname, OBJPROP_WIDTH, 1);
}

//+------------------------------------------------------------------+
//| Channel
//+------------------------------------------------------------------+

//チャネルの高さ計算
double CalculateChannelHeight(datetime starttime, double startprice, datetime endtime, double endprice, int direction, double slope){
   double ret=0;
   double x, y;
   double height;

   x = Bars(_Symbol,_Period,starttime,endtime);
   y = endprice - startprice;
   height = MathAbs(y);

   //upward wave
   if(y>0){
      ret = height - direction*slope*x;
   }
   //downward wave
   if(y<0){
      ret = height + direction*slope*x;
   }

   return MathAbs(ret);
}

double CalculateChannelHeight(double x, double y, int direction, double slope){
   double ret=0;
   //double x, y;
   double height;

   //x = Bars(_Symbol,_Period,starttime,endtime);
   //y = endprice - startprice;
   height = MathAbs(y);

   //upward wave
   if(y>0){
      ret = height - direction*slope*x;
   }
   //downward wave
   if(y<0){
      ret = height + direction*slope*x;
   }

   return MathAbs(ret);
}

//+------------------------------------------------------------------+
//| 平面図形計算用
//+------------------------------------------------------------------+

//三角形の面積計算
//3つの座標バージョン
//一応順番は右から1,2,3
double CalculateAreaofTriangle(datetime time1, double price1, datetime time2, double price2, datetime time3, double price3){
   double s=0;
   /*datetime timearray[3]={0};
   double pricearray[3]={0};


   //time
   timearray[0] = time1;
   timearray[1] = time2;
   timearray[2] = time3;

   //時間で昇順にソート
   ArraySort(timearray);

   for(int i=0;i<3;i++){
      if(timearray[i]==time1)pricearray[0]=price1;
      if(timearray[i]==time2)pricearray[1]=price2;
      if(timearray[i]==time3)pricearray[2]=price3;
   }

   for(int i=0;i<3;i++){
      if(pricearray[i]==0){
         Print("Error Wrong Calculation Area of Triangle");
         return s;
      }
   }
   */

   s = MathAbs(Bars(_Symbol, _Period, time3, time1)*(price2 - price3) - Bars(_Symbol, _Period, time3, time2)*(price1 - price3))/2;

   return s;
}

void CalculateVector(datetime starttime, double startprice, datetime endtime, double endprice, double& retx, double& rety){
   retx = (int)Bars(_Symbol,_Period,starttime,endtime);
   rety = endprice - startprice;
}

//　点と距離計算
double CalculateLineDistance(double x, double y, double direction, double slope){
   double a,b,d;

   a = -1*slope*direction;
   b = 1;
   d = MathAbs(a*x+b*y)/sqrt(MathPow(a,2)+MathPow(b,2));

   return d;
}

double CalculateLineDistance(datetime starttime, double startprice, datetime endtime, double endprice, double direction, double slope){
   double a,b,d;
   double x = (int)Bars(_Symbol, _Period, starttime, endtime);
   double y = endprice - startprice;
   
   a = -1*slope*direction;
   b = 1;
   d = MathAbs(a*x+b*y)/sqrt(MathPow(a,2)+MathPow(b,2));
   
   return d;
}


//とりあえずdirectionは逆向きなのは必須
//取得したラインに対してstarttimeより前で交差してたらtrueを出すようにできるようにする
bool CheckLineCross(LineInformation& LineInfo1, LineInformation& LineInfo2){
   //LineInfoから取得
   datetime starttime1, starttime2;
   double startprice1, startprice2;
   //datetime pretime1, pretime2;
   //double preprice1, preprice2;
   int direction1, direction2;
   double slope1, slope2;

   //関数の仕様上、startが右でpreが左
   starttime1 = LineInfo1.time;
   starttime2 = LineInfo2.time;
   startprice1 = LineInfo1.price;
   startprice2 = LineInfo2.price;
   direction1 = LineInfo1.direction;
   direction2 = LineInfo2.direction;
   slope1 = LineInfo1.slope;
   slope2 = LineInfo2.slope;

   int bx;
   int cx1, cx2;
   double bprice1, bprice2;
   double cprice1, cprice2;

   //現状同じ向きのラインが入力されたらエラーを出す
   if(direction1 == direction2){
      Print("Check Line Cross Function: Error, Same Directions are inserted");
      return false;
   }

   //既に交差してる場合もあるのでその判定部分も後々作成
   

   //以下判定
   if(starttime1 == starttime2){
      bprice1 = startprice1;
      bprice2 = startprice2;
   }
   else if(starttime1 < starttime2){
      bx = Bars(_Symbol, _Period, starttime1, starttime2);

      bprice1 = startprice1;
      bprice2 = startprice2 - direction2*slope2*bx;
   }
   else {
      bx = Bars(_Symbol, _Period, starttime2, starttime1);

      bprice1 = startprice1 - direction1*slope1*bx;
      bprice2 = startprice2;
   }

   cx1 = Bars(_Symbol, _Period, starttime1, iTime(_Symbol,_Period,0));
   cx2 = Bars(_Symbol, _Period, starttime2, iTime(_Symbol,_Period,0));
   cprice1 = startprice1 + direction1*slope1*cx1;
   cprice2 = startprice2 + direction2*slope2*cx2;
   
   if((bprice1 > bprice2 && cprice1 <= cprice2)
      || (bprice1 > bprice2 && cprice1 <= cprice2) ) return true;
   
   return false;
}
