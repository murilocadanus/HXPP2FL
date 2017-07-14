package;

#if cpp
import cpp.Lib;
#elseif neko
import neko.Lib;
#end

#if (android && openfl)
import openfl.utils.JNI;
#end


class NativeData {
	
	
	public static function sampleMethod (inputValue:Int):Int {
		
		#if (android && openfl)
		
		var resultJNI = nativedata_sample_method_jni(inputValue);
		var resultNative = nativedata_sample_method(inputValue);
		
		if (resultJNI != resultNative) {
			
			throw "Fuzzy math!";
			
		}
		
		return resultNative;
		
		#else
		
		return nativedata_sample_method(inputValue);
		
		#end
		
	}
	
	
	private static var nativedata_sample_method = Lib.load ("nativedata", "nativedata_sample_method", 1);
	
	#if (android && openfl)
	private static var nativedata_sample_method_jni = JNI.createStaticMethod ("org.haxe.extension.NativeData", "sampleMethod", "(I)I");
	#end
	
	
}