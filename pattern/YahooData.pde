class YahooData {
  String symbol;
  int lookback;
  int numQuotes;
  String dt[];
  float op[],hi[],lo[],cl[],vo[],avg[],normclose[],normavg[];
  float priceMin=MAX_FLOAT;
  float priceMax=MIN_FLOAT;
  float closeMin=MAX_FLOAT;
  float closeMax=MIN_FLOAT;
  float avgMin=MAX_FLOAT;
  float avgMax=MIN_FLOAT;
  float priceInterval;
  YahooData(String symbol,String startDate, String endDate,int lookback) {

    this.symbol = symbol;

    if( endDate=="today" || endDate=="" ) {
      endDate = DateUtil.getTodayStr();
    }

    // simple cache
    //String filename = endDate+"_"+symbol+".csv";
    String lines[]=null;
    //try {
    //  lines = loadStrings(filename);
    //} catch(Exception e) {
    //  lines = null;
    //}
    if( lines==null ) {
      String url = "http://ichart.finance.yahoo.com/table.csv?s="+
        symbol+
        "&a="+nf(int(startDate.substring(5,7))-1,2)+
        "&b="+startDate.substring(8,10)+
        "&c="+startDate.substring(0,4)+
        "&d="+nf(int(endDate.substring(5,7))-1,2)+
        "&e="+endDate.substring(8,10)+
        "&f="+endDate.substring(0,4)+
        "&g=d"+
        "&ignore=.csv";  
      lines = loadStrings(url);
      //if( lines != null )
        //saveStrings(filename,lines);
    }

    lines = reverse(lines);
    dt = new String[lines.length-1];
    op = new float[lines.length-1];
    hi = new float[lines.length-1];
    lo = new float[lines.length-1];
    cl = new float[lines.length-1];
    vo = new float[lines.length-1]; 
    avg = new float[lines.length-1]; 
    normclose = new float[lines.length-1]; 
    normavg = new float[lines.length-1]; 
    for( int i=0; i < lines.length-1; i++ ) {
      String p[] = split(lines[i],',');
      dt[i] = p[0];
      op[i] = float(p[1]);
      hi[i] = float(p[2]);
      lo[i] = float(p[3]);
      cl[i] = float(p[4]);
      vo[i] = int(p[5]);
      float adjclose = float(p[6]);
      if( cl[i] != adjclose ) {
        float factor = adjclose/cl[i];
        op[i] *= factor;
        hi[i] *= factor;
        lo[i] *= factor;
        cl[i] *= factor;
      }
      avg[i] = (hi[i]+lo[i]+cl[i])/3.0;
      if( lo[i]<priceMin && i>= lookback )
        priceMin = lo[i];

      if( cl[i]<closeMin && i>= lookback )
        closeMin = cl[i];

      if( avg[i]<avgMin && i>= lookback )
        avgMin = avg[i];

      if( hi[i]>priceMax && i>=lookback )
        priceMax = hi[i];

      if( cl[i]>closeMax && i>=lookback )
        closeMax = cl[i];

      if( avg[i]>avgMax && i>=lookback )
        avgMax = avg[i];
    }
    this.lookback = lookback;
    numQuotes = cl.length;
    priceInterval = getPriceInterval(priceMin,priceMax);
    
    for( int i=0; i<cl.length; i++ ) {
      normclose[i] = (cl[i]-closeMin)/(closeMax-closeMin);
      normavg[i] = (avg[i]-avgMin)/(avgMax-avgMin);
    }
    
  }

  float getPriceInterval(float pmin,float pmax) {
    int numValues=20;
    float range = pmax-pmin;
    if( range/0.10 < numValues ) return 0.10;
    if( range/0.25 < numValues ) return 0.25;
    if( range/0.50 < numValues ) return 0.50;
    if( range/1.00 < numValues ) return 1.00;
    if( range/2.50 < numValues ) return 2.50;
    if( range/5.00 < numValues ) return 5.00;
    if( range/10.0 < numValues ) return 10.0;
    return 25.0;
  }
}

