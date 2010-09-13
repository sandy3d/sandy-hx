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
import sandy.parser.IParser;
import sandy.parser.Parser;
import sandy.parser.ColladaParser;
import sandy.parser.ParserEvent;
import sandy.parser.ParserStack;
import sandy.util.LoaderQueue;
import sandy.events.SandyEvent;
import sandy.events.QueueEvent;
import sandy.core.scenegraph.Camera3D;
import sandy.core.scenegraph.Group;
import sandy.core.scenegraph.Geometry3D;
import sandy.core.scenegraph.Shape3D;
import sandy.materials.BitmapMaterial;
import sandy.materials.ColorMaterial;
#if flash
import sandy.core.scenegraph.StarField;
import sandy.core.data.Vertex;
import flash.filters.GlowFilter;
import flash.text.TextField;
#end
import sandy.core.Scene3D;
import sandy.primitive.Box;
import sandy.view.ViewPort;
import flash.display.Sprite;
import flash.display.BitmapData;
import flash.display.Loader;
import flash.events.Event;
import flash.Lib;
import flash.net.URLRequest;
import flash.net.URLLoader;
import formats.json.JSON;
import Type;

class TestParsers extends TestCase {

	public static function add ( r:hxunit.Runner ) {
				r.addCase( new TestCollada() );
				r.addCase( new TestASE() );
				r.addCase( new TestMax() );
				r.addCase( new TestUtil() );
	}

}

class TestCollada extends TestCase {

	public function testDice() {

			var parser: ColladaParser = Parser.create( "../assets/dice.dae", Parser.COLLADA );
			var ttl = 4000;

			var self = this;
			var root : Group = null;
			var func = function () {
					self.assertEquals( root.children.length, 1 );
					self.assertIs( root.children[0], sandy.core.scenegraph.Shape3D );
					var l_oGeom : Geometry3D = Reflect.field( root.children[0], 'm_oGeometry' );
					self.assertEquals( l_oGeom.aFacesVertexID.length, 12 );
					self.assertEquals( l_oGeom.aVertex.length, 8 );
					self.assertEquals( l_oGeom.aFacesNormals.length, 12 );
					self.assertEquals( l_oGeom.aUVCoords.length, 14 );
					self.assertIs( root.children[0].appearance.frontMaterial, BitmapMaterial );
					var l_oMat : BitmapMaterial = untyped root.children[0].appearance.frontMaterial;
					var l_oLoader : Loader = new Loader();
					l_oLoader.contentLoaderInfo.addEventListener( Event.COMPLETE, function ( e:Event ) {
									self.assertEquals( e.target.content.bitmapData.compare( l_oMat.texture ), 0x00000000 );
					} );
					l_oLoader.load( new URLRequest( '../assets/dice.jpg' ) );
			}
			var cb = asyncResponder( func, ttl );
			parser.addEventListener( ParserEvent.INIT, 
									function (pEvt) {root = pEvt.group; cb();} );

			parser.parse();

	}

	public function testMenu3() {

			var parser: ColladaParser = Parser.create( "../assets/arrow.dae", Parser.COLLADA );
			var ttl = 4000;

			var self = this;
			var root : Group = null;
			var func = function () {

					self.assertEquals( root.children.length, 2 );
					self.assertIs( root.children[0], sandy.core.scenegraph.Shape3D );
					var l_oGeom : Geometry3D = Reflect.field( root.children[0], 'm_oGeometry' );
					self.assertEquals( l_oGeom.aFacesVertexID.length, 38 );
					self.assertEquals( l_oGeom.aVertex.length, 21 );
					self.assertEquals( l_oGeom.aFacesNormals.length, 38 );
					self.assertEquals( l_oGeom.aUVCoords.length, 34 );

					self.assertIs( root.children[1].appearance.frontMaterial, BitmapMaterial );
					var l_oMat : BitmapMaterial = untyped root.children[1].appearance.frontMaterial;
					var l_oULoader : URLLoader = new URLLoader();
					l_oULoader.addEventListener( 'INIT', function ( e:Event ) {
									self.assertEquals( e.target.bitmapData, l_oMat.texture );
					} );
					l_oULoader.load( new URLRequest( '../assets/pCube1SG-pCube2.jpg' ) );

					self.assertIs( root.children[0].appearance.frontMaterial, BitmapMaterial );
					var l_oMat : BitmapMaterial = untyped root.children[1].appearance.frontMaterial;
					var l_oULoader : URLLoader = new URLLoader();
					l_oULoader.addEventListener( 'INIT', function ( e:Event ) {
									self.assertEquals( e.target.bitmapData, l_oMat.texture );
					} );
					l_oULoader.load( new URLRequest( '../assets/pCube1SG-pasted__pPlane1.jpg' ) );

			}
			var cb = asyncResponder( func, ttl );
			parser.addEventListener( ParserEvent.INIT, 
									function (pEvt) {root = pEvt.group; cb();} );

			parser.parse();

	}

