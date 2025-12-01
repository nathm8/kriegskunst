package utilities;

function normalise(arr: Array<Float>): Array<Float> {
    var min = arr[0];
    var max = 0.0;
    for (n in arr) {
        min = n < min ? n : min;
        max = n > max ? n : max;
    }
    max -= min;
    var out = new Array<Float>();
    for (n in arr)
        out.push((n-min)/max);
    return out;
}

//https://stackoverflow.com/questions/23689001/how-to-reliably-format-a-floating-point-number-to-a-specified-number-of-decimal
function floatToStringPrecision(n:Float, prec:Int){
    n = Math.round(n * Math.pow(10, prec));
    var str = ''+n;
    var len = str.length;
    if(len <= prec){
      while(len < prec){
        str = '0'+str;
        len++;
      }
      return '0.'+str;
    }
    else{
      return str.substr(0, str.length-prec) + '.'+str.substr(str.length-prec);
    }
  }