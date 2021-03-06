/*
Copyright © 2006-2015 Ludo Factory - http://www.ludokado.com/
Framework mobile
Author  : Maxime Lhoez
Created : 27 mai 2013
*/
package com.ludofactory.mobile.navigation.ads
{
	
	import com.freshplanet.nativeExtensions.AirNetworkInfo;
	import com.ludofactory.common.utils.logs.log;
	import com.ludofactory.mobile.core.AbstractGameInfo;
	import com.ludofactory.mobile.core.manager.TimerManager;
	import com.milkmangames.nativeextensions.AdMob;
	import com.milkmangames.nativeextensions.AdMobAdType;
	import com.milkmangames.nativeextensions.AdMobAlignment;
	import com.milkmangames.nativeextensions.events.AdMobErrorEvent;
	import com.milkmangames.nativeextensions.events.AdMobEvent;
	import com.milkmangames.nativeextensions.ios.IAd;
	import com.milkmangames.nativeextensions.ios.IAdBannerAlignment;
	import com.milkmangames.nativeextensions.ios.IAdContentSize;
	import com.milkmangames.nativeextensions.ios.events.IAdErrorEvent;
	import com.milkmangames.nativeextensions.ios.events.IAdEvent;
	
	/**
	 * This is the main ad manager. It handles both iAd and AdMob networks so that both
	 * are easily working no matter if you are on iOS or Android. When no iAd is available
	 * (banner or interstitial), the AdManager fallback to the AdMob network which have a 
	 * much higher fillrate (but a lower eCPM).
	 * 
	 * <p><strong>Banners best pratice :</strong>
	 * <ul>
	 * <li>Create banners when the game starts and set visibility to false.</li>
	 * <li>Switch visibility instead of creating / destroying ads each time the pause menu is shown.</li>
	 * <li>When the game ends, destroy ads.</li>
	 * </ul></p>
	 */	
	public class AdManager
	{
		/**
		 * Whether iAd is available. */		
		private static var _iAdAvailable:Boolean = false;
		
		/**
		 * Whether AdMob is available. */		
		private static var _adMobAvailable:Boolean = false;
		
		private static var _timeriAd:TimerManager;
		private static var _timerAdMob:TimerManager;
		
		/**
		 * Initializes both iAd and adMob ad networks.
		 * 
		 * <p>If iAd is available and if we are on an iPad, an interstitial
		 * will be preloaded so that be can quickly show it when needed.</p>
		 * 
		 * <p>If AdMob is available, it will be initialized for both Android
		 * and iOS devices.</p>
		 */		
		public static function initialize():void
		{
			if( IAd.isSupported() )
			{
				IAd.create();
				if( !IAd.iAd.isIAdAvailable() )
				{
					IAd.iAd.dispose();
				}
				else
				{
					// preload interstitial if possible (only available on iPad)
					if( IAd.iAd.isInterstitialAvailable() )
					{
						IAd.iAd.addEventListener(IAdEvent.INTERSTITIAL_SHOWN, oniAdInterstitalShown);
						IAd.iAd.addEventListener(IAdEvent.INTERSTITITAL_DISMISSED, oniAdInterstitalDismissed);
						//IAd.iAd.addEventListener(IAdEvent.INTERSTITIAL_AD_UNLOADED, onInterstitalAdDismissed); // useless ?
						IAd.iAd.addEventListener(IAdEvent.INTERSTITIAL_AD_LOADED, oniAdInterstitialLoaded);
						IAd.iAd.addEventListener(IAdErrorEvent.INTERSTITIAL_AD_FAILED, oniAdInterstitalFailed);
						
						_timeriAd = new TimerManager(6, -1, null, onReloadiAdInterstitial, null);
						if( AirNetworkInfo.networkInfo.isConnected() )
						{
							IAd.iAd.loadInterstitial(false);
						}
						else
						{
							_timeriAd.restart();
						}
						
					}
					_iAdAvailable = true;
				}
			}
			
			// initialize AdMob network on both iOS and Android devices
			if( AdMob.isSupported )
			{
				AdMob.init(AbstractGameInfo.ADMOB_ANDROID_DEFAULT_BANNER_UNIT_ID, AbstractGameInfo.ADMOB_IOS_DEFAULT_BANNER_UNIT_ID);
				// setup test devices to avoid making impressions while testing
				if( CONFIG::DEBUG )
					AdMob.enableTestDeviceIDs(AdMob.getCurrentTestDeviceIDs());
				
				// preload interstitials for both plateforms
				AdMob.addEventListener(AdMobEvent.SCREEN_PRESENTED, onAdMobInterstitialShown);
				AdMob.addEventListener(AdMobEvent.SCREEN_DISMISSED, onAdMobInterstitalDismissed);
				AdMob.addEventListener(AdMobEvent.RECEIVED_AD, onAdMobInterstitialLoaded);
				AdMob.addEventListener(AdMobErrorEvent.FAILED_TO_RECEIVE_AD, onAdMobInterstitialFailed);
				
				_timerAdMob = new TimerManager(6, -1, null, onReloadAdMobInterstitial, null);
				if( AirNetworkInfo.networkInfo.isConnected() )
				{
					AdMob.loadInterstitial(AbstractGameInfo.ADMOB_ANDROID_INTERSTITIAL_ID, false, AbstractGameInfo.ADMOB_IOS_INTERSTITIAL_ID);
				}
				else
				{
					_timerAdMob.restart();
				}
				

				_adMobAvailable = true;
			}
		}
		
//------------------------------------------------------------------------------------------------------------
//	iAd and AdMob Banners
		
		/**
		 * Creates an iAd banner and sets its visibility.
		 * 
		 * @param vAlign Banner vertical alignment (use IAdBannerAlignment)
		 * @param autoShow Whether the banner should be automatically shown.
		 * @param offsetY Banner Y offset.
		 */		
		public static function createiAdBanner(vAlign:String = IAdBannerAlignment.TOP, visible:Boolean = false, animate:Boolean = false, offsetY:Number = 0):void
		{
			if( _iAdAvailable )
				IAd.iAd.createBannerAd(vAlign, IAdContentSize.PORTRAIT_AND_LANDSCAPE, offsetY);
			setiAdBannerVisibility(visible, animate);
		}
		
		/**
		 * Shows an AdMob banner.
		 * 
		 * @param hAlign Banner horizontal alignment (use AdMobAlignment).
		 * @param valign Banner vertical alignment (use AdMobAlignment).
		 * @param offsetX Banner X offset.
		 * @param offsetY Banner Y offset.
		 * @param customAndroidBannerUnitId Custom banner unit id for Android (if multiple banners are defined).
		 * @param customiOSBannerUnitId Custom banner unit id for iOS (if multiple banners are defined).
		 */		
		public static function crateAdMobBanner(hAlign:String = AdMobAlignment.CENTER, vAlign:String = AdMobAlignment.TOP, visible:Boolean = false, offsetX:Number = 0, offsetY:Number = 0, customAndroidBannerUnitId:String = null, customiOSBannerUnitId:String = null):void
		{
			if( _adMobAvailable )
			{
				// change the current banner unit ids for both iOS and Android if necessary.
				// It is useful when multiple banners have been defined on the AdMob interface.
				if( customAndroidBannerUnitId && customiOSBannerUnitId )
					AdMob.setBannerAdUnitID(customAndroidBannerUnitId, customiOSBannerUnitId);
				AdMob.showAd(AdMobAdType.SMART_BANNER, hAlign, vAlign, offsetX, offsetY);
				setAdMobBannerVisibility(visible);
			}
		}
		
//------------------------------------------------------------------------------------------------------------
//	Interstitials
		
		/**
		 * Shows an interstitial ad.
		 * 
		 * If iAd is available, we first try to display an iAd interstitial. If no interstitial
		 * can be retreived, we try to load an AdMob interstitial instead.
		 * 
		 * If iAd is not available but AdMob is, we display an AdMob interstitial directly.
		 * 
		 * @return true if there is network, false otherwise
		 * 
		 */		
		public static function showInterstitial():Boolean
		{
			if( _iAdAvailable && IAd.iAd.isInterstitialAvailable() )
			{
				if(IAd.iAd.isInterstitialReady())
				{
					IAd.iAd.showPendingInterstitial();
					return true;
				}
				
			}
			
			if( _adMobAvailable )
			{
				if( AdMob.isInterstitialReady() )
				{
					AdMob.showPendingInterstitial();
					return true;
				}
			}
			
			return false;
		}
		
//------------------------------------------------------------------------------------------------------------
//	Chnage banners visibility
		
		/**
		 * Changes the visibility of all banners (both AdMob and iAd banners).
		 */		
		public static function setBannersVisibility(visible:Boolean, animate:Boolean = false):void
		{
			setiAdBannerVisibility(visible, animate);
			setAdMobBannerVisibility(visible);
		}
		
		/**
		 * Changes the visibility of iAd banners.
		 * 
		 * @param visible Whether the banner should be visible.
		 * @param animate Whether the banner is animated.
		 */		
		public static function setiAdBannerVisibility(visible:Boolean, animate:Boolean = false):void
		{
			if( _iAdAvailable )
			{
				try
				{
					IAd.iAd.setBannerVisibility(visible, animate);
				} 
				catch(err:Error)
				{
					// probably no banner currently created and/or visible
				}
			}
		}
		
		/**
		 * Changes the visibility of AdMob banners.
		 * 
		 * @param visible Whether the banner should be visible.
		 */		
		public static function setAdMobBannerVisibility(visible:Boolean):void
		{
			if( _adMobAvailable )
			{
				try
				{
					AdMob.setVisibility(visible);
				} 
				catch(err:Error)
				{
					// probably no banner currently created and/or visible
				}
			}
		}
		
//------------------------------------------------------------------------------------------------------------
//	Events
		
	// Interstitial loaded
		
		/**
		 * When the interstitial have been loaded and now ready to display.
		 */
		public static function oniAdInterstitialLoaded(event:IAdEvent):void
		{
			_timeriAd.stop();
			log("[AdManager] iAd interstitial loaded.");
		}
		
		/**
		 * When the interstitial have been loaded and now ready to display.
		 */
		public static function onAdMobInterstitialLoaded(event:AdMobEvent):void
		{
			if(event.isInterstitial)
			{
				_timerAdMob.stop();
				log("[AdManager] AdMob interstitial loaded.");
			}
		}
		
	// Interstitial dismissed
		
		/**
		 * When the interstitial was dismissed by the user. In this case we can load another one for the next time.
		 */
		public static function oniAdInterstitalDismissed(event:IAdEvent):void
		{
			log("[AdManager] iAd interstitial dismissed.");
			
			// interstitial dismissed, so we can load another one for the next time
			try
			{
				_timeriAd.stop();
				IAd.iAd.loadInterstitial(false);
			}
			catch (e:Error)
			{
				trace("[AdManager] Can't preload iAd interstitial again yet.");
			}
		}
		
		/**
		 * When the interstitial was dismissed by the user. In this case we can load another one for the next time.
		 */
		public static function onAdMobInterstitalDismissed(event:AdMobEvent):void
		{
			log("[AdManager] AdMob interstitial dismissed.");
			
			// interstitial dismissed, so we can load another one for the next time
			try
			{
				_timerAdMob.stop();
				AdMob.loadInterstitial(AbstractGameInfo.ADMOB_ANDROID_INTERSTITIAL_ID, false, AbstractGameInfo.ADMOB_IOS_INTERSTITIAL_ID);
			}
			catch (e:Error)
			{
				trace("[AdManager] Can't preload AdMob interstitial again yet.");
			}
		}
		
	// Interstitial shown
		
		/**
		 * The interstitial was successfully shown.
		 */
		public static function oniAdInterstitalShown(event:IAdEvent):void
		{
			_timeriAd.stop();
			log("[AdManager] Showing iAd interstitial.");
		}
		
		/**
		 * The interstitial was successfully shown.
		 */
		public static function onAdMobInterstitialShown(event:AdMobEvent):void
		{
			_timerAdMob.stop();
			log("[AdManager] Showing AdMob interstitial.");
		}
		
	// Interstitial failed
		
		/**
		 * When the interstitial failed to load. In this case we try to load another one.
		 */
		public static function oniAdInterstitalFailed(event:IAdErrorEvent):void
		{
			log("[AdManager] iAd interstitial failed to load.");
			
			// interstitial failed to load, so we can load another one for the next time
			try
			{
				if( AirNetworkInfo.networkInfo.isConnected() )
				{
					_timeriAd.stop();
					IAd.iAd.loadInterstitial(false);
				}
				else
				{
					_timeriAd.restart();
				}
			}
			catch (e:Error)
			{
				trace("[AdManager] Can't preload iAd again yet.");
			}
		}
		
		public static function onReloadiAdInterstitial():void
		{
			trace("[AdManager] Reload iAd interstitial from timer callback.");
			try
			{
				if( AirNetworkInfo.networkInfo.isConnected() )
				{
					_timeriAd.stop();
					IAd.iAd.loadInterstitial(false);
				}
			}
			catch (e:Error)
			{
				trace("[AdManager] Can't preload iAd again yet.");
			}
		}
		
		/**
		 * When the interstitial failed to load. In this case we try to load another one.
		 */
		public static function onAdMobInterstitialFailed(event:AdMobErrorEvent):void
		{
			log("[AdManager] AdMob interstitial failed to load.");
			
			// interstitial failed to load, so we can load another one for the next time
			try
			{
				if( AirNetworkInfo.networkInfo.isConnected() )
				{
					_timerAdMob.stop();
					AdMob.loadInterstitial(AbstractGameInfo.ADMOB_ANDROID_INTERSTITIAL_ID, false, AbstractGameInfo.ADMOB_IOS_INTERSTITIAL_ID);
				}
				else
				{
					_timerAdMob.restart();
				}
			}
			catch (e:Error)
			{
				trace("[AdManager] Can't preload AdMob interstitial again yet.");
			}
		}
		
		public static function onReloadAdMobInterstitial():void
		{
			log("[AdManager] Reload AdMob interstitial from timer callback.");
			try
			{
				if( AirNetworkInfo.networkInfo.isConnected() )
				{
					_timerAdMob.stop();
					AdMob.loadInterstitial(AbstractGameInfo.ADMOB_ANDROID_INTERSTITIAL_ID, false, AbstractGameInfo.ADMOB_IOS_INTERSTITIAL_ID);
				}
			}
			catch (e:Error)
			{
				trace("[AdManager] Can't preload AdMob interstitial again yet.");
			}
		}
		
//------------------------------------------------------------------------------------------------------------
//	Dispose banners
		
		/**
		 * Dispose all banners.
		 */		
		public static function disposeBanners():void
		{
			if( _iAdAvailable )
			{
				try
				{
					IAd.iAd.destroyBannerAd();
				} 
				catch(err:Error)
				{
					// probably no banner currently created and/or visible
				}
			}
			
			if( _adMobAvailable )
			{
				try
				{
					AdMob.destroyAd()
				} 
				catch(err:Error)
				{
					// probably no banner currently created and/or visible
				}
			}
		}
	}
}