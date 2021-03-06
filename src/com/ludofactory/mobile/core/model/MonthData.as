/*
Copyright © 2006-2015 Ludo Factory - http://www.ludokado.com/
Framework mobile
Author  : Maxime Lhoez
Created : 10 oct. 2013
*/
package com.ludofactory.mobile.core.model
{
	import com.ludofactory.common.gettext.aliases._;

	public class MonthData
	{
		private var _id:int;
		
		private var _translationKey:String;
		
		public function MonthData(data:Object)
		{
			_id = data.id;
			_translationKey = data.translationKey;
		}
		
		public function get id():int { return _id; }
		public function get translationKey():String { return _translationKey; }
		
		public function toString():String
		{
			return _( _translationKey );
		}
	}
}