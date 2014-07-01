package plugin.net.parsers.mtl.errors 
{
	/**
	 * ...
	 * @author Gary Paluk - http://www.plugin.io
	 */
	public class ParserMTLError 
	{
		
		public static const SUCCESSFUL:ParserMTLError = new ParserMTLError( "successful", 0 );
		public static const LOGFILE_OPEN_FAILED:ParserMTLError = new ParserMTLError( "logfileOpenFailed", 1 );
		public static const FILE_OPEN_FAILED:ParserMTLError = new ParserMTLError( "fileOpenFailed", 2 );
		public static const NO_TOKENS:ParserMTLError = new ParserMTLError( "noTokens", 3 );
		public static const TOO_FEW_TOKENS: ParserMTLError = new ParserMTLError( "tooFewTokens", 4 );
		public static const TOO_MANY_TOKENS: ParserMTLError = new ParserMTLError( "tooManyTokens", 5 );
		public static const UNEXPECTED_TOKEN: ParserMTLError = new ParserMTLError( "unexpectedToken", 6 );
		public static const NOT_YET_IMPLEMENTED: ParserMTLError = new ParserMTLError( "notYetImplemented", 7 );
		public static const VALUE_OUT_OF_RANGE: ParserMTLError = new ParserMTLError( "valueOutOfRange", 8 );
		public static const MISSING_MAP_FILENAME: ParserMTLError = new ParserMTLError( "missingMapFilename", 9 );
		public static const INVALID_OPTION:ParserMTLError = new ParserMTLError( "invalidOption", 10 );
		public static const TOO_FEW_OPTION_TOKENS:ParserMTLError = new ParserMTLError( "tooFewOptionTokens", 11 );
		public static const INVALID_OPTION_ARGUMENT: ParserMTLError = new ParserMTLError( "invalidOptionArgument", 12 );
		public static const MAX_ERROR_CODES:ParserMTLError = new ParserMTLError( "maxErrorCodes", 13 );
		
		private var _type:String;
		private var _index:int;
		public function ParserMTLError( type:String, index:int ) 
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