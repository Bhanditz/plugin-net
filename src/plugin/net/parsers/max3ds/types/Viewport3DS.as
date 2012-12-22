/*
 * Copyright (c) 2012 by Gary Paluk, all rights reserved.
 * Plugin.IO - http://www.plugin.io
 * 
 * Copyright (c) 1996-2008 by Jan Eric Kyprianidis, all rights reserved.
 * 
 * This program is free  software: you can redistribute it and/or modify 
 * it under the terms of the GNU Lesser General Public License as published 
 * by the Free Software Foundation, either version 3 of the License, or 
 * (at your option) any later version.
 * 
 * This program  is  distributed in the hope that it will be useful, 
 * but WITHOUT ANY WARRANTY; without even the implied warranty of 
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the 
 * GNU Lesser General Public License for more details.
 * 
 * You should  have received a copy of the GNU Lesser General Public License
 * along with  this program; If not, see <http://www.gnu.org/licenses/>. 
 */
package plugin.net.parsers.max3ds.types 
{
	import plugin.net.parsers.max3ds.Chunk3DS;
	import plugin.net.parsers.max3ds.enum.View3DSType;
	import plugin.net.parsers.max3ds.Reader3DS;
	/**
	 * ...
	 * @author Gary Paluk
	 */
	public class Viewport3DS 
	{
		
		public static const LAYOUT_MAX_VIEWS: int = 32;
		
		public var layoutStyle: int = 0;
		public var layoutActive: int = 0;
		public var layoutSwap: int = 0;
		public var layoutSwapPrior: int = 0;
		public var layoutSwapView: int = 0;
		public var layoutPosition: Array = [ 0, 0 ];
		public var layoutSize: Array = [ 0, 0 ];
		public var layoutViews: Array = [];
		public var defaultType: View3DSType;
		public var defaultPosition: Array = Vertex3DS.create();
		public var defaultWidth: Number = 0;
		public var defaultHorizAngle: Number = 0;
		public var defaultVertAngle: Number = 0;
		public var defaultRollAngle: Number = 0;
		public var defaultCamera: String = "";
		
		public function Viewport3DS( model: Model3DS, r: Reader3DS, cp: Chunk3DS ) 
		{
			read( model, r, cp );
		}
		
		public function read( model: Model3DS, r: Reader3DS, cp: Chunk3DS ): void
		{
			var cp1: Chunk3DS;
			
			switch( cp.id )
			{
				case Chunk3DS.VIEWPORT_LAYOUT:
						var cur: int = 0;
						layoutStyle = r.readU16( cp );
						layoutActive = r.readS16( cp );
						cp.skip( 4 );
						layoutSwap = r.readS16( cp );
						cp.skip( 4 );
						layoutSwapPrior = r.readS16( cp );
						layoutSwapView = r.readS16( cp );
						while( cp.inside() )
						{
							cp1 = r.next( cp );
							switch( cp1.id )
							{
								case Chunk3DS.VIEWPORT_SIZE:
										layoutPosition[ 0 ] = r.readU16( cp1 );
										layoutPosition[ 1 ] = r.readU16( cp1 );
										layoutSize[ 0 ] = r.readU16( cp1 );
										layoutSize[ 1 ] = r.readU16( cp1 );
									break;
								case Chunk3DS.VIEWPORT_DATA_3:
										if ( cur < LAYOUT_MAX_VIEWS )
										{
											cp1.skip( 4 );
											layoutViews.push( new View3DS() );
											layoutViews[ cur ].axisLock = r.readU16( cp1 );
											layoutViews[ cur ].position[ 0 ] = r.readS16( cp1 );
											layoutViews[ cur ].position[ 1 ] = r.readS16( cp1 );
											layoutViews[ cur ].size[ 0 ] = r.readS16( cp1 );
											layoutViews[ cur ].size[ 1 ] = r.readS16( cp1 );
											layoutViews[ cur ].type = r.readU16( cp1 );
											layoutViews[ cur ].zoom = r.readFloat( cp1 );
											r.readVector( cp1, layoutViews[ cur ].center );
											layoutViews[ cur ].horizAngle = r.readFloat( cp1 );
											layoutViews[ cur ].vertAngle = r.readFloat( cp1 );
											layoutViews[ cur ].camera = r.readString( cp1 );
											++cur;
										}
									break;
								case Chunk3DS.VIEWPORT_DATA:
										trace( "WARNING: 3DS R2 & R3 chunk unsupported." );
									break;
							}
						}
					break;
				case Chunk3DS.DEFAULT_VIEW:
						while ( cp.inside() )
						{
							cp1 = r.next( cp );
							switch( cp1.id )
							{
								case Chunk3DS.VIEW_TOP:
										defaultType = View3DSType.TOP;
										r.readVector( cp1, defaultPosition );
										defaultWidth = r.readFloat( cp1 );
									break;
								case Chunk3DS.VIEW_BOTTOM:
										defaultType = View3DSType.BOTTOM;
										r.readVector( cp1, defaultPosition );
										defaultWidth = r.readFloat( cp1 );
									break;
								case Chunk3DS.VIEW_LEFT:
										defaultType = View3DSType.LEFT;
										r.readVector( cp1, defaultPosition );
										defaultWidth = r.readFloat( cp1 );
									break;
								case Chunk3DS.VIEW_RIGHT:
										defaultType = View3DSType.RIGHT;
										r.readVector( cp1, defaultPosition );
										defaultWidth = r.readFloat( cp1 );
									break;
								case Chunk3DS.VIEW_FRONT:
										defaultType = View3DSType.FRONT;
										r.readVector( cp1, defaultPosition );
										defaultWidth = r.readFloat( cp1 );
									break;
								case Chunk3DS.VIEW_BACK:
										defaultType = View3DSType.BACK;
										r.readVector( cp1, defaultPosition );
										defaultWidth = r.readFloat( cp1 );
									break;
								case Chunk3DS.VIEW_USER:
										defaultType = View3DSType.USER;
										r.readVector( cp1, defaultPosition );
										defaultWidth = r.readFloat( cp1 );
										defaultHorizAngle = r.readFloat( cp1 );
										defaultVertAngle = r.readFloat( cp1 );
										defaultRollAngle = r.readFloat( cp1 );
									break;
								case Chunk3DS.VIEW_CAMERA:
										defaultType = View3DSType.CAMERA;
										defaultCamera = r.readString( cp1 );
									break;
							}
						}
					break;
			}
		}
		
	}

}