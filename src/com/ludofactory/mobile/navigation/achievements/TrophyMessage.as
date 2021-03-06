/*
Copyright © 2006-2015 Ludo Factory - http://www.ludokado.com/
Framework mobile
Author  : Maxime Lhoez
Created : 4 nov. 2013
*/
package com.ludofactory.mobile.navigation.achievements
{
	
	import com.greensock.TweenLite;
	import com.ludofactory.common.utils.scaleAndRoundToDpi;
	import com.ludofactory.mobile.core.AbstractEntryPoint;
	import com.ludofactory.mobile.core.config.GlobalConfig;
	import com.ludofactory.mobile.core.theme.Theme;
	
	import feathers.controls.ImageLoader;
	import feathers.core.FeathersControl;
	import feathers.display.Scale9Image;
	import feathers.skins.IStyleProvider;
	
	import starling.core.Starling;
	import starling.extensions.PDParticleSystem;
	import starling.text.TextField;
	
	/**
	 * A trophy message.
	 */	
	public class TrophyMessage extends FeathersControl
	{
		/**
		 * The trophy background. */		
		private var _background:Scale9Image;
		
		/**
		 * The trophy image. */		
		private var _image:ImageLoader;
		
		/**
		 * The trophy message. */		
		private var _message:TextField;
		
		/**
		 * The trophy data. */		
		private var _trophyData:TrophyData;
		
		/**
		 * Particles */		
		private var _particles:PDParticleSystem;
		
		public function TrophyMessage( trophyData:TrophyData )
		{
			super();
			touchable = false;
			_trophyData = trophyData;
		}
		
		override protected function initialize():void
		{
			super.initialize();
			
			this.width = scaleAndRoundToDpi(500);
			this.height = scaleAndRoundToDpi(130);
			
			_background = new Scale9Image(Theme.trophyBackgroundSkinTextures, GlobalConfig.dpiScale);
			addChild(_background);
			
			_particles = new PDParticleSystem(Theme.particleSlowXml, Theme.particleRoundTexture);
			_particles.touchable = false;
			_particles.maxNumParticles = scaleAndRoundToDpi(100);
			_particles.startSizeVariance = scaleAndRoundToDpi(15);
			_particles.endSize = scaleAndRoundToDpi(10);
			_particles.endSizeVariance = scaleAndRoundToDpi(10);
			_particles.speed = scaleAndRoundToDpi(10);
			_particles.lifespan = scaleAndRoundToDpi(_particles.lifespan);
			_particles.lifespanVariance = scaleAndRoundToDpi(_particles.lifespanVariance);
			addChild(_particles);
			Starling.juggler.add(_particles);
			
			_image = new ImageLoader();
			_image.source = _trophyData.textureName.indexOf("http") >= 0 ? _trophyData.textureName : AbstractEntryPoint.assets.getTexture(_trophyData.textureName);
			_image.snapToPixels = true;
			addChild(_image);
			
			_message = new TextField(10, 10, _trophyData.description, Theme.FONT_SANSITA, scaleAndRoundToDpi(24), Theme.COLOR_WHITE);
			_message.autoScale = true;
			addChild(_message);
		}
		
		override protected function draw():void
		{
			super.draw();
			
			_background.width = actualWidth;
			_background.height = actualHeight;
			
			_image.height = actualHeight - scaleAndRoundToDpi(6); // background stroke
			_image.validate();
			_image.x = actualWidth - _image.width - scaleAndRoundToDpi(5);
			_image.y = (actualHeight - _image.height) * 0.5;
			
			_message.x = scaleAndRoundToDpi(10);
			_message.width = _image.x - _message.x - scaleAndRoundToDpi(5);
			_message.height = actualHeight;
			
			_particles.emitterX = (actualWidth * 0.5);
			_particles.emitterY = (actualHeight * 0.5);
			_particles.emitterXVariance = (actualWidth * 0.5);
			_particles.emitterYVariance = (actualHeight * 0.5);
			_particles.start();
			
			TweenLite.to(_message, 0.5, { delay:3, alpha:0, onComplete:displayReward });
		}
		
		/**
		 * Replaces the trophy description by the rewerd.
		 */		
		private function displayReward():void
		{
			_message.text = _trophyData.reward;
			_message.fontSize = scaleAndRoundToDpi(38);
			_message.y = (Math.max(actualHeight, _message.height) - Math.min(actualHeight, _message.height)) * 0.5;
			TweenLite.to(_message, 0.5, { alpha:1 });
		}
		
//------------------------------------------------------------------------------------------------------------
//	Get / Set
//------------------------------------------------------------------------------------------------------------
		
		public function set background(val:Scale9Image):void
		{
			_background = val;
		}
		
		/**
		 * Required for the new Theme. */
		public static var globalStyleProvider:IStyleProvider;
		override protected function get defaultStyleProvider():IStyleProvider
		{
			return TrophyMessage.globalStyleProvider;
		}
		
//------------------------------------------------------------------------------------------------------------
//	Dispose
//------------------------------------------------------------------------------------------------------------
		
		override public function dispose():void
		{
			Starling.juggler.remove(_particles);
			_particles.stop(true);
			_particles.removeFromParent(true);
			_particles = null;
			
			_background.removeFromParent(true);
			_background = null;
			
			_image.removeFromParent(true);
			_image = null;
			
			_message.removeFromParent(true);
			_message = null;
			
			_trophyData = null;
			
			super.dispose();
		}
		
	}
}