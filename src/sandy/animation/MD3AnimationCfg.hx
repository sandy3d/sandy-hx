
package sandy.animation;

import sandy.HaxeTypes;

/**
 * MD3 animation.cfg file utils
 * @author		Russell Weir (madrok)
 * @date		03.21.2009
 **/
class MD3AnimationCfg {

	/**
	* Reads an animation.cfg file from bytes, returning an array of Animation instances.
	* For each animation line, there should be a corresponding name and type. Lines are
	* parsed in order, so name[0] corresponds to type[0] which is applied to the first
	* line of frame animation data.
	*
	* @param b Input bytes
	* @param names Name for each animation line
	* @param types Animation type string for each line
	* @param md3numbering Standard MD3 files have a strange way of numbering frames in player animations. Turn on to enable correct frame numbers
	**/
	public static function read( b : Bytes, names : Array<String>, types:Array<String>, ?md3numbering:Bool=true) : Hash<Animation> {

		var idx = 0;
		var animations = new Hash();

		if(names.length != types.length)
			throw "Names and types must be the same length";

		var sex : String = "n";
		var footsteps : String = "";
		var eSex = ~/sex[\s]+([a-z])/i;
		var eFootsteps = ~/footsteps[\s]+([a-z]+)/i;
		var eAnim = ~/([0-9]+)[\s]+([0-9]+)[\s]+([0-9]+)[\s]+([0-9]+)[\s]+/;

		var inHeader = true;
		var firstTorso = -1.;
		var offset = -1.;
		var text = b.readUTFBytes(b.length);
		var lines = text.split("\n");
		for(l in lines) {
			if(inHeader) {
				if(eSex.match(l)) {
					sex = eSex.matched(1);
					continue;
				}
				if(eFootsteps.match(l)) {
					footsteps = eFootsteps.matched(1);
					continue;
				}
				if(eAnim.match(l))
					inHeader = false;
			}

			if(!inHeader && eAnim.match(l) && idx < names.length) {


				var anim = new Animation(names[idx]);
				anim.type = types[idx];
				anim.sex = sex;
				anim.soundName = footsteps;
				// first frame, num frames, looping frames, frames per second
				anim.firstFrame = Std.parseFloat(eAnim.matched(1));
				anim.frames = Std.parseFloat(eAnim.matched(2));
				anim.loopingFrames = Std.parseFloat(eAnim.matched(3));
				anim.fps = Std.parseFloat(eAnim.matched(4));

				if(anim.type == "torso" && firstTorso == -1)
					firstTorso = anim.firstFrame;
				if(anim.type == "legs" && md3numbering) {
					if (offset == -1)
						offset = anim.firstFrame - firstTorso;
					anim.firstFrame -= offset;
				}

				animations.set(anim.name, anim);

				idx ++;
			}
		}

		return animations;
	}
}