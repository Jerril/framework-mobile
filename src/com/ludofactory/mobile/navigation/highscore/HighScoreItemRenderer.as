/*
Copyright © 2006-2014 Ludo Factory
Framework mobile
Author  : Maxime Lhoez
Created : 18 sept. 2013
*/
package com.ludofactory.mobile.navigation.highscore
{
	import com.ludofactory.common.utils.Utilities;
	import com.ludofactory.common.utils.scaleAndRoundToDpi;
	import com.ludofactory.mobile.core.config.GlobalConfig;
	import com.ludofactory.mobile.core.theme.Theme;
	
	import flash.geom.Point;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;
	
	import feathers.controls.Callout;
	import feathers.controls.Label;
	import feathers.controls.List;
	import feathers.controls.renderers.IListItemRenderer;
	import feathers.core.FeathersControl;
	
	import starling.display.Quad;
	import starling.display.QuadBatch;
	import starling.events.Event;
	import starling.events.Touch;
	import starling.events.TouchEvent;
	import starling.events.TouchPhase;
	
	public class HighScoreItemRenderer extends FeathersControl implements IListItemRenderer
	{
		private static const HELPER_POINT:Point = new Point();
		private static const HELPER_TOUCHES_VECTOR:Vector.<Touch> = new <Touch>[];
		protected var _touchPointID:int = -1;
		
		private static var _isCalloutDisplaying:Boolean = false;
		private static var _calloutLabel:Label;
		private static var _callout:Callout;
		
		/**
		 * The base height of a line in the list. */		
		private static const BASE_HEIGHT:int = 60;
		/**
		 * The scaled item height. */		
		private var _itemHeight:Number;
		
		/**
		 * The base stroke thickness. */		
		private static const BASE_STROKE_THICKNESS:int = 2;
		/**
		 * The scaled stroke thickness. */		
		private var _strokeThickness:Number;
		
		/**
		 * The normal text format. */		
		private static var _normalTextFormat:TextFormat;
		/**
		 * The selected text format. */		
		private static var _selectedTextFormat:TextFormat;
		
		private static var _sideWidth:Number;
		private static var _middleWidth:Number;
		
		/**
		 * Whether the elements have already been positioned. */		
		private var _elementsPositioned:Boolean = false;
		
		/**
		 * The idle background. */		
		private var _idleBackground:QuadBatch;
		/**
		 * 	The selected background. */		
		private var _selectedBackground:QuadBatch;
		
		/**
		 * The rank label. */		
		private var _rankLabel:Label;
		/**
		 * The name label. */		
		private var _nameLabel:Label;
		/**
		 * The number of stars label. */		
		private var _numStarsLabel:Label;
		
		public function HighScoreItemRenderer()
		{
			super();
			//this.touchable = false;
			addEventListener(TouchEvent.TOUCH, touchHandler);
		}
		
		override protected function initialize():void
		{
			super.initialize();
			
			_itemHeight = scaleAndRoundToDpi(BASE_HEIGHT);
			_strokeThickness = scaleAndRoundToDpi(BASE_STROKE_THICKNESS);
			_sideWidth = GlobalConfig.stageWidth * 0.25;
			_middleWidth = GlobalConfig.stageWidth * 0.5;
			
			this.width = GlobalConfig.stageWidth;
			this.height = _itemHeight;
			
			if( !_selectedTextFormat )
				_selectedTextFormat = new TextFormat(Theme.FONT_SANSITA, scaleAndRoundToDpi(24), 0xffdd00, false, false, null, null, null, TextFormatAlign.CENTER);
			if( !_normalTextFormat )
				_normalTextFormat = new TextFormat(Theme.FONT_SANSITA, scaleAndRoundToDpi(24), 0x353535, false, false, null, null, null, TextFormatAlign.CENTER);
			
			// idle
			_idleBackground = new QuadBatch();
			const background:Quad = new Quad( this.actualWidth, _itemHeight, 0xfbfbfb );
			_idleBackground.addQuad( background );
			background.x = _sideWidth;
			background.width = _middleWidth;
			background.color = 0xeeeeee;
			_idleBackground.addQuad( background );
			background.x = 0;
			background.y = _itemHeight - _strokeThickness;
			background.width  = _sideWidth * 2 + _middleWidth;
			background.height = _strokeThickness;
			background.color  = 0xbfbfbf;
			_idleBackground.addQuad( background );
			addChild( _idleBackground );
			
			// selected
			_selectedBackground = new QuadBatch();
			background.y = 0;
			background.color = 0x401800;
			background.height = _itemHeight;
			_selectedBackground.addQuad( background );
			background.x = _sideWidth;
			background.width = _middleWidth;
			background.color = 0x3e1600;
			_selectedBackground.addQuad( background );
			addChild( _selectedBackground );
			
			// labels
			_rankLabel = new Label();
			_rankLabel.text = "999999";
			addChild(_rankLabel);
			_rankLabel.textRendererProperties.textFormat = _normalTextFormat;
			
			_nameLabel = new Label();
			_nameLabel.text = "999999";
			addChild(_nameLabel);
			_nameLabel.textRendererProperties.textFormat = _normalTextFormat;
			
			_numStarsLabel = new Label();
			_numStarsLabel.text = "999999";
			addChild(_numStarsLabel);
			_numStarsLabel.textRendererProperties.textFormat = _normalTextFormat;
		}
		
		override protected function draw():void
		{
			const dataInvalid:Boolean = this.isInvalid(INVALIDATION_FLAG_DATA);
			const selectionInvalid:Boolean = this.isInvalid(INVALIDATION_FLAG_SELECTED);
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
			_rankLabel.width = NaN;
			_rankLabel.height = NaN;
			_rankLabel.validate();
			var newWidth:Number = this.explicitWidth;
			if(needsWidth)
			{
				newWidth = _rankLabel.width;
				newWidth += this._paddingLeft + this._paddingRight;
			}
			var newHeight:Number = this.explicitHeight;
			if(needsHeight)
			{
				newHeight = _rankLabel.height;
			}
			return this.setSizeInternal(newWidth, newHeight, false);
		}
		
		protected function commitData():void
		{
			if(this._owner)
			{
				if( _data )
				{
					_rankLabel.textRendererProperties.textFormat = _nameLabel.textRendererProperties.textFormat = _numStarsLabel.textRendererProperties.textFormat = _data.isMe ? _selectedTextFormat : _normalTextFormat;
					
					_rankLabel.text =  Utilities.splitThousands( _data.rank );
					if( !_data.countryCode )
						_nameLabel.text = _data.truncatedPseudo;
					else
						_nameLabel.text = _data.truncatedPseudo + " (" + _data.countryCode + ")";
					_numStarsLabel.text =  Utilities.splitThousands( _data.score );
					
					_selectedBackground.visible = _data.isMe ? true : false;
					_idleBackground.visible = !_selectedBackground.visible;
				}
				else
				{
					_idleBackground.visible = false;
					_selectedBackground.visible = false;
				}
			}
			else
			{
				_idleBackground.visible = false;
				_selectedBackground.visible = false;
			}
		}
		
		protected function layout():void
		{
			if( !_elementsPositioned )
			{
				_rankLabel.width = _numStarsLabel.width = _sideWidth;
				_nameLabel.width = _middleWidth;
				
				_numStarsLabel.x = _sideWidth + _middleWidth;
				_nameLabel.x = _sideWidth;
				
				_rankLabel.validate();
				_rankLabel.y = _numStarsLabel.y = _nameLabel.y =  (_itemHeight - _rankLabel.height) * 0.5;
				
				_elementsPositioned = true;
			}
		}
		
		protected var _data:HighScoreData;
		
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
			this._data = HighScoreData(value);
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
			if(this._owner)
			{
				this._owner.removeEventListener(Event.SCROLL, owner_scrollHandler);
			}
			this._owner = value;
			if(this._owner)
			{
				this._owner.addEventListener(Event.SCROLL, owner_scrollHandler);
			}
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
			this.invalidate(INVALIDATION_FLAG_SELECTED);
			this.dispatchEventWith(Event.CHANGE);
		}
		
		protected var _paddingTop:Number = 0;
		
		public function get paddingTop():Number
		{
			return this._paddingTop;
		}
		
		public function set paddingTop(value:Number):void
		{
			if(this._paddingTop == value)
			{
				return;
			}
			this._paddingTop = value;
			this.invalidate(INVALIDATION_FLAG_STYLES);
		}
		
		protected var _paddingRight:Number = 0;
		
		public function get paddingRight():Number
		{
			return this._paddingRight;
		}
		
		public function set paddingRight(value:Number):void
		{
			if(this._paddingRight == value)
			{
				return;
			}
			this._paddingRight = value;
			this.invalidate(INVALIDATION_FLAG_STYLES);
		}
		
		protected var _paddingBottom:Number = 0;
		
		public function get paddingBottom():Number
		{
			return this._paddingBottom;
		}
		
		public function set paddingBottom(value:Number):void
		{
			if(this._paddingBottom == value)
			{
				return;
			}
			this._paddingBottom = value;
			this.invalidate(INVALIDATION_FLAG_STYLES);
		}
		
		protected var _paddingLeft:Number = 0;
		
		public function get paddingLeft():Number
		{
			return this._paddingLeft;
		}
		
		public function set paddingLeft(value:Number):void
		{
			if(this._paddingLeft == value)
			{
				return;
			}
			this._paddingLeft = value;
			this.invalidate(INVALIDATION_FLAG_STYLES);
		}
		
		protected function touchHandler(event:TouchEvent):void
		{
			if(!this._isEnabled)
			{
				return;
			}
			
			const touches:Vector.<Touch> = event.getTouches(this, null, HELPER_TOUCHES_VECTOR);
			if(touches.length == 0)
			{
				//end of hover
				return;
			}
			if(this._touchPointID >= 0)
			{
				var touch:Touch;
				for each(var currentTouch:Touch in touches)
				{
					if(currentTouch.id == this._touchPointID)
					{
						touch = currentTouch;
						break;
					}
				}
				
				if(!touch)
				{
					//end of hover
					HELPER_TOUCHES_VECTOR.length = 0;
					return;
				}
				
				if(touch.phase == TouchPhase.ENDED)
				{
					this._touchPointID = -1;
					touch.getLocation(this, HELPER_POINT);
					var isInBounds:Boolean = this.hitTest(HELPER_POINT, true) != null;
					if(isInBounds)
					{
						if( _data.isTruncated )
						{
							if( !_isCalloutDisplaying )
							{
								_isCalloutDisplaying = true;
								if( !_calloutLabel )
								{
									_calloutLabel = new Label();
								}
								_calloutLabel.text = _data.pseudo + " (" + _data.countryCode + ")";
								_callout = Callout.show(_calloutLabel, this, Callout.DIRECTION_UP, false);
								_callout.disposeContent = false;
								_callout.touchable = false;
								_callout.addEventListener(Event.REMOVED_FROM_STAGE, onCalloutRemoved);
								_calloutLabel.textRendererProperties.textFormat = new TextFormat(Theme.FONT_ARIAL, scaleAndRoundToDpi(26), Theme.COLOR_DARK_GREY, false, false, null, null, null, TextFormatAlign.CENTER);
								_calloutLabel.textRendererProperties.wordWrap = false;
							}
						}
					}
				}
			}
			else //if we get here, we don't have a saved touch ID yet
			{
				for each(touch in touches)
				{
					if(touch.phase == TouchPhase.BEGAN)
					{
						this._touchPointID = touch.id;
						break;
					}
				}
			}
			HELPER_TOUCHES_VECTOR.length = 0;
		}
		
		private function onCalloutRemoved(event:Event):void
		{
			event.target.removeEventListener(Event.REMOVED_FROM_STAGE, onCalloutRemoved);
			_isCalloutDisplaying = false;
		}
		
		protected function owner_scrollHandler(event:Event):void
		{
			this._touchPointID = -1;
			if( _callout )
			{
				_callout.removeFromParent(true);
				_callout = null;
			}
		}
		
//------------------------------------------------------------------------------------------------------------
//	Dispose
//------------------------------------------------------------------------------------------------------------
		
		override public function dispose():void
		{
			removeEventListener(TouchEvent.TOUCH, touchHandler);
			
			if( this._owner )
				this._owner.removeEventListener(Event.SCROLL, owner_scrollHandler);
			
			_idleBackground.reset();
			_idleBackground.removeFromParent(true);
			_idleBackground = null;
			
			_selectedBackground.reset();
			_selectedBackground.removeFromParent(true);
			_selectedBackground = null;
			
			_numStarsLabel.removeFromParent(true);
			_numStarsLabel = null;
			
			_nameLabel.removeFromParent(true);
			_nameLabel = null;
			
			_rankLabel.removeFromParent(true);
			_rankLabel = null;
			
			_data = null;
			
			if( _calloutLabel )
			{
				_calloutLabel.removeFromParent(true);
				_calloutLabel = null;
			}
			
			if( _callout )
			{
				_callout.removeFromParent(true);
				_callout = null;
			}
			
			super.dispose();
		}
	}
}