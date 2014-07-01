package plugin.net.parsers.mtl.types 
{
	/**
	 * ...
	 * @author Gary Paluk - http://www.plugin.io
	 */
	public class TextureMTL 
	{
		
		public var filename:String = "";
		public var blendU:Boolean = true;
		public var blendV:Boolean = true;
		public var bumpMultiplier:Number = 1;
		public var boost:Number = 0;
		public var colorCorrection:Boolean = false;
		public var clamp:Boolean = false;
		public var imfChannel:String = "m";
		public var base:Number = 0;
		public var gain:Number = 0;
		public var texResolution:Number = 0; // TODO What is this?
		
		public var offset:Array = [0, 0, 0];
		public var scale:Array = [1, 1, 1];
		public var turbulence:Array = [0, 0, 0];
		
		
	}

}