	/* A unit test matching example07 ColladaCar */
	public function testColladaCar() {

			var parser:IParser = Parser.create("../assets/models/COLLADA/car.DAE",Parser.COLLADA );
			var parserLF:IParser = Parser.create("../assets/models/COLLADA/wheel_Front_L.DAE",Parser.COLLADA );
			var parserRF:IParser = Parser.create("../assets/models/COLLADA/wheel_Front_R.DAE",Parser.COLLADA );
			var parserLR:IParser = Parser.create("../assets/models/COLLADA/wheel_Rear_L.DAE",Parser.COLLADA );
			var parserRR:IParser = Parser.create("../assets/models/COLLADA/wheel_Rear_R.DAE",Parser.COLLADA );

			var parserStack:ParserStack = new ParserStack();
			parserStack.add("carParser",parser);
			parserStack.add("wheelLFParser",parserLF);
			parserStack.add("wheelRFParser",parserRF);
			parserStack.add("wheelLRParser",parserLR);
			parserStack.add("wheelRRParser",parserRR);
			var l_aStackMap = untyped parserStack.m_aList; 
			assertEquals( l_aStackMap.length, 5 );

			var ttl = 40000;

			var self = this;
			var func = function () {

					// number of shapes imported
					self.assertEquals( untyped Lambda.count( parserStack.m_oGroupMap ), 5 );

					// check car geometry
					var car : Geometry3D = untyped parserStack.getGroupByName("carParser").children[0].m_oGeometry;
					self.assertEquals( car.aFacesVertexID.length, 724 );
					self.assertEquals( car.aVertex.length, 364 );
					self.assertEquals( car.aFacesNormals.length, 724 );
					self.assertEquals( car.aUVCoords.length, 484 );

					// check wheel geometry
					var wheel : Geometry3D = untyped parserStack.getGroupByName("wheelLFParser").children[0].m_oGeometry;
					self.assertEquals( wheel.aFacesVertexID.length, 60 );
					self.assertEquals( wheel.aVertex.length, 32 );
					self.assertEquals( wheel.aFacesNormals.length, 60 );
					self.assertEquals( wheel.aUVCoords.length, 68 );
			}

			var cb = asyncResponder( func, ttl );

			parserStack.addEventListener(ParserStack.COMPLETE, 
							function (pEvt) {cb();} );
			parserStack.start();

	}

}

class TestASE extends TestCase {

	/* A test matching example07 ASECar */
	public function testASECar() {

			var parser:IParser = Parser.create("../assets/models/ASE/car.ASE",Parser.ASE );
			var parserLF:IParser = Parser.create("../assets/models/ASE/wheel_Front_L.ASE",Parser.ASE );
			var parserRF:IParser = Parser.create("../assets/models/ASE/wheel_Front_R.ASE",Parser.ASE );
			var parserLR:IParser = Parser.create("../assets/models/ASE/wheel_Rear_L.ASE",Parser.ASE );
			var parserRR:IParser = Parser.create("../assets/models/ASE/wheel_Rear_R.ASE",Parser.ASE );

			var parserStack:ParserStack = new ParserStack();
			parserStack.add("carParser",parser);
			parserStack.add("wheelLFParser",parserLF);
			parserStack.add("wheelRFParser",parserRF);
			parserStack.add("wheelLRParser",parserLR);
			parserStack.add("wheelRRParser",parserRR);
			var l_aStackMap = untyped parserStack.m_aList; 
			assertEquals( l_aStackMap.length, 5 );

			var ttl = 4000;

			var self = this;
			var func = function () {

					// number of shapes imported
					self.assertEquals( untyped Lambda.count( parserStack.m_oGroupMap ), 5 );

					// check car geometry
					var car : Geometry3D = untyped parserStack.getGroupByName("carParser").children[0].m_oGeometry;
					self.assertEquals( car.aFacesVertexID.length, 724 );
					self.assertEquals( car.aVertex.length, 364 );
					self.assertEquals( car.aFacesNormals.length, 724 );
					self.assertEquals( car.aUVCoords.length, 484 );

					// check wheel geometry
					var wheel : Geometry3D = untyped parserStack.getGroupByName("wheelLFParser").children[0].m_oGeometry;
					self.assertEquals( wheel.aFacesVertexID.length, 60 );
					self.assertEquals( wheel.aVertex.length, 32 );
					self.assertEquals( wheel.aFacesNormals.length, 60 );
					self.assertEquals( wheel.aUVCoords.length, 68 );
			}

			var cb = asyncResponder( func, ttl );

			parserStack.addEventListener(ParserStack.COMPLETE, 
							function (pEvt) {cb();} );
			parserStack.start();

	}

}

