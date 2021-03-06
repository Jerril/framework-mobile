/*
Copyright © 2006-2015 Ludo Factory - http://www.ludokado.com/
Framework mobile
Author  : Maxime Lhoez
Created : 26 déc. 2013
*/
package com.ludofactory.mobile.navigation.home
{
	
	import com.ludofactory.common.gettext.Domains;
	import com.ludofactory.common.gettext.aliases._d;
	import com.ludofactory.common.utils.Utilities;
	import com.ludofactory.common.utils.scaleAndRoundToDpi;
	import com.ludofactory.mobile.core.AbstractEntryPoint;
	import com.ludofactory.mobile.core.AbstractGameInfo;
	import com.ludofactory.mobile.core.config.GlobalConfig;
	
	import feathers.controls.Label;
	import feathers.controls.List;
	import feathers.controls.renderers.IListItemRenderer;
	import feathers.core.FeathersControl;
	import feathers.skins.IStyleProvider;
	
	import flash.text.TextFormat;
	
	import starling.display.Image;
	import starling.display.Quad;
	
	/**
	 * Custom item renderer used in the CSThreadScreen to display
	 * a conversation between the user and the customer service.
	 */	
	public class RuleItemRenderer extends FeathersControl implements IListItemRenderer
	{
		/**
		 * The minimum height of the item renderer */		
		private var _minItemHeight:int;
		
		/**
		 * The stripe displayed behind a message "bubble". This is an
		 * orange stripe with a shadow at the bottom. */		
		private var _background:Quad;
		/**
		 * The user picture. */		
		private var _picture:Image;
		/**
		 * The message label */		
		private var _message:Label;
		
		private var _padding:int;
		
		private var _titleTextFormat:TextFormat;
		private var _ruleTextFormat:TextFormat;
		
		public function RuleItemRenderer()
		{
			super();
			this.touchable = false;
		}
		
		override protected function initialize():void
		{
			super.initialize();
			
			// TODO Ajuster la position ici pour le format portrait (GlobalConfig.stageWidth * xxx) comme ça a été fait pour le format paysage
			// TODO et rescaler les images TOP et BOTTOM de façon proportionnelle
			width = GlobalConfig.isPhone ? (AbstractGameInfo.LANDSCAPE ? (GlobalConfig.stageWidth * 0.8) : scaleAndRoundToDpi(560) ) : (AbstractGameInfo.LANDSCAPE ? scaleAndRoundToDpi(760) : scaleAndRoundToDpi(760)) ;
			height = _minItemHeight = scaleAndRoundToDpi(150);
			_padding = scaleAndRoundToDpi(GlobalConfig.isPhone ? 20 : 20);
			
			_background = new Quad(this.width, this.height, 0xE8E8E8);
			addChild(_background);
			
			/*_picture = new image();
			_picture.textureScale = GlobalConfig.dpiScale;
			addChild(_picture);*/
			
			_message = new Label();
			addChild(_message);
		}
		
		override protected function draw():void
		{
			const dataInvalid:Boolean = this.isInvalid(INVALIDATION_FLAG_DATA);
			var sizeInvalid:Boolean = this.isInvalid(INVALIDATION_FLAG_SIZE);
			
			if(dataInvalid)
			{
				this.commitData();
			}
			
			sizeInvalid = this.autoSizeIfNeeded() || sizeInvalid;
			
			if(dataInvalid || sizeInvalid)
			{
				this.layout();
			}
		}
		
		protected function autoSizeIfNeeded():Boolean
		{
			const needsWidth:Boolean = isNaN(this.explicitWidth);
			const needsHeight:Boolean = isNaN(this.explicitHeight);
			if(!needsWidth && !needsHeight)
			{
				return false;
			}
			var newWidth:Number = this.explicitWidth;
			if(needsWidth)
			{
				newWidth = _background.width;
			}
			var newHeight:Number = this.explicitHeight;
			if(needsHeight)
			{
				newHeight = _background.height;
			}
			return this.setSizeInternal(newWidth, newHeight, false);
		}
		
		protected function commitData():void
		{
			if(this._owner)
			{
				if( _data )
				{
					_message.visible = true;
					_message.text = _d(Domains.GAME, _data.ruleText);
					if( _data.imageSource != null && _data.imageSource != "" )
					{
						if( !_picture )
						{
							_picture = new Image(AbstractEntryPoint.assets.getTexture(_data.imageSource));
							//_picture.scaleX = _picture.scaleY = GlobalConfig.dpiScale;
							addChild(_picture);
						}
						else
						{
							_picture.texture = AbstractEntryPoint.assets.getTexture(_data.imageSource);
							_picture.scaleX = _picture.scaleY = 1;
							_picture.readjustSize();
						}
					}
					
					
					_isDataCommitted = true;
				}
				else
				{
					_message.text = "";
				}
			}
			else
			{
				_message.visible = false;
			}
		}
		
		private var _isDataCommitted:Boolean = false;
		
		protected function layout():void
		{
			if(!_isDataCommitted )
				return;
			
			switch(_data.type)
			{
				case RuleProperties.TYPE_TITLE:
				{
					if( _picture )
						_picture.visible = false;
					_background.visible = false;
					
					_message.textRendererProperties.textFormat = _titleTextFormat;
					
					_message.width = actualWidth - (_padding * 2);
					_message.x = _padding;
					_message.y = _padding;
					_message.validate();
					
					_background.height = _message.y + _message.height + _padding;
					
					break;
				}
				case RuleProperties.TYPE_RULE_WITH_IMAGE:
				{
					if( _picture )
					{
						_picture.scaleX = _picture.scaleY = 1;
						_picture.visible = true;
					}
					_background.visible = true;
					
					//_picture.validate();
					
					_message.textRendererProperties.textFormat = _ruleTextFormat;
					
					switch(_data.imagePosition)
					{
						case RuleProperties.POSITION_NONE:
						{
							_message.width = actualWidth - (_padding * 2);
							_message.x = _padding;
							_message.y = _padding;
							_message.validate();
							
							_background.height = _message.y + _message.height + _padding;
							
							break;
						}
						case RuleProperties.POSITION_TOP:
						{
							_message.width = actualWidth - (_padding * 2);
							_message.x = _padding;
							_message.y = _picture.height + _padding;
							_message.validate();
							
							_picture.x = _picture.y = 0;
							
							_picture.scaleX = _picture.scaleY = Utilities.getScaleToFillWidth(_picture.width, _background.width);
							_background.height = _message.y + _message.height + _padding;
							
							break;
						}
						case RuleProperties.POSITION_BOTTOM:
						{
							_message.width = actualWidth - (_padding * 2);
							_message.x = _padding;
							_message.y = _padding;
							_message.validate();
							
							_picture.x = 0;
							_picture.y = _message.height + (_padding * 2);
							
							_picture.scaleX = _picture.scaleY = Utilities.getScaleToFillWidth(_picture.width, _background.width);
							_background.height = _picture.y + _picture.height;
							
							break;
						}
						case RuleProperties.POSITION_LEFT:
						{
							_picture.x = _picture.y = 0;
							_picture.scaleX = _picture.scaleY = Utilities.getScaleToFillWidth(_picture.width, (_background.width * 0.25));
							
							_message.width = actualWidth - _picture.width - (_padding * 2);
							_message.x = _picture.width + _padding;
							_message.validate();
							
							if( _message.height > _picture.height )
							{
								_message.y = _padding;
								_picture.y = _message.y + (_message.height - _picture.height) * 0.5;
								
								_background.height = _message.y + _message.height + _padding;
							}
							else
							{
								_message.y = (_picture.height - _message.height) * 0.5;
								
								_background.height = _picture.y + _picture.height;
							}
							
							break;
						}
						case RuleProperties.POSITION_RIGHT:
						{
							_picture.y = 0;
							_picture.scaleX = _picture.scaleY = Utilities.getScaleToFillWidth(_picture.width, (_background.width * 0.25));
							_picture.x = actualWidth - _picture.width;
							
							_message.width = _picture.x - (_padding * 2);
							_message.x = _padding;
							_message.validate();
							
							if( _message.height > _picture.height )
							{
								_message.y = _padding;
								_picture.y = _message.y + (_message.height - _picture.height) * 0.5;
								
								_background.height = _message.y + _message.height + _padding;
							}
							else
							{
								_message.y = (_picture.height - _message.height) * 0.5;
								
								_background.height = _picture.y + _picture.height;
							}
							
							break;
						}
					}
					
					break;
				}
				case RuleProperties.TYPE_RULE_WITHOUT_IMAGE:
				{
					if( _picture )
						_picture.visible = false;
					_background.visible = true;
					
					_message.textRendererProperties.textFormat = _ruleTextFormat;
					
					_message.width = actualWidth - (_padding * 2);
					_message.x = _padding;
					_message.y = _padding;
					_message.validate();
					
					_background.height = _message.y + _message.height + _padding;
					
					break;
				}
			}
			
			setSize(actualWidth, _background.height);
			
			_isDataCommitted = false;
		}
		
		protected var _data:RuleData;
		
		public function get data():Object
		{
			return this._data;
		}
		
		public function set data(value:Object):void
		{
			if(this._data == value)
			{
				return;
			}
			this._data = RuleData(value);
			this.invalidate(INVALIDATION_FLAG_DATA);
		}
		
		protected var _index:int = -1;
		
		public function get index():int
		{
			return this._index;
		}
		
		public function set index(value:int):void
		{
			if(this._index == value)
			{
				return;
			}
			this._index = value;
			this.invalidate(INVALIDATION_FLAG_DATA);
		}
		
		protected var _owner:List;
		
		public function get owner():List
		{
			return List(this._owner);
		}
		
		public function set owner(value:List):void
		{
			if(this._owner == value)
			{
				return;
			}
			this._owner = value;
			this.invalidate(INVALIDATION_FLAG_DATA);
		}
		
		protected var _isSelected:Boolean;
		
		public function get isSelected():Boolean
		{
			return this._isSelected;
		}
		
		public function set isSelected(value:Boolean):void
		{
			if(this._isSelected == value)
			{
				return;
			}
			this._isSelected = value;
		}
		
		public function set titleTextFormat(val:TextFormat):void
		{
			_titleTextFormat = val;
		}
		
		public function set ruleTextFormat(val:TextFormat):void
		{
			_ruleTextFormat = val;
		}
		
		/**
		 * Required for the new Theme. */
		public static var globalStyleProvider:IStyleProvider;
		override protected function get defaultStyleProvider():IStyleProvider
		{
			return RuleItemRenderer.globalStyleProvider;
		}
		
//------------------------------------------------------------------------------------------------------------
//	Dispose
//------------------------------------------------------------------------------------------------------------
		
		override public function dispose():void
		{
			if( _picture )
			{
				_picture.removeFromParent(true);
				_picture = null;
			}
			
			_message.removeFromParent(true);
			_message = null;
			
			_data = null;
			
			super.dispose();
		}
	}
}