/*
Copyright © 2006-2015 Ludo Factory - http://www.ludokado.com/
Based on the work of Vincent Petithory https://github.com/vincent-petithory/as3-gettext
Framework mobile
Author  : Maxime Lhoez
Created : 7 mai 2014
*/
package com.ludofactory.common.gettext.aliases
{
	import com.ludofactory.common.gettext.ASGettext;

	/**
	 * Alias of gettext.
	 * 
	 * @see com.ludofactory.common.gettext.Gettext#gettext()
	 */	
	public function gettext(key:String):String
	{
		return ASGettext.gettext(key);
	}
}