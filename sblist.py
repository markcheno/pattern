# Copyright (c) 2012, Mark Chenoweth
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

def normalize(n):
    nmax = max(n)
    nmin = min(n)
    return [ (x-nmin)/(nmax-nmin) for x in n]

class SBList:
  def __init__(self,symbol,dataset,maxPIPs=-1):
    self.symbol = symbol
    self.y = dataset          # original y values
    self.ylen = len(dataset)  # length of dataset
    self.mask = [0]*self.ylen # mask used for keeping track of calculated points
    self.vd = []              # fluctuation
    self.x = []               # x index in order of importance
    if maxPIPs==-1: 
      self.maxPIPs=self.ylen
    else:
      self.maxPIPs=maxPIPs
    self.buildList()

  def addPIP(self,index,vd):
    # add a PIP
    self.x.append(index)
    self.vd.append(vd)
    self.mask[index]=1 # mark as picked

  def buildList(self):
    # add the first and last values of the dataset to bootstrap
    self.addPIP(0,0)
    self.addPIP(self.ylen-1,0)
    # calculate requested PIPs
    while len(self.vd)<self.maxPIPs:
      self.locateNextPIP()

  def locateNextPIP(self):
    x1=0
    index=-1
    maxvd=-1
    while True:
      while self.mask[x1]==1 and x1<self.ylen-1: x1+=1
      if x1>self.ylen-2: break
      x2=x1
      x1-=1
      while self.mask[x2]==0 and x2<self.ylen-1: x2+=1
      for x in range(x1,x2):
        vd = abs((self.y[x1]+(self.y[x2]-self.y[x1])*((float(x-x1))/(float(x2-x1))))-self.y[x])
        if vd > maxvd:
          maxvd = vd
          index = x
      x1=x2
    self.addPIP(index,maxvd)
      
  def __repr__(self):
    out = "Rank\tx\ty\tFluctuation\n"
    for i in range(0,len(self.vd)):
      out += "%d\t%d\t%.2f\t%.2f\n" % (i+1,self.x[i]+1,self.y[self.x[i]],self.vd[i])
    return out
    
if __name__ == '__main__':

  from quote import YahooQuote
  
  #y = [0.1, 0.4, 0.3, 0.7, 0.9, 0.6, 0.7, 0.4, 0.3, 0.5]
  #s1 = SBList("test",y,5)

  q1 = YahooQuote("spy")
  print SBList(q1.symbol,normalize(q1.close),30)


