package qs.validators{
	import mx.validators.Validator;
	import qs.utils.StringUtils;
	import mx.validators.ValidationResult;
	import mx.core.UIComponent;
	import sjd.validators.MultipTipsValidator;
	import sjd.validators.MultipTipsValidationResult;

	public class EventValidator extends MultipTipsValidator{
		
		private var results:Array;
		
		override protected function doValidation(value:Object):Array {

			var startDate:Number = Number(value.date.startDate);
			var endDate:Number = Number(value.date.endDate);
			var eventName:String = value.name;
           
			results = [];

			results = super.doValidation(value);        
   
            if (results.length > 0){
				return results;
            }

			if(eventName == null || eventName.length < 1 || StringUtils.trim(eventName) == ""){
            	results.push(new MultipTipsValidationResult("eventNameUI", true, "", "EventNameError", "Please input Event Name!"));
            }
				
			if(startDate > endDate){
				results.push(new MultipTipsValidationResult("startDateUI", true, "", "DateRangeStartError", "Start Date must be earlier than the End Date!"));
				results.push(new MultipTipsValidationResult("endDateUI", true, "", "DateRangeEndError", "End Date must be later than the Start Date!"));
			}
			
			if(results.length > 0){
				setListener(results);
			}
			
			
			return results;	
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