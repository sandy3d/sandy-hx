/*
# ***** BEGIN LICENSE BLOCK *****
Copyright the original author or authors.
Licensed under the MOZILLA PUBLIC LICENSE, Version 1.1 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at
	http://www.mozilla.org/MPL/MPL-1.1.html
Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.

# ***** END LICENSE BLOCK *****
*/

/* All of these tests require the 'hxunit' package available here: http://code.google.com/p/hxunit/ */

package tests.unit;

class TestAll {

		public static function main() {

				// bootstrap the javascript environment 
#if js
				neash.Lib.Init("Container", 400, 400);
				neash.Lib.Run();

				if(haxe.Firebug.detect()) {
						haxe.Firebug.redirectTraces();
				}
#end

				var r = new hxunit.Runner();
				TestParsers.add(r);
				TestExtrusion.add(r);
				TestCore.add(r);
				r.run();
		}
}
