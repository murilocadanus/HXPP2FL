package ;

import openfl.display.Loader;
import openfl.display.LoaderInfo;
import openfl.events.Event;
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

import openfl.Assets;
/**
 * ...
 * @author djoker
 */


class DataPack
{

	private var files:Map < String, DataFile>;
	private var filesIndex:Int;
	private var filesId:Array<DataFile>;
	public function new() 
	{
		files =new Map < String, DataFile>();
		filesIndex = 0;
		filesId = [];

		
	}

		public function addFile(filename:String,name:String):Bool
	{
		if (Assets.exists(filename))
		{
		var file:DataFile = new DataFile(name);
	//	var data:ByteArray = Assets.getBytes(filename);
	//	data.endian = Endian.LITTLE_ENDIAN;
	//	data.writeByte(
		file.writeBytes(Assets.getBytes(filename));
	  //  file.data=Assets.getBytes(filename);
		add(file);
		filesIndex++;
		return true;
		} else 
		{
			return false;
		  //throw("asset " + filename + "dont exists");
		}
	}
	/*
	 * deprecated now i use data loader
	 * */
	
		public function addBitmapPixels(filename:String,name:String):Bool
	{
	
		if (Assets.exists(filename))
		{
		 var file:DataFile = new DataFile(name);
		 var bmp:BitmapData = Assets.getBitmapData(filename);

		 file.data.writeInt(bmp.width);
		 file.data.writeInt(bmp.height);
		 
		 var pixels:ByteArray = bmp.getPixels(bmp.rect);
		 file.data.writeBytes(pixels,0,pixels.length);
		 pixels.clear();
		 bmp = null;
		 add(file);
		 filesIndex++;
		return true;
		} else 
		{
			return false;
		  //throw("asset " + filename + "dont exists");
		}
	}
	private function add(data:DataFile)
	{
		
		files.set(data.name, data);
		filesId.push(data);
		
	}
	public function load(filename:String):Bool
	{
		if (Assets.exists(filename))
		{
	 	var bytes:ByteArray =	Assets.getBytes(filename);
		if (bytes.length <= 0) return false;
		bytes.endian = Endian.LITTLE_ENDIAN;
		trace(" File size :"+bytes.length + ' Bytes');
		//bytes.uncompress(CompressionAlgorithm.ZLIB);//html5 dont supor the feature
			 
		
		var header:String="";
		var numFiles:Int=0;
		var sizeofHeader:Int=0;
		sizeofHeader=bytes.readByte();
		header   = bytes.readUTFBytes(sizeofHeader);
		numFiles = bytes.readByte();
				
		trace("Heade size :" + sizeofHeader);
		trace("ID :" + header);
     	trace("Num files:" + numFiles);

		
		for (i in 0...numFiles)
		{
			var offset:Int = 0;
			var nameLength:Int = 0;
			var name:String;
			var fileSize:Int;
			var data:ByteArray = null;
			var isCompress:Bool = false;
	
			offset = bytes.readInt();//offsetn in pack
			isCompress = bytes.readBoolean();//html dont have compress :(
			nameLength = bytes.readByte();//name of file size
			name = bytes.readUTFBytes(nameLength);//name of file bytes
			fileSize = bytes.readInt();//real file size
			data = new ByteArray();
			data.endian=Endian.LITTLE_ENDIAN;
			bytes.readBytes(data, 0, fileSize);
			var file:DataFile = new DataFile(name);
			file.writeBytes(data);
			add(file);
			data = null;
			
		
			trace("File :" + name + " size:" + fileSize + " offset " + offset);
		}
	
		   bytes = null;
			
          return true;		
			
		} else
		{
			throw("Pack " + filename + "dont exists");
		}
	
   }	
	public function save(filename:String)
	{
	    var buffer:ByteArray = new  ByteArray();
	    buffer.endian = Endian.LITTLE_ENDIAN;
		var header:String = "HDP";
		buffer.writeByte(header.length);
		buffer.writeUTFBytes(header);
		buffer.writeByte(filesId.length);//num files
		for (f in filesId)
		{
			f.offset = buffer.position;
			buffer.writeInt(f.offset);//index of data
			buffer.writeBoolean(f.isCompress);
			var nameLength:Int = f.name.length;
			buffer.writeByte(nameLength);//size of name file
			buffer.writeUTFBytes(f.name);//name of file
			var fileSize:Int = f.data.length;
		    buffer.writeInt(fileSize);//size of the datafile 
			buffer.writeBytes(f.data);//write data
		
				 trace("File :" + f.name + " size:" + fileSize + " offset " + f.offset);
		}
		//buffer.compress(CompressionAlgorithm.ZLIB);//html5 dont supor the feature
		
	  #if neko
	   var f:FileOutput = File.write(filename);
	   trace("write :" + buffer.length);
       f.writeBytes(buffer, 0, buffer.length);
       f.close();
     #end
	 buffer = null;
   }
   
