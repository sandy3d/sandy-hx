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

/* note: Javascript tests must be run from a web server - not local file, due to
	* same-domain restrictions */

package tests.unit;

import hxunit.TestCase;
import hxunit.Assert;
import flash.geom.Point;
import sandy.extrusion.data.Polygon2D;

class TestExtrusion extends TestCase {

	public static function add ( r:hxunit.Runner ) {
				r.addCase( new TestPolygon2D() );
	}
}

class TestPolygon2D extends TestCase {

  public function testConvexHull() {
    var arrayElm:Array<Point> = new Array();
    arrayElm[0] = new Point(0,-10);	arrayElm[1] = new Point(0,10);	arrayElm[2] = new Point(30,10); arrayElm[3] = new Point(30,0);
    arrayElm[4] = new Point(20,0);  arrayElm[5] = new Point(20,5);  arrayElm[6] = new Point(10,5); arrayElm[7] = new Point(10,-10);
    arrayElm[8] = new Point(0,-10);

    var sectionElm:Polygon2D = new Polygon2D(arrayElm);
    var l_oPoly:Polygon2D = sectionElm.convexHull();
    var l_aCheck:Array<Point> = [ new Point(0,-10), new Point(0, -10), new Point(10, -10), new Point(30, 0), new Point(30, 10), new Point(0, 10) ];
    for ( i in 0...l_aCheck.length ) {
      assertEquals( l_oPoly.vertices[i].x, l_aCheck[i].x );
      assertEquals( l_oPoly.vertices[i].y, l_aCheck[i].y );
    }
  }
}


