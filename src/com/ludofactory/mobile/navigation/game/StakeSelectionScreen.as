/*
Copyright © 2006-2014 Ludo Factory
Framework mobile
Author  : Maxime Lhoez
Created : 23 Juillet 2013
*/
package com.ludofactory.mobile.navigation.game
{

	import com.greensock.TweenMax;
	import com.ludofactory.common.gettext.aliases._;
	import com.ludofactory.common.utils.scaleAndRoundToDpi;
	import com.ludofactory.mobile.core.AbstractGameInfo;
	import com.ludofactory.mobile.core.controls.AdvancedScreen;
	import com.ludofactory.mobile.core.ScreenIds;
	import com.ludofactory.mobile.core.events.LudoEventType;
	import com.ludofactory.mobile.core.storage.Storage;
	import com.ludofactory.mobile.core.storage.StorageConfig;
	import com.ludofactory.mobile.core.config.GlobalConfig;
	import com.ludofactory.mobile.core.push.GameSession;
	import com.ludofactory.mobile.core.theme.Theme;

	import feathers.controls.Label;

	import flash.filters.DropShadowFilter;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;

	import starling.events.Event;

	/**
	 * The screen used to select a price for the next game session.
	 * 
	 * <p>Whether free, with credits and in tournament mode, with points.</p>
	 */	
	public class StakeSelectionScreen extends AdvancedScreen
	{
		/**
		 * Title */		
		private var _title:Label;
		
		/**
		 * Play with free credits */		
		private var _withFree:StakeButtonFree;
		
		/**
		 * Play with points (only in tournament mode) */		
		private var _withPoints:StakeButtonPoint;
		
		/**
		 * Play with credits */		
		private var _withCredits:StakeButtonCredit;
		
		public function StakeSelectionScreen()
		{
			super();
			
			_appClearBackground = true;
		}
		
		override protected function initialize():void
		{
			super.initialize();
			
			_title = new Label();
			_title.touchable = false;
			_title.text = _("Sélectionnez votre mise...");
			addChild( _title );
			_title.textRendererProperties.textFormat = new TextFormat(Theme.FONT_SANSITA, scaleAndRoundToDpi(GlobalConfig.isPhone ? 50 : 70), Theme.COLOR_WHITE, false, false, null, null, null, TextFormatAlign.CENTER);
			_title.textRendererProperties.nativeFilters = [ new DropShadowFilter(0, 75, 0x000000, 0.75, 5, 5, 3) ];
			
			_withFree = new StakeButtonFree( this.advancedOwner.screenData.gameType );
			_withFree.addEventListener(Event.TRIGGERED, onPlayWithFree);
			addChild(_withFree);
			
			_withCredits = new StakeButtonCredit(this.advancedOwner.screenData.gameType);
			_withCredits.addEventListener(Event.TRIGGERED, onPlayWithCredits);
			addChild(_withCredits);
			
			if( advancedOwner.screenData.gameType == GameSession.TYPE_TOURNAMENT )
			{
				_withPoints = new StakeButtonPoint();
				_withPoints.addEventListener(Event.TRIGGERED, onPlayWithPoints);
				addChild(_withPoints);
			}
		}
		
		override protected function draw():void
		{
			if( isInvalid(INVALIDATION_FLAG_SIZE) )
			{
				if( AbstractGameInfo.LANDSCAPE )
				{
					_title.width = actualWidth;
					_title.validate();
					
					_withFree.width = _withCredits.width = actualWidth * (GlobalConfig.isPhone ? 0.55 : 0.35);
					if( _withPoints ) _withPoints.width = _withFree.width;
					
					_withFree.x = _withCredits.x = ((actualWidth - _withFree.width) * 0.5) << 0;
					if( _withPoints ) _withPoints.x = _withFree.x;
					
					_withFree.validate();
					
					_title.y = (actualHeight - (_title.height + scaleAndRoundToDpi(_withFree ? 40 : 140 ) + _withFree.height * (_withPoints ? 3 : 2))) * 0.5;
					
					_withFree.y = _title.y + _title.height + buttonGap + scaleAndRoundToDpi(_withFree ? 20 : 60);
					_withCredits.y = _withFree.y + _withFree.height + buttonGap + scaleAndRoundToDpi(_withFree ? 10 : 40);
					
					if( _withPoints )
						_withPoints.y = _withCredits.y + _withFree.height + buttonGap + scaleAndRoundToDpi(_withFree ? 10 : 40);
				}
				else
				{
					var buttonGap:int = scaleAndRoundToDpi(GlobalConfig.isPhone ? 30 : 40);
					var titleGap:int = scaleAndRoundToDpi(GlobalConfig.isPhone ? 50 : 60);
					
					// define width
					_title.width = actualWidth;
					_withFree.width = _withCredits.width = actualWidth * (GlobalConfig.isPhone ? 0.75 : 0.55);
					if( _withPoints ) _withPoints.width = _withFree.width;
					
					// then validate each element to calculate the title y position
					_withFree.validate();
					_title.validate();
					_title.y = ((actualHeight - (_title.height + (_withFree.height * (_withPoints ? 3 : 2)) + titleGap + (buttonGap * (_withPoints ? 1 : 2)))) * 0.5) << 0;
					
					_withFree.x = _withCredits.x = ((actualWidth - _withFree.width) * 0.5) << 0;
					if( _withPoints ) _withPoints.x = _withFree.x;
					_withFree.y = _title.y + _title.height + titleGap;
					_withFree.validate();
					
					_withCredits.y = _withFree.y + _withFree.height + buttonGap;
					
					if( _withPoints )
					{
						_withCredits.validate();
						_withPoints.y = _withCredits.y + _withCredits.height + buttonGap;
					}
				}
			}
		}
		
//------------------------------------------------------------------------------------------------------------
//	Handlers
//------------------------------------------------------------------------------------------------------------
		
		/**
		 * Play with points (tournament mode only).
		 * 
		 * <p>No verification is needed here because this listener is not set if
		 * the user doesn't have enough points.</p>
		 */		
		private function onPlayWithPoints(event:Event):void
		{
			this.advancedOwner.screenData.gamePrice = GameSession.PRICE_POINT;
			advancedOwner.dispatchEventWith(LudoEventType.ANIMATE_SUMMARY, false, { type:GameSession.PRICE_POINT, value:-Storage.getInstance().getProperty( StorageConfig.PROPERTY_NUM_POINTS_IN_TOURNAMENT_MODE ) })
			handleNextScreen();
		}
		
		/**
		 * Play with free game session.
		 * 
		 * <p>No verification is needed here because this listener is not set if
		 * the user doesn't have free game sessions left.</p>
		 */		
		private function onPlayWithFree(event:Event):void
		{
			this.advancedOwner.screenData.gamePrice = GameSession.PRICE_FREE;
			advancedOwner.dispatchEventWith(LudoEventType.ANIMATE_SUMMARY, false, { type:GameSession.PRICE_FREE, value:-Storage.getInstance().getProperty( this.advancedOwner.screenData.gameType == GameSession.TYPE_CLASSIC ? StorageConfig.PROPERTY_NUM_FREE_IN_FREE_MODE:StorageConfig.PROPERTY_NUM_FREE_IN_TOURNAMENT_MODE ) })
			handleNextScreen();
		}
		
		/**
		 * Play with credits.
		 * 
		 * <p>If the user doesn't have enough credits, he will be redirected
		 * to the store.</p>
		 */		
		private function onPlayWithCredits(event:Event):void
		{
			if( _withCredits.isEnabled )
			{
				this.advancedOwner.screenData.gamePrice = GameSession.PRICE_CREDIT;
				advancedOwner.dispatchEventWith(LudoEventType.ANIMATE_SUMMARY, false, { type:GameSession.PRICE_CREDIT, value:-Storage.getInstance().getProperty( this.advancedOwner.screenData.gameType == GameSession.TYPE_CLASSIC ? StorageConfig.PROPERTY_NUM_CREDITS_IN_FREE_MODE:StorageConfig.PROPERTY_NUM_CREDITS_IN_TOURNAMENT_MODE ) })
				handleNextScreen();
			}
			else
			{
				this.advancedOwner.showScreen( ScreenIds.STORE_SCREEN );
			}
		}
		
		private function handleNextScreen():void
		{
			_withCredits.touchable = false;
			if( _withPoints )
				_withPoints.touchable = false;
			_withFree.touchable = false;
			_canBack = false;
			
			TweenMax.delayedCall(2, changeScreen);
		}
		
		private function changeScreen():void
		{
			TweenMax.killAll();
			advancedOwner.showScreen( ScreenIds.GAME_SCREEN );
		}
		
//------------------------------------------------------------------------------------------------------------
//	Dispose
//------------------------------------------------------------------------------------------------------------
		
		override public function dispose():void
		{
			_title.removeFromParent(true);
			_title = null;
			
			if( _withPoints )
			{
				_withPoints.removeEventListener(Event.TRIGGERED, onPlayWithPoints);
				_withPoints.removeFromParent(true);
				_withPoints = null;
			}
			
			_withFree.removeEventListener(Event.TRIGGERED, onPlayWithFree);
			_withFree.removeFromParent(true);
			_withFree = null;
			
			_withCredits.removeEventListener(Event.TRIGGERED, onPlayWithCredits);
			_withCredits.removeFromParent(true);
			_withCredits = null;
			
			super.dispose();
		}
		
	}
}