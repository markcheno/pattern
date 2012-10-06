static class DateUtil {
  // Useful functions for doing date arithmetic.
  //
  // All string dates should be formatted as: 
  //   0123456789  
  //   yyyy-mm-dd

  static int SUNDAY=0;
  static int MONDAY=1;
  static int TUESDAY=2;
  static int WEDNESDAY=3;
  static int THURSDAY=4;
  static int FRIDAY=5;
  static int SATURDAY=6;

  static float getMJD(String dateStr) {
    int y = int(dateStr.substring(0,4));
    int d = int(dateStr.substring(8,10));
    int m = int(dateStr.substring(5,7));
    float a = 10000.0*y+100.0*m+d;
    int b=0;

    if( m <=2 ) {
      m += 12;
      y -= 1;
    }

    if( a < 15821004.1 )
      b = -2+floor((y+4716)/4)-1179;
    else
      b = floor(y/400)-floor(y/100)+floor(y/4);

    a = 365.0*y-679004.0;

    return a+b+floor(30.6001*(m+1))+d;
  }

  static String getDateStr(float mjd) {
    int mm,dd,yyyy;
    float jd,jdo,c;

    jd = mjd + 2400000.5;
    jdo = int(jd+0.5);

    if( jdo < 2299161.0 ) {
      c = jdo+1524.0;
    } 
    else {
      int b = floor((jdo-1867216.25)/36524.25);
      c = jdo+(b-floor(b/4))+1525.0;
    }

    int d = floor((c-122.1)/365.25);
    float e = 365.0*d+floor(d/4);
    int f = floor((c-e)/30.6001);

    dd = floor(c-e+0.5)-floor(30.6001*f);
    mm = f-1-12*floor(f/14);
    yyyy = d-4715-floor((7+mm)/10); 

    return yyyy+"-"+nf(mm,2)+"-"+nf(dd,2);
  }

  static String getTodayStr() {
    return year()+"-"+nf(month(),2)+"-"+nf(day(),2);
  }

  static float getTodayMJD() {
    return getMJD(getTodayStr());
  }

  static String getDayOfWeekStr(String dateStr) {
    return getDayOfWeekStr(getMJD(dateStr));
  }

  static String getDayOfWeekStr(float mjd) {
    int iday = getDayOfWeekInt(mjd); 
    String sday="error";

    switch(iday) {
    case 0: 
      sday="Sun"; 
      break;
    case 1: 
      sday="Mon"; 
      break;
    case 2: 
      sday="Tue"; 
      break;
    case 3: 
      sday="Wed"; 
      break;
    case 4: 
      sday="Thu"; 
      break;
    case 5: 
      sday="Fri"; 
      break;
    case 6: 
      sday="Sat"; 
      break;
    }

    return sday;
  }

  static int getDayOfWeekInt(String dateStr) {
    return getDayOfWeekInt(getMJD(dateStr));
  }

  static int getDayOfWeekInt(float mjd) {
    float jd = mjd+2400000.5;
    float a = (jd+1.5)/7.0;
    float fraction = a-floor(a);

    return floor((fraction*7.0)+0.5);
  }

  static String getNTradingDaysAgo(String startDate,int n) {
    int dayOfWeek;
    float mjd = getMJD(startDate);

    while(n > 0 ) {
      mjd--;
      dayOfWeek = getDayOfWeekInt(mjd);
      if( dayOfWeek>0 && dayOfWeek<6 )
        n--;
    }

    return getDateStr(mjd);
  }
}

