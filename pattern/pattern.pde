import controlP5.*;
ControlP5 controlP5;
static int margin=10;
static int headerHeight=20;
static int priceWidth=50;
static int dateHeight=25;
static int controlHeight=80;
static float aspectRatio=1.85;
static int width=900;
static int height=int((width-priceWidth)/aspectRatio)+headerHeight+dateHeight+(margin*2);
color black = color(0,0,0);
color white = color(256,256,256);
color grey = color(200,200,200);
int numPips;
int maxPips = 30;
String symbol;
YahooData quotes;
PIPList pips;

void setup() {
  size(width,height+controlHeight);
  symbol = "spy";
  frameRate(10);
  smooth();
  hint(ENABLE_NATIVE_FONTS);
  String today = DateUtil.getTodayStr();
  //quotes = new YahooData(symbol,DateUtil.getNTradingDaysAgo(today,126),today,0);
  quotes = new YahooData(symbol,"2012-01-01","today",0);
  //pips = new PIPList(symbol,quotes.normclose,maxPips);
  //pips.output();

  controlP5 = new ControlP5(this);
  if( maxPips==-1 )
    numPips = quotes.normclose.length/4;
  else
    numPips = maxPips;
  controlP5.addSlider("slider",4,numPips,margin*2,height+controlHeight-40,200,20);
  Slider s = (Slider)controlP5.controller("slider");
  s.setNumberOfTickMarks(numPips);
  s.snapToTickMarks(true);
  s.setSliderMode(Slider.FLEXIBLE);
  s.setLabel("numPips");

  renderAll();
}

void slider(float nPips) {
  if( nPips != numPips ) {
    numPips = int(nPips);
    pips = new PIPList(symbol,quotes.normavg,numPips);
    controlP5.controller("slider").setValueLabel(nf(numPips,0));
    renderAll();
  }
}

void draw() {
}

void renderAll() {
  background(grey);
  renderHeader();
  renderChart();
  renderDate();
  renderPrice();
}

void renderHeader() {
  String title = quotes.symbol;
  fill(black);
  stroke(black);
  line(0,headerHeight,width,headerHeight);
  textAlign(LEFT,CENTER);
  text(title,margin,10);
}

void renderChart() {
  int strokeWidth = 2;
  if( width < 500 )
    strokeWidth = 1;
  int xMin = margin;
  int xMax = width-priceWidth-margin;
  int yMin = height-dateHeight-margin;
  int yMax = headerHeight+margin;
  // plot candles
  stroke(black);
  for( int i=quotes.lookback; i<quotes.numQuotes; i++ ) {
    float x  = map(i-quotes.lookback,0,quotes.numQuotes-quotes.lookback,xMin,xMax);
    float op = map(quotes.op[i],quotes.priceMin,quotes.priceMax,yMin,yMax);
    float hi = map(quotes.hi[i],quotes.priceMin,quotes.priceMax,yMin,yMax);
    float lo = map(quotes.lo[i],quotes.priceMin,quotes.priceMax,yMin,yMax);
    float cl = map(quotes.cl[i],quotes.priceMin,quotes.priceMax,yMin,yMax);
    fill(black);
    line(x,hi,x,lo);
    if( cl < op )
      fill(white);
    rect(x-strokeWidth,op,strokeWidth*2,cl-op);
  }

  // plot approximation
  int[] xx = sort(pips.x);
  for( int i=1; i<pips.x.length; i++ ) {
    stroke(color(0,0,255));
    float x1  = map(xx[i-1],0,quotes.numQuotes-quotes.lookback,xMin,xMax);
    float y1 = map(quotes.cl[xx[i-1]],quotes.priceMin,quotes.priceMax,yMin,yMax);
    float x2  = map(xx[i],0,quotes.numQuotes-quotes.lookback,xMin,xMax);
    float y2 = map(quotes.cl[xx[i]],quotes.priceMin,quotes.priceMax,yMin,yMax);
    line(x1,y1,x2,y2);
    fill(color(255,0,0));
    stroke(color(255,0,0));
    ellipse(x1,y1,8,8);
    ellipse(x2,y2,8,8);
  }

}

void renderDate() {
  int yMin = height-dateHeight;
  int xMin = margin;
  int xMax = width-priceWidth-margin;
  fill(black);
  stroke(black);
  textAlign(CENTER,TOP);
  line(0,yMin,width,yMin);
  int dateInterval = (quotes.numQuotes-quotes.lookback)/12;
  for( int i=dateInterval; i<quotes.numQuotes; i+=dateInterval ) {
    float x = map(i-quotes.lookback,0,quotes.numQuotes-quotes.lookback,xMin,xMax);
    line(x,yMin,x,yMin+3);
    String dateStr = quotes.dt[i].substring(5,7)
                +"/"+quotes.dt[i].substring(8,10)
                +"/"+quotes.dt[i].substring(2,4);
    text(dateStr,x,yMin+5);
  }
}

void renderPrice() {
  int xMin = width-priceWidth;
  int yMin = height-dateHeight-margin;
  int yMax = headerHeight+margin;
  fill(black);
  stroke(black);
  textAlign(LEFT,CENTER);
  line(xMin,headerHeight,xMin,height-dateHeight);
  float priceStart = int(round(quotes.priceMin/quotes.priceInterval))*quotes.priceInterval;
  for( float v=priceStart+quotes.priceInterval; v<quotes.priceMax; v+=quotes.priceInterval ) {
    float y = map(v,quotes.priceMin,quotes.priceMax,yMin,yMax);
    line(xMin,y,xMin+3,y);
    text(nf(v,0,2),xMin+8,y);
  }
}

