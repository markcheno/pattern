# Copyright (c) 2011, Mark Chenoweth
# All rights reserved.
#
# Redistribution and use in source and binary forms, with or without modification, are permitted 
# provided that the following conditions are met:
#
# - Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
#
# - Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following 
#   disclaimer in the documentation and/or other materials provided with the distribution.
#
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, 
# INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE 
# DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL,
# EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS 
# OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, 
# STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF 
# ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

from urllib2 import urlopen
from urllib import urlencode
from random import normalvariate
from datetime import date,datetime,timedelta

class Quote(object):
  
  DATE_FMT = '%Y-%m-%d'
  TIME_FMT = '%H:%M:%S'
  
  def __init__(self):
    self.symbol = ''
    self.date,self.time,self.open_,self.high,self.low,self.close,self.volume = ([] for _ in range(7))

  def append(self,dt,open_,high,low,close,volume):
    self.date.append(dt.date())
    self.time.append(dt.time())
    self.open_.append(float(open_))
    self.high.append(float(high))
    self.low.append(float(low))
    self.close.append(float(close))
    self.volume.append(int(volume))
      
  def to_csv(self):
    return ''.join(["{0},{1},{2},{3:.2f},{4:.2f},{5:.2f},{6:.2f},{7}\n".format(self.symbol,
              self.date[bar].strftime('%Y-%m-%d'),self.time[bar].strftime('%H:%M:%S'),
              self.open_[bar],self.high[bar],self.low[bar],self.close[bar],self.volume[bar]) 
              for bar in xrange(len(self.close))])
    
  def write_csv(self,filename=None):
    with open(filename,'w') as f:
      f.write(self.to_csv())
        
  def read_csv(self,filename):
    self.symbol = ''
    self.date,self.time,self.open_,self.high,self.low,self.close,self.volume = ([] for _ in range(7))
    try:
      for line in open(filename,'r'):
        symbol,ds,ts,open_,high,low,close,volume = line.rstrip().split(',')
        self.symbol = symbol
        dt = datetime.strptime(ds+' '+ts,self.DATE_FMT+' '+self.TIME_FMT)
        self.append(dt,open_,high,low,close,volume)
      return True
    except:
      return False

  def __repr__(self):
    return self.to_csv()
    
      
class GoogleQuote(Quote):
  ''' Daily quotes from Google. Date format='yyyy-mm-dd' '''
  def __init__(self,symbol,start_date=(date.today()-timedelta(125)).isoformat(),end_date=date.today().isoformat(),cache_file=None):
    super(GoogleQuote,self).__init__()
    if cache_file != None:
      if self.read_csv(cache_file):
        return
    self.symbol = symbol.upper()
    start = date(int(start_date[0:4]),int(start_date[5:7]),int(start_date[8:10]))
    end = date(int(end_date[0:4]),int(end_date[5:7]),int(end_date[8:10]))
    url_string = "http://www.google.com/finance/historical?"
    query_args = {'q':self.symbol, 'startdate':start.strftime('%b %d, %Y'), 'enddate':end.strftime('%b %d, %Y'), 'output':'csv' }
    encoded_args = urlencode(query_args)
    csv = urlopen(url_string+encoded_args).readlines()
    csv.reverse()
    for bar in xrange(0,len(csv)-1):
      ds,open_,high,low,close,volume = csv[bar].rstrip().split(',')
      open_,high,low,close = [float(x) for x in [open_,high,low,close]]
      dt = datetime.strptime(ds,'%d-%b-%y')
      self.append(dt,open_,high,low,close,volume)
    if cache_file != None:
      self.write_csv(cache_file)

class GoogleIntradayQuote(Quote):
  ''' Intraday quotes from Google. Specify interval seconds and number of days '''
  def __init__(self,symbol,interval_seconds=300,num_days=5,cache_file=None):
    super(GoogleIntradayQuote,self).__init__()
    if cache_file != None:
      if self.read_csv(cache_file):
        return
    self.symbol = symbol.upper()
    url_string = "http://www.google.com/finance/getprices?q={0}".format(self.symbol)
    url_string += "&i={0}&p={1}d&f=d,o,h,l,c,v".format(interval_seconds,num_days)
    csv = urlopen(url_string).readlines()
    for bar in xrange(7,len(csv)):
      if csv[bar].count(',')!=5: continue
      offset,close,high,low,open_,volume = csv[bar].split(',')
      if offset[0]=='a':
        day = float(offset[1:])
        offset = 0
      else:
        offset = float(offset)
      open_,high,low,close = [float(x) for x in [open_,high,low,close]]
      dt = datetime.fromtimestamp(day+(interval_seconds*offset))
      self.append(dt,open_,high,low,close,volume)
    if cache_file != None:
      self.write_csv(cache_file)
   
