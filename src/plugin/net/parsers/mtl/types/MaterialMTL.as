package plugin.net.parsers.mtl.types 
{
	/**
	 * ...
	 * @author Gary Paluk - http://www.plugin.io
	 */
	public class MaterialMTL 
	{
		
		public var name:String = "";
		public var illuminationModel:int = -1;
		public var ambientColor:Array = [0, 0, 0];
		public var diffuseColor:Array = [0, 0, 0];
		public var specularColor:Array = [0, 0, 0];
		public var transmissionFilter:Array = [0, 0, 0];
		public var opticalDensity:Number = 0;
		public var specularExponent:Number = 0;
		
		public var ambientMap:TextureMTL = new TextureMTL();
		public var diffuseMap:TextureMTL = new TextureMTL();
		public var specularMap:TextureMTL = new TextureMTL();
		
	}

}