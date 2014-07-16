package plugin.net.parsers.obj.types 
{
	/**
	 * ...
	 * @author Gary Paluk - http://www.plugin.io
	 */
	public class GroupOBJ 
	{
		
		public var name:String = "";
		public var posStart:int;
		public var tcdStart:int;
		public var norStart:int;
		public var meshes:Vector.<MeshOBJ>;
		
		public function GroupOBJ() 
		{
			meshes = new Vector.<MeshOBJ>();
		}
		
	}

}