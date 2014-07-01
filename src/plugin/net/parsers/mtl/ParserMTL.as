package plugin.net.parsers.mtl 
{
	import br.com.stimuli.loading.BulkLoader;
	import flash.events.ErrorEvent;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.utils.ByteArray;
	import plugin.core.system.Assert;
	import plugin.net.parsers.mtl.errors.ParserMTLError;
	import plugin.net.parsers.mtl.types.MaterialMTL;
	import plugin.net.parsers.mtl.types.TextureMTL;
	/**
	 * ...
	 * @author Gary Paluk - http://www.plugin.io
	 */
	public class ParserMTL extends EventDispatcher
	{
		
		private var _code:ParserMTLError;
		
		//TODO logfile dump
		private var _current:int;
		private var _materials:Vector.<MaterialMTL>;
		
		private var _loader:BulkLoader;
		
		private var _path:String;
		private var _filename:String;
		
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
			"Failed to load materials",
			"Failed to find material",
			"Invalid vertex"
		];
		
		public function ParserMTL( path:String, filename:String ) 
		{
			_path = path;
			_filename = filename;
			
			_materials = new Vector.<MaterialMTL>();
			
			_code = ParserMTLError.SUCCESSFUL;
			_current = -1;
		}
		
		public function parse():void
		{
			_loader = new BulkLoader( "parserMTLLoader" );
			_loader.addEventListener(BulkLoader.COMPLETE, onLoaderComplete );
			_loader.addEventListener(BulkLoader.ERROR, onLoaderError );
			
			var filePath:String = _path + _filename;
			
			_loader.add( filePath, { type:"binary", id:"mtl" } );
			_loader.start();
		}
		
		private function onLoaderError(e:Event):void 
		{
			trace( "error loading mtl" );
		}
		
		private function onLoaderComplete(e:Event):void 
		{
			trace( "loaded mtl" );
			
			var obj:ByteArray = _loader.getContent("mtl") as ByteArray;
			
			var char:String = "";
			var line:String = "";
			var tokens:Vector.<String> = new Vector.<String>();
			
			while ( obj.bytesAvailable )
			{
				char = obj.readUTFBytes(1);
				
				if ( char == "\n" || char == "\r" )
				{
					
					// skip if blank or comment
					if ( line != "" && line.charAt(0) != "#" )
					{
						
						getTokens( line, tokens );
						
						// newmtl
						if ( getNewMaterial(tokens)) { line = ""; continue; }
						if ( _code != ParserMTLError.SUCCESSFUL ) { break; }
						
						// illum
						if ( getIlluminationMode(tokens)) { line = ""; continue; }
						if ( _code != ParserMTLError.SUCCESSFUL) { break; }
						
						// Ka
						if ( getAmbientColor(tokens)) { line = ""; continue; }
						if ( _code != ParserMTLError.SUCCESSFUL) { break; }
						
						// Kd
						if ( getDiffuseColor(tokens)) { line = ""; continue; }
						if ( _code != ParserMTLError.SUCCESSFUL) { break; }
						
						// Ks
						if ( getSpecularColor(tokens)) { line = ""; continue; }
						if ( _code != ParserMTLError.SUCCESSFUL) { break; }
						
						// Tf
						if ( getTransmissionFilter(tokens)) { line = ""; continue; }
						if ( _code != ParserMTLError.SUCCESSFUL) { break; }
						
						// Ni
						if ( getOpticalDensity(tokens)) { line = ""; continue; }
						if ( _code != ParserMTLError.SUCCESSFUL) { break; }
						
						// Ni
						if ( getSpecularExponent(tokens)) { line = ""; continue; }
						if ( _code != ParserMTLError.SUCCESSFUL) { break; }
						
						// map_Kd
						if ( getDiffuseTexture(tokens)) { line = ""; continue; }
						if ( _code != ParserMTLError.SUCCESSFUL) { break; }
					}
					line = "";
				}
				else
				{
					line += char;
				}
			}
			
			if ( _code == ParserMTLError.SUCCESSFUL)
			{
				dispatchEvent( new Event( Event.COMPLETE ) );
			}
			else
			{
				dispatchEvent( new ErrorEvent( ErrorEvent.ERROR, false, false, msCodeString[_code.index] ) );
			}
		}
		
		[Inline]
		public final function getCode():ParserMTLError
		{
			return _code;
		}
		
		[Inline]
		public final function getMaterials():Vector.<MaterialMTL>
		{
			return _materials;
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
		
		private function getColor( tokens:Vector.<String>, color:Array ):Boolean
		{
			if ( tokens[1] == "spectal" || tokens[1] == "xyz" )
			{
				Assert.isTrue( false );
				_code = ParserMTLError.NOT_YET_IMPLEMENTED;
				return false;
			}
			
			// red
			var fValue: Number = Number( tokens[1] );
			if ( fValue < 0 || fValue > 1 )
			{
				Assert.isTrue( false )
				_code = ParserMTLError.VALUE_OUT_OF_RANGE;
			}
			color[0] = fValue;
			
			if ( tokens.length == 2 )
			{
				// grey scale
				color[1] = fValue;
				color[2] = fValue;
				return true;
			}
			
			if ( tokens.length == 3 )
			{
				Assert.isTrue( false );
				_code = ParserMTLError.TOO_FEW_TOKENS;
				return false;
			}
			
			if ( tokens.length >= 5 )
			{
				Assert.isTrue( false );
				_code = ParserMTLError.TOO_MANY_TOKENS;
				return false;
			}
			
			// green channel
			fValue = Number( tokens[2] );
			if ( fValue < 0 || fValue > 1 )
			{
				Assert.isTrue( false );
				_code = ParserMTLError.VALUE_OUT_OF_RANGE;
				return false;
			}
			color[1] = fValue;
			
			// blue
			fValue = Number( tokens[3] );
			if ( fValue < 0 || fValue > 1 )
			{
				Assert.isTrue( false );
				_code = ParserMTLError.VALUE_OUT_OF_RANGE;
				return false;
			}
			color[2] = fValue;
			return true;
		}
		
		private function getTexture( tokens:Vector.<String>, texture:TextureMTL ):Boolean
		{
			texture.filename = tokens[tokens.length-1];
			
			if ( texture.filename.charAt(0) == "-" )
			{
				Assert.isTrue(false);
				_code = ParserMTLError.MISSING_MAP_FILENAME;
				return false;
			}
			
			if ( tokens.length >= 3 )
			{
				var iMin:int = 1;
				var iMax:int = tokens.length - 2;
				
				for ( var i: int = iMin; i <= iMax; ++i )
				{
					var token:String = tokens[i];
					if ( token[0] != "-" )
					{
						Assert.isTrue( false );
						_code = ParserMTLError.INVALID_OPTION;
						return false;
					}
					
					token = token.substr(1);
					if ( token == "blendu" )
					{
						if ( getBoolArg( tokens, iMax, i, texture.blendU ) )
						{
							continue;
						}
						return false;
					}
					
					if ( token == "blendv" )
					{
						if ( getBoolArg( tokens, iMax, i, texture.blendV ) )
						{
							continue;
						}
						return false;
					}
					
					if ( token == "bm" )
					{
						if ( getFloatArg( tokens, iMax, -Number.MAX_VALUE, Number.MAX_VALUE, i, texture.bumpMultiplier ) )
						{
							continue;
						}
						return false;
					}
					
					if ( token == "boost" )
					{
						if( getFloatArg( tokens, iMax, -Number.MAX_VALUE, Number.MAX_VALUE, i, texture.boost ) )
						{
							continue;
						}
						return false;
					}
					
					if ( token == "cc" )
					{
						if( getBoolArg( tokens, iMax, i, texture.colorCorrection ) )
						{
							continue;
						}
						return false;
					}
					
					if ( token == "clamp" )
					{
						if( getBoolArg( tokens, iMax, i, texture.clamp ) )
						{
							continue;
						}
						return false;
					}
					
					if ( token == "imfchan" )
					{
						if( getCharArg( tokens, iMax, "rgbmlz", i, texture.imfChannel ) )
						{
							continue;
						}
						return false;
					}
					
					if ( token == "mm" )
					{
						if( getFloatArg2( tokens, iMax, -Number.MAX_VALUE, Number.MAX_VALUE, -Number.MAX_VALUE, Number.MAX_VALUE, i, texture.base, texture.gain ) )
						{
							continue;
						}
						return false;
					}
					
					if ( token == "o" )
					{
						if( getFloatArg3Opt2( tokens, iMax, -Number.MAX_VALUE, Number.MAX_VALUE, -Number.MAX_VALUE, Number.MAX_VALUE, -Number.MAX_VALUE, Number.MAX_VALUE, i, texture.offset ) )
						{
							continue;
						}
						return false;
					}
					
					if ( token == "s" )
					{
						if( getFloatArg3Opt2( tokens, iMax, -Number.MAX_VALUE, Number.MAX_VALUE, -Number.MAX_VALUE, Number.MAX_VALUE, -Number.MAX_VALUE, Number.MAX_VALUE, i, texture.scale ) )
						{
							continue;
						}
						return false;
					}
					
					if ( token == "t" )
					{
						if( getFloatArg3Opt2( tokens, iMax, -Number.MAX_VALUE, Number.MAX_VALUE, -Number.MAX_VALUE, Number.MAX_VALUE, -Number.MAX_VALUE, Number.MAX_VALUE, i, texture.turbulence ) )
						{
							continue;
						}
						return false;
					}
					
					if ( token == "o" )
					{
						if( getFloatArg( tokens, iMax, -Number.MAX_VALUE, Number.MAX_VALUE, i, texture.texResolution ) )
						{
							continue;
						}
						return false;
					}
				}
			}
			return true;
		}
		
		private function getBoolArg( tokens:Vector.<String>, iMax:int, i: int, value:Boolean ):Boolean
		{
			if ( ++i > iMax )
			{
				Assert.isTrue( false );
				_code = ParserMTLError.TOO_FEW_OPTION_TOKENS;
				return false;
			}
			
			if ( tokens[i] == "on" )
			{
				value = true;
				return value;
			}
			
			if ( tokens[i] == "off" )
			{
				value = false;
				return value;
			}
			
			Assert.isTrue( false );
			_code = ParserMTLError.TOO_FEW_TOKENS;
			return false;
		}
		
		private function getCharArg( tokens:Vector.<String>, iMax:int, valid:String, i:int, value:String ):Boolean
		{
			if ( ++i > iMax )
			{
				Assert.isTrue( false );
				_code = ParserMTLError.TOO_FEW_TOKENS;
				return false;
			}
			
			if ( tokens[i].length != 0 )
			{
				Assert.isTrue( false );
				_code = ParserMTLError.INVALID_OPTION_ARGUMENT;
				return false;
			}
			
			value = tokens[i][0];
			var isValid:Boolean = false;
			
			for ( var j: int = 0; j < valid.length; ++j )
			{
				if ( value == valid.charAt(j) )
				{
					isValid = true;
					break;
				}
			}
			
			if ( !isValid )
			{
				Assert.isTrue( false );
				_code = ParserMTLError.VALUE_OUT_OF_RANGE;
				return false;
			}
			
			return true;
		}
		
		private function getFloatArg( tokens:Vector.<String	>, iMax:int, vMin:Number, vMax:Number, i:int, value:Number ):Boolean
		{
			if ( ++i > iMax )
			{
				Assert.isTrue( false );
				_code = ParserMTLError.TOO_FEW_OPTION_TOKENS;
				return false;
			}
			
			value = Number( tokens[i] );
			if ( ( vMin > -Number.MAX_VALUE && value < vMin ) ||
				 ( vMax < Number.MAX_VALUE && value > vMax ) )
			{
				Assert.isTrue( false );
				_code = ParserMTLError.VALUE_OUT_OF_RANGE;
				return false;
			}
			
			return true;
		}
		
		private function getFloatArg2( tokens:Vector.<String>, iMax:int, vMin0:Number, vMax0:Number, vMin1:Number, vMax1:Number, i: int, value0:Number, value1:Number ):Boolean
		{
			if ( ++i > iMax )
			{
				Assert.isTrue( false );
				_code = ParserMTLError.TOO_FEW_OPTION_TOKENS;
				return false;
			}
			
			value0 = Number( tokens[i] );
			if ( ( vMin0 > -Number.MAX_VALUE && value0 < vMin0 ) ||
				 ( vMax0 < Number.MAX_VALUE && value0 > vMax0 ) )
			{
				Assert.isTrue( false );
				_code = ParserMTLError.VALUE_OUT_OF_RANGE;
				return false;
			}
			
			if ( ++i > iMax )
			{
				Assert.isTrue( false );
				_code = ParserMTLError.TOO_FEW_OPTION_TOKENS;
				return false;
			}
			
			value1 = Number( tokens[i] );
			if ( ( vMin1 > -Number.MAX_VALUE && value1 < vMin1 ) ||
				 ( vMax1 < Number.MAX_VALUE && value1 > vMax1 ) )
			{
				Assert.isTrue( false );
				_code = ParserMTLError.VALUE_OUT_OF_RANGE;
				return false;
			}
			
			return true;
		}
		
		private function getFloatArg3Opt2( tokens:Vector.<String>, iMax: int, vMin0:Number, vMax0:Number, vMin1:Number, vMax1:Number, vMin2:Number, vMax2:Number, i:int, values:Array ):Boolean
		{
			if ( ++i > iMax )
			{
				Assert.isTrue( false );
				_code = ParserMTLError.TOO_FEW_OPTION_TOKENS;
				return false;
			}
			
			values[0] = Number( tokens[i] );
			if ( ( vMin0 > -Number.MAX_VALUE && values[0] < vMin0 ) ||
				 ( vMax0 < Number.MAX_VALUE && values[0] > vMax0 ) )
			{
				Assert.isTrue( false );
				_code = ParserMTLError.VALUE_OUT_OF_RANGE;
				return false;
			}
			
			for ( var j:int = 1; j <= 2; ++j )
			{
				if( ++i > iMax )
				{
					return true;
				}
				
				var token:String = tokens[i];
				if ( token[0] == "-" )
				{
					if ( token.length == 1 )
					{
						Assert.isTrue( false );
						_code = ParserMTLError.UNEXPECTED_TOKEN;
						return false;
					}
					
					var pattern:RegExp = /[0-9.]/;
					var begin:int = token.search( pattern );
					
					if ( begin != -1 )
					{
						--i;
						return true;
					}
					
					token = token.substr( 1 );
				}
				
				//token is a number
				values[j] = Number( token );
				if ( (vMin1 > -Number.MAX_VALUE && values[j] < vMin1 )
				  || (vMax1 >  Number.MAX_VALUE && values[j] > vMax1 ) )
				{
					Assert.isTrue( false );
					_code = ParserMTLError.VALUE_OUT_OF_RANGE;
					return false;
				}
			}
			
			return true;
		}
		
		private function getNewMaterial( tokens:Vector.<String> ):Boolean
		{
			if ( tokens[0] == "newmtl" )
			{
				_current = _materials.length;
				_materials.push( new MaterialMTL() );
				
				if ( tokens.length > 1 )
				{
					_materials[_current].name = tokens[1];
					return true;
				}
				Assert.isTrue( false );
				_code = ParserMTLError.TOO_MANY_TOKENS;
			}
			return false;
		}
		
		private function getIlluminationMode( tokens:Vector.<String> ):Boolean
		{
			if ( tokens[0] == "illum" )
			{
				if ( tokens.length == 1 )
				{
					Assert.isTrue( false );
					_code = ParserMTLError.TOO_FEW_TOKENS;
					return false;
				}
				
				if ( tokens.length > 2 )
				{
					Assert.isTrue( false );
					_code = ParserMTLError.TOO_MANY_TOKENS;
					return false;
				}
				
				var illum:int = int( tokens[1] );
				if ( (illum == 0 && tokens[1][0] != "0") || illum > 10 )
				{
					Assert.isTrue( false );
					_code = ParserMTLError.VALUE_OUT_OF_RANGE;
					return false;
				}
				_materials[_current].illuminationModel = illum;
				return true;
			}
			return false;
		}
		
		private function getAmbientColor( tokens:Vector.<String> ):Boolean
		{
			if ( tokens[0] == "Ka" )
			{
				if ( tokens.length == 1 )
				{
					Assert.isTrue( false );
					_code = ParserMTLError.TOO_FEW_TOKENS;
					return false;
				}
				return getColor( tokens, _materials[_current].ambientColor );
			}
			return false;
		}
		
		private function getDiffuseColor( tokens:Vector.<String> ):Boolean
		{
			if ( tokens[0] == "Kd" )
			{
				if ( tokens.length == 1 )
				{
					Assert.isTrue( false );
					_code = ParserMTLError.TOO_FEW_TOKENS;
					return false;
				}
				return getColor( tokens, _materials[_current].diffuseColor );
			}
			return false;
		}
		
		private function getSpecularColor( tokens:Vector.<String> ):Boolean
		{
			if ( tokens[0] == "Ks" )
			{
				if ( tokens.length == 1 )
				{
					Assert.isTrue( false );
					_code = ParserMTLError.TOO_FEW_TOKENS;
					return false;
				}
				return getColor( tokens, _materials[_current].specularColor );
			}
			return false;
		}
		
		private function getTransmissionFilter( tokens:Vector.<String> ):Boolean
		{
			if ( tokens[0] == "Tf" )
			{
				if ( tokens.length == 1 )
				{
					Assert.isTrue( false );
					_code = ParserMTLError.TOO_FEW_TOKENS;
					return false;
				}
				return getColor( tokens, _materials[_current].specularColor );
			}
			return false;
		}
		
		private function getOpticalDensity( tokens:Vector.<String> ):Boolean
		{
			if ( tokens[0] == "Ni" )
			{
				if ( tokens.length == 1 )
				{
					Assert.isTrue( false );
					_code = ParserMTLError.TOO_FEW_TOKENS;
					return false;
				}
				
				if ( tokens.length > 2 )
				{
					Assert.isTrue( false );
					_code = ParserMTLError.TOO_MANY_TOKENS;
					return false;
				}
				
				var density:Number = Number(tokens[1]);
				if ( density < 0.001 || density > 10 )
				{
					Assert.isTrue( false );
					_code = ParserMTLError.VALUE_OUT_OF_RANGE;
					return false;
				}
				_materials[_current].opticalDensity = density;
				return true;
			}
			return false;
		}
		
		private function getSpecularExponent( tokens:Vector.<String> ):Boolean
		{
			if ( tokens[0] == "Ns" )
			{
				if ( tokens.length == 1 )
				{
					Assert.isTrue( false );
					_code = ParserMTLError.TOO_FEW_TOKENS;
					return false;
				}
				
				if ( tokens.length > 2 )
				{
					Assert.isTrue( false );
					_code = ParserMTLError.TOO_MANY_TOKENS;
					return false;
				}
				
				var exponent:Number = Number( tokens[1] );
				if ( exponent < 0 || exponent > 1000 )
				{
					Assert.isTrue( false );
					_code = ParserMTLError.VALUE_OUT_OF_RANGE;
					return false;
				}
				_materials[_current].specularExponent = exponent;
				return true;
			}
			return false;
		}
		
		private function getAmbientTexture( tokens:Vector.<String> ):Boolean
		{
			if ( tokens[0] == "map_Ka" )
			{
				if ( tokens.length == 1 )
				{
					Assert.isTrue( false );
					_code = ParserMTLError.TOO_FEW_TOKENS;
					return false;
				}
				return getTexture( tokens, _materials[_current].ambientMap );
			}
			return false;
		}
		
		private function getDiffuseTexture( tokens:Vector.<String> ):Boolean
		{
			if ( tokens[0] == "map_Kd" )
			{
				if ( tokens.length == 1 )
				{
					Assert.isTrue( false );
					_code = ParserMTLError.TOO_FEW_TOKENS;
					return false;
				}
				return getTexture( tokens, _materials[_current].diffuseMap );
			}
			return false;
		}
		
		private function getSpecularTexture( tokens:Vector.<String> ):Boolean
		{
			if ( tokens[0] == "map_Ks" )
			{
				if ( tokens.length == 1 )
				{
					Assert.isTrue( false );
					_code = ParserMTLError.TOO_FEW_TOKENS;
					return false;
				}
				return getTexture( tokens, _materials[_current].specularMap );
			}
			return false;
		}
		
	}

}