/*
Copyright © 2006-2015 Ludo Factory - http://www.ludokado.com/
Framework mobile
Author  : Maxime Lhoez
Created : 9 août 2013
*/
package com.ludofactory.mobile.navigation.home.summary
{
	
	import com.greensock.TweenLite;
	import com.greensock.TweenMax;
	import com.greensock.easing.Back;
	import com.greensock.easing.Linear;
	import com.greensock.easing.Power1;
	import com.ludofactory.common.gettext.aliases._;
	import com.ludofactory.common.utils.Utilities;
	import com.ludofactory.common.utils.roundUp;
	import com.ludofactory.common.utils.scaleAndRoundToDpi;
	import com.ludofactory.mobile.core.AbstractEntryPoint;
	import com.ludofactory.mobile.core.AbstractGameInfo;
	import com.ludofactory.mobile.core.GameSessionTimer;
	import com.ludofactory.mobile.core.config.GlobalConfig;
	import com.ludofactory.mobile.core.events.MobileEventTypes;
	import com.ludofactory.mobile.core.manager.MemberManager;
	import com.ludofactory.mobile.core.model.ScreenIds;
	import com.ludofactory.mobile.core.model.StakeType;
	import com.ludofactory.mobile.core.promo.PromoManager;
	import com.ludofactory.mobile.core.theme.Theme;
	
	import feathers.controls.Callout;
	import feathers.controls.ImageLoader;
	import feathers.controls.Label;
	import feathers.core.FeathersControl;
	import feathers.display.Scale9Image;
	import feathers.textures.Scale9Textures;
	
	import flash.filters.DropShadowFilter;
	import flash.geom.Rectangle;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;
	
	import starling.core.Starling;
	import starling.display.DisplayObject;
	import starling.display.Image;
	import starling.events.Event;
	import starling.events.Touch;
	import starling.events.TouchEvent;
	import starling.events.TouchPhase;
	import starling.extensions.PDParticleSystem;
	import starling.text.TextField;
	import starling.text.TextFieldAutoSize;
	import starling.utils.HAlign;
	import starling.utils.VAlign;
	import starling.utils.formatString;
	
	/**
	 * Element displayed in the footer and container an stake value.
	 */
	public class FooterStakeElement extends FeathersControl
	{
		
	// ---------- Common props
		
		/**
		 * The type used to choose the correct icon and background. */
		private var _stakeType:int;
		
		/**
		 * The element background. */
		private var _background:Scale9Image;
		/**
		 * The associated stake icon. */
		private var _icon:ImageLoader;
		/**
		 * Stake value label. */
		private var _stakeValueLabel:TextField;
		
		/**
		 * Particles */
		private var _particles:PDParticleSystem;
		
		/**
		 * Promo notification displayed beside the credit icon when a promo is available. */
		private var _promoNotification:Image;
		
	// ---------- Callout
		
		/**
		 * The textfield displayed in the callout. */
		private var _calloutLabel:TextField;
		/**
		 * Whether the callout is displaying. */
		private var _isCalloutDisplaying:Boolean = false;
		
	// ---------- Question marks
		
		/**
		 * Whether the question marks are displaying. */
		private var _areQuestionMarksDisplaying:Boolean = false;
		
		/**
		 * First question mark textfield. */
		private var _firstQuestionLabel:TextField;
		/**
		 * Second question mark textfield. */
		private var _secondQuestionLabel:TextField;
		/**
		 * Third question mark textfield. */
		private var _thirdQuestionLabel:TextField;
		
		/**
		 * Question marks animation. */
		private var _saveXFirst:int;
		private var _saveXSecond:int;
		private var _saveXThird:int;
		private var _saveY:int;
		
	// ---------- ?
		
		private var _animationLabel:Label;
		public var _oldTweenValue:int;
		public var _targetTweenValue:int;
		
		public function FooterStakeElement(stakeType:int)
		{
			super();
			
			_stakeType = stakeType;
		}
		
		override protected function initialize():void
		{
			super.initialize();
			
			_calloutLabel = new TextField(5, 5, "", Theme.FONT_SANSITA, scaleAndRoundToDpi(26), Theme.COLOR_DARK_GREY);
			_calloutLabel.autoSize = TextFieldAutoSize.BOTH_DIRECTIONS;
			
			var backgroundTextureName:String;
			var iconTextureName:String;
			
			switch(_stakeType)
			{
				case StakeType.TOKEN:
				{
					backgroundTextureName = "summary-green-container" + (AbstractGameInfo.LANDSCAPE ? "-landscape" : "");
					iconTextureName = GlobalConfig.isPhone ? "summary-icon-token" : "summary-icon-token-hd";
					break;
				}
				case StakeType.CREDIT:
				{
					backgroundTextureName = "summary-yellow-container" + (AbstractGameInfo.LANDSCAPE ? "-landscape" : "");
					iconTextureName = GlobalConfig.isPhone ? "summary-icon-credits" : "summary-icon-credits-hd";
					break;
				}
				case StakeType.POINT:
				{
					backgroundTextureName = "summary-blue-container" + (AbstractGameInfo.LANDSCAPE ? "-landscape" : "");
					iconTextureName = GlobalConfig.isPhone ? "summary-icon-points" : "summary-icon-points-hd";
					break;
				}
			}
			
			var textures:Scale9Textures;
			if( AbstractGameInfo.LANDSCAPE )
				textures = new Scale9Textures( AbstractEntryPoint.assets.getTexture( backgroundTextureName ), new Rectangle(63, 16, 20, 28) );
			else
				textures = new Scale9Textures( AbstractEntryPoint.assets.getTexture( backgroundTextureName ), new Rectangle(18, 18, 14, 14) );
			_background = new Scale9Image( textures, GlobalConfig.dpiScale);
			_background.useSeparateBatch = false;
			addChild( _background );
			textures.texture.dispose();
			
			_icon = new ImageLoader();
			_icon.source = AbstractEntryPoint.assets.getTexture( iconTextureName );
			_icon.textureScale = GlobalConfig.dpiScale;
			_icon.snapToPixels = true;
			addChild(_icon);
			
			if(_stakeType == StakeType.CREDIT)
			{
				_promoNotification = new Image(AbstractEntryPoint.assets.getTexture(GlobalConfig.isPhone ? "promo-notification" : "promo-notification-hd"));
				_promoNotification.scaleX = _promoNotification.scaleY = GlobalConfig.dpiScale;
				_promoNotification.alignPivot();
				_promoNotification.alpha = 0;
				_promoNotification.visible = false;
				addChild(_promoNotification);
				
				PromoManager.getInstance().addEventListener(MobileEventTypes.PROMO_UPDATED, onPromoUpdated);
			}
			
			_particles = new PDParticleSystem(Theme.particleSlowXml, AbstractEntryPoint.assets.getTexture(iconTextureName));
			_particles.touchable = false;
			_particles.maxNumParticles = 100;
			_particles.radialAccelerationVariance = 0;
			_particles.startColor.alpha = 0.6;
			_particles.endColor.alpha = 0;
			_particles.speed = 10;
			_particles.speedVariance = 5;
			_particles.lifespan = 1;
			_particles.lifespanVariance = 0.5;
			addChild(_particles);
			 
			_stakeValueLabel = new TextField(5, 5, "000000", Theme.FONT_SANSITA, scaleAndRoundToDpi(30), 0xe2bf89);
			_stakeValueLabel.vAlign = VAlign.CENTER;
			_stakeValueLabel.autoScale = true;
			addChild(_stakeValueLabel);
			
			_animationLabel = new Label();
			_animationLabel.visible = false;
			_animationLabel.alpha = 0;
			addChild(_animationLabel);
			_animationLabel.textRendererProperties.textFormat = new TextFormat(Theme.FONT_SANSITA, scaleAndRoundToDpi(46), Theme.COLOR_WHITE, false, false, null, null, null, TextFormatAlign.CENTER);
			_animationLabel.textRendererProperties.nativeFilters = [ new DropShadowFilter(0, 75, 0x000000, 0.75, 6, 6, 5) ];
			
			addEventListener(TouchEvent.TOUCH, onTouch);
		}
		
		override protected function draw():void
		{
			super.draw();
			
			if( isInvalid(INVALIDATION_FLAG_SIZE) )
			{
				if( AbstractGameInfo.LANDSCAPE )
				{
					_icon.x = roundUp((scaleAndRoundToDpi(60) - _icon.width) * 0.5); // 60 = size of the colored part that contains the icon
					_icon.y = roundUp((actualHeight - _icon.height) * 0.5);
				}
				else
				{
					_icon.x = ( (this.actualWidth - _icon.width) * 0.5 ) << 0;
					_icon.y = _icon.y << 0;
				}
				
				if(_promoNotification)
				{
					_promoNotification.scaleX = _promoNotification.scaleY = GlobalConfig.dpiScale;
					_promoNotification.x = _icon.x + _icon.width + (_promoNotification.width * 0.25);
					_promoNotification.y = _icon.y + (_icon.height * 0.25);
					_promoNotification.scaleX = _promoNotification.scaleY = 0;
				}
				
				if( AbstractGameInfo.LANDSCAPE )
				{
					_background.width = this.actualWidth;
					_background.height = this.actualHeight * 0.7;
					_background.y = roundUp((actualHeight - _background.height) * 0.5);
					_background.x = _background.x << 0;
				}
				else
				{
					_background.width = this.actualWidth;
					_background.y = (_icon.height * 0.35) << 0;
					_background.x = _background.x << 0;
					_background.height = this.actualHeight - _background.y;
				}
				
				if( AbstractGameInfo.LANDSCAPE )
				{
					_stakeValueLabel.width = _background.width - scaleAndRoundToDpi(60) - scaleAndRoundToDpi(16); // 8 + 8 padding on each side
					_stakeValueLabel.x = scaleAndRoundToDpi(60) + scaleAndRoundToDpi(5);
					_stakeValueLabel.height = _background.height;
					_stakeValueLabel.y = _background.y;
				}
				else
				{
					_stakeValueLabel.width = _background.width;
					_stakeValueLabel.height = _background.height;
					_stakeValueLabel.y = ((this.actualHeight - _icon.height - scaleAndRoundToDpi(10)) - _stakeValueLabel.height) * 0.5 + _icon.height;
				}
				
				_particles.emitterX = _particles.emitterXVariance = actualWidth * 0.5;
				_particles.emitterY = _particles.emitterYVariance = actualHeight * 0.5;
				
				_animationLabel.width = actualWidth;
				
				if( _areQuestionMarksDisplaying )
				{
					TweenLite.killTweensOf([_firstQuestionLabel,_secondQuestionLabel,_thirdQuestionLabel]);
					
					if( AbstractGameInfo.LANDSCAPE )
					{
						_saveXFirst = _firstQuestionLabel.x = scaleAndRoundToDpi(60) + ((_background.width - scaleAndRoundToDpi(60)) - (_firstQuestionLabel.width * 3)) * 0.5;
						_saveXSecond = _secondQuestionLabel.x = _firstQuestionLabel.x + _firstQuestionLabel.width;
						_saveXThird = _thirdQuestionLabel.x = _firstQuestionLabel.x + (_firstQuestionLabel.width * 2);
						_saveY = _firstQuestionLabel.y = _secondQuestionLabel.y = _thirdQuestionLabel.y = scaleAndRoundToDpi(10) + ((this.actualHeight - scaleAndRoundToDpi(10)) - _firstQuestionLabel.height) * 0.5;
					}
					else
					{
						_saveXFirst = _firstQuestionLabel.x = (_background.width - (_firstQuestionLabel.width * 3)) * 0.5;
						_saveXSecond = _secondQuestionLabel.x = _firstQuestionLabel.x + _firstQuestionLabel.width;
						_saveXThird = _thirdQuestionLabel.x = _firstQuestionLabel.x + (_firstQuestionLabel.width * 2);
						_saveY = _firstQuestionLabel.y = _secondQuestionLabel.y = _thirdQuestionLabel.y = ((this.actualHeight - _icon.height - scaleAndRoundToDpi(10)) - _firstQuestionLabel.height) * 0.5 + _icon.height;
					}
					
					_firstQuestionLabel.visible = _secondQuestionLabel.visible = _thirdQuestionLabel.visible = true;
					repeatAnimation();
				}
			}
		}
		
//------------------------------------------------------------------------------------------------------------
//
		/**
		 * Updates the label text.
		 */
		public function setLabelText(value:String):void
		{
			if( value == "???" || (value == "-" && MemberManager.getInstance().tokens == 0) )
			{
				if( !_areQuestionMarksDisplaying )
				{
					_stakeValueLabel.text = "";
					addInterrogationLabels();
				}
			}
			else
			{
				if( _areQuestionMarksDisplaying )
					removeInterrogationLabels();
				_stakeValueLabel.text = value;
				if( MemberManager.getInstance().isLoggedIn() && MemberManager.getInstance().tokens == 0 )
					_calloutLabel.text = formatString(_("{0} Jetons dans {1}"), MemberManager.getInstance().totalTokensADay, value);
			}
			
			invalidate(INVALIDATION_FLAG_SIZE);
		}
		
//------------------------------------------------------------------------------------------------------------
//	Handlers
		
		/**
		 * Animates a change in the element.
		 */		
		public function animateChange(newValue:int):void
		{
			_oldTweenValue = int(_stakeValueLabel.text.split(" ").join(""));
			_targetTweenValue = _oldTweenValue + newValue;
			if( newValue < 0 )
				TweenMax.to(this, 0.75, { _oldTweenValue : _targetTweenValue, onUpdate : function():void{ _stakeValueLabel.text = Utilities.splitThousands(_oldTweenValue); }, ease:Linear.easeNone } );
			_animationLabel.text = (newValue < 0 ? "- " : "+ ") + Math.abs(newValue);
			_animationLabel.visible = false;
			_animationLabel.alpha = 0;
			_animationLabel.y = 0;
			TweenMax.to(_animationLabel, 1.25, { y:scaleAndRoundToDpi(-50) });
			TweenMax.to(_animationLabel, 0.5, { autoAlpha:1, yoyo:true, repeatDelay:1, repeat:1 });
			
			Starling.juggler.add(_particles);
			_particles.addEventListener(Event.COMPLETE, onParticlesComplete);
			_particles.start(0.5);
		}
		
		private function onParticlesComplete(event:Event):void
		{
			_particles.removeEventListener(Event.COMPLETE, onParticlesComplete);
			Starling.juggler.remove(_particles);
		}
		
//------------------------------------------------------------------------------------------------------------
//	Handlers
		
		/**
		 * Touch event.
		 */
		private function onTouch(event:TouchEvent):void
		{
			var touch:Touch = event.getTouch(this);
			if( touch && touch.phase == TouchPhase.ENDED )
			{
				if( !_isCalloutDisplaying )
				{
					switch(_stakeType)
					{
						case StakeType.TOKEN:
						{
							if( MemberManager.getInstance().isLoggedIn() )
							{
								if( GameSessionTimer.IS_TIMER_OVER_AND_REQUEST_FAILED )
									_calloutLabel.text = formatString(_("Reconnectez-vous pour récupérer vos {0} Jetons."), MemberManager.getInstance().totalTokensADay);
								else
									_calloutLabel.text = formatString(_("Vos Jetons ({0} quotidiens + {1} bonus)"), (MemberManager.getInstance().tokens - MemberManager.getInstance().totalBonusTokensADay), MemberManager.getInstance().totalBonusTokensADay);
							}
							else
							{
								_calloutLabel.text = _("Obtenez 50 Jetons par jour en créant votre compte (tapotez ici)")
							}
							break;
						}
						case StakeType.CREDIT:
						{
							if( !MemberManager.getInstance().isLoggedIn() && MemberManager.getInstance().tokens == 0 )
								_calloutLabel.text = formatString(_("Obtenez 50 Jetons par jour en créant votre compte (tapotez ici)"), MemberManager.getInstance().totalTokensADay);
							else
								_calloutLabel.text = _("Vos Crédits de jeu\nTapotez ici pour recharger votre compte");
							
							break;
						}
						case StakeType.POINT:
						{
							if( !MemberManager.getInstance().isLoggedIn() && MemberManager.getInstance().tokens == 0 )
								_calloutLabel.text = formatString(_("Obtenez 50 Jetons par jour en créant votre compte (tapotez ici)"), MemberManager.getInstance().totalTokensADay);
							else
								_calloutLabel.text = MemberManager.getInstance().getGiftsEnabled() ? _("Vos Points à convertir en Cadeaux\nTapotez ici pour accéder à la boutique") : _("Vos Points à convertir en Crédits\nTapotez ici pour accéder à la boutique");
							break;
						}
					}
					
					if((_stakeType == StakeType.CREDIT && MemberManager.getInstance().isLoggedIn()) || (_stakeType == StakeType.POINT && MemberManager.getInstance().tokens != 0))
					{
						_calloutLabel.autoSize = TextFieldAutoSize.VERTICAL;
						_calloutLabel.width = scaleAndRoundToDpi(500);
						_calloutLabel.hAlign = HAlign.CENTER;
					}
					else
					{
						_calloutLabel.autoSize = TextFieldAutoSize.BOTH_DIRECTIONS;
					}
					if(_calloutLabel.width > (GlobalConfig.stageWidth * 0.9))
					{
						_calloutLabel.autoSize = TextFieldAutoSize.VERTICAL;
						_calloutLabel.width = GlobalConfig.stageWidth * 0.9;
					}
					
					if(PromoManager.getInstance().isPromoPending && _stakeType == StakeType.CREDIT)
					{
						AbstractEntryPoint.screenNavigator.showScreen(ScreenIds.STORE_SCREEN);
					}
					else
					{
						_isCalloutDisplaying = true;
						
						var callout:Callout = Callout.show(_calloutLabel, this, Callout.DIRECTION_UP, false);
						callout.touchable = false;
						callout.disposeContent = false;
						callout.addEventListener(Event.REMOVED_FROM_STAGE, onCalloutRemoved);
						
						if(MemberManager.getInstance().isLoggedIn() && _stakeType == StakeType.POINT)
						{
							AbstractEntryPoint.screenNavigator.showScreen(ScreenIds.BOUTIQUE_HOME);
						}
						else if( !MemberManager.getInstance().isLoggedIn() && (_stakeType == StakeType.TOKEN || MemberManager.getInstance().tokens == 0))
						{
							callout.touchable = true;
							callout.addEventListener(TouchEvent.TOUCH, onRegister);
						}
					}
				}
			}
			callout = null;
			touch = null;
		}
		
		/**
		 * Go to the authentication screen.
		 */
		private function onRegister(event:TouchEvent):void
		{
			var touch:Touch = event.getTouch(DisplayObject(event.target));
			if( touch && touch.phase == TouchPhase.ENDED )
			{
				DisplayObject(event.target).removeFromParent();
				AbstractEntryPoint.screenNavigator.showScreen(ScreenIds.AUTHENTICATION_SCREEN);
			}
			touch = null;
		}
		
		/**
		 * When the callout is removed.
		 */
		private function onCalloutRemoved(event:Event):void
		{
			event.target.removeEventListener(Event.REMOVED_FROM_STAGE, onCalloutRemoved);
			event.target.removeEventListener(TouchEvent.TOUCH, onRegister);
			_isCalloutDisplaying = false;
		}
		
//------------------------------------------------------------------------------------------------------------
//	Question marks
		
		/**
		 * Adds all the question marks. */
		private function addInterrogationLabels():void
		{
			_firstQuestionLabel = new TextField(5, 5, "?", Theme.FONT_SANSITA, scaleAndRoundToDpi(26), 0xe2bf89);
			_firstQuestionLabel.autoSize = TextFieldAutoSize.BOTH_DIRECTIONS;
			_firstQuestionLabel.text = "?";
			_firstQuestionLabel.visible = false;
			addChild(_firstQuestionLabel);
			
			_secondQuestionLabel = new TextField(5, 5, "?", Theme.FONT_SANSITA, scaleAndRoundToDpi(26), 0xe2bf89);
			_secondQuestionLabel.autoSize = TextFieldAutoSize.BOTH_DIRECTIONS;
			_secondQuestionLabel.visible = false;
			addChild(_secondQuestionLabel);
			
			_thirdQuestionLabel = new TextField(5, 5, "?", Theme.FONT_SANSITA, scaleAndRoundToDpi(26), 0xe2bf89);
			_thirdQuestionLabel.autoSize = TextFieldAutoSize.BOTH_DIRECTIONS;
			_thirdQuestionLabel.visible = false;
			addChild(_thirdQuestionLabel);
			
			_areQuestionMarksDisplaying = true;
		}
		
		/**
		 * Removes all the question marks.
		 */
		private function removeInterrogationLabels():void
		{
			TweenLite.killTweensOf(_firstQuestionLabel);
			_firstQuestionLabel.removeFromParent(true);
			_firstQuestionLabel = null;
			
			TweenLite.killTweensOf(_secondQuestionLabel);
			_secondQuestionLabel.removeFromParent(true);
			_secondQuestionLabel = null;
			
			TweenLite.killTweensOf(_thirdQuestionLabel);
			_thirdQuestionLabel.removeFromParent(true);
			_thirdQuestionLabel = null;
			
			_areQuestionMarksDisplaying = false;
		}
		
		/**
		 * Animates the question marks.
		 */
		private function repeatAnimation():void
		{
			TweenLite.to(_firstQuestionLabel, 0.85, { delay:1, bezier:[{x:_saveXFirst, y:(_saveY - scaleAndRoundToDpi(8))}, {x:_saveXFirst, y:_saveY}], orientToBezier:false });
			TweenLite.to(_secondQuestionLabel, 0.85, { delay:1.15, bezier:[{x:_saveXSecond, y:(_saveY - scaleAndRoundToDpi(8))}, {x:_saveXSecond, y:_saveY}], orientToBezier:false });
			TweenLite.to(_thirdQuestionLabel, 0.85, { delay:1.3, bezier:[{x:_saveXThird, y:(_saveY - scaleAndRoundToDpi(8))}, {x:_saveXThird, y:_saveY}], orientToBezier:false, onComplete:repeatAnimation});
		}
		
//------------------------------------------------------------------------------------------------------------
//	Promo management (only for the credit container)
		
		/**
		 * When the promo manager is updated (whether because there is a promotion to display or because one has
		 * finishe), we need to show or hide the notification icon.
		 */
		private function onPromoUpdated(event:Event):void
		{
			TweenLite.killDelayedCallsTo(moveNotification);
			TweenLite.killTweensOf(_promoNotification);
			if(PromoManager.getInstance().isPromoPending)
			{
				_promoNotification.scaleX = _promoNotification.scaleY = 0;
				TweenLite.to(_promoNotification, 0.5, { autoAlpha:1, scaleX:GlobalConfig.dpiScale, scaleY:GlobalConfig.dpiScale, ease:Back.easeOut });
				TweenLite.delayedCall(3, moveNotification);
			}
			else
			{
				TweenLite.to(_promoNotification, 0.5, { autoAlpha:0, scaleX:0, scaleY:0 });
			}
		}
		
		private function moveNotification():void
		{
			_promoNotification.scaleX = _promoNotification.scaleY = GlobalConfig.dpiScale;
			TweenLite.to(_promoNotification, 0.35, { scaleX:(GlobalConfig.dpiScale + (GlobalConfig.dpiScale * 0.4)), scaleY:(GlobalConfig.dpiScale + (GlobalConfig.dpiScale * 0.4)), ease:Power1.easeInOut, repeat:3, yoyo:true });
			TweenLite.delayedCall(4, moveNotification);
		}
		
	}
}