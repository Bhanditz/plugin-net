package plugin.net.parsers.obj.errors 
{
	/**
	 * ...
	 * @author Gary Paluk - http://www.plugin.io
	 */
	public class ParserOBJError
	{
		
		public static const SUCCESSFUL:ParserOBJError = new ParserOBJError( "successful", 0 );
		public static const LOGFILE_OPEN_FAILED:ParserOBJError = new ParserOBJError( "logfileOpenFailed", 1 );
		public static const FILE_OPEN_FAILED:ParserOBJError = new ParserOBJError( "fileOpenFailed", 2 );
		public static const NO_TOKENS:ParserOBJError = new ParserOBJError( "noTokens", 3 );
		public static const TOO_FEW_TOKENS:ParserOBJError = new ParserOBJError( "tooFewTokens", 4 );
		public static const TOO_MANY_TOKENS:ParserOBJError = new ParserOBJError( "tooManyTokens", 5 );
		public static const UNEXPECTED_TOKEN:ParserOBJError = new ParserOBJError( "unexpectedToken", 6 );
		public static const NOT_YET_IMPLEMENTED:ParserOBJError = new ParserOBJError( "notYetImplemented", 7 );
		public static const FAILED_TO_LOAD_MATERIALS:ParserOBJError = new ParserOBJError( "failedToLoadMaterials", 8 );
		public static const FAILED_TO_FIND_MATERIALS:ParserOBJError = new ParserOBJError( "failedToFindMaterials", 9 );
		public static const INVALID_VERTEX:ParserOBJError = new ParserOBJError( "invalidVertex", 10 );
		public static const MAX_ERROR_CODES:ParserOBJError = new ParserOBJError( "maxErrorCodes", 11 );
		
		private var _type:String;
		private var _index:int;
		
		public function ParserOBJError( type:String, index:int ) 
		{
			_type = type;
			_index = index;
		}
		
		public function get type():String 
		{
			return _type;
		}
		
		public function get index():int 
		{
			return _index;
		}
		
	}

}