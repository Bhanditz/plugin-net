package plugin.net.parsers.obj.types 
{
	/**
	 * ...
	 * @author Gary Paluk - http://www.plugin.io
	 */
	public class MeshOBJ 
	{
		
		public var mtlIndex:int;
		public var faces:Vector.<FaceOBJ>;
		
		public function MeshOBJ() 
		{
			faces = new Vector.<FaceOBJ>();
		}
		
	}

}