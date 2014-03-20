package com.ludofactory.common.soundbis.events{	import com.ludofactory.common.soundbis.SoundItem;		import flash.events.Event;
	/**	 * @author Matt Przybylski [http://www.reintroducing.com] 	 * @version 1.0 	 */	public class SoundManagerEvent extends Event	{//- PRIVATE & PROTECTED VARIABLES -------------------------------------------------------------------------				//- PUBLIC & INTERNAL VARIABLES ---------------------------------------------------------------------------				// event constants		public static const SOUND_ITEM_ADDED:String = "sound.item.added";		public static const SOUND_ITEM_REMOVED:String = "sound.item.removed";		public static const SOUND_ITEM_PLAY_START:String = "sound.item.play.start";		public static const SOUND_ITEM_PAUSE:String = "sound.item.pause";		public static const SOUND_ITEM_STOP:String = "sound.item.stop";		public static const SOUND_ITEM_PLAY_COMPLETE:String = "sound.item.play.complete";		public static const SOUND_ITEM_FADE:String = "sound.item.fade";		public static const SOUND_ITEM_FADE_COMPLETE:String = "sound.item.fade.complete";		public static const SOUND_ITEM_LOAD_ERROR:String = "sound.item.load.error";		public static const SOUND_ITEM_LOAD_PROGRESS:String = "sound.item.load.progress";		public static const SOUND_ITEM_LOAD_COMPLETE:String = "sound.item.load.complete";		public static const REMOVED_ALL:String = "removed.all";		public static const PLAY_ALL:String = "play.all";		public static const STOP_ALL:String = "stop.all";		public static const PAUSE_ALL:String = "pause.all";		public static const MUTE_ALL:String = "mute.all";		public static const UNMUTE_ALL:String = "unmute.all";				public var soundItem:SoundItem;		public var duration:Number;		public var percent:Number;		//- CONSTRUCTOR	-------------------------------------------------------------------------------------------			public function SoundManagerEvent($type:String, $soundItem:SoundItem = null, $duration:Number = 0, $percent:Number = 0, $bubbles:Boolean = false, $cancelable:Boolean = false)		{			super($type, $bubbles, $cancelable);						this.soundItem = $soundItem;			this.duration = $duration;			this.percent = $percent;		}		//- PRIVATE & PROTECTED METHODS ---------------------------------------------------------------------------						//- PUBLIC & INTERNAL METHODS -----------------------------------------------------------------------------				//- EVENT HANDLERS ----------------------------------------------------------------------------------------				//- GETTERS & SETTERS -------------------------------------------------------------------------------------				//- HELPERS -----------------------------------------------------------------------------------------------			public override function clone():Event		{			return new SoundManagerEvent(type, this.soundItem, this.duration, this.percent, bubbles, cancelable);		}				public override function toString():String		{			return formatToString("SoundManagerEvent", "soundItem", "duration", "percent", "type", "bubbles", "cancelable");		}	//- END CLASS ---------------------------------------------------------------------------------------------	}}