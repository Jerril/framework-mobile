/*
 Copyright © 2006-2015 Ludo Factory - http://www.ludokado.com/
 Framework mobile
 Author  : Maxime Lhoez
 Created : 27 septembre 2014
*/
package com.ludofactory.mobile.core.notification
{
	
	import com.greensock.TweenMax;
	import com.ludofactory.mobile.core.AbstractGameInfo;
	import com.ludofactory.mobile.core.config.GlobalConfig;
	import com.ludofactory.mobile.core.config.GlobalConfig;
	import com.ludofactory.mobile.core.events.MobileEventTypes;
	import com.ludofactory.mobile.core.notification.content.AbstractPopupContent;
	
	import feathers.core.FeathersControl;
	
	import starling.core.Starling;
	import starling.display.DisplayObject;
	import starling.display.Quad;
	import starling.events.Event;
	import starling.events.Touch;
	import starling.events.TouchEvent;
	import starling.events.TouchPhase;
	
	public class NotificationPopupManager
	{
		/**
		 * The overlay.
		 */
		private static var _overlay:DisplayObject;
		
		/**
		 * The currently displayed notification.
		 */
		private static var _currentNotification:NotificationPopup;
		
		/**
		 * Determines if a notification is currently displaying.
		 */
		public static var isNotificationDisplaying:Boolean = false;

		/**
		 * Initializes the popup.
		 * 
		 * <p>I did this because at the first call of addNotification, the content
		 * was not well placed.</p>
		 */
		public static function initializeNotification():void
		{
			if( !_currentNotification )
			{
				_currentNotification = new NotificationPopup();
				
				_currentNotification.width = GlobalConfig.stageWidth * (GlobalConfig.isPhone ? (AbstractGameInfo.LANDSCAPE ? 0.85 : 0.95) :  (AbstractGameInfo.LANDSCAPE ? 0.78 : 0.8));
				_currentNotification.height = GlobalConfig.stageHeight * (GlobalConfig.isPhone ? 0.95 : 0.95);
				_currentNotification.alignPivot();
				_currentNotification.x = GlobalConfig.stageWidth * 0.5;
				_currentNotification.y = GlobalConfig.stageHeight * 0.5;
				Starling.current.stage.addChild(_currentNotification);
				Starling.current.stage.removeChild(_currentNotification);

				_overlay = new Quad(GlobalConfig.stageWidth, GlobalConfig.stageHeight, 0x000000);
				_overlay.alpha = 0;
				_overlay.visible = false;
			}
		}

//------------------------------------------------------------------------------------------------------------
//	API

		/**
		 * Adds a notification on the screen.
		 */
		public static function addNotification(content:AbstractPopupContent, callback:Function = null):void
		{
			if( isNotificationDisplaying )
			{
				closeNotification();
				TweenMax.delayedCall(0.75, addNotification, [content]);
				return;
			}

			_overlay.addEventListener(TouchEvent.TOUCH, onClose);
			Starling.current.stage.addChild(_overlay);
			TweenMax.to(_overlay, 0.25, { autoAlpha:0.75 });
			
			Starling.current.stage.addChild(_currentNotification);
			_currentNotification.addEventListener(MobileEventTypes.CLOSE_NOTIFICATION, onNotificationClosed);
			_currentNotification.setContentAndCallBack(content, callback);
			_currentNotification.validate();
			_currentNotification.y = GlobalConfig.stageHeight * 0.5 + _currentNotification.offset;
			_currentNotification.animateIn();
			
			isNotificationDisplaying = true;
		}
		
		public static function adjustCurrentNotification():void
		{
			_currentNotification.invalidate(FeathersControl.INVALIDATION_FLAG_SIZE);
			_currentNotification.validate();
			_currentNotification.y = GlobalConfig.stageHeight * 0.5 + _currentNotification.offset;
		}
		
		public static function moveCurrentToTop():void
		{
			// the code below can be used to center the popup in the space between the soft keyboard and the top
			// of the screen. Actually this is not used because it's tricky to get the softKeyboardRect property
			// to store the correct values of the soft keyboard : we need to listen the the event
			// SoftKeyboardEvent.SOFT_KEYBOARD_DEACTIVATE on the component the get the correct rectangle, otherwise
			// everything reports 0
			
			// don't forget to include the FreshPlanet ANE "KeyboardSize" to get the correct size on Android
			
			// offset == all the blank space left if the popup is smaller
			/*var popupHeight:int = _currentNotification.height - _currentNotification.offset;
			var softKeyboardY:int = 0;
			log(Starling.current.nativeStage.softKeyboardRect);
			log(MeasureKeyboard.getInstance().getKeyboardY());
			if(GlobalConfig.ios)
			{
				softKeyboardY = Starling.current.nativeStage.softKeyboardRect.y;
			}
			else
			{
				softKeyboardY = MeasureKeyboard.getInstance().getKeyboardY() as int;
			}
			
			if(!isNaN(softKeyboardY) && softKeyboardY > 0)
			{
				// we know the Y position of the soft keyboard
				if(popupHeight > softKeyboardY)
				{
					// the popup is bigger than the space left between the top of the screen and the Y position of
					// the soft keyboad, so we simply move it to the top
					_currentNotification.y = GlobalConfig.stageHeight * 0.5;
				}
				else
				{
					// otherwise it's smaller, so we can center it
					_currentNotification.y = GlobalConfig.stageHeight * 0.5 + ((softKeyboardY - popupHeight) * 0.5);
				}
			}
			else
			{
				_currentNotification.y = GlobalConfig.stageHeight * 0.5;
			}*/
			
			_currentNotification.y = GlobalConfig.stageHeight * 0.5;
		}
		
		public static function centerCurrent():void
		{
			_currentNotification.y = GlobalConfig.stageHeight * 0.5 + _currentNotification.offset;
		}

		/**
		 * Tihs function is meant to be called whenever we need to close a notification.
		 */
		public static function closeNotification():void
		{
			if( isNotificationDisplaying )
				_currentNotification.close();
		}
		
		private static function onClose(event:TouchEvent):void
		{
			var touch:Touch = event.getTouch(_overlay, TouchPhase.ENDED);
			if( touch )
				closeNotification();
			touch = null;
		}
		
		public static function get maxContentHeight():Number
		{
			return _currentNotification.maxContentHeight;
		}

//------------------------------------------------------------------------------------------------------------
//	Handlers

		/**
		 * When the notification have been closed, whether when the user touches the close
		 * button or when we explicitly request it from the closeNotification function.
		 */
		private static function onNotificationClosed(event:Event):void
		{
			isNotificationDisplaying = false;
			_currentNotification.removeEventListener(MobileEventTypes.CLOSE_NOTIFICATION, onNotificationClosed);
			TweenMax.to(_overlay, 0.5, { autoAlpha:0 });
			_currentNotification.animateOut();
			_overlay.removeEventListener(TouchEvent.TOUCH, onClose);
		}
		
	}
}
