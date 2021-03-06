/*
Copyright © 2006-2015 Ludo Factory - http://www.ludokado.com/
Framework mobile
Author  : Maxime Lhoez
Created : 17 sept. 2012
*/
package com.ludofactory.common.utils
{
	
	import com.ludofactory.common.gettext.LanguageManager;
	import com.ludofactory.common.gettext.aliases._;
	
	import flash.desktop.NativeApplication;
	import flash.globalization.DateTimeFormatter;
	import flash.utils.describeType;
	import flash.utils.getDefinitionByName;
	
	public class Utilities
	{
		/**
		 * Whether the tracer is enabled. */		
		private static var _isLogEnabled:Boolean = false;
		
//------------------------------------------------------------------------------------------------------------
//	Colors
		
		/**
		 * Returns the App version defined in the application descriptor.
		 */		
		public static function getAppVersion():String
		{
			var appXml:XML = NativeApplication.nativeApplication.applicationDescriptor;
			var ns:Namespace = appXml.namespace();
			
			//if( Capabilities.manufacturer.toLowerCase().indexOf("android") >= 0 )
			//	return String(appXml.ns::versionNumber[0]).substr(0, 3);  // remove the last .0 automatically added
			//else
				return String(appXml.ns::versionLabel[0])//.substr(0, 3);  // remove the last .0 automatically added
		}
		
		/**
		 * Returns the Build version defined in the application descriptor.
		 */
		public static function getBuildVersion():String
		{
			var appXml:XML = NativeApplication.nativeApplication.applicationDescriptor;
			var ns:Namespace = appXml.namespace();
			return String(appXml.ns::versionNumber[0]);
		}
		
		/**
		 * Returns the App version defined in the application descriptor.
		 */
		public static function getBundleIdFromDescriptor():String
		{
			var appXml:XML = NativeApplication.nativeApplication.applicationDescriptor;
			var ns:Namespace = appXml.namespace();
			return appXml.ns::id;
		}
		
		/**
		 * Returns the App version defined in the application descriptor.
		 */
		public static function getGameNameFromDescriptor():String
		{
			var appXml:XML = NativeApplication.nativeApplication.applicationDescriptor;
			var ns:Namespace = appXml.namespace();
			return appXml.ns::name;
		}
		
		/**
		 * Returns the App version defined in the application descriptor.
		 */
		public static function getIsLandscapeFromDescriptor():Boolean
		{
			var appXml:XML = NativeApplication.nativeApplication.applicationDescriptor;
			var ns:Namespace = appXml.namespace();
			var str:String = String(appXml.ns::initialWindow)
					.match(/<aspectRatio>(.+?)<\/aspectRatio>/gm)[0]
					.replace(/<aspectRatio>|<\/aspectRatio>/gm, "");
			return str == "landscape";
		}
		
//------------------------------------------------------------------------------------------------------------
//	Colors
		
		/**
		 * Returns a random color.
		 */		
		public static function getRandomColor():uint
		{
			return (Math.random() * 0xffffff);
		}
		
//------------------------------------------------------------------------------------------------------------
//	Maths
//------------------------------------------------------------------------------------------------------------
		
		/**
		 * Retourne aléatoirement un index d'un tableau dont la longueur est passée en paramètre.
		 * 
		 * @param arrayLength Longueur du tableau dont on veut un index aléatoirement
		 */		
		public static function getRandomArrayIndex(arrayLength:int):int
		{
			return (Math.random() * arrayLength) << 0;
		}
		
		/**
		 * Retourne un chiffre aléatoire entre les limites définies par les paramètres <code>min</code>
		 * et <code>max</code>.
		 * 
		 * @param min Nombre limite inférieur (inclus).
		 * @param max Nombre limite supérieur (inclus).
		 */
		public static function getRandomBetween(min:Number, max:Number):int
		{
			//return Math.round(Math.random() * (max - min) + min);
			
			// Optimized version
			// use max + 1 because << 0 always round down to nearest
			// so the value of max will never be returned
			return (Math.random() * ((max+1) - min) + min) << 0;
		}
		
		/**
		 * Mélange un tableau.
		 * 
		 * @param arr Tableau source.
		 * @param nb Nombre de fois où le tableau sera mélangé.
		 */ 
		public static function shuffleArray(arr:Array, nb:int):void
		{
			var length:int  = arr.length;
			var howMany:int = length * nb;
			var rdm1:int    = 0;
			var rdm2:int    = 0;
			var val:*;
			
			for(var i:int = 0; i < howMany; i++)
			{
				rdm1 = getRandomArrayIndex(length);
				rdm2 = getRandomArrayIndex(length);
				val = arr[rdm1];
				arr[rdm1] = arr[rdm2];
				arr[rdm2] = val;    
			}
			val = null;
		}
		
		public static function shuffleVector(vect:Object, nb:int):void
		{
			var length:int  = (vect as Vector.<*>).length;
			var howMany:int = length * nb;
			var rdm1:int    = 0;
			var rdm2:int    = 0;
			var val:*;
			
			for(var i:int = 0; i < howMany; i++)
			{
				rdm1 = getRandomArrayIndex(length);
				do
				{
					rdm2 = getRandomArrayIndex(length);
				}while( rdm2 == rdm1)
				
				val = (vect as Vector.<*>)[rdm1];
				(vect as Vector.<*>)[rdm1] = (vect as Vector.<*>)[rdm2];
				(vect as Vector.<*>)[rdm2] = val;    
			}
			val = null;
		}
		
		
		public static function translatePosition(value:int):String
		{
			var translation:String;
			
			if( LanguageManager.getInstance().lang == LanguageManager.FRENCH && value > 1 )
			{
				translation = _("TOURNAMENT_END.POSITION_SECOND");
			}
			else
			{
				switch( int(String(value).split("").reverse()[0]) )
				{
					case 1:  { translation = _("TOURNAMENT_END.POSITION_FIRST");  break; }
					case 2:  { translation = _("TOURNAMENT_END.POSITION_SECOND"); break; }
					case 3:  { translation = _("TOURNAMENT_END.POSITION_THIRD");  break; }
					default: { translation = _("TOURNAMENT_END.POSITION_FOURTH"); break; }
				}
			}
			
			return translation;
		}
		
//------------------------------------------------------------------------------------------------------------
//	Validation
//------------------------------------------------------------------------------------------------------------
		
		/**
		 * Number validation
		 * 
		 * @param text The string to check
		 */		
		public static function isNumberOnly(text:String):String
		{
			var regExpMailValidation:RegExp = new RegExp("^[0-9]*$", "gi");
			return regExpMailValidation.exec(text);
		}
		
		/**
		 * 
		 * @param dateString format : 28/01/2014
		 * 
		 */		
		public static function isToday(dateString:String):Boolean
		{
			var now:Date = new Date();
			if( int(dateString.split("/")[0]) == now.date && int(dateString.split("/")[1]) == (now.month + 1) && int(dateString.split("/")[2]) == now.fullYear )
				return true;
			return false;
		}
		
		/**
		 * Phone number validation (franch only)
		 * Matches any phone number with this format :
		 * 06 or 07 and starting with +33 or 0033
		 * 
		 * @param text The string to check
		 */		
		public static function isFrenchPortableOnly(text:String):String
		{
			// attention aux / si new RegExp(" en mettre 2 ici : // sinon ça marche pas ", "")
			var regExpMailValidation:RegExp = /(0|\+33|0033\s?)(6|7)(\s?\d{2}){4}/i;
			return regExpMailValidation.exec(text) ? regExpMailValidation.exec(text)[0]:null;
		}
		
		/**
		 * Mail validation.
		 * 
		 * @param mail The mail to check
		 */		
		public static function isValidMail(mail:String):String
		{
			//var regExpMailValidation:RegExp = new RegExp("[a-z0-9!#$%&'*+/=?^_`{|}~-]+(?:\.[a-z0-9!#$%&'*+/=?^_`{|}~-]+)*@(?:[a-z0-9](?:[a-z0-9-]*[a-z0-9])?\.)+[a-z0-9](?:[a-z0-9-]*[a-z0-9])?", "gi");
			// 2 caractères après le .xx
			var regExpMailValidation:RegExp = new RegExp("[a-z0-9!#$%&'*+/=?^_`{|}~-]+(?:\.[a-z0-9!#$%&'*+/=?^_`{|}~-]+)*@(?:[a-z0-9](?:[a-z0-9-]*[a-z0-9])?\.)+[a-z0-9](?:[a-z0-9-]*[a-z0-9]){1,6}?", "gi");
			return regExpMailValidation.exec(mail);
		}
		
		public static function splitThousands(value:Number):String
		{
			var base:String = value.toString();
			if(base.length > 1)
			{
				base = base.split("").reverse().join("");
				base = base.replace(/\d{3}(?=\d)/g, "$& ");
				return base.split("").reverse().join("");
			}
			else
			{
				// no need to do anything
				return base;
			}
		}
		
		public static function replaceCurrency(value:String):String
		{
			if( !value )
				return null;
			return value.replace(/\/euro\//g, "€")
				.replace(/\/dollar\//g, "$");
		}
		
		public static function parseHtmlText(value:String):String
		{
			return value.replace(/<br \/>/g, "\n")
				.replace(/&#39;/g, "'")
				.replace(/&eacute;/g, "é")
				.replace(/&egrave;/g, "è")
				.replace(/&quot;/g, "\"")
				.replace(/&agrave;/g, "à")
				.replace(/&ecirc;/g, "ê")
				.replace(/&acirc;/g, "â")
				.replace(/&ccedil;/g, "ç")
				.replace(/&ocirc;/g, "ô");
		}
		
		public static function formatDate(date:Date):String
		{
			// le mois + 1 car Flash commence Janvier à 00 et non 01
			return (date.date < 10 ? ("0" + date.date) : date.date) + "/" + ((date.month + 1) < 10 ? ("0" + (date.month + 1)) : (date.month + 1))  + "/" + date.fullYear + " " + (date.hours < 10 ? ("0" + date.hours) : date.hours) + ":"+ (date.minutes < 10 ? ("0" + date.minutes) : date.minutes);
		}

		/**
		 * 
		 * @param refWidth The item we want to scale
		 * @param refHeight
		 * @param contentToFillWidth The frame we want the item to fill
		 * @param contentToFillHeight
		 * @return
		 */
		/*public static function getScaleToFill(refWidth:Number, refHeight:Number, contentToFillWidth:Number, contentToFillHeight:Number):Number
		{
			// /!\ Attention : il faut ne pas mettre de scaleX et / ou scaleY sur l'item dont on récupère _item.width/height, sinon ça fausse le calcul
			var ratio:Number = 1;
			if (!isNaN(contentToFillWidth) && contentToFillWidth / refWidth > contentToFillHeight / refHeight)
				ratio = contentToFillWidth / refWidth;
			else if(!isNaN(contentToFillHeight))
				ratio = contentToFillHeight / refHeight;
			return ratio;
		}*/
		
		// version olivier, à tester
		/**
		 * Can be bigger = si true, le scale va faire déborder l'image, en gros c'est à utiliser surtout pour les backgrounds dont
		 * on veut qu'ils prennent toute la largeur et hauteur de l'écran, peu importe s'ils débordent.
		 * 
		 * @param itemToScaleWidth
		 * @param itemToScaleHeight
		 * @param widthToFit
		 * @param heightToFit
		 * @param canBeBigger
		 * @return
		 */
		public static function getScaleToFill(itemToScaleWidth:Number, itemToScaleHeight:Number, widthToFit:Number, heightToFit:Number, canBeBigger:Boolean = false):Number
		{
			var ratio:Number = 1;
			if( !canBeBigger )
			{
				if (widthToFit / itemToScaleWidth < heightToFit / itemToScaleHeight)
					ratio = widthToFit / itemToScaleWidth;
				else
					ratio = heightToFit / itemToScaleHeight;
			}
			else
			{
				if (widthToFit / itemToScaleWidth > heightToFit / itemToScaleHeight)
					ratio = widthToFit / itemToScaleWidth;
				else
					ratio = heightToFit / itemToScaleHeight;
			}
			
			return ratio;
		}
		
		public static function getScaleToFillWidth(refWidth:Number, contentToFillWidth:Number):Number
		{
			return contentToFillWidth / refWidth;
		}

		public static function getScaleToFillHeight(refHeight:Number, contentToFillHeight:Number):Number
		{
			return contentToFillHeight / refHeight;
		}
		
//------------------------------------------------------------------------------------------------------------
//	Date util
//------------------------------------------------------------------------------------------------------------
		
		/**
		 * Références :
		 * http://www.computus.org/journal/?p=44
		 * http://www.peachpit.com/articles/article.aspx?p=27016
		 * 
		 * Fonctionne uniquement si la date n'est pas modifiée sur
		 * l'appareil, sinon Flash soustrait simplement le timezone
		 * offset pour récupérer la date UTC, donc ps fiable du tout
		 * si la date a été changée.
		 * 
		 * @return 
		 */		
		public static function getLocalFrenchDate():Date
		{
			// FIXME Très important !
			// /!\ Cette fonction a été codée en heure d'hiver, il faudra donc
			// vérifier qu'elle fonctionne toujours bien en heure d'été !!
			// En heure d'hiver : timezoneOffset = -60
			// En heure d'été : timezoneOffset = -120
			
			// create local Date
			var now:Date = new Date();
			// convert the Date to UTC by adding or subtracting the time zone offset in milliseconds
			// because the timezoneOffset is in minutes, we do *60 (seconds) * 1000 (milliseconds)
			//now.setTime(now.getTime() + (now.getTimezoneOffset() * 60 * 1000));
			// France is GMT-1, so we need to add one hour to the UTC date
			//now.setTime(now.getTime() + (60 * 60 * 1000));
			return now;
		}
		
		/**
		 * @return
		 */		
		/*public static function getTimezone():Number
		{
			// Create two dates: one summer and one winter
			var d1:Date = new Date( 0, 0, 1 )
			var d2:Date = new Date( 0, 6, 1 )
			
			// largest value has no DST modifier
			var tzd:Number = Math.max( d1.timezoneOffset, d2.timezoneOffset )
			
			// convert to milliseconds
			return tzd * 60000
		}*/
		
		/**
		 * Daylight Saving Time (Summer / Winter offset)
		 */		
		/*public static function getDST( d:Date ):Number
		{
			var tzd:Number = getTimezone()
			var dst:Number = (d.timezoneOffset * 60000) - tzd
			return dst
		}*/
		
		/**
		 * Format date to : 
		 * @param d
		 * @return
		 */
		public static function formatDateUS(d:Date):String
		{
			var dtf:DateTimeFormatter = new DateTimeFormatter("en-US");
			dtf.setDateTimePattern("yyyy-MM-dd hh:mm:ssa");
			return dtf.format(d);
		}
		
		
		
		
		public static function countObject(value:Object):int
		{
			var i:int = 0;
			//if(CONFIG::DEBUG)
			//	enableEnumerableObject(value);
			for each(var o:Object in value)
				i++;
			
			return i;
		}
		
		// Permet de rendre les variables de 'obj' enumerable au for in comme s'il été de type Object
		public static function enableEnumerableObject(obj:Object):void
		{
			var key:String;
			var xml:XML = describeType(obj);
			var classPath:String = xml.@name;
			
			if(classPath == "Array" || classPath == "Vector" || classPath == "Object")
				return;
			
			var className:Class = getDefinitionByName(classPath) as Class;
			
			// permet de rendre la class enumérable pour les for in
			for each(key in xml.variable.@name)
			{
				className.prototype[key] = obj[key];
			}
			for each(key in xml.accessor.(@declaredBy == classPath).@name)
			{
				try
				{
					className.prototype[key] = obj[key];
					
				}
				catch(error:Error)
				{
					className.prototype[key] = error.message
				}
			}
		}
		
	}
}