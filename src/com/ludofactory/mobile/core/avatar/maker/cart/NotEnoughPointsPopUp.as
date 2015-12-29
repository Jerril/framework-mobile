/*
 Copyright © 2006-2015 Ludo Factory
 Avatar Maker - Ludokado
 Author  : Olivier Chevarin - Maxime Lhoez (refactoring)
 Created : 17 Avril 2015
*/
package com.ludofactory.mobile.core.avatar.maker.cart
{
	
	import com.ludofactory.desktop.core.StarlingRoot;
	import com.ludofactory.desktop.gettext.aliases._;
	import com.ludofactory.desktop.tools.roundUp;
	import com.ludofactory.globbies.events.AvatarMakerEventTypes;
	import com.ludofactory.server.starling.theme.Theme;
	
	import starling.display.Button;
	import starling.display.Image;
	import starling.display.Sprite;
	import starling.events.Event;
	import starling.text.TextField;
	import starling.utils.HAlign;
	import starling.utils.VAlign;
	
	public class NotEnoughPointsPopUp extends Sprite
	{
        /**
         * The popup background. */
        private var _background:Image;

        /**
         * The popup title. */
        private var _titleLabel:TextField;
		/**
		 * The popup description. */
        private var _descriptionLabel:TextField;
		/**
		 * The tool tip label. */
        private var _toolTipLabel:TextField;
        
        /**
         * The close button. */
        private var _closeButton:Button;
        /**
         * The validation button. */
        private var _validateButton:Button;
        
        public function NotEnoughPointsPopUp()
        {
            super();

            _background = new Image(Theme.notEnoughPointsPopupBackgroundTexture);
            addChild(_background);

            _titleLabel = new TextField(430, 50, _("VOUS N'AVEZ PAS ASSEZ DE POINTS"), Theme.FONT_MOUSE_MEMOIRS, 40, 0xffffff);
            _titleLabel.x = 120;
            _titleLabel.y = 18;
            _titleLabel.autoScale = true;
            _titleLabel.batchable = true;
            addChild(_titleLabel);

            //_descriptionLabel = new TextField(_background.width - 40, 40, "Comment obtenir plus de <b>Points</b> pour acheter des <b>trucs cool</b> pour mon avatar ?", Theme.FONT_OSWALD, 18, 0x838383);
            _descriptionLabel = new TextField(_background.width - 40, 40, _("Il vous manque encore quelques Points à récolter mon Capitaine !"), Theme.FONT_OSWALD, 18, 0x838383);
            _descriptionLabel.touchable = false;
            _descriptionLabel.isHtmlText = true;
            _descriptionLabel.autoScale = true;
            _descriptionLabel.batchable = true;
            _descriptionLabel.hAlign = HAlign.CENTER;
            _descriptionLabel.y = 95;
            _descriptionLabel.x = 20;
            addChild(_descriptionLabel);
            
            //_toolTipLabel = new TextField(310, 180, "<textformat leading='-4'>Que vous gagnez ou perdez,<br />vous <font size='20'><b>gagnez des Points</b><br /></font></textformat><font size='20'><b>à chaque partie</b></font> jouée !<font size='10'><br /><br /></font><textformat leading='-4'><p align='right' ><font size='15'>Il y a un tas d'objets que vous pourriez acheter<br />avec tous ces <b>Points</b>, pensez-y !</font></p></textformat>", Theme.FONT_OSWALD , 18 , 0x838383);
            _toolTipLabel = new TextField(310, 180, _("Retirez des objets ou continuez à vous amuser sur le site et ces objets seront à vous !"), Theme.FONT_OSWALD , 18 , 0x838383);
            _toolTipLabel.touchable = false;
            _toolTipLabel.batchable = true;
            _toolTipLabel.isHtmlText = true;
            _toolTipLabel.autoScale = true;
            _toolTipLabel.hAlign = HAlign.LEFT;
            _toolTipLabel.vAlign = VAlign.CENTER;
            _toolTipLabel.x = 278;
            _toolTipLabel.y = 160;
            addChild(_toolTipLabel);
	
	        _closeButton = new Button(StarlingRoot.assets.getTexture("close-button-background"));
	        _closeButton.addEventListener(Event.TRIGGERED, onClose);
	        _closeButton.x = _background.width - _closeButton.width - 16;
	        _closeButton.y = 34;
	        _closeButton.scaleWhenDown = 0.9;
	        addChild(_closeButton);
	
	        _validateButton = new Button(StarlingRoot.assets.getTexture("save-button-background"), _("Continuer"), StarlingRoot.assets.getTexture("save-button-over-background"), StarlingRoot.assets.getTexture("save-button-over-background"));
	        _validateButton.fontName = Theme.FONT_OSWALD;
	        _validateButton.fontColor = 0xffffff;
	        _validateButton.fontBold = true;
	        _validateButton.fontSize = 20;
	        _validateButton.addEventListener(Event.TRIGGERED, onClose);
	        _validateButton.scaleWhenDown = 0.9;
	        _validateButton.x = roundUp((_background.width - _validateButton.width) * 0.72);
	        _validateButton.y = roundUp(_background.height - _validateButton.height - 25);
	        addChild(_validateButton);
        }
	
//------------------------------------------------------------------------------------------------------------
//	Get - Set
	
	    /**
	     * Closes the popup.
	     */
        private function onClose(event:Event):void
        {
	        //_validateButton.enabled = false;
	        //_closeButton.enabled = false;
	        
            dispatchEventWith(AvatarMakerEventTypes.CLOSE_NOT_ENOUGH_COOKIES, false, false);
        }
	
//------------------------------------------------------------------------------------------------------------
//	Dispose
	    
	    override public function dispose():void
	    {
		    _background.removeFromParent(true);
		    _background = null;
		    
		    _titleLabel.removeFromParent(true);
		    _titleLabel = null;
		
		    _descriptionLabel.removeFromParent(true);
		    _descriptionLabel = null;
		
		    _toolTipLabel.removeFromParent(true);
		    _toolTipLabel = null;
		
		    _closeButton.removeEventListener(Event.TRIGGERED, onClose);
		    _closeButton.removeFromParent(true);
		    _closeButton = null;
		    
		    _validateButton.removeEventListener(Event.TRIGGERED, onClose);
		    _validateButton.removeFromParent(true);
		    _validateButton =  null;
		    
		    super.dispose();
	    }
	    
    }
}