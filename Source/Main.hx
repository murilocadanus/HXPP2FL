package;


import openfl.display.Sprite;
import openfl.text.Font;
import openfl.text.TextField;
import openfl.text.TextFormat;
import openfl.display.Bitmap;

import haxe.io.Bytes;
import haxe.crypto.Base64;
import openfl.utils.ByteArray;
import openfl.utils.Endian;
import openfl.display.Loader;
import openfl.events.Event;
import openfl.events.ProgressEvent;

import openfl.Assets;
import openfl.display.BitmapData;

class Main extends Sprite
{
	var _imgLoader:Loader;
	var _format = new TextFormat ("Katamotz Ikasi", 30, 0x7A0026);

	public function new ()
	{	
		super();
		createArrayImageCall();
	}

	private function createSumRemoteCall()
	{
		// Native call
		var a = 1; var b = 2;
		var n = NativeCOM.sum(a, b);

		// Sum text field
		var intTextField = new TextField ();
		intTextField.defaultTextFormat = _format;
		intTextField.embedFonts = true;
		intTextField.selectable = false;
		intTextField.x = 50;
		intTextField.y = 50;
		intTextField.width = 300;
		intTextField.text = "Native Sum: " + a + " + " + b + " = " + n;
		addChild (intTextField);
	}

	private function createStringRemoteCall()
	{
		var s = NativeCOM.byteString();
		// String Array text field
		var byteStringTextField = new TextField ();
		byteStringTextField.defaultTextFormat = _format;
		byteStringTextField.embedFonts = true;
		byteStringTextField.selectable = false;
		byteStringTextField.x = 50;
		byteStringTextField.y = 150;
		byteStringTextField.width = 500;
		byteStringTextField.text = s;
		addChild (byteStringTextField);
	}

	private function createArrayRemoteCall()
	{
		// Convert cpp.UInt8 to haxe.io.Bytes
		var u:Bytes = Bytes.ofData(NativeCOM.byteArray());

		// Convert haxe.io.Bytes to openfl.utils.ByteArray
		var byteArray:ByteArray = ByteArray.fromBytes(u);

		// Byte Array text field
		var byteArrayTextFieldSum = new TextField ();
		byteArrayTextFieldSum.defaultTextFormat = _format;
		byteArrayTextFieldSum.embedFonts = true;
		byteArrayTextFieldSum.selectable = false;
		byteArrayTextFieldSum.x = 50;
		byteArrayTextFieldSum.y = 250;
		byteArrayTextFieldSum.width = 100;
		byteArrayTextFieldSum.text = "bytesArray[" + byteArray.length + "]: " + byteArray[0] + " " + byteArray[1] + " " + byteArray[2];
		addChild (byteArrayTextFieldSum);
	}

	private function createArrayImageCall()
	{	
		// Convert cpp.UInt8 to haxe.io.Bytes
		//var imgData:Bytes = Bytes.ofData(NativeCOM.byteImageArray());

		// Convert haxe.io.Bytes to openfl.utils.ByteArray
		//var ba:ByteArray = ByteArray.fromBytes(imgData);

		// Byte Array image Base64
		var imgData:String = NativeCOM.byteImageArray();
		var ba:ByteArray = Base64.decode(imgData);

		trace(ba.readUTF());

		_imgLoader = new Loader(); 
		_imgLoader.contentLoaderInfo.addEventListener(Event.COMPLETE, textureLoadComplete);
		_imgLoader.loadBytes(ba);
	}

	private function textureLoadComplete(e:Event):Void
	{
		var bitmap:Bitmap = cast(_imgLoader.content, Bitmap);
		var bdata:BitmapData = bitmap.bitmapData;

		//bitmap.x = 50;
		//bitmap.y = 350;
        addChild (bitmap);
	}
}
