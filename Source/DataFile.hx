package ;
import openfl.utils.ByteArray;
import openfl.utils.CompressionAlgorithm;
import openfl.utils.Endian;

import openfl.geom.Rectangle;

import openfl.utils.ByteArray;
import openfl.utils.CompressionAlgorithm;
import openfl.utils.Endian;
import openfl.display.Bitmap;
import openfl.display.BitmapData;

#if neko
import sys.io.File;
import sys.io.FileOutput;
import sys.io.FileInput;
#end

/**
 * ...
 * @author djoker
 */

 


class DataFile
{

public var offset:Int;
public var length:Int;
public var name:String;
public var data:ByteArray;
public var isCompress:Bool;


	public function new(name:String ) 
	{
		this.name = name;
		this.length = 0;
		this.offset = 0;
	    this.data = new ByteArray();
		this.data.endian = Endian.LITTLE_ENDIAN;
	    isCompress = false;
	 
		
	}


	public function writeBytes(bytes:ByteArray)
	{
		data.position = 0;
		bytes.readBytes(data, 0, bytes.length);
		//data.writeBytes(bytes);
		trace("write :"+bytes.length+'<>'+data.length);
		
		data.position = 0;
		this.length = bytes.length;
	}	
	
	public function compress()
	{
		//data.compress(CompressionAlgorithm.LZMA);//html5 dont supor the feature
		this.length = this.data.length;
		isCompress = true;
	}
	public function depress()
	{
		//data.uncompress(CompressionAlgorithm.LZMA);//html5 dont supor the feature
		this.length = this.data.length;
		isCompress = false;
	}
	public function dispose()
	{
		data.clear();
		data = null;
	}
	
	public function toBitmapData():BitmapData
	{
		    data.position = 0;
		   if (data.length<=0) return null;
		    var width   = data.readInt();
		    var  height  = data.readInt();
			 trace(width+'<>'+height);
			 
			 var pixels:ByteArray = new ByteArray(); 
			 data.readBytes(pixels);
			 
			 trace("Pixels size:" + pixels.length);
		     var bd:BitmapData =  new BitmapData(width, height,true,0);
		   //  bd.lock();
			 bd.setPixels(new Rectangle(0, 0, width, height), pixels);
			// bd.unlock();
			// pixels.clear();
			
			data.position = 0;
			
			
			
			 return bd;
			
			
			
	}
	public function saveToFile(filename:String)
	{
		#if neko
		 var f:FileOutput = File.write(filename);
         f.writeString(data.toString());
         f.close();
		 #end
		
	}
	
}