   public function dispose()
   {
	 		for (f in filesId)
		{
			f.dispose();
			
		}
		this.filesId = null;
		this.files = null;
   }
   
   //**deprecated
  
   
   public function getBitmapDataPixels(name:String):BitmapData
   {
	  trace("deprecated");
	   if (files.exists(name))
	   {
	       var d:DataFile = files.get(name);
		 
		    return d.toBitmapData();
		  
		  
	   } else
	   {
		   throw (" resource " + name + " dont exist in Pack");
	   }
	   
   }
      public function getFileData(name:String):ByteArray
   {
	   if (files.exists(name))
	   {
	       var d:DataFile = files.get(name);
			return d.data;
	   } else
	   {
		   throw (" resource " + name + " dont exist in path");
	   }
	   
   }
      public function getFileStrings(name:String):String
   {
	   if (files.exists(name))
	   {
	       var d:DataFile = files.get(name);
		   
			return d.data.toString();
	   } else
	   {
		   throw (" resource " + name + " dont exist in path");
	   }
	   
   }
   
   public function getBitmap(name:String):Bitmap
   {
	   if (files.exists(name))
	   {
	       var d:DataFile = files.get(name);
		   
			return bytesToBitmap(d.data);
	   } else
	   {
		   throw (" resource " + name + " dont exist in path");
	   }
	   
   }
   public function getBitmapData(name:String):BitmapData
   {
	   if (files.exists(name))
	   {
	       var d:DataFile = files.get(name);
		   
			return  bytesToBitmapData(d.data);
			
	   } else
	   {
		   throw (" resource " + name + " dont exist in path");
	   }
	   
   }
 private function bytesToBitmap(ba:ByteArray) :Bitmap
{
	var imgLoader:Loader;
	var bitmap:Bitmap=null;
   imgLoader = new Loader();
   imgLoader.contentLoaderInfo.addEventListener(Event.COMPLETE,  function loadData(e:Event):Void
   {
	bitmap = cast(imgLoader.content, Bitmap);
     
   });
   imgLoader.loadBytes(ba);
   
  
   return  bitmap;
}
	
 private function bytesToBitmapData(ba:ByteArray) :BitmapData
{
	var imgLoader:Loader;
	var bdata:BitmapData = null;
   imgLoader = new Loader();
   imgLoader.contentLoaderInfo.addEventListener(Event.COMPLETE,  function loadData(e:Event):Void
   {
	  // trace(imgLoader.contentLoaderInfo.bytes);
	   trace(imgLoader.contentLoaderInfo.bytesLoaded);
	   trace(imgLoader.contentLoaderInfo.bytesTotal);
	   
	   //trace(imgLoader.loadBytes());
	   
	    var bitmap:Bitmap = cast(imgLoader.content, Bitmap);
        bdata = bitmap.bitmapData;
		//bitmap = null;
   });
   imgLoader.loadBytes(ba);
   return bdata;
}
	
}