class YahooQuote(Quote):
  ''' Daily quotes from Yahoo. Date format='yyyy-mm-dd' '''
  def __init__(self,symbol,start_date=(date.today()-timedelta(252)).isoformat(),end_date=date.today().isoformat(),cache_file=None):
    super(YahooQuote,self).__init__()
    if cache_file != None:
      if self.read_csv(cache_file):
        return
    self.symbol = symbol.upper()
    start_year,start_month,start_day = start_date.split('-')
    start_month = str(int(start_month)-1)
    end_year,end_month,end_day = end_date.split('-')
    end_month = str(int(end_month)-1)
    url_string  = "http://ichart.finance.yahoo.com/table.csv?s={0}".format(symbol)
    url_string += "&a={0}&b={1}&c={2}".format(start_month,start_day,start_year)
    url_string += "&d={0}&e={1}&f={2}".format(end_month,end_day,end_year)
    csv = urlopen(url_string).readlines()
    csv.reverse()
    for bar in xrange(0,len(csv)-1):
      ds,open_,high,low,close,volume,adjc = csv[bar].rstrip().split(',')
      open_,high,low,close,adjc = [float(x) for x in [open_,high,low,close,adjc]]
      if close != adjc:
        factor = adjc/close
        open_,high,low,close = [x*factor for x in [open_,high,low,close]]
      dt = datetime.strptime(ds,'%Y-%m-%d')
      self.append(dt,open_,high,low,close,volume)
    if cache_file != None:
      self.write_csv(cache_file)

class BrownianQuote(Quote):
  ''' Brownian Motion synthetic quotes. Close only. Date format='yyyy-mm-dd' '''
  def __init__(self,symbol,start_date=(date.today()-timedelta(365)).isoformat(),end_date=date.today().isoformat(),cache_enabled=False,initial_price=50.00,trend_pct=0.005,volatility_pct=0.02,cache_file=None):
    super(BrownianQuote,self).__init__()
    if cache_file != None:
      if self.read_csv(cache_file):
        return
    self.symbol = symbol.upper()
    dt_end = datetime.strptime(end_date,self.DATE_FMT)
    delta = timedelta(days=1)
    dt = datetime.strptime(start_date,self.DATE_FMT)
    self.append(dt,initial_price,initial_price,initial_price,initial_price,0)
    while dt <= dt_end:
      if dt.weekday()<5:
        v = self.close[-1] + (trend_pct-0.5*pow(volatility_pct,2))*self.close[-1] + volatility_pct*normalvariate(0.0,1.0)*self.close[-1]
        self.append(dt,v,v,v,v,0)
      dt += delta
    if cache_file != None:
      self.write_csv(cache_file)
 
if __name__ == '__main__':

  import argparse
  
  parser = argparse.ArgumentParser(description='Free Quote Downloader (c) 2011 Mark Chenoweth ')
  parser.add_argument('symbol', action='store')
  parser.add_argument('--output', action='store_true', help="Save to file", default=False)  
  parser.add_argument('--file', action='store', help="Filename to save to")  
  parser.add_argument('--mode', action='store', choices=('daily','intraday'), default='daily')
  parser.add_argument('--source', action='store', choices=('yahoo','google'), default='yahoo')
  i_group = parser.add_argument_group('intraday')
  i_group.add_argument('--interval', action='store', help='Interval seconds (60,120,300,900,1800,3600)', type=int, default=300)
  i_group.add_argument('--numdays', action='store', help='Number of days (up to 10)', type=int, default=10)
  d_group = parser.add_argument_group('daily')
  d_group.add_argument('--start', action='store', help="Start date (yyyy-mm-dd)")
  d_group.add_argument('--end', action='store', help="End date (yyyy-mm-dd)")
  args = parser.parse_args()
  
  if args.mode=='daily':
  
    if args.start==None:
      args.start = (date.today()-timedelta(365)).isoformat()
    else:
      args.start = args.start.replace("'","")
      args.start = args.start.replace('"',"")
    
    if args.end==None:
      args.end = date.today().isoformat()
    else:
      args.enddate = args.end.replace("'","")
      args.enddate = args.end.replace('"',"")
    
    if args.source=='yahoo':
      q = YahooQuote(args.symbol,args.start,args.end)
      
    elif args.source=='google':
      q = GoogleQuote(args.symbol,args.start,args.end)
        
  elif args.mode=='intraday':
    q = GoogleIntradayQuote(args.symbol,args.interval,args.numdays)
  
  if args.output:
    if args.file:
      args.file = args.file.replace("'","")
      args.file = args.file.replace('"',"")
      q.write_csv(args.file)
    else:
      q.write_csv()
  else:
    print q
