/*Copyright (c) 2006 Adobe Systems Incorporated

Permission is hereby granted, free of charge, to any person
obtaining a copy of this software and associated documentation
files (the "Software"), to deal in the Software without
restriction, including without limitation the rights to use,
copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the
Software is furnished to do so, subject to the following
conditions:

The above copyright notice and this permission notice shall be
included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
OTHER DEALINGS IN THE SOFTWARE.
*/
package qs.utils
{
	public class DateUtils
	{
		public static const MILLI_IN_DAY:Number = 24*60*60*1000;
		public static const MILLI_IN_HOUR:Number = 60*60*1000;
		public static const MILLI_IN_MINUTE:Number = 60*1000;
		public static const MILLI_IN_SECOND:Number = 60*1000;

		public static function toIcsDate(d:Date, format:Boolean = false):String{
			var year:String;
			var month:String;
			var date:String;
			
			var dateStr:String;
			
			year = String(d.getFullYear());
			
			if(d.getMonth() + 1 < 10){
				month = "0" + (d.getMonth() + 1);
			}else{
				month = String(d.getMonth() + 1);
			}
			
			if(d.getDate() < 10){
				date = "0" + (d.getDate());
			}else{
				date = String(d.getDate());
			}
			if(format){
				dateStr =  month + "/" + date + "/" + year;
			}else{
				dateStr =  year + month + date;
			}
			return dateStr;
		}
		
		public static function toIcsTime(d:Date, format:Boolean = false):String{
			
			var hour:String;
			var minute:String;
			var second:String;
			
			var timeStr:String;
			
			if(d.getHours() < 10){
				hour = "0" + (d.getHours());
			}else{
				hour = String(d.getHours());
			}
			
			if(d.getMinutes() < 10){
				minute = "0" + (d.getMinutes());
			}else{
				minute = String(d.getMinutes());
			}
			
			if(d.getSeconds() < 10){
				second = "0" + (d.getSeconds());
			}else{
				second = String(d.getSeconds());
			}
			if(format){
				timeStr =  hour + ":" +  minute + ":" + second;
			}else{
				timeStr =  hour + minute + second;
			}
			return timeStr;
		}
		
		
	}
}

/** 
  * ------------------------------------------------------------------------
  *                       Modification Log
  * Date     	Developer         	Description of Change
  * ----------	-----------------	-----------------------------------------
  * 02/25/2007	Jove Shi			Initial code
  */