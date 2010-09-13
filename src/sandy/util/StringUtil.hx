
package sandy.util;

import sandy.HaxeTypes;

/**
* Utility class for string manipulation.
*
* @author		Thomas Pfeiffer - kiroukou
* @version		3.1
* @date 		13.08.2008
*/
class StringUtil
{
	/**
	* Replaces a sub string with another in the target string.
	*
	* @param p_sStr 	The string to modify.
	* @param p_sOld 	The pattern to replace.
	* @param p_sNew 	What to replace the pattern with.
	*
	* @return			The modified string.
	*/
	public static function replace( p_sStr:String, p_sOld:String, p_sNew:String ):String
	{
		// we do the replacement if the element is present at least once.
		if( p_sStr.lastIndexOf( p_sOld ) >= 0)
		{
			return p_sStr.split( p_sOld ).join( p_sNew );
		}
		else
			return p_sStr;
	}

	/**
	* Returns all sub strings in a string between two given delimiter patterns.
	*
	* <p>The delimiters are not included in the results.</p>
	*
	* @param p_sStr	The string to search.
	* @param p_sStart	The start delimiter.
	* @param p_sEnd	The end delimiter.
	*
	* @return 		An array of found sub strings. Empty if no matching patterns were found.
	*/
	public static function getTextBetween( p_sStr:String, p_sStart:String, p_sEnd:String ):Array<String>
	{
		var r:Array<String> = [];
		var idd:Int 	= 0;
		var idf:Int 	= p_sStart.length;
		// --
		while( ( idd = p_sStr.indexOf( p_sStart, idd ) ) > 0 && ( idf = p_sStr.indexOf( p_sEnd, idd+p_sStart.length ) ) > 0 )
		{
			r.push( p_sStr.substr( idd+p_sStart.length, idf ) );
			idd = idf+p_sEnd.length;
			idf = idd+p_sStart.length;
		}
		return r;
	}

//--------------------------The following added by [Peanut]-------------------------//
	/**
	* Returns pairs of start and end indices of a block in a source string.
	*
	* <p>The target string is searched for blocks of text between a start and and an end delimiter string.<br/>
	* The start and end indices into the searched string, for each found block is stored in a two dimensional array.<br />
	* All inices are returned as an array of index pairs.</p>
	*
	*	<p>array struct:</p>
	*	<p>array[0] = [Block_Start_String_Length, Block_End_String_Length]</p>
	*	<p>array[1] = [Start_Index_1, End_Index_1]</p>
	*	<p>array[x] = [Start_Index_x, End_Index_x]</p>
	*
	* @param p_sStr		The string to search.
	* @param p_sStart		Block start with.
	* @param p_sEnd		Block end with.
	*
	* @return		An array containtng all the start and end indices.
	*/
	public static function findBlockIndex (p_sStr:String, p_sStart:String, p_sEnd:String):Array<Array<Int>>  {
		var pps:Array<Int> = new Array(), ppe:Array<Int> = new Array();
		var pairs:Array<Array<Int>> = new Array();
		pairs.push([p_sStart.length, p_sEnd.length]);
		//--start serach
		var searchStart1:Int = -1;
		var searchStart2:Int = -1;
		var i:Int;
		while (p_sStr.indexOf(p_sStart, searchStart1+1)>-1 && p_sStr.indexOf(p_sEnd, searchStart2+1)>-1){
			searchStart1 = p_sStr.indexOf(p_sStart, searchStart1+1);
			pps.push(searchStart1);
			searchStart2 = p_sStr.indexOf(p_sEnd, searchStart2+1);
			ppe.push(searchStart2);
		}
		var i = 0;
		while(i < (ppe.length-1)) {
			var j = i+1;
			while(j < pps.length) {
				var a:Float = ppe[i]-pps[j];
				if (a<0) {
					pairs.push( [pps[j-1]+p_sStart.length, ppe[i]] );
					pps.splice(j-1, 1);
					ppe.splice(i, 1);
					i--;
					break;
				}
				j++;
				//delete a; // throws an error in as3
			}
			i++;
		}
		for (i in 0...pps.length) {
			pairs.push( [pps[i]+p_sStart.length, ppe[pps.length-1-i]] );
		}
		pairs.sort(function (a:Array<Int>, b:Array<Int>):Int {
			if (a[0]<b[0]) {
				return -1;
			} else {
				return 1;
			}
		});
		//
		return pairs;
	}

