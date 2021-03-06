/*
Copyright © 2006-2015 Ludo Factory - http://www.ludokado.com/
Framework mobile
Author  : Maxime Lhoez
Created : 23 août 2013
*/
package com.ludofactory.mobile.navigation.shop.bid
{
	
	import com.gamua.flox.Flox;
	import com.ludofactory.common.gettext.aliases._;
	import com.ludofactory.common.utils.roundUp;
	import com.ludofactory.common.utils.scaleAndRoundToDpi;
	import com.ludofactory.mobile.core.AbstractEntryPoint;
	import com.ludofactory.mobile.core.AbstractGameInfo;
	import com.ludofactory.mobile.core.config.GlobalConfig;
	import com.ludofactory.mobile.core.controls.AdvancedScreen;
	import com.ludofactory.mobile.core.controls.OffsetTabBar;
	import com.ludofactory.mobile.core.manager.MemberManager;
	import com.ludofactory.mobile.core.notification.NotificationPopupManager;
	import com.ludofactory.mobile.core.notification.content.ComingSoonBidDetailNotificationContent;
	import com.ludofactory.mobile.core.notification.content.FinishedBidDetailNotificationContent;
	import com.ludofactory.mobile.core.notification.content.PendingBidDetailNotificationContent;
	import com.ludofactory.mobile.core.theme.Theme;
	import com.ludofactory.mobile.navigation.shop.bid.comingsoon.ComingSoonBidContainer;
	import com.ludofactory.mobile.navigation.shop.bid.comingsoon.ComingSoonBidItemData;
	import com.ludofactory.mobile.navigation.shop.bid.finished.FinishedBidContainer;
	import com.ludofactory.mobile.navigation.shop.bid.finished.FinishedBidItemData;
	import com.ludofactory.mobile.navigation.shop.bid.pending.PendingBidContainer;
	import com.ludofactory.mobile.navigation.shop.bid.pending.PendingBidItemData;
	import com.milkmangames.nativeextensions.GAnalytics;
	
	import feathers.data.ListCollection;
	import feathers.display.TiledImage;
	
	import starling.events.Event;
	import starling.text.TextField;
	
	public class BidHomeScreen extends AdvancedScreen
	{
		/**
		 * Message */		
		private var _message:TextField;
		
		/**
		 * Menu */		
		private var _bidsMenu:OffsetTabBar;
		
		/**
		 * The list tiled background */		
		private var _listBackground:TiledImage;
		
		/**
		 * Pending bids displayed by default in the first tab */		
		private var _pendingBidsContainer:PendingBidContainer;
		
		/**
		 * Finished bids displayed in the second tab */		
		private var _finishedBidsContainer:FinishedBidContainer;
		
		/**
		 * Coming soon bids displayed in the third tab */		
		private var _comingSoonBidsContainer:ComingSoonBidContainer;
		
		public function BidHomeScreen()
		{
			super();
			
			_fullScreen = false;
			_appClearBackground = false;
			_whiteBackground = true;
		}
		
		override protected function initialize():void
		{
			super.initialize();
			
			_message = new TextField(10, scaleAndRoundToDpi(GlobalConfig.isPhone ? 100 : 200), _("Utilisez vos Points pour enchérir et\nremporter un des lots en jeu."), Theme.FONT_SANSITA, scaleAndRoundToDpi(GlobalConfig.isPhone ? 40 : 60), Theme.COLOR_DARK_GREY);
			_message.autoScale = true;
			addChild(_message);
			
			_bidsMenu = new OffsetTabBar();
			_bidsMenu.dataProvider = new ListCollection( [ _("En cours"),
													       _("Terminées"),
													       _("A venir") ] );
			_bidsMenu.addEventListener(Event.CHANGE, onChangeTab);
			addChild(_bidsMenu);
			
			_listBackground = new TiledImage(AbstractEntryPoint.assets.getTexture("MenuTile"), GlobalConfig.dpiScale);
			addChild(_listBackground);
			
			_pendingBidsContainer = new PendingBidContainer();
			_pendingBidsContainer.addEventListener(Event.CHANGE, onPendingBidSelected);
			addChild(_pendingBidsContainer);
		}
		
		override protected function draw():void
		{
			if( isInvalid(INVALIDATION_FLAG_SIZE) )
			{
				_message.y = roundUp(scaleAndRoundToDpi(GlobalConfig.isPhone ? (AbstractGameInfo.LANDSCAPE ? 5 : 10) : (AbstractGameInfo.LANDSCAPE ? 15 : 30)));
				_message.width = roundUp(actualWidth * 0.9);
				_message.x = roundUp((actualWidth - _message.width) * 0.5);
				
				_bidsMenu.width = actualWidth;
				_bidsMenu.y = _message.y + _message.height + scaleAndRoundToDpi(GlobalConfig.isPhone ? (AbstractGameInfo.LANDSCAPE ? 10 : 20) : (AbstractGameInfo.LANDSCAPE ? 20 : 40));
				_bidsMenu.validate();
				
				_pendingBidsContainer.y = _listBackground.y = _bidsMenu.y + _bidsMenu.height;
				_pendingBidsContainer.width = _listBackground.width = actualWidth;
				_pendingBidsContainer.height = _listBackground.height = actualHeight - _pendingBidsContainer.y;
			}
			
			super.draw();
		}
		
		private function layoutFinishedEncheresContainer():void
		{
			_finishedBidsContainer.width = _pendingBidsContainer.width;
			_finishedBidsContainer.height = _pendingBidsContainer.height;
			_finishedBidsContainer.y = _pendingBidsContainer.y;
		}
		
		private function layoutComingSoonBidContainer():void
		{
			_comingSoonBidsContainer.width = _pendingBidsContainer.width;
			_comingSoonBidsContainer.height = _pendingBidsContainer.height;
			_comingSoonBidsContainer.y = _pendingBidsContainer.y;
		}
		
//------------------------------------------------------------------------------------------------------------
//	Handlers
//------------------------------------------------------------------------------------------------------------
		
		/**
		 * When the user change tab.
		 */		
		private function onChangeTab(event:Event):void
		{
			switch(_bidsMenu.selectedIndex)
			{
				case 0:
				{
					_pendingBidsContainer.visible = true;
					
					if( _finishedBidsContainer )
						_finishedBidsContainer.visible = false;
					
					if( _comingSoonBidsContainer )
						_comingSoonBidsContainer.visible = false;
					
					if( GAnalytics.isSupported() )
						GAnalytics.analytics.defaultTracker.trackEvent("Enchères", "Enchères en cours", null, NaN, MemberManager.getInstance().id);
					
					break;
				}
				case 1:
				{
					_pendingBidsContainer.visible = false;
					
					if( _comingSoonBidsContainer )
						_comingSoonBidsContainer.visible = false;
					
					if( !_finishedBidsContainer )
					{
						_finishedBidsContainer = new FinishedBidContainer();
						_finishedBidsContainer.addEventListener(Event.CHANGE, onFinishedBidSelected);
						addChild(_finishedBidsContainer);
						layoutFinishedEncheresContainer();
					}
					_finishedBidsContainer.visible = true;
					
					if( GAnalytics.isSupported() )
						GAnalytics.analytics.defaultTracker.trackEvent("Enchères", "Enchères terminées", null, NaN, MemberManager.getInstance().id);
					
					break;
				}
				case 2:
				{
					_pendingBidsContainer.visible = false;
					
					if( _finishedBidsContainer )
						_finishedBidsContainer.visible = false;
					
					if( !_comingSoonBidsContainer )
					{
						_comingSoonBidsContainer = new ComingSoonBidContainer();
						_comingSoonBidsContainer.addEventListener(Event.CHANGE, onComingSoonBidSelected);
						addChild(_comingSoonBidsContainer);
						layoutComingSoonBidContainer();
					}
					_comingSoonBidsContainer.visible = true;
					
					if( GAnalytics.isSupported() )
						GAnalytics.analytics.defaultTracker.trackEvent("Enchères", "Enchères à venir", null, NaN, MemberManager.getInstance().id);
					
					break;
				}
			}
		}
		
		/**
		 * When a pending bid is selected.
		 */		
		private function onPendingBidSelected(event:Event):void
		{
			Flox.logInfo("Affichage de l'enchère en cours <strong>{0} - {1}</strong>", PendingBidItemData(event.data).id, PendingBidItemData(event.data).name);
			//NotificationManager.addNotification( new PendingBidDetailNotification( PendingBidItemData(event.data) ), onClosePendingBidDetailNotification, false );
			if( GAnalytics.isSupported() )
				GAnalytics.analytics.defaultTracker.trackEvent("Enchères", "Affichage de l'enchère en cours " + PendingBidItemData(event.data).id + " - " + PendingBidItemData(event.data).name, null, NaN, MemberManager.getInstance().id);
			NotificationPopupManager.addNotification( new PendingBidDetailNotificationContent(PendingBidItemData(event.data)), onClosePendingBidDetailNotification);
		}
		
		/**
		 * When the user closes the notification. We will check if we need
		 * to refresh the list or not (if he made a bid, the data is obsolet
		 * so we need to refresh the data).
		 */		
		private function onClosePendingBidDetailNotification(data:Object):void
		{
			if( data )
				_pendingBidsContainer.refreshList();
		}
		
		/**
		 * When a finished bid is selected.
		 */		
		private function onFinishedBidSelected(event:Event):void
		{
			Flox.logInfo("Affichage de l'enchère terminée <strong>{0} - {1}</strong>", FinishedBidItemData(event.data).name, FinishedBidItemData(event.data).winnerName);
			//NotificationManager.addNotification( new FinishedBidDetailNotification( FinishedBidItemData(event.data) ) );
			if( GAnalytics.isSupported() )
				GAnalytics.analytics.defaultTracker.trackEvent("Enchères", "Affichage de l'enchère terminée " + FinishedBidItemData(event.data).name + " - " + FinishedBidItemData(event.data).winnerName, null, NaN, MemberManager.getInstance().id);
			NotificationPopupManager.addNotification( new FinishedBidDetailNotificationContent( FinishedBidItemData(event.data) ) );
		}
		
		/**
		 * When a coming soon bid is selected
		 */		
		private function onComingSoonBidSelected(event:Event):void
		{
			Flox.logInfo("Affichage de l'enchère à venir <strong>{0}</strong>", ComingSoonBidItemData(event.data).description);
			//NotificationManager.addNotification( new ComingSoonBidDetailNotification( ComingSoonBidItemData(event.data) ) );
			if( GAnalytics.isSupported() )
				GAnalytics.analytics.defaultTracker.trackEvent("Enchères", "Affichage de l'enchère à venir " + ComingSoonBidItemData(event.data).description, null, NaN, MemberManager.getInstance().id);
			NotificationPopupManager.addNotification( new ComingSoonBidDetailNotificationContent( ComingSoonBidItemData(event.data) ) );
		}
		
//------------------------------------------------------------------------------------------------------------
//	Dispose
//------------------------------------------------------------------------------------------------------------
		
		override public function dispose():void
		{
			_listBackground.removeFromParent(true);
			_listBackground = null;
			
			_message.removeFromParent(true);
			_message = null;
			
			_bidsMenu.removeEventListener(Event.CHANGE, onChangeTab);
			_bidsMenu.removeFromParent(true);
			_bidsMenu = null;
			
			_pendingBidsContainer.removeEventListener(Event.CHANGE, onPendingBidSelected);
			_pendingBidsContainer.removeFromParent(true);
			_pendingBidsContainer = null;
			
			if( _finishedBidsContainer )
			{
				_finishedBidsContainer.removeEventListener(Event.CHANGE, onFinishedBidSelected);
				_finishedBidsContainer.removeFromParent(true);
				_finishedBidsContainer = null;
			}
			
			if( _comingSoonBidsContainer )
			{
				_comingSoonBidsContainer.removeEventListener(Event.CHANGE, onComingSoonBidSelected);
				_comingSoonBidsContainer.removeFromParent(true);
				_comingSoonBidsContainer = null;
			}
			
			super.dispose();
		}
	}
}