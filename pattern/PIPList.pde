class PIPList {
 String symbol;
 int x[] = new int[0];
 float y[] = new float[0];
 int msk[] = new int[0];
 float vd[] = new float[0];
 int maxPIPs;
 
 PIPList(String sym,float dataset[], int maxP) {
   symbol=sym;
   y=dataset;
   msk=new int[y.length];
   if( maxP==-1 )
     maxPIPs=y.length;
   else
     maxPIPs=maxP;
   buildList();
   findPatterns(4,4);
 }
 
 void addPIP(int index,float v) {
   x = append(x,index);
   vd = append(vd,v);
   msk[index] = 1;
 }
 
 void buildList() {
   addPIP(0,0);
   addPIP(y.length-1,0);
   while( vd.length < maxPIPs ) {
     locateNextPIP();
   }
 }
 
 void findPatterns(int windowSize,int theta) {
  int[] xs = sort(x);
  float[] ys = new float[xs.length];
  for(int i=0; i<xs.length; i++ )
    ys[i] = y[xs[i]];
  
  println("--------- xs.length="+nf(xs.length,3));
  for(int i=0; i<xs.length; i++ )
    println("xs="+nf(xs[i],3)+",ys="+nf(ys[i],1,2));
  
  int pat=0;
  float[] p = new float[0]; 
  p = append(p,ys[0]);
  p = append(p,ys[1]);
  p = append(p,ys[2]);
  p = append(p,ys[3]);
  float maxP = max(p);
  float minP = min(p);
  float scaleF = (maxP-minP)/float(theta);
  pat = int((p[3]/scaleF*1.0)+(p[2]/scaleF*10.0)+(p[1]/scaleF*100.0)+(p[0]/scaleF*1000.0));
  println("P0="+nf(p[0],2,2));
  println("P1="+nf(p[1],2,2));
  println("P2="+nf(p[2],2,2));
  println("P3="+nf(p[3],2,2));

  println("maxP="+nf(maxP,2,2));
  println("minP="+nf(minP,2,2));
  println("scaleF="+nf(scaleF,0,2));
  println("pat="+nf(pat,4));

 }
 
 void locateNextPIP() {
   int x1=0;
   int x2=0;
   int index=-1;
   float maxvd=-1.0;
   while(true) {
     while( msk[x1]==1 && x1<y.length-1) x1++;
     if( x1>y.length-2 ) break;
     x2=x1;
     x1--;
     while( msk[x2]==0 && x2<y.length-1) x2++;
     for( int x=x1; x<=x2; x++ ) {
       float vd = abs((y[x1]+(y[x2]-y[x1])*((float(x-x1))/(float(x2-x1))))-y[x]);
       if( vd > maxvd ) {
         maxvd=vd;
         index=x;
       }
     }
     x1=x2;
   }
   addPIP(index,maxvd);
 }
 
 void output() {
   println("Rank\tx\ty\tFluctuation");
   for(int i=0; i<vd.length; i++) {
     println((i+1)+"\t"+(x[i]+1)+"\t"+nf(y[x[i]],1,2)+"\t"+nf(vd[i],1,2));
   }   
 }
}