	/**
	* Returns all blocks between start and end indices from a source string.
	*
	* <p>Given an array of index pairs, normally created by a call to findBlockIndex,
	* all blocks between index pairs are extracted and stored in an array</p>
	*
	* @param p_sStr		The string to search.
	* @param p_aPairs		Index pairs created by findBlockIndex.
	* @param p_bWithSymbol	Include start and end symbols if set to true.
	*
	* @return			All blocks between the start and end indices.
	*/
	public static function getBlocks (p_sStr:String, p_aPairs:Array<Array<Int>>, p_bWithSymbol:Bool):Array<String>  {
		var pairStrs:Array<String> = new Array();
		var i:Float;
		var t:String;

		if (p_bWithSymbol) {
			for(i in 1...p_aPairs.length) {
				t = p_sStr.substr(p_aPairs[i][0]-p_aPairs[0][0], p_aPairs[i][1]+p_aPairs[0][1]);
				pairStrs.push(t);
			}
		} else {
			for(i in 1...p_aPairs.length) {
				t = p_sStr.substr(p_aPairs[i][0], p_aPairs[i][1]);
				pairStrs.push(t);
			}
		}
		return pairStrs;
	}

	/**
	* Returns a specific sub string of the source string.
	*
	* @param p_sStr		The string to search.
	* @param p_aPairs		Index pairs created by findBlockIndex.
	* @param p_nIndex		Start index into the string of the block to search for.
	* @param p_bNoSymbol	Do not include start and end symbols.
	*
	* @return		The searched sub string or an empty string if not found.
	*/
	public static function getBlockByIndex(p_sStr:String, p_aPairs:Array<Array<Int>>, p_nIndex:Float, p_bNoSymbol:Bool):String{
		var _str:String = "";
		for (i in 1...p_aPairs.length) {
			if(p_nIndex == p_aPairs[i][0]-p_aPairs[0][0])
				if(p_bNoSymbol)
					_str = p_sStr.substr(p_aPairs[i][0], p_aPairs[i][1]);
				else
					_str = p_sStr.substr(p_aPairs[i][0]-p_aPairs[0][0], p_aPairs[i][1]+p_aPairs[0][1]);
		}

		return _str;
	}

	/**
	* Returns the start and end indices for a substr, analyzed by findBlockIndex.
	*
	* @param p_aPairs	Index pairs created by findBlockIndex.
	* @param p_nIndex	Start index into the string of the block of interest.
	*
	* @return		The pair of start and end indices, [-1, -1] if not found.
	*/
	public static function getBlockRange(p_aPairs:Array<Array<Int>>, p_nIndex:Float):Array<Int>{
		for(i in 1...p_aPairs.length) {
			if(p_nIndex == p_aPairs[i][0]-p_aPairs[0][0])
				return [p_aPairs[i][0]-p_aPairs[0][0], p_aPairs[i][1]+p_aPairs[0][1]];
		}
		return [-1, -1];
	}

	/**
	* Strips &quot;\r&quot; and &quot;\n&quot; characters from a string and removes consecutive spaces.
	*
	* @param p_sStr	The string to modify.
	* @param p_aExpand	Other strings you want to clear out.
	*
	* @return			The modified string.
	*/
	public static function clear(p_sStr:String, p_aExpand:Array<String>):String{
		p_sStr = p_sStr.split("\r").join(" ");
		p_sStr = p_sStr.split("\n").join(" ");
		if(p_aExpand != null){
			for(i in 0...p_aExpand.length) {
				p_sStr = p_sStr.split(p_aExpand[i]).join(" ");
			}
		}
		p_sStr = StringUtil.clearRepeat(p_sStr, " ", " ");
		return p_sStr;
	}

	/**
	* Clears the source string from multiple occurences of a pattern.
	*
	* <p>Ex: If you want to clear "ababab", you can use "ab" as a pattern.</p>
	*
	* @param p_sRepeat		The pattern to clear out.
	* @param p_sReplace	Replace chars, default is a space.
	*
	* @return			The modified string.
	*/
	public static function clearRepeat(p_sStr:String, p_sRepeat:String, ?p_sReplace:String=""):String{
		if(p_sReplace == "") p_sReplace = " ";
		var r:String = p_sRepeat+p_sRepeat;

		while (p_sStr.indexOf(r) > -1)
			p_sStr = p_sStr.split(r).join(p_sRepeat);

		return p_sStr.split(p_sRepeat).join(p_sReplace);
	}

	/**
	* Returns the index of the Nth occurance of sub string.
	*
	* @param p_sStr	The string to search.
	* @param p_sSubstr	Sub string you want find.
	* @param p_nOccur	The occurance of the sub string to find.
	* @param p_nStart	Start index for the search.
	*
	* @return		Start index of the search sub string.
	*/
	public static function indexTimes(p_sStr:String, p_sSubstr:String, p_nOccur:Int, p_nStart:Int):Int
	{
		var id:Int = p_nStart > 0 ? p_nStart : 0;
		for(i in 0...p_nOccur) {
			id = p_sStr.indexOf(p_sSubstr, id)+1;
		}
		return id-1;
	}
//--------------------------------------END-------------------------------------//
}
