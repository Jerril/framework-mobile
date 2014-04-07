/*
LudoFactory
Framework mobile
Author  : Maxime Lhoez
Created : 19 mars 2014
*/
package com.ludofactory.mobile.core
{
	/**
	 * Game info used in the framework.
	 * 
	 * <p>These values must be set in the function <code>setGameInfo</code> of the class
	 * <code>AbstractEntryPoint</code> when the application starts (this function must be
	 * overridden in the sublass).</p>
	 * 
	 * <p><strong>Remember that whenever you add a property here, it must be set in every
	 * <code>setGameInfo</code> of each application using the framework.</strong></p>
	 */	
	public class AbstractGameInfo
	{
//------------------------------------------------------------------------------------------------------------
//	Game informations
			
			/**
			 * Game version. */		
			public static var GAME_VERSION:String;
			/**
			 * Game bundle id (in reverse dns style). */		
			public static var GAME_BUNDLE_ID:String;
			/**
			 * Game name. */		
			public static var GAME_NAME:String;
			/**
			 * The game id in the database. */		
			public static var GAME_ID:int;
			
//------------------------------------------------------------------------------------------------------------
//	Tracking and logging
			
			/**
			 * The Flox id.
			 * 
			 * @see http://www.flox.cc */		
			public static var FLOX_ID:String;
			/**
			 * The Flox key.
			 * 
			 * @see http://www.flox.cc */		
			public static var FLOX_KEY:String;
			
			/**
			 * The Flox debug id.
			 * 
			 * @see http://www.flox.cc */		
			public static var FLOX_DEBUG_ID:String;
			/**
			 * The Flox debug key.
			 * 
			 * @see http://www.flox.cc */		
			public static var FLOX_DEBUG_KEY:String;
			
			/**
			 * The Google Analytics tracker id. */		
			public static var GOOGLE_ANALYTICS_TRACKER:String;
			
			/**
			 * HasOffers (MobileAppTracking) advertiser id. */		
			public static var HAS_OFFERS_ADVERTISER_ID:String;
			
			/**
			 * HasOffers (MobileAppTracking) conversion key. */		
			public static var HAS_OFFERS_CONVERSION_KEY:String;
			
//------------------------------------------------------------------------------------------------------------
//	Google Play and Facebook
			
			/**
			 * This is the prefix used by <code>StoreData</code> to build the
			 * correct product id registered in both Google Play and iTunes
			 * Connect. The dot after the prefix is automatically added in
			 * StoreData.
			 * 
			 * <p>Note that there is nothing to do in Php side, because the
			 * offer is only linked with the number id, not the full id
			 * registered in both Google Play and iTunes Connect.</p>
			 * 
			 * @see com.ludofactory.mobile.store.StoreData */		
			public static var PRODUCT_ID_PREFIX:String;
			
			/**
			 * The unique google play license key for this application.
			 * 
			 * <p>This license key is used by the store to make puchases.</p>*/		
			public static var GOOGLE_PLAY_ID:String;
			
			/**
			 * The Google Cloud Messaging sender ID.
			 * 
			 * <p>Can be found here : https://cloud.google.com/console/project</p>
			 * 
			 * See : http://developer.android.com/google/gcm/gs.html */		
			public static var GCM_SENDER_ID:String;
			
			/**
			 * The is the Facebook application id used for the SSO. */		
			public static var FACEBOOK_APP_ID:String;
			/**
			 * The required Facebook permissions
			 *  user_games_activity,friends_games_activity = all apps - not necessary for current app 
			 * publish_actions : doit être demandé plus tard (on ne peut pas inclure des autorisation
			 * read et publish au login. */		
			public static var FACEBOOK_PERMISSIONS:String;
			
//------------------------------------------------------------------------------------------------------------
//	Game Center
			
			/**
			 * Pyramid High Scores leaderboard (Game Center). */		
			public static var LEADERBOARD_HIGHSCORE:String;
			
//------------------------------------------------------------------------------------------------------------
//	AdMob
			
			/**
			 * AdMob interstital unit id on Android.
			 */		
			public static var ADMOB_ANDROID_INTERSTITIAL_ID:String;
			
			/**
			 * AdMob interstitial unit id on iOS.
			 */		
			public static var ADMOB_IOS_INTERSTITIAL_ID:String;
			
			/**
			 * AdMob default unit id used to display banners on Android.
			 * 
			 * <p>The default banner is always the one displayed on top
			 * of the screen when the game is paused.</p>
			 */		
			public static var ADMOB_ANDROID_DEFAULT_BANNER_UNIT_ID:String;
			
			/**
			 * AdMob default unit id used to display banners on iOS.
			 * 
			 * <p>The default banner is always the one displayed on top
			 * of the screen when the game is paused.</p>
			 */		
			public static var ADMOB_IOS_DEFAULT_BANNER_UNIT_ID:String;
	}
}