package plugin.net.parsers.obj 
{
	import br.com.stimuli.loading.BulkLoader;
	import flash.events.ErrorEvent;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.utils.ByteArray;
	import io.plugin.core.system.Assert;
	import plugin.net.parsers.mtl.errors.ParserMTLError;
	import plugin.net.parsers.mtl.ParserMTL;
	import plugin.net.parsers.mtl.types.MaterialMTL;
	import plugin.net.parsers.obj.errors.ParserOBJError;
	import plugin.net.parsers.obj.types.FaceOBJ;
	import plugin.net.parsers.obj.types.Float2OBJ;
	import plugin.net.parsers.obj.types.Float3OBJ;
	import plugin.net.parsers.obj.types.GroupOBJ;
	import plugin.net.parsers.obj.types.MeshOBJ;
	import plugin.net.parsers.obj.types.VertexOBJ;
	/**
	 * ...
	 * @author Gary Paluk - http://www.plugin.io
	 */
	public class ParserOBJ extends EventDispatcher
	{
		
		private var _code:ParserOBJError;
		
		//TODO logfile dump
		
		private var _materials:Vector.<MaterialMTL>;
		
		private var _currentGroup:int;
		private var _currentPos:int;
		private var _currentTcd:int;
		private var _currentNor:int;
		private var _currentMtl: int;
		private var _currentMesh: int;
		
		private var _groups:Vector.<GroupOBJ>;
		private var _positions:Vector.<Float3OBJ>;
		private var _tCoords:Vector.<Float2OBJ>;
		private var _normals:Vector.<Float3OBJ>;
		
		private var _loader:BulkLoader;
		
		private var _path:String;
		private var _filename:String;
		private var _filepath:String;
		
		private var _parserMTL:ParserMTL;
		
		private var _obj:ByteArray;
		
		private static const msCodeString:Array =
		[
			"Loaded successfully",
			"Logfile open failed",
			"File open failed",
			"No tokens",
			"Too few tokens",
			"Too many tokens",
			"Unexpected token",
			"Not yet implemented",
			"Value out of range",
			"Missing map filename",
			"Invalid option",
			"Too few option tokens",
			"Invalid option argument"
		];
		
		public function ParserOBJ( path:String, filename:String ) 
		{
			_path = path;
			_filename = filename;
			_filepath = _path + _filename;
			
			_materials = new Vector.<MaterialMTL>();
			_groups = new Vector.<GroupOBJ>();
			_positions = new Vector.<Float3OBJ>();
			_tCoords = new Vector.<Float2OBJ>();
			_normals = new Vector.<Float3OBJ>();
			
			_code = ParserOBJError.SUCCESSFUL;
			_currentGroup = -1;
			_currentPos = -1;
			_currentTcd = -1;
			_currentNor = -1;
			_currentMtl = -1;
			_currentMesh = -1;
		}
		
		public function parse():void
		{
			_loader = new BulkLoader( "parserOBJLoader" );
			_loader.addEventListener(BulkLoader.COMPLETE, onLoaderComplete );
			_loader.addEventListener(BulkLoader.ERROR, onLoaderError );
			
			var filePath:String = _path + _filename;
			
			_loader.add( filePath, { type:"binary", id:"obj" } );
			_loader.start();
		}
		
		private function onLoaderError(e:Event):void 
		{
			dispatchEvent( new ErrorEvent( ErrorEvent.ERROR ) );
		}
		
		private function onLoaderComplete(e:Event):void 
		{
			_obj = _loader.getContent("obj") as ByteArray;
			_obj.position = 0;
			
			var char:String = "";
			var line:String = "";
			var tokens:Vector.<String> = new Vector.<String>();
			
			while ( _obj.bytesAvailable )
			{
				char = _obj.readUTFBytes(1);
				
				if ( char == "\n" || char == "\r" )
				{
					// skip if blank or comment
					if ( line != "" && line.charAt(0) != "#" )
					{
						getTokens( line, tokens );
						
						// mtllib
						if ( getMaterialLibrary( _path, tokens ) ) { line = ""; return; };
						if ( _code != ParserOBJError.SUCCESSFUL ) { break; };
						
					}
					line = "";
				}
				else
				{
					line += char;
				}
			}
		}
		
		private function onMTLParserError(e:Event):void
		{
			dispatchEvent( new ErrorEvent( ErrorEvent.ERROR, false, false, msCodeString[_code.index] ) );
		}
		
		private function onMTLParserComplete(e:Event):void
		{
			_obj = _loader.getContent("obj") as ByteArray;
			_obj.position = 0;
			
			var char:String = "";
			var line:String = "";
			var tokens:Vector.<String> = new Vector.<String>();
			
			while ( _obj.bytesAvailable )
			{
				char = _obj.readUTFBytes(1);
				
				if ( char == "\n" || char == "\r" )
				{
					// skip if blank or comment
					if ( line != "" && line.charAt(0) != "#" )
					{
						getTokens( line, tokens );
						
						// g default
						if ( getDefaultGroup( tokens ) ) { line = ""; continue; };
						if ( _code != ParserOBJError.SUCCESSFUL ) { break; };
						
						// v x y z
						if ( getPosition(tokens) ) { line = ""; continue };
						if ( _code != ParserOBJError.SUCCESSFUL ) { break; };
						
						// vt x y
						if ( getTCoord(tokens)) { line = ""; continue; };
						if ( _code != ParserOBJError.SUCCESSFUL ) { break; };
						
						// vn x y z
						if ( getNormal(tokens)) { line = ""; continue; };
						if ( _code != ParserOBJError.SUCCESSFUL ) { break; };
						
						// Ignore smoothing groups for now (syntax:  's number').
						if ( tokens[0] == "s") { line = ""; continue; };
						
						// g groupname
						if ( getGroup(tokens)) { line = ""; continue; }
						if ( _code != ParserOBJError.SUCCESSFUL ) { break; };
						
						// usemtl mtlname
						if ( getMaterialAndMesh(tokens)) { line = ""; continue; }
						if ( _code != ParserOBJError.SUCCESSFUL ) { break; };
						
						// f vertexList
						if ( getFace(tokens)) { line = ""; continue; };
						if ( _code != ParserOBJError.SUCCESSFUL ) { break; };
						
						
						//_code = ParserOBJError.UNEXPECTED_TOKEN;
						//Assert.isTrue(false, msCodeString[_code.index]);
						//break;
					}
					line = "";
				}
				else
				{
					line += char;
				}
				
				_materials = _parserMTL.getMaterials();
			}
			
			//TODO create custom Events
			if ( _code == ParserOBJError.SUCCESSFUL )
			{
				dispatchEvent( new Event( Event.COMPLETE ) );
			}
			else
			{
				dispatchEvent( new ErrorEvent( ErrorEvent.ERROR, false, false, msCodeString[_code.index] ) );
			}
		}
		
		
		
		[Inline]
		public final function get code():ParserOBJError
		{
			return _code;
		}
		
		[Inline]
		public final function get materials():Vector.<MaterialMTL>
		{
			return _materials;
		}
		
		[Inline]
		public final function get groups():Vector.<GroupOBJ>
		{
			return _groups;
		}
		
		[Inline]
		public final function get positions():Vector.<Float3OBJ>
		{
			return _positions;
		}
		
		[Inline]
		public final function get tCoords():Vector.<Float2OBJ>
		{
			return _tCoords;
		}
		
		[Inline]
		public final function get normals():Vector.<Float3OBJ>
		{
			return _normals;
		}
		
		private function getTokens( line:String, tokens:Vector.<String> ):void
		{
			tokens.length = 0;
			
			var pattern:RegExp = /[ \t]/;
			var tokenList:Array = line.split( pattern );
			
			for each( var i:String in tokenList )
			{
				if ( i != "" )
				{
					tokens.push( i );
				}
			}
		}
		
		private function getMaterialLibrary( path:String, tokens:Vector.<String> ):Boolean
		{
			if ( tokens[0] == "mtllib" )
			{
				if ( tokens.length == 1 )
				{
					_code = ParserOBJError.TOO_FEW_TOKENS;
					Assert.isTrue( false, msCodeString[_code.index] );
					return false;
				}
				
				if ( tokens.length > 2 )
				{
					_code = ParserOBJError.TOO_MANY_TOKENS;
					Assert.isTrue( false, msCodeString[_code.index] );
					return false;
				}
				
				_parserMTL = new ParserMTL( path, tokens[1] );
				_parserMTL.addEventListener( Event.COMPLETE, onMTLParserComplete );
				_parserMTL.addEventListener( ErrorEvent.ERROR, onMTLParserError );
				_parserMTL.parse();
				
				if ( _parserMTL.getCode() != ParserMTLError.SUCCESSFUL )
				{
					_code = ParserOBJError.FAILED_TO_LOAD_MATERIALS;
					Assert.isTrue( false, msCodeString[_code.index] );
					return false;
				}
				
				return true;
			}
			return false;
		}
		
		private function getDefaultGroup( tokens:Vector.<String> ):Boolean
		{
			if ( tokens[0] == "g" )
			{
				if ( tokens.length == 1 )
				{
					_code = ParserOBJError.TOO_FEW_TOKENS;
					Assert.isTrue( false, msCodeString[_code.index] );
					return false;
				}
				
				if ( tokens.length > 2 )
				{
					_code = ParserOBJError.TOO_MANY_TOKENS;
					Assert.isTrue( false, msCodeString[_code.index] );
					return false;
				}
				
				if ( tokens[1] == "default" )
				{
					_currentPos = _positions.length;
					_currentTcd = _tCoords.length;
					_currentNor = _normals.length;
					return true;
				}
			}
			return false;
		}
		
		private function getPosition( tokens:Vector.<String> ):Boolean
		{
			if ( tokens[0] == "v" )
			{
				if ( tokens.length < 4 )
				{
					_code = ParserOBJError.TOO_FEW_TOKENS;
					Assert.isTrue( false, msCodeString[_code.index] );
					return false;
				}
				
				if ( tokens.length > 4 )
				{
					_code = ParserOBJError.TOO_MANY_TOKENS;
					Assert.isTrue( false, msCodeString[_code.index] );
					return false;
				}
				
				var pos:Float3OBJ = new Float3OBJ();
				pos.x = Number( tokens[1] );
				pos.y = Number( tokens[2] );
				pos.z = Number( tokens[3] );
				
				_positions.push( pos );
				return true;
			}
			return false;
		}
		
		private function getTCoord( tokens:Vector.<String> ):Boolean
		{
			if ( tokens[0] == "vt" )
			{
				if ( tokens.length < 3 )
				{
					_code = ParserOBJError.TOO_FEW_TOKENS;
					Assert.isTrue( false, msCodeString[_code.index] );
					return false;
				}
				
				if ( tokens.length > 3 )
				{
					_code = ParserOBJError.TOO_MANY_TOKENS;
					Assert.isTrue( false, msCodeString[_code.index] );
					return false;
				}
				
				var tcd:Float2OBJ = new Float2OBJ();
				tcd.x = Number( tokens[1] );
				tcd.y = Number( tokens[2] );
				
				_tCoords.push( tcd );
				return true;
			}
			return false;
		}
		
		private function getNormal( tokens:Vector.<String> ):Boolean
		{
			if ( tokens[0] == "vn" )
			{
				if ( tokens.length < 4 )
				{
					_code = ParserOBJError.TOO_FEW_TOKENS;
					Assert.isTrue( false, msCodeString[_code.index] );
					return false;
				}
				
				if ( tokens.length > 4 )
				{
					_code = ParserOBJError.TOO_MANY_TOKENS;
					Assert.isTrue( false, msCodeString[_code.index] );
					return false;
				}
				
				var nor:Float3OBJ = new Float3OBJ();
				nor.x = Number( tokens[1] );
				nor.y = Number( tokens[2] );
				nor.z = Number( tokens[3] );
				_normals.push( nor );
				return true;
			}
			return false;
		}
		
		private function getGroup( tokens:Vector.<String> ):Boolean
		{
			if ( tokens[0] == "g" )
			{
				if ( tokens.length == 1 )
				{
					_code = ParserOBJError.TOO_FEW_TOKENS;
					Assert.isTrue( false, msCodeString[_code.index] );
					return false;
				}
				
				if ( tokens[1] == "default" )
				{
					_code = ParserOBJError.UNEXPECTED_TOKEN;
					Assert.isTrue( false, msCodeString[_code.index] );
					return false;
				}
				
				_currentGroup = _groups.length;
				
				var group:GroupOBJ = new GroupOBJ();
				group.name = tokens[1];
				_groups.push( group );
				
				for ( var i: int = 2; i < tokens.length; ++i )
				{
					group.name += tokens[i];
				}
				group.posStart = _currentPos;
				group.tcdStart = _currentTcd;
				group.norStart = _currentNor;
				
				_currentPos = _positions.length;
				_currentTcd = _tCoords.length;
				_currentNor = _normals.length;
				return true;
			}
			return false;
		}
		
		private function getMaterialAndMesh( tokens:Vector.<String> ):Boolean
		{
			if ( tokens[0] == "usemtl" )
			{
				if ( tokens.length == 1 )
				{
					_code = ParserOBJError.TOO_FEW_TOKENS;
					Assert.isTrue( false, msCodeString[_code.index] );
					return false;
				}
				
				if ( tokens.length > 2 )
				{
					_code = ParserOBJError.TOO_MANY_TOKENS;
					Assert.isTrue( false, msCodeString[_code.index] );
					return false;
				}
				
				var i:int;
				for ( i = 0; i < _materials.length; ++i )
				{
					if ( tokens[1] == _materials[i].name )
					{
						break;
					}
				}
				if ( i == _materials.length )
				{
					_code = ParserOBJError.FAILED_TO_FIND_MATERIALS;
					Assert.isTrue( false, msCodeString[_code.index] );
					return false;
				}
				_currentMtl = i;
				
				var group:GroupOBJ = _groups[_currentGroup];
				for ( i = 0; i < group.meshes.length; ++i )
				{
					if ( group.meshes[i].mtlIndex == _currentMtl )
					{
						break;
					}
				}
				if ( i == group.meshes.length )
				{
					var mesh:MeshOBJ = new MeshOBJ();
					mesh.mtlIndex = _currentMtl;
					group.meshes.push( mesh );
				}
				
				_currentMesh = i;
				return true;
			}
			return false;
		}
		
		private function getFace( tokens:Vector.<String> ):Boolean
		{
			if ( tokens[0] == "f" )
			{
				if ( tokens.length < 4 )
				{
					_code = ParserOBJError.TOO_FEW_TOKENS;
					Assert.isTrue( false, msCodeString[_code.index] );
					return false;
				}
				
				var group:GroupOBJ = _groups[_currentGroup];
				var mesh:MeshOBJ = group.meshes[_currentMesh];
				
				var face:FaceOBJ = new FaceOBJ();
				mesh.faces.push( face );
				
				var numVertices:int = tokens.length - 1;
				face.vertices.length = numVertices;
				
				for ( var i:int = 0; i < numVertices; ++i )
				{
					var token:String = tokens[i + 1];
					var slash1:int = token.indexOf("/");
					var slash2:int = token.lastIndexOf("/");
					face.vertices[i] = new VertexOBJ();
					
					if ( slash1 == -1 && slash2 == -1 )
					{
						var tkn:String = token;
						face.vertices[i].tcdIndex = int( tkn ) - 1;
						
						continue;
					}
					
					if ( slash1 == 0 || slash1 == token.length
					  || slash2 == 0 || slash2 == token.length
					  || slash1 == slash2 )
					{
						_code = ParserOBJError.INVALID_VERTEX;
						Assert.isTrue( false, msCodeString[_code.index] );
						return false;
					}
					
					var pos:String = token.substr( 0, slash1 );
					face.vertices[i].posIndex = int( pos ) - 1;
					
					var numDigits:int = slash2 - slash1 - 1;
					if ( numDigits > 0 )
					{
						var tcd:String = token.substr( slash1 + 1, numDigits );
						face.vertices[i].tcdIndex = int( tcd ) - 1;
					}
					if ( token.length > slash2 + 1 )
					{
						var nor:String = token.substr( slash2 + 1 );
						face.vertices[i].norIndex = int( nor ) - 1;
					}
				}
				return true;
			}
			return false;
		}
		
	}

}