package
{
	
	import mx.managers.PopUpManager;
	import qs.calendar.Calendar;
	import qs.calendar.iParser;
	import qs.calendar.CalendarSet;
	import mx.core.Application;
	import mx.core.UIComponent;
	import mx.rpc.http.mxml.HTTPService;
	import mx.controls.TextInput;
	import mx.rpc.AsyncToken;
	import mx.rpc.Responder;
	import mx.controls.Alert;
	import mx.rpc.events.ResultEvent;
	import qs.controls.CalendarDisplay;
	import qs.utils.DateRange;
	import mx.controls.DateChooser;
	import mx.rpc.remoting.RemoteObject;
	import qs.utils.URLUtils;
	import mx.utils.URLUtil;
	import mx.controls.ToggleButtonBar;
	import qs.utils.DateUtils;
	import mx.core.IFlexDisplayObject;
	import qs.utils.StringUtils;
	import mx.utils.StringUtil;
	import qs.calendar.CalendarEvent;
	import mx.managers.ToolTipManager;
	import sjd.controls.HtmlToolTip;
	import qs.controls.calendarDisplayClasses.CalendarDisplayEvent;
	import mx.events.CalendarLayoutChangeEvent;
	
	

	public class app_code extends Application
	{
		public function app_code()
		{
			super();
			
			calLoader = new HTTPService();
			calLoader.resultFormat = "text";
		}
		
		[Bindable] public var calSet:CalendarSet = new CalendarSet();
		protected static const displayOptions:Array = ['month','week','day']
		
		public var calLoader:HTTPService;
		public var calUrl:TextInput;
		[Bindable] public var displayMode:ToggleButtonBar;
		
		[Bindable] public var cal:CalendarDisplay;
		public var chooser:DateChooser;
		
		public var busy:Busy;
			
		protected function addCalendar():void
		{
			var createDlg:CreateCalendarDialog = new CreateCalendarDialog();
			createDlg.loadCallback = function(dlg:CreateCalendarDialog):void
			{
				loadCalendar(dlg.url,dlg.calendarName,dlg.color);
			}
			
			PopUpManager.addPopUp(createDlg,this,true);
			PopUpManager.centerPopUp(createDlg);
		}
		
		
		protected function showHelp():void
		{
			var hlp:Help = new Help();
			PopUpManager.addPopUp(hlp,this,true);
			PopUpManager.centerPopUp(hlp);
		}
		protected function load():void
		{
			ToolTipManager.toolTipClass = HtmlToolTip;
			//showHelp();
			cal.range = new DateRange(chooser.selectedDate,chooser.selectedDate);			
			loadCalendar("data/test.ics","default",0xBB0000);
		}
		

		private function loadCalendar(url:String, name:String, color:uint):void
		{
			
			busy.currentState = "busy";
			url = URLUtil.getFullURL(systemManager.loaderInfo.url,url);
			calLoader.url = url + "?" + Math.random();
			var token:AsyncToken = calLoader.send();
			token.addResponder(new Responder(
				function(param:*):void {
					var calData:String = (token.result as String);
					var p:iParser = new iParser();
					var calendar:Calendar  = p.parse(calData)[0];
					calendar.contextColor = color;
					calendar.name = name;
					calSet.calendars = calSet.calendars.concat([calendar]);							
					cal.dataProvider = calSet.events;
					busy.currentState = "free";
				},
				function (param:*):void {
				
					Alert.show("calendar load failed");
					busy.currentState = "free";
				}));				
				
		}
		
		protected function goToToday():void
		{
			cal.range = new DateRange(new Date(),new Date());
		}
		protected function formatDate(d:Date):String
		{
			var r:String = d.toDateString();
			return r;
		}
		public function removeCalendar(cal:Object):void
		{
			var cals:Array = calSet.calendars.concat();
			for(var i:int = 0;i<cals.length;i++)
			{
				if(cals[i] == cal)
				{
					cals.splice(i,1);
					calSet.calendars = cals;
					return;
				}
			}
		}
		
		protected function updateRange():void
		{
			cal.displayMode = "auto";
			if(chooser.selectedRanges.length == 0)
				return;
			var selRange:Object = chooser.selectedRanges[0];
			cal.range = new DateRange(selRange.rangeStart,selRange.rangeEnd);			
		}
		
		protected function rangeChangeHandler():void
		{
			chooser.selectedRanges = [ {rangeStart: cal.range.start, rangeEnd: cal.range.end} ];
			chooser.displayedYear = cal.range.start.fullYear;
			chooser.displayedMonth = cal.range.start.month;
		}
		
		protected function displayModeHandler():void
		{
			switch(cal.displayMode)
			{
				case "day":
				case "days":
					displayMode.selectedIndex = 2;
					break;
				case "week":
				case "weeks":
					displayMode.selectedIndex = 1;
					break;
				case "month":
				default:
					displayMode.selectedIndex = 0;
					break;					
			}
		}
		
		protected function headerClickHandler(d:Date):void
		{
			cal.displayMode = "auto";
			cal.range = new DateRange(d,d);						
		}

		protected function dayClickHandler(d:Date):void
		{
			cal.displayMode = "auto";
			cal.range = new DateRange(d,d);						
		}
		
		protected function displayModeItemClickHandler():void
		{
			cal.displayMode=displayOptions[displayMode.selectedIndex];
		}
		
		protected var _colors:Array = [
			0xBB0000,
			0x00BB00,
			0x0000BB,
			0xBBBB00,
			0xBB00BB,
			0x00BBBB
		];
		
		
	
	
	
	
	
	
	
	
	
	
		
		//popup AddCalendarEventDialog
		public function addCalendarDialog(start:Date, end:Date, allDay:Boolean):void
		{
			var createDlg:IFlexDisplayObject = new AddCalendarEventDialog();
			
			AddCalendarEventDialog(createDlg).startDate = start;
			AddCalendarEventDialog(createDlg).endDate = end;
			
			AddCalendarEventDialog(createDlg).addDayCallback = addCalendarDay;
			AddCalendarEventDialog(createDlg).addTimeCallback = addCalendarTime;
			
			var startNum:Number = 0;
			var endNum:Number = 0;
				
			if(allDay){
				startNum = 0;
				endNum = 23.5;
			}else{
				startNum = start.hours;
				endNum = end.hours;
			
				if(start.minutes > 0){
					startNum += 0.5;
				}
				if(end.minutes > 0){
					endNum += 0.5;
				}
			}
			
			PopUpManager.addPopUp(createDlg,this,true);
			PopUpManager.centerPopUp(createDlg);
			
			AddCalendarEventDialog(createDlg).startDateUI.selectedDate = start;
			AddCalendarEventDialog(createDlg).endDateUI.selectedDate = end;
			AddCalendarEventDialog(createDlg).timeUI.values = [startNum, endNum];
			
			callLater(AddCalendarEventDialog(createDlg).refresh);
		}
		
		//popup EditCalendarEventDialog
		public function editCalendarDialog(event:CalendarEvent):void{
			var createDlg:IFlexDisplayObject = new EditCalendarEventDialog();
			
			EditCalendarEventDialog(createDlg).cd = cal;
			EditCalendarEventDialog(createDlg).event = event;
			
			PopUpManager.addPopUp(createDlg,this,true);
			PopUpManager.centerPopUp(createDlg);
			
			var startNum:Number = 0;
			var endNum:Number = 0;
			if(event.allDay){
				startNum = 0;
				endNum = 23.5;
			}else{
				startNum = event.start.hours;
				endNum = event.end.hours;
			
				if(event.start.minutes > 0){
					startNum += 0.5;
				}
				if(event.end.minutes > 0){
					endNum += 0.5;
				}
			}
			EditCalendarEventDialog(createDlg).timeUI.values = [startNum, endNum];
			
			callLater(EditCalendarEventDialog(createDlg).refresh);
		}
		
		//We creat a calendar body to parse the event, refer to function loadCalendar
		public function addCalendarDay(start:Date, end:Date, summary:String, description:String = "", color:Number = 0):void{
			if(DateUtils.toIcsDate(start) == DateUtils.toIcsDate(end)){
					return;
			}else{
				end.date += 1;

			}
			description = StringUtils.replaceAll(description, "\n", "\\n");
			description = StringUtils.replaceAll(description, "\r", "\\n");
			var now:Date = new Date();
			
			//A event begin with BEGIN:VCALENDAR, end with END:VEVENT
			//And Time Zone currently is not used
			var calData:String = 
			"BEGIN:VCALENDAR\r\n"+
			"PRODID:-//Google Inc//Google Calendar 70.9054//EN\r\n"+
			"VERSION:2.0\r\n"+
			"CALSCALE:GREGORIAN\r\n"+
			"METHOD:PUBLISH\r\n"+
			"X-WR-CALNAME:test cal\r\n"+
			"X-WR-TIMEZONE:America/Los_Angeles\r\n"+
			"X-WR-CALDESC:\r\n"+
			
			"BEGIN:VEVENT\r\n"+
			"DTSTART;VALUE=DATE:"+DateUtils.toIcsDate(start)+"\r\n"+
			"DTEND;VALUE=DATE:"+DateUtils.toIcsDate(end)+"\r\n"+
			"DTSTAMP:"+DateUtils.toIcsDate(now) + "T" + DateUtils.toIcsTime(now)+"Z\r\n"+
			/*
			"DTSTART;VALUE=DATE:20060924\r\n"+
			"DTEND;VALUE=DATE:20060925\r\n"+
			"DTSTAMP:20060907T165551Z\r\n"+
			*/
			"ORGANIZER;CN=test cal:MAILTO:0vpmlit9621663ap27ilpg4hr0@group.calendar.goog\r\n"+
			" le.com\r\n"+
//TODO change generate the uid from server
			"UID:cagcjos8b9sd7641vbk6mcv708@google.com\r\n"+
			"CLASS:PRIVATE\r\n"+
			"CREATED:"+DateUtils.toIcsDate(now) + "T" + DateUtils.toIcsTime(now)+"Z\r\n"+
			"LAST-MODIFIED:"+DateUtils.toIcsDate(now) + "T" + DateUtils.toIcsTime(now)+"Z\r\n"+
			/*
			"CREATED:20060907T165040Z\r\n"+
			"LAST-MODIFIED:20060907T165101Z\r\n"+
			*/
			"SEQUENCE:1\r\n"+
			"STATUS:CONFIRMED\r\n"+
			"DESCRIPTION:"+description+"\r\n"+
			"SUMMARY:"+summary+"\r\n"+
			//"SUMMARY:cross week 2 day event\r\n"+
			"TRANSP:OPAQUE\r\n"+
			"END:VEVENT\r\n"+
			
			/*"BEGIN:VTIMEZONE\r\n"+
			"TZID:America/Los_Angeles\r\n"+
			"X-LIC-LOCATION:America/Los_Angeles\r\n"+
			"BEGIN:STANDARD\r\n"+
			"TZOFFSETFROM:-0700\r\n"+
			"TZOFFSETTO:-0800\r\n"+
			"TZNAME:PST\r\n"+
			"DTSTART:19701025T020000\r\n"+
			"RRULE:FREQ=YEARLY;BYMONTH=10;BYDAY=-1SU\r\n"+
			"END:STANDARD\r\n"+
			"BEGIN:DAYLIGHT\r\n"+
			"TZOFFSETFROM:-0800\r\n"+
			"TZOFFSETTO:-0700\r\n"+
			"TZNAME:PDT\r\n"+
			"DTSTART:19700405T020000\r\n"+
			"RRULE:FREQ=YEARLY;BYMONTH=4;BYDAY=1SU\r\n"+
			"END:DAYLIGHT\r\n"+
			"END:VTIMEZONE\r\n"+*/
			"END:VCALENDAR";

			var p:iParser = new iParser();
			var calendar:Calendar  = p.parse(calData)[0];
			//The color is set to every calendar event.
			//Maybe we should add a new parameter in the calendar body text to save the color for every event instead of just use the color for whole canlendar.
			calendar.contextColor = color;
			calendar.name = "name";
			calSet.calendars = calSet.calendars.concat([calendar]);							
			cal.dataProvider = calSet.events;
			busy.currentState = "free";

			
		}
	
	
		//We creat a calendar body to parse the event, refer to function loadCalendar
		public function addCalendarTime(start:Date, end:Date, summary:String, description:String = "", color:Number = 0):void{
			var now:Date = new Date();
			description = StringUtils.replaceAll(description, "\n", "\\n");
			description = StringUtils.replaceAll(description, "\r", "\\n");
			var calData:String = 
			"BEGIN:VCALENDAR\r\n"+
			"PRODID:-//Google Inc//Google Calendar 70.9054//EN\r\n"+
			"VERSION:2.0\r\n"+
			"CALSCALE:GREGORIAN\r\n"+
			"METHOD:PUBLISH\r\n"+
			//"X-WR-CALNAME:test cal\r\n"+
			//"X-WR-TIMEZONE:America/Los_Angeles\r\n"+
			//"X-WR-CALDESC:\r\n"+
			"BEGIN:VEVENT\r\n"+
			"DTSTART;TZID=America/Los_Angeles:" + DateUtils.toIcsDate(start) + "T" + DateUtils.toIcsTime(start)+"\r\n"+
			"DTEND;TZID=America/Los_Angeles:" + DateUtils.toIcsDate(end) + "T" + DateUtils.toIcsTime(end)+"\r\n"+
			//"DTSTART;TZID=America/Los_Angeles:20060923T160000\r\n"+
			//"DTEND;TZID=America/Los_Angeles:20060923T210000\r\n"+
			"DTSTAMP:"+DateUtils.toIcsDate(now) + "T" + DateUtils.toIcsTime(now)+"Z\r\n"+
			//"DTSTAMP:20060907T165551Z\r\n"+
			"ORGANIZER;CN=test cal:MAILTO:0vpmlit9621663ap27ilpg4hr0@group.calendar.goog\r\n"+
			" le.com\r\n"+
			"UID:j1o618k1tklj779nu2kgj9560s@google.com\r\n"+
			"CLASS:PRIVATE\r\n"+
			"CREATED:20060907T165444Z\r\n"+
			"LAST-MODIFIED:20060907T165444Z\r\n"+
			"LOCATION:\r\n"+
			"SEQUENCE:0\r\n"+
			"STATUS:CONFIRMED\r\n"+
			"DESCRIPTION:"+description+"\r\n"+
			"SUMMARY:"+summary+"\r\n"+
			//"SUMMARY:timed event\r\n"+
			"TRANSP:OPAQUE\r\n"+
			"END:VEVENT\r\n"+
			/*"BEGIN:VTIMEZONE\r\n"+
			"TZID:America/Los_Angeles\r\n"+
			"X-LIC-LOCATION:America/Los_Angeles\r\n"+
			"BEGIN:STANDARD\r\n"+
			"TZOFFSETFROM:-0700\r\n"+
			"TZOFFSETTO:-0800\r\n"+
			"TZNAME:PST\r\n"+
			"DTSTART:19701025T020000\r\n"+
			"RRULE:FREQ=YEARLY;BYMONTH=10;BYDAY=-1SU\r\n"+
			"END:STANDARD\r\n"+
			"BEGIN:DAYLIGHT\r\n"+
			"TZOFFSETFROM:-0800\r\n"+
			"TZOFFSETTO:-0700\r\n"+
			"TZNAME:PDT\r\n"+
			"DTSTART:19700405T020000\r\n"+
			"RRULE:FREQ=YEARLY;BYMONTH=4;BYDAY=1SU\r\n"+
			"END:DAYLIGHT\r\n"+
			"END:VTIMEZONE\r\n"+*/
			"END:VCALENDAR";
	
			var p:iParser = new iParser();
			var calendar:Calendar  = p.parse(calData)[0];
			//The color is set to every calendar event.
			//Maybe we should add a new parameter in the calendar body text to save the color for every event instead of just use the color for whole canlendar.			
			calendar.contextColor = color;
			calendar.name = "name";
			calSet.calendars = calSet.calendars.concat([calendar]);							
			cal.dataProvider = calSet.events;
			busy.currentState = "free";
		}
		
	}
}


/** 
  * ------------------------------------------------------------------------
  *                       Modification Log
  * Date     	Developer         	Description of Change
  * ----------	-----------------	-----------------------------------------
  * 02/25/2007	Jove Shi			Add add/edit event functions 
  */