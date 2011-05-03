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
package qs.controls.calendarDisplayClasses
{
	import flash.events.Event;
	import flash.events.FocusEvent;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.ui.Keyboard;
	import flash.utils.getQualifiedClassName;
	
	import mx.binding.utils.BindingUtils;
	import mx.containers.HBox;
	import mx.controls.Button;
	import mx.controls.Label;
	import mx.core.Application;
	import mx.core.IDataRenderer;
	import mx.core.UIComponent;
	import mx.core.UITextField;
	import mx.events.FlexEvent;
	
	import qs.calendar.CalendarEvent;
	import qs.controls.CalendarDisplay;
	import qs.utils.ColorUtils;
	import qs.utils.DateUtils;
	import qs.utils.StringUtils;

	public class CalendarEventRenderer extends UIComponent implements IDataRenderer, ICalendarEventRenderer
	{
		private var _eventSummary:UITextField;
		private var _eventDescription:UITextField;
		private var _event:CalendarEvent;
		private var _allDay:Boolean = false;
		private var _displayMode:String;
		private var headerColor:uint;
		private var _grabColor:uint;
		
		private var _calendarDisplay:CalendarDisplay = null;
		

		private const BORDER_COLOR:Number = 0xAAAADD;
		private const HEADER_FILL:Number = 0xFFAAAA;
		
		
		public function CalendarEventRenderer():void
		{
			cacheAsBitmap = true;
		}
		
		override protected function createChildren():void
		{
			_eventSummary = new UITextField();	
			_eventSummary.styleName = this;
//\			_eventSummary.cacheAsBitmap = true;
			addChild(_eventSummary);
			
			
			var description:String = StringUtils.replaceAll(_event.description, "\\n", "\n");
			_eventDescription = new UITextField();
			_eventDescription.text = description;
			_eventDescription.visible = false;
			addChild(_eventDescription);
			
			this.toolTip = "<b>" + _event.summary + "</b>\n" + description + "\n\n<i>Double Click to Edit</i>";
			
			
			this.doubleClickEnabled = true;
			this.addEventListener(MouseEvent.DOUBLE_CLICK, editSummary);
			this.addEventListener(MouseEvent.MOUSE_WHEEL, dispatchMouseEvent);
			this.addEventListener(MouseEvent.MOUSE_UP, dispatchMouseEvent);
			this.addEventListener(MouseEvent.MOUSE_MOVE, dispatchMouseEvent);
			
			_calendarDisplay = CalendarDisplay(this.parent.parent);
		}
		
		private function dispatchMouseEvent(event:MouseEvent):void{
			if(_calendarDisplay.displayMode == "days"
					&& _calendarDisplay.currentDay != null
					&& !_calendarDisplay.isEventDrag()){
				CalendarDisplay(this.parent.parent).currentDay.dispatchEvent(event);
			}
		}
		
		private function editSummary(event:MouseEvent):void{
			var ce:CalendarDisplayEvent = new CalendarDisplayEvent(CalendarDisplayEvent.ITEM_EDIT);
			ce.event = this._event;
			//this.parent.parent is CalendarDisplay
			UIComponent(this.parent.parent).dispatchEvent(ce);
			
		}
		
		
		override protected function measure():void
		{
			measuredWidth = _eventSummary.measuredWidth;
			measuredHeight = _eventSummary.measuredHeight;
		}
	
		public function set displayMode(value:String):void
		{
			_displayMode = value;
			invalidateProperties();	
		}
		
		public function set data(value:Object):void
		{
			_event = CalendarEvent(value);
			if(_event != null)
			{
				if(_event.allDay)
					_allDay= true;

				var hsv:Object = ColorUtils.RGBToHSV(_event.color);
				var v:Number = hsv.v;
				var s:Number = hsv.s;
				if(hsv.v > .3)
				{				
					hsv.v *= .7;
					hsv.s *= .9;
				}
				else
				{
					hsv.v *= 2;
					hsv.s *= .9;
				}
				headerColor = ColorUtils.HSVToRGB(hsv);
				hsv.v = Math.min(1,v*1.5);
				hsv.s = s/2;
				_grabColor = ColorUtils.HSVToRGB(hsv);

			}
			else
				_allDay = false;
			invalidateProperties();
		}
		public function get data():Object
		{
			return _event;
		}
		
		override protected function commitProperties():void
		{
			
			var eventText:String = "";
			if(_event != null)
			{
				if(_event.allDay == false)
				{
					var hour:int = _event.start.hours;
					if(hour >= 12)
						hour -= 12;
					if(hour == 0)
						hour = 12;
					eventText += hour.toString();
					if(_event.start.minutes > 0)
						eventText += ":"+_event.start.minutes;
					if(_event.start.hours >= 12)
						eventText += " pm";
					else
						eventText += " am";
				}
				eventText += " " + _event.summary;	
				
			}
			if(_allDay || _displayMode == "box")
			{
				setStyle("color",0xFFFFFF);
			}
			else
			{
				setStyle("color",_event.color);				
			}
			_eventSummary.text = eventText;
			//toolTip = (_event)? eventText:null;
			var description:String = StringUtils.replaceAll(_event.description, "\\n", "\n");
			_eventDescription.text = description;
			
			this.toolTip = "<b>" + _event.summary + "</b>\n" + description + "\n\n<i>Double Click to Edit</i>";
			
			
			var hsv:Object = ColorUtils.RGBToHSV(_event.color);
			var v:Number = hsv.v;
			var s:Number = hsv.s;
			if(hsv.v > .3)
			{				
				hsv.v *= .7;
				hsv.s *= .9;
			}
			else
			{
				hsv.v *= 2;
				hsv.s *= .9;
			}
			headerColor = ColorUtils.HSVToRGB(hsv);
			hsv.v = Math.min(1,v*1.5);
			hsv.s = s/2;
			_grabColor = ColorUtils.HSVToRGB(hsv);
			
			//invalidateSize();
			invalidateDisplayList();
			
		}
		
		override protected function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void
		{
			
			if(checkModeChanged()){
				callLater(_calendarDisplay.invalidateDisplayList);
			}
			
			
			graphics.clear();
			if(_displayMode == "line")
			{
				_eventSummary.setActualSize(unscaledWidth-_eventSummary.measuredHeight,unscaledHeight);			
				_eventSummary.x = measuredHeight/4;
				
				_eventDescription.visible = false;
				
				if(_allDay)
				{
					graphics.lineStyle(1,BORDER_COLOR);
					graphics.beginFill(_event.color);
					graphics.drawRoundRect(0,2,unscaledWidth, unscaledHeight-4,unscaledHeight*.75,unscaledHeight*.75);
					graphics.endFill();
				}
			}
			else
			{
				_eventSummary.setActualSize(unscaledWidth-8,unscaledHeight);
				_eventSummary.move(4,4);
				
				
				graphics.lineStyle(1,BORDER_COLOR);
				
				
				
				
				graphics.beginFill(headerColor);
				graphics.lineStyle(0,0,0);

				if(unscaledHeight <= 20)
				{
					graphics.drawRoundRectComplex(0,2,unscaledWidth, unscaledHeight-4,8,8,8,8);
					graphics.endFill();
					graphics.lineStyle(1,_grabColor,1,false,"normal","none");
				}
				else
				{
					// In some cases _eventSummary.measuredHeight calculates as "NaN or 0" because of transformation matrices a and d (X and Y axis) values are 0.
					// Here is a work around for this issue
					if(_eventSummary.measuredHeight){
						graphics.drawRoundRectComplex(0,2,unscaledWidth, _eventSummary.measuredHeight,8,8,0,0);
						graphics.endFill();
						graphics.beginFill(_event.color);
						graphics.drawRoundRectComplex(0,2+_eventSummary.measuredHeight,unscaledWidth, unscaledHeight-2 - (2+_eventSummary.measuredHeight),0,0,8,8);
					}else{
						var newValue:int = 5
						graphics.drawRoundRectComplex(0,2,unscaledWidth, newValue,8,8,0,0);
						graphics.endFill();
						graphics.beginFill(_event.color);
						graphics.drawRoundRectComplex(0,2+newValue,unscaledWidth, unscaledHeight-2 - (2+newValue),0,0,8,8);
					}
					graphics.endFill();
					graphics.lineStyle(1,_grabColor,1,false,"normal","none");
					graphics.moveTo(0,unscaledHeight-8 );
					graphics.lineTo(unscaledWidth,unscaledHeight-8);
					
					
					_eventDescription.setActualSize(unscaledWidth-8,unscaledHeight - 20);
					_eventDescription.move(4,20);
					_eventDescription.visible = true;
				}
				graphics.moveTo(unscaledWidth/2-4,unscaledHeight-6 );
				graphics.lineTo(unscaledWidth/2+4,unscaledHeight-6 );
				graphics.moveTo(unscaledWidth/2-4,unscaledHeight-4 );
				graphics.lineTo(unscaledWidth/2+4,unscaledHeight-4 );
				
			}
			
			
			
		}
		
		private function checkModeChanged():Boolean{
			var chenged:Boolean = (_allDay != _event.allDay);
			if(chenged){
				_allDay = _event.allDay;
				if(_allDay){
					_displayMode = "line";
				}else{
					_displayMode = "box";
				}
			}
			return chenged;
		}
		
	}
}

/** 
  * ------------------------------------------------------------------------
  *                       Modification Log
  * Date     	Developer         	Description of Change
  * ----------	-----------------	-----------------------------------------
  * 02/25/2007	Jove Shi			Add add/edit event functions and description field, color etc..
  */