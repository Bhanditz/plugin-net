package plugin.net.parsers.obj.types 
{
	/**
	 * ...
	 * @author Gary Paluk - http://www.plugin.io
	 */
	public class VertexOBJ 
	{
		
		public var posIndex:int;
		public var tcdIndex:int;
		public var norIndex:int;
		
		public function VertexOBJ() 
		{
			posIndex = -1;
			tcdIndex = -1;
			norIndex = -1;
		}
		
		public function lessThan( vertex:VertexOBJ ):Boolean
		{
			if ( posIndex < vertex.posIndex )
			{
				return true;
			}
			if ( posIndex > vertex.posIndex )
			{
				return false;
			}
			if ( tcdIndex < vertex.tcdIndex )
			{
				return true;
			}
			if ( tcdIndex > vertex.tcdIndex )
			{
				return false;
			}
			if ( norIndex < vertex.norIndex )
			{
				return true;
			}
			return false;
		}
		
	}

}