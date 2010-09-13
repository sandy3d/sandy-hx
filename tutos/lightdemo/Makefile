all: flash9 flash10 haxe

flash9:
	mxmlc -sp=../../../../as3/trunk/src -optimize -default-frame-rate 140 -default-size 500 300 -target-player 9.0.124 -output test_f9.swf LightDemo.as

flash10:
	mxmlc -sp=../../../../as3/trunk/src -optimize -default-frame-rate 140 -default-size 500 300 -target-player 10.0.12 -output test_f10.swf LightDemo.as

haxe:
	haxe lightdemo.hxml
