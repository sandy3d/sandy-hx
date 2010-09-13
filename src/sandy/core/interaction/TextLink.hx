/**
* ...
* @author Default
* @author Niel Drummond - haXe port
*
*/

package sandy.core.interaction;

import flash.geom.Rectangle;
import flash.text.TextField;
#if flash9
import flash.utils.Dictionary;
#end

import sandy.HaxeTypes;

class TextLink
{


#if flash9
	public static var textLinks : Dictionary;
#end

	public var x 				: Float;
	public var y 				: Float;
	public var height			: Float;
	public var width			: Float;

	private var __sHRef			: String;
	private var __sTarget		: String;
	private var __iOpenIndex	: Int;
	private var __iCloseIndex	: Int;
	private var __tfOwner		: TextField;
	private var __rBounds		: Rectangle;

	public function new()
	{
		x = 0;
		y = 0;
		height = 0;
		width = 0;
	}

/* ****************************************************************************
* PUBLIC FUNCTIONS
**************************************************************************** */
	/**
	 * Return an array of textlinks
	 * @param	t
	 * @return
	 */
	public static function getTextLinks( t : TextField, ?force : Bool=false ) : Array<TextLink>
	{
#if flash
		if ( t.htmlText == null ) return null;
		if ( textLinks == null ) textLinks = new Dictionary();
		if ( untyped( textLinks[t] ) && !force ) return untyped( textLinks[t] );

		untyped( textLinks[t] = new Array() );

		var rawText 	: String = t.htmlText;

		var reHRef		: EReg = ~/href=['"].*?['"]/i;
		var reTarget	: EReg = ~/target=['"].*?['"]/i;
		var reLink		: EReg = ~/<A.*?A>/i;
		var openA		: EReg = ~/<A.*?\>/i;
		var closeA		: EReg = ~/<\/A>/i;

	//	replace html tag with empty string
		var reHTMLTag	: EReg = ~/<[^A][^\/A].*?>/gi;
		rawText = reHTMLTag.replace( rawText, "" );

		reLink.match( rawText );
		var linkText : Array<String> = [];
		for ( i in 1...reLink.matchedPos().len )
				linkText.push( reLink.matched(i) );

		while ( linkText.length > 0 )
		{
			var link : TextLink = new TextLink();
			link.owner = t;
			untyped( textLinks[t].push( link ) );

			reHRef.match( linkText[0] );
			var h : String = reHRef.matched(0);
			link.href = h.substr( 6, h.length-1 );

			reTarget.match( linkText[0] );
			var tg : String = reTarget.matched(0);
			link.target = tg.substr( 8, tg.length-1 );

		//	remove <a ... >
			openA.match( rawText );
			var mt : String = openA.matched(0);
			link.openIndex = rawText.indexOf( mt );
			rawText = openA.replace( rawText, "" );

		//	delete closing tag
			closeA.match( rawText );
			mt = closeA.matched(0);
			link.closeIndex =  rawText.indexOf( mt );
			rawText = closeA.replace( rawText, "" );

			link._init();

			reLink.match( rawText );
			linkText = [];
			for ( i in 1...reLink.matchedPos().len )
					linkText.push( reLink.matched(i) );
		}

		return untyped( textLinks[t] );
#else
		return [];
#end
	}

	public function getBounds() : Rectangle
	{
		return __rBounds;
	}


/* ****************************************************************************
* GETTER && SETTER
**************************************************************************** */
	public var owner(__getOwner,__setOwner) : TextField;
	private function __getOwner() : TextField
	{
		return __tfOwner;
	}
	private function __setOwner( tf : TextField ) : TextField
	{
		__tfOwner = tf;
		return tf;
	}

	public var target(__getTarget,__setTarget) : String;
	private function __getTarget() : String
	{
		return __sTarget;
	}
	private function __setTarget( s : String ) : String
	{
		__sTarget = s;
		return s;
	}

	public var href(__getHref,__setHref) : String;
	private function __getHref() : String
	{
		return __sHRef;
	}
	private function __setHref( s : String ) : String
	{
		__sHRef = s;
		return s;
	}

	public var openIndex(__getOpenIndex,__setOpenIndex) : Int;
	private function __getOpenIndex() : Int
	{
		return __iOpenIndex;
	}
	private function __setOpenIndex( i : Int ) : Int
	{
		__iOpenIndex = i;
		return i;
	}

	public var closeIndex(__getCloseIndex,__setCloseIndex) : Int;
	private function __getCloseIndex() : Int
	{
		return __iCloseIndex;
	}
	private function __setCloseIndex( i : Int ) : Int
	{
		__iCloseIndex = i;
		return i;
	}


/* ****************************************************************************
* PRIVATE FUNCTIONS
**************************************************************************** */
	private function _init() : Void
	{
		for ( j in 0...(__iCloseIndex - __iOpenIndex) )
		{
			var rectB : Rectangle = __tfOwner.getCharBoundaries( openIndex + j );
			if ( j == 0 ) {
				x = rectB.x;
				y = rectB.y;
			}
			width += rectB.width;
			height = height < rectB.height ? rectB.height : height ;
		}

		__rBounds = new Rectangle();
		__rBounds.x = x;
		__rBounds.y = y;
		__rBounds.height = height;
		__rBounds.width = width;
	}

}


