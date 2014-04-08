/*
Copyright © 2006-2014 Ludo Factory
Framework mobile
Author  : Maxime Lhoez
Created : 31 août 2013
*/
package com.ludofactory.mobile.core
{
	import com.freshplanet.nativeExtensions.AirNetworkInfo;
	import com.gamua.flox.Flox;
	import com.ludofactory.common.utils.Utility;
	import com.ludofactory.common.utils.log;
	import com.ludofactory.common.utils.scaleAndRoundToDpi;
	import com.ludofactory.mobile.core.authentication.MemberManager;
	import com.ludofactory.mobile.core.controls.AdvancedScreen;
	import com.ludofactory.mobile.core.controls.ScreenIds;
	import com.ludofactory.mobile.core.events.LudoEventType;
	import com.ludofactory.mobile.core.manager.InfoContent;
	import com.ludofactory.mobile.core.manager.InfoManager;
	import com.ludofactory.mobile.core.remoting.Remote;
	import com.ludofactory.mobile.core.scoring.ScoreConverter;
	import com.ludofactory.mobile.core.storage.Storage;
	import com.ludofactory.mobile.core.storage.StorageConfig;
	import com.ludofactory.mobile.core.test.achievements.GameCenterManager;
	import com.ludofactory.mobile.core.test.achievements.TrophyManager;
	import com.ludofactory.mobile.core.test.ads.AdManager;
	import com.ludofactory.mobile.core.test.config.GlobalConfig;
	import com.ludofactory.mobile.core.test.pause.PauseManager;
	import com.ludofactory.mobile.core.test.push.GameSession;
	import com.ludofactory.mobile.core.test.push.PushType;
	import com.ludofactory.mobile.core.theme.Theme;
	import com.milkmangames.nativeextensions.ios.IAdBannerAlignment;
	
	import flash.display.StageAspectRatio;
	import flash.events.Event;
	import flash.filesystem.File;
	
	import feathers.controls.Button;
	
	import starling.core.Starling;
	import starling.display.Image;
	import starling.display.MovieClip;
	import starling.events.Event;
	
	/**
	 * AbstractGame
	 */	
	public class AbstractGame extends AdvancedScreen implements IGame
	{
		/**
		 * The game session. */		
		private var _gameSession:GameSession;
		
		/**
		 * Loader */		
		private var _loader:MovieClip;
		
		/**
		 * The transparent black overlay. */		
		protected var _playOverlay:Image;
		/**
		 * The play button displayed at the begining of a game session. */		
		protected var _playButton:Button;
		
		private var _nextScreenId:String;
		
		/**
		 * Whether the player gave up this game session. */		
		private var _gaveUp:Boolean;
		
		/**
		 * Whether the screen is validating. This is added for security reason
		 * in order to avoird multiple validations.
		 */		
		private var _isValidatingGame:Boolean = false;
		
		/**
		 * @param isLandscape
		 */		
		public function AbstractGame(isLandscape:Boolean)
		{
			super();
			
			_fullScreen = true;
			_isLandscape = isLandscape;
			_canBack = false;
			_gaveUp = false;
		}
		
		override protected function initialize():void
		{
			super.initialize();
			
			// We need to check first if the user can really play, this case can can happen if the user played
			// while being logged out and at the end of the game, he chooses to play again and then logged in
			// but the account didn't have enought free game sessions points or credits.
			switch( advancedOwner.screenData.gamePrice )
			{
				case GameSession.PRICE_FREE:
				{
					if( MemberManager.getInstance().getNumFreeGameSessions() < Storage.getInstance().getProperty( advancedOwner.screenData.gameType == GameSession.TYPE_CLASSIC ? StorageConfig.PROPERTY_NUM_FREE_IN_FREE_MODE:StorageConfig.PROPERTY_NUM_FREE_IN_TOURNAMENT_MODE ) )
					{
						advancedOwner.screenData.purgeData();
						advancedOwner.showScreen( ScreenIds.HOME_SCREEN );
						return;
					}
					else
					{
						// he can play with free game sessions
						MemberManager.getInstance().setNumFreeGameSessions( MemberManager.getInstance().getNumFreeGameSessions() - Storage.getInstance().getProperty( advancedOwner.screenData.gameType == GameSession.TYPE_CLASSIC ? StorageConfig.PROPERTY_NUM_FREE_IN_FREE_MODE:StorageConfig.PROPERTY_NUM_FREE_IN_TOURNAMENT_MODE ) );
					}
					break;
				}
				case GameSession.PRICE_CREDIT:
				{
					if( MemberManager.getInstance().getCredits() < Storage.getInstance().getProperty( advancedOwner.screenData.gameType == GameSession.TYPE_CLASSIC ? StorageConfig.PROPERTY_NUM_CREDITS_IN_FREE_MODE:StorageConfig.PROPERTY_NUM_CREDITS_IN_TOURNAMENT_MODE ) )
					{
						advancedOwner.screenData.purgeData();
						advancedOwner.showScreen( ScreenIds.HOME_SCREEN );
						return;
					}
					else
					{
						// he can play with credits
						MemberManager.getInstance().setCredits( MemberManager.getInstance().getCredits() - Storage.getInstance().getProperty( advancedOwner.screenData.gameType == GameSession.TYPE_CLASSIC ? StorageConfig.PROPERTY_NUM_CREDITS_IN_FREE_MODE:StorageConfig.PROPERTY_NUM_CREDITS_IN_TOURNAMENT_MODE ) );
					}
					break;
				}
				case GameSession.PRICE_POINT:
				{
					if( MemberManager.getInstance().getPoints() < Storage.getInstance().getProperty( StorageConfig.PROPERTY_NUM_POINTS_IN_TOURNAMENT_MODE ) )
					{
						advancedOwner.screenData.purgeData();
						advancedOwner.showScreen( ScreenIds.HOME_SCREEN );
						return;
					}
					else
					{
						// he can play with points
						MemberManager.getInstance().setPoints( MemberManager.getInstance().getPoints() - Storage.getInstance().getProperty( StorageConfig.PROPERTY_NUM_POINTS_IN_TOURNAMENT_MODE ) );
					}
					break;
				}
			}
			
			// if the user can really play, we now initialize a game session which will be saved until the
			// end of the game and we decrement the associated stake (whether free game sessions, points or credits).
			log("Démarrage d'une partie en mode <strong>" + advancedOwner.screenData.gameType + ", mise : " + advancedOwner.screenData.gamePrice + "</strong>");
			Flox.logEvent("Parties", { "1. Nombre total de parties":"Total", "2. Mode":(advancedOwner.screenData.gameType == GameSession.TYPE_CLASSIC ? "Classique":"Tournoi"), "3. Mise":advancedOwner.screenData.gamePrice });
			
			// create banners in order to display them faster when the game is paused
			AdManager.createiAdBanner(IAdBannerAlignment.BOTTOM);
			AdManager.crateAdMobBanner();
			
			advancedOwner.screenData.displayPopupOnHome = false;
			
			// disable the push manager while playing
			AbstractEntryPoint.pushManager.isEnabled = false;
			_gameSession = new GameSession(PushType.GAME_SESSION, advancedOwner.screenData.gameType, advancedOwner.screenData.gamePrice );
			
			TrophyManager.getInstance().currentGameSession = _gameSession;
			
			if( MemberManager.getInstance().isLoggedIn() )
			{
				AbstractEntryPoint.pushManager.addElementToPush( _gameSession );
			}
			else
			{
				MemberManager.getInstance().getAnonymousGameSessions().push( _gameSession );
				MemberManager.getInstance().setAnonymousGameSessions( MemberManager.getInstance().getAnonymousGameSessions() );
			}
			
			if( _isLandscape )
			{
				Starling.current.nativeStage.addEventListener(flash.events.Event.RESIZE, onOrientationChanged, false, int.MAX_VALUE, true);
				Starling.current.nativeStage.setAspectRatio(StageAspectRatio.LANDSCAPE);
			}
			else
			{
				initializeGame();
			}
		}
		
		private function onOrientationChanged(event:flash.events.Event):void
		{
			Starling.current.nativeStage.removeEventListener(flash.events.Event.RESIZE, onOrientationChanged, false);
			initializeGame();
		}
		
		/**
		 * The application has finished resizing, we can start loading all the assets for
		 * the game. Depending on which type of device we are we will load a specific
		 * size of the game assets so that it fits any device.
		 * 
		 * <p>When we initialize the game, we need to store the current GameSession
		 * so that we can push it at the end of the game if possible and if not, later
		 * in the PushManager. Thus, while the user plays, we disable the PushManager
		 * so that no information is pushed while he is playing.</p>
		 * 
		 * <p>We need to do this in the resize function because otherwise, we will get a
		 * contect error (context = dispose while resizing).</p>
		 * 
		 * @see com.ludofactory.mobile.push.PushManager
		 * @see com.ludofactory.mobile.push.GameSession
		 */		
		private function initializeGame():void
		{
			// create the loader
			_loader = new MovieClip( AbstractEntryPoint.assets.getTextures("Loader") );
			_loader.x = (GlobalConfig.stageWidth - _loader.width) * 0.5;
			_loader.y = (GlobalConfig.stageHeight - _loader.height) * 0.5;
			Starling.juggler.add(_loader);
			addChild(_loader);
			
			var basePath:String = File.applicationDirectory.resolvePath( GlobalConfig.isPhone ? "assets/game/sd/" : "assets/game/hd/").url;
			AbstractEntryPoint.assets.enqueue( basePath + "/game.png" );
			AbstractEntryPoint.assets.enqueue( basePath + "/game.xml" );
			AbstractEntryPoint.assets.loadQueue( function onLoading(ratio:Number):void{ if(ratio == 1) initializeContent(); });
		}
		
		/**
		 * @inheritDoc
		 */		
		public function initializeSounds():void
		{
			// to override in GameScreen
		}
		
		/**
		 * @inheritDoc
		 */		
		public function initializeContent():void
		{
			// initialize sounds
			initializeSounds();
			
			Starling.juggler.remove(_loader);
			_loader.removeFromParent(true);
			_loader = null;
			
			// create the overlay and play button
			_playOverlay = new Image(AbstractEntryPoint.assets.getTexture("overlay-skin"));
			_playOverlay.width = GlobalConfig.stageWidth;
			_playOverlay.height = GlobalConfig.stageHeight;
			addChild(_playOverlay);
			
			_playButton = new feathers.controls.Button();
			_playButton.nameList.add( Theme.BUTTON_SPECIAL_BIGGER );
			_playButton.label = Localizer.getInstance().translate("GAME.START_BUTTON_LABEL");
			_playButton.addEventListener(starling.events.Event.TRIGGERED, onPlay);
			addChild(_playButton);
			_playButton.height = scaleAndRoundToDpi(118);
			_playButton.validate();
			_playButton.width += scaleAndRoundToDpi(60);
			_playButton.x = (GlobalConfig.stageWidth - _playButton.width) * 0.5;
			_playButton.y = (GlobalConfig.stageHeight - _playButton.height) * 0.5;
			
			// enable the pause view and listeners
			PauseManager.isPlaying = true;
			PauseManager.dispatcher.addEventListener(LudoEventType.EXIT, giveUp);
			PauseManager.dispatcher.addEventListener(LudoEventType.RESUME, resume);
		}
		
		
		/**
		 * The user touched the play button.
		 */		
		protected function onPlay(event:starling.events.Event):void
		{
			_playOverlay.removeFromParent(true);
			_playOverlay = null;
			
			_playButton.removeEventListener(starling.events.Event.TRIGGERED, onPlay);
			_playButton.removeFromParent(true);
			_playButton = null;
			
			startLevel();
		}
		
		/**
		 * @inheritDoc
		 */		
		public function startLevel():void
		{
			// to override
		}
		
		/**
		 * @inheritDoc
		 */		
		public function giveUp(event:starling.events.Event):void
		{
			// to override
			_gaveUp = true;
			gameOver();
		}
		
		/**
		 * @inheritDoc
		 */		
		public function resume(event:starling.events.Event):void
		{
			// to override
		}
		
		/**
		 * @inheritDoc
		 */		
		public function gameOver():void
		{
			// to override
			
			InfoManager.show(Localizer.getInstance().translate("GAME.VALIDATION"));
			Flox.logEvent("Parties", { "4. Etat de la partie":(_gaveUp ? "Abandonnee" : "Terminee"), "5. Connectivité en fin de partie":( AirNetworkInfo.networkInfo.isConnected() ? "Connecte" : "Deconnecte") });
			
			// update tutorial state
			if( MemberManager.getInstance().getDisplayTutorial() == true )
				MemberManager.getInstance().setDisplayTutorial(false);
			
			PauseManager.isPlaying = false;
		}
		
//------------------------------------------------------------------------------------------------------------
//	Game validation
		
		/**
		 * <p>This function will convert the final score to retrieve the appropriate gain : whether
		 * stars or points depending on which type of game have been choose (classic or tournament).</p>
		 * 
		 * <p>The score is updated in the GameSession object (which have been initialized at the beginning
		 * of the game) so that we can push it right after (if we can).</p>
		 * 
		 * <p>Those informations (score and gain) are also stored in the <code>advancedOwner.screenData.gameData</code>
		 * object in order to be passed to the next screen.</p>
		 */		
		protected function validateGame(finalScore:int, totalElapsedTime:int):void
		{
			if( !_isValidatingGame )
			{
				// we add this by security
				_isValidatingGame = true;
				
				log("Score <strong>" + finalScore + "</strong> made in <strong>" + (totalElapsedTime / 1000) +" seconds</strong>.");
				TrophyManager.getInstance().currentGameSession = null;
				AdManager.disposeBanners();
				
				// update the score and the gain (note that the value of gain might be replaced if the push is a success
				// and if the scoring have changed in the server side)
				var scoreConverter:ScoreConverter = new ScoreConverter();
				_gameSession.score = finalScore;
				_gameSession.elapsedTime = totalElapsedTime;
				advancedOwner.screenData.gameData.score = _gameSession.score;
				advancedOwner.screenData.gameData.numStarsOrPointsEarned = _gameSession.numStarsOrPointsEarned = scoreConverter.convertScore(_gameSession.score, _gameSession.gamePrice, _gameSession.gameType);
				
				// report iOS Leaderboard
				GameCenterManager.reportLeaderboardScore(AbstractGameInfo.LEADERBOARD_HIGHSCORE, _gameSession.score);
				
				// Try to directly push this game session
				if( MemberManager.getInstance().isLoggedIn() &&  AirNetworkInfo.networkInfo.isConnected() )
				{
					_gameSession.connected = true;
					Remote.getInstance().pushGame(_gameSession, onGamePushSuccess, onGamePushFailure, onGamePushFailure, 1);
				}
				else
				{
					onGamePushFailure();
				}
			}
		}
		
//------------------------------------------------------------------------------------------------------------
//	Game validation callbacks
		
		/**
		 * The game session was pushed, we can remove it from the push manager and go to the next screen.
		 */		
		private function onGamePushSuccess(result:Object):void
		{
			log("[AbstractGame] GameSession validated : " + result.code + " => " + result.txt);
			
			AbstractEntryPoint.pushManager.removeLastGameSession(_gameSession);
			
			switch(result.code)
			{
				case 0:  // invalid data
				case 2:  // game with credits but not enough in database ( ask to buy credits ? )
				case 3:  // cannot retreive the score to points array in php
				case 4:  // game with free game but not enough free game sessions in database
				case 5:  // id jeux arcade not defined in config
				case 6:  // not tournament actually for this game
				case 7:  // not enough points for this tournament
				case 8:  // not enough credits for this tournament
				case 9:  // cannot retreive the score to stars array in php
				case 10: // given date is higher than the one of the server
				case 11: // the game session could not be counted because the tournament is over
				case 12: // classic game too old to be taken in account
				case 13: // game session already pushed
				{
					// false = no update because even if there is an error, an object obj_membre_mobile
					// will be returned
					onGamePushFailure(false);
					break;
				}
				case 1: // ok
				{
					advancedOwner.screenData.gameData.gameSessionPushed = true;
					
					// Facebook data - only returned when the user is connected with Facebook and have a valid token
					if( result.hasOwnProperty("fb_hs_friends") && result.fb_hs_friends )
					{
						if( result.fb_hs_friends.hasOwnProperty("classement") && (result.fb_hs_friends.classement as Array).length > 0 )
						{
							advancedOwner.screenData.gameData.facebookFriends = (result.fb_hs_friends.classement as Array).concat();
							advancedOwner.screenData.gameData.facebookMoving = int(result.fb_hs_friends.deplacement);
							advancedOwner.screenData.gameData.facebookPosition = int(result.fb_hs_friends.key_position);
						}
					}
					/*else
					{
						// FIXME Temporaire !!!
						advancedOwner.screenData.gameData.facebookFriends = [ { classement:1, id:7525971, id_facebook:1087069645, last_classement:1, last_score:350, nom:"Maxime Lhoez", score:350 },
																			  { classement:2, id:7525967, id_facebook:100001491084445, last_classement:3, last_score:220, nom:"Nicolas Alexandre", score:220 },
																			  { classement:2, id:7525969, id_facebook:100003577159732, last_classement:4, last_score:100, nom:"Maxime Lhz", score:250 } ];
						advancedOwner.screenData.gameData.facebookMoving = 1;
						advancedOwner.screenData.gameData.facebookPosition = 2;
					}*/
					
					if( result.hasOwnProperty("tab_php_trophy_win") && result.tab_php_trophy_win && result.tab_php_trophy_win.length > 0 )
					{
						for each( var idTrophy:int in result.tab_php_trophy_win )
						{
							// Display trophy only once
							if( TrophyManager.getInstance().canWinTrophy(idTrophy) )
								TrophyManager.getInstance().onWinTrophy( idTrophy );
						}
					}
					
					if( _gameSession.gameType == GameSession.TYPE_CLASSIC )
					{
						// classic game
						this.advancedOwner.screenData.gameData.numStarsOrPointsEarned = int(result.gains);
						if( TrophyManager.getInstance().isTrophyMessageDisplaying )
						{
							_nextScreenId = int(result.isHighscore) == 1 ? ScreenIds.NEW_HIGH_SCORE_SCREEN : ScreenIds.FREE_GAME_END_SCREEN;
							TrophyManager.getInstance().addEventListener(starling.events.Event.COMPLETE, onTrophiesDisplayed);
						}
						else
						{
							InfoManager.hide("", InfoContent.ICON_NOTHING, 0);
							advancedOwner.showScreen( int(result.isHighscore) == 1 ? ScreenIds.NEW_HIGH_SCORE_SCREEN : ScreenIds.FREE_GAME_END_SCREEN );
						}
					}
					else
					{
						// tournament
						advancedOwner.screenData.gameData.numStarsOrPointsEarned = int(result.etoiles);
						advancedOwner.screenData.gameData.position = int(result.classement);
						advancedOwner.screenData.gameData.top = int(result.top);
						advancedOwner.screenData.gameData.actualGiftImageUrl = result.lot_actuel.image;
						advancedOwner.screenData.gameData.actualGiftName = Utility.replaceCurrency(result.lot_actuel.nom);
						advancedOwner.screenData.gameData.nextGiftImageUrl = result.lot_suivant.image;
						advancedOwner.screenData.gameData.nextGiftName = Utility.replaceCurrency(result.lot_suivant.nom);
						advancedOwner.screenData.gameData.numStarsForNextGift = int(result.lot_suivant.nb_etoiles);
						advancedOwner.screenData.gameData.hasReachNewTop = int(result.podium) == 1 ? true:false;
						advancedOwner.screenData.gameData.timeUntilTournamentEnd = int(result.temps_fin_tournoi);
						advancedOwner.screenData.gameData.displayPushAlert = int(result.afficher_alerte_push) == 1 ? true : false;
						advancedOwner.screenData.gameData.topDotationName = result.top_dotation;
						
						if( result.isHighscore == 1 )
						{
							if( TrophyManager.getInstance().isTrophyMessageDisplaying )
							{
								_nextScreenId = ScreenIds.NEW_HIGH_SCORE_SCREEN;
								TrophyManager.getInstance().addEventListener(starling.events.Event.COMPLETE, onTrophiesDisplayed);
							}
							else
							{
								InfoManager.hide("", InfoContent.ICON_NOTHING, 0);
								advancedOwner.showScreen( ScreenIds.NEW_HIGH_SCORE_SCREEN );
							}
						}
						else
						{
							// no highscore but maybe a new level
							if( TrophyManager.getInstance().isTrophyMessageDisplaying )
							{
								_nextScreenId = int(result.podium) == 1 ? ScreenIds.PODIUM_SCREEN : ScreenIds.TOURNAMENT_GAME_END_SCREEN;
								TrophyManager.getInstance().addEventListener(starling.events.Event.COMPLETE, onTrophiesDisplayed);
							}
							else
							{
								InfoManager.hide("", InfoContent.ICON_NOTHING, 0);
								advancedOwner.showScreen( int(result.podium) == 1 ? ScreenIds.PODIUM_SCREEN : ScreenIds.TOURNAMENT_GAME_END_SCREEN );
							}
						}
					}
					break;
				}
					
				default:
				{
					onGamePushFailure(false);
					break;
				}
			}
			
			// re-enable the PushManager
			AbstractEntryPoint.pushManager.isEnabled = true;
		}
		
		/**
		 * The game session could not be validated or there was no connection when we
		 * tried to push it to our server.
		 * 
		 * <p>In this case wee need to save this game session so that it can be pushed
		 * later.</p>
		 * 
		 * <p>The points (in classic mode) or the cumulated stars (in tournament mode)
		 * will be updated here so that it matches what the user just earned. Those values
		 * might be replaced at any time when a <code>obj_membre_mobile</code> is returned
		 * by a query in <code>Remote</code>.</p>
		 */		
		private function onGamePushFailure(error:Object = null):void
		{
			advancedOwner.screenData.gameData.gameSessionPushed = false;
			
			// update earned values in any cases
			if( _gameSession.gameType == GameSession.TYPE_CLASSIC ) MemberManager.getInstance().setPoints( MemberManager.getInstance().getPoints() + advancedOwner.screenData.gameData.numStarsOrPointsEarned );
			else MemberManager.getInstance().setCumulatedStars( MemberManager.getInstance().getCumulatedStars() + advancedOwner.screenData.gameData.numStarsOrPointsEarned );
			
			_nextScreenId = _gameSession.gameType == GameSession.TYPE_CLASSIC ? ScreenIds.FREE_GAME_END_SCREEN : ScreenIds.TOURNAMENT_GAME_END_SCREEN;
			if( MemberManager.getInstance().getHighscore() != 0 && _gameSession.score > MemberManager.getInstance().getHighscore() )
			{
				// the user got a new high score
				MemberManager.getInstance().setHighscore( _gameSession.score );
				if( TrophyManager.getInstance().isTrophyMessageDisplaying )
				{
					_nextScreenId = ScreenIds.NEW_HIGH_SCORE_SCREEN;
					TrophyManager.getInstance().addEventListener(starling.events.Event.COMPLETE, onTrophiesDisplayed);
				}
				else
				{
					InfoManager.hide("", InfoContent.ICON_NOTHING, 0);
					advancedOwner.showScreen( _nextScreenId );
				}
			}
			else
			{
				// set up the new high score, because this is the first one
				if( MemberManager.getInstance().getHighscore() == 0 )
					MemberManager.getInstance().setHighscore(_gameSession.score);
				
				if( TrophyManager.getInstance().isTrophyMessageDisplaying )
				{
					TrophyManager.getInstance().addEventListener(starling.events.Event.COMPLETE, onTrophiesDisplayed);
				}
				else
				{
					InfoManager.hide("", InfoContent.ICON_NOTHING, 0);
					advancedOwner.showScreen( _nextScreenId );
				}
			}
			
			if( !MemberManager.getInstance().isLoggedIn() )
			{
				// if the user is not logged in, we need to store the game sessions
				MemberManager.getInstance().getAnonymousGameSessions()[ (MemberManager.getInstance().getAnonymousGameSessions().length - 1) ] = _gameSession;
				MemberManager.getInstance().setAnonymousGameSessions( MemberManager.getInstance().getAnonymousGameSessions() );
			}
			
			// re-enable the PushManager
			AbstractEntryPoint.pushManager.isEnabled = true;
		}
		
		/**
		 * All the trophies have been displayed, in this case we can show the next screen.
		 */		
		private function onTrophiesDisplayed(event:starling.events.Event):void
		{
			InfoManager.hide("", InfoContent.ICON_NOTHING, 0);
			TrophyManager.getInstance().removeEventListener(starling.events.Event.COMPLETE, onTrophiesDisplayed);
			AbstractEntryPoint.screenNavigator.showScreen( _nextScreenId ); // bug des fois si AdvancedOwner utilisé à la place
		}
		
//------------------------------------------------------------------------------------------------------------
//	Dispose
		
		override public function dispose():void
		{
			PauseManager.isPlaying = false;
			PauseManager.dispatcher.removeEventListener(LudoEventType.EXIT, giveUp);
			PauseManager.dispatcher.removeEventListener(LudoEventType.RESUME, resume);
			
			if( _loader )
			{
				Starling.juggler.remove(_loader);
				_loader.removeFromParent(true);
				_loader = null;
			}
			
			if( _playOverlay )
			{
				_playOverlay.removeFromParent(true);
				_playOverlay = null;
			}
			
			if( _playButton )
			{
				_playButton.removeEventListener(starling.events.Event.TRIGGERED, onPlay);
				_playButton.removeFromParent(true);
				_playButton = null;
			}
			
			super.dispose();
		}
		
	}
}