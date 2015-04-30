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
	 * Alias of ngettext
	 * 
	 * @see com.ludofactory.common.gettext.Gettext#ngettext()
	 */	
	public function _n(keySingular:String, keyPlural:String, n:int):String
	{
		return ASGettext.ngettext(keySingular, keyPlural, n);
	}
}