class TestMax extends TestCase {

	/* A test matching example07 MaxCar */
	public function testMaxCar() {

			var parser:IParser = Parser.create("../assets/models/3DS/car.3DS", Parser.MAX_3DS );
			var parserLF:IParser = Parser.create("../assets/models/3DS/wheel_Front_L.3DS", Parser.MAX_3DS );
			var parserRF:IParser = Parser.create("../assets/models/3DS/wheel_Front_R.3DS", Parser.MAX_3DS );
			var parserLR:IParser = Parser.create("../assets/models/3DS/wheel_Rear_L.3DS", Parser.MAX_3DS );
			var parserRR:IParser = Parser.create("../assets/models/3DS/wheel_Rear_R.3DS", Parser.MAX_3DS );

			var parserStack:ParserStack = new ParserStack();
			parserStack.add("carParser",parser);
			parserStack.add("wheelLFParser",parserLF);
			parserStack.add("wheelRFParser",parserRF);
			parserStack.add("wheelLRParser",parserLR);
			parserStack.add("wheelRRParser",parserRR);
			var l_aStackMap = untyped parserStack.m_aList; 
			assertEquals( l_aStackMap.length, 5 );

			var ttl = 4000;

			var self = this;
			var func = function () {

					// number of shapes imported
					self.assertEquals( untyped Lambda.count( parserStack.m_oGroupMap ), 5 );

					// check car geometry
					var car : Geometry3D = untyped parserStack.getGroupByName("carParser").children[0].m_oGeometry;
					self.assertEquals( car.aFacesVertexID.length, 724 );
					self.assertEquals( car.aVertex.length, 695 );
					self.assertEquals( car.aFacesNormals.length, 724 );
					self.assertEquals( car.aUVCoords.length, 695 );

					// check wheel geometry
					var wheel : Geometry3D = untyped parserStack.getGroupByName("wheelLFParser").children[0].m_oGeometry;
					self.assertEquals( wheel.aFacesVertexID.length, 60 );
					self.assertEquals( wheel.aVertex.length, 125 );
					self.assertEquals( wheel.aFacesNormals.length, 60 );
					self.assertEquals( wheel.aUVCoords.length, 125 );
			}

			var cb = asyncResponder( func, ttl );

			parserStack.addEventListener(ParserStack.COMPLETE, 
							function (pEvt) {cb();} );
			parserStack.start();

	}

}

class TestUtil extends TestCase {

	/* Used frequently in the parser examples */
	public function testLoaderQueue () {

			var queue:LoaderQueue = new LoaderQueue();
			queue.add( "carSkin", new URLRequest("../assets/textures/car.jpg") );
			queue.add( "wheels", new URLRequest("../assets/textures/wheel.jpg") ); 
			var ttl = 3000;
			var self = this;
			var func = function ( e:Event ) {

					self.assertEquals( Lambda.count( queue.data ), 2 );

					var l_oLoaderA : Loader = new Loader();
					l_oLoaderA.contentLoaderInfo.addEventListener( Event.COMPLETE, function ( e:Event ) {
									self.assertEquals( e.target.content.bitmapData.compare( untyped queue.data.get( "carSkin" ).bitmapData ), 0x00000000 );
									} );
					l_oLoaderA.load( new URLRequest( "../assets/textures/car.jpg" ) );

					var l_oLoaderB : Loader = new Loader();
					l_oLoaderB.contentLoaderInfo.addEventListener( Event.COMPLETE, function ( e:Event ) {
									self.assertEquals( e.target.content.bitmapData.compare( untyped queue.data.get( "wheels" ).bitmapData ), 0x00000000 );
									} );
					l_oLoaderB.load( new URLRequest( "../assets/textures/wheel.jpg" ) );

			};

			var cb = asyncResponder( func, ttl );

			queue.addEventListener(SandyEvent.QUEUE_COMPLETE, 
							function (pEvt) {cb();} );
			queue.start();

	}

}
