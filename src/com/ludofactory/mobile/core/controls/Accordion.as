/*
Copyright © 2006-2014 Ludo Factory
Framework mobile
Author  : Maxime Lhoez
Created : 2 sept. 2013
*/
package com.ludofactory.mobile.core.controls
{
	import com.ludofactory.mobile.core.AbstractEntryPoint;
	import com.ludofactory.mobile.core.events.LudoEventType;
	import com.ludofactory.mobile.core.test.vip.VipAccordionItem;
	
	import feathers.controls.ScrollContainer;
	import feathers.layout.VerticalLayout;
	
	import starling.events.Event;
	
	public class Accordion extends ScrollContainer
	{
		private var _dataProvider:Vector.<AbstractAccordionItem>;
		
		public function Accordion()
		{
			super();
		}
		
		override protected function initialize():void
		{
			super.initialize();
			
			const vlayout:VerticalLayout = new VerticalLayout();
			layout = vlayout;
			
			if( _dataProvider )
			{
				var accordionElement:AbstractAccordionItem;
				for( var i:int = 0; i < _dataProvider.length; i++)
				{
					accordionElement = _dataProvider[i];
					accordionElement.index = i;
					accordionElement.isLast = i == (_dataProvider.length - 1) ? true : false;
					accordionElement.addEventListener(LudoEventType.EXPAND_BEGIN, collapseAllOthers);
					accordionElement.addEventListener(LudoEventType.EXPAND_COMPLETE, onExpandComplete);
					addEventListener(Event.SCROLL, accordionElement.onScroll);
					addChild(accordionElement);
				}
			}
		}
		
		override protected function draw():void
		{
			super.draw();
			
			if( _dataProvider )
			{
				const sizeInvalid:Boolean = isInvalid( INVALIDATION_FLAG_SIZE );
				if( sizeInvalid )
				{
					var accordionElement:AbstractAccordionItem;
					var i:int;
					for( i = 0; i < _dataProvider.length; i++)
					{
						accordionElement = _dataProvider[i];
						accordionElement.width = this.actualWidth;
					}
				}
			}
		}
		
		public function testVip(indexesToSetVisible:Array, newPrivilegesIndexes:Array):void
		{
			if( _dataProvider )
			{
				var abstractAccordionItem:AbstractAccordionItem;
				for each(abstractAccordionItem in _dataProvider )
				{
					abstractAccordionItem.visible = false;
					abstractAccordionItem.includeInLayout = false;
					abstractAccordionItem.collapse(0);
					VipAccordionItem(abstractAccordionItem).isNew = false;
				}
				
				for each(abstractAccordionItem in _dataProvider )
				{
					for each(var index:int in indexesToSetVisible )
					{
						if( abstractAccordionItem.index == index )
						{
							if( newPrivilegesIndexes.indexOf( abstractAccordionItem.index ) != -1 )
								VipAccordionItem(abstractAccordionItem).isNew = true;
							abstractAccordionItem.visible = true;
							abstractAccordionItem.includeInLayout = true;
						}
					}
				}
			}

            // go back to the top of the list
            scrollToPosition(0, 0, 0.5);
		}
		
//------------------------------------------------------------------------------------------------------------
//	Handlers
//------------------------------------------------------------------------------------------------------------
		
		private function collapseAllOthers(event:Event):void
		{
			var accordionElement:AbstractAccordionItem = AbstractAccordionItem(event.target);
			var otherAccordionElements:AbstractAccordionItem;
			for(var i:int = 0; i < _dataProvider.length; i++)
			{
				otherAccordionElements = _dataProvider[i];
				
				if(otherAccordionElements == accordionElement)
					continue;
				
				if(otherAccordionElements.isExpanded)
					otherAccordionElements.collapse();
			}
		}
		
		private function onExpandComplete(event:Event):void
		{
			if( AbstractAccordionItem(event.target).isLast )
				scrollToPosition(NaN, maxVerticalScrollPosition, 0.5);
			
			if( AbstractEntryPoint.screenNavigator.activeScreenID == ScreenIds.MY_ACCOUNT_SCREEN )
				scrollToPosition(NaN, 0, 0.5);
		}
		
		public function set dataProvider(val:Vector.<AbstractAccordionItem>):void
		{
			_dataProvider = val;
		}
		
		public function get dataProvider():Vector.<AbstractAccordionItem>
		{
			return _dataProvider;
		}
		
//------------------------------------------------------------------------------------------------------------
//	Dispose
//------------------------------------------------------------------------------------------------------------
		
		override public function dispose():void
		{
			if( _dataProvider )
			{
				var accordionElement:AbstractAccordionItem;
				for( var i:int = 0; i < _dataProvider.length; i++)
				{
					accordionElement = _dataProvider[i];
					accordionElement.removeEventListener(LudoEventType.EXPAND_BEGIN, collapseAllOthers);
					accordionElement.removeEventListener(LudoEventType.EXPAND_COMPLETE, onExpandComplete);
					removeEventListener(Event.SCROLL, accordionElement.onScroll);
					accordionElement.removeFromParent(true);
					accordionElement = null;
				}
				accordionElement = null;
				
				_dataProvider.length = 0;
			}
			
			super.dispose();
		}
		
	}
}