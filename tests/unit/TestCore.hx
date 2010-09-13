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


package tests.unit;

import hxunit.TestCase;
import hxunit.Assert;

import sandy.core.scenegraph.TransformGroup;
import sandy.core.scenegraph.Shape3D;
import sandy.core.scenegraph.Geometry3D;
import sandy.core.scenegraph.Group;

class TestCore extends TestCase {

	public static function add ( r:hxunit.Runner ) {
		r.addCase( new TestTransformGroup() );
	}
}

class TestTransformGroup extends TestCase {

	public function testClone() {

		var a : TransformGroup = new TransformGroup();

		// Test a Shape3D
		var shape : Shape3D = new Shape3D();
		shape.geometry = new Geometry3D();

		a.addChild( shape );
		var b :TransformGroup = a.clone( "transformGroup" );
		assertEquals( 1, b.children.length );
		assertEquals( Type.getClass( b.children.pop() ), Type.getClass( shape ) );

		// Test a TransformGroup
		a.addChild( b );
		var c :TransformGroup = a.clone( "c" );
		assertEquals( 2, c.children.length );
		assertEquals( Type.getClass( c.children.pop() ), Type.getClass( b ) );

		// Test a Group
		var group : Group = new Group();
		group.addChild( c );
		group.addChild( shape );
		a.addChild( group );
		var d :TransformGroup = a.clone( "d" );
		assertEquals( 2, d.children.length );
		assertEquals( Type.getClass( d.children.pop() ), Type.getClass( group ) );

	}
}

