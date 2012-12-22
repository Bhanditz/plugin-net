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
	import plugin.net.parsers.max3ds.enum.Node3DSType;
	import plugin.net.parsers.max3ds.enum.Track3DSType;
	/**
	 * ...
	 * @author Gary Paluk
	 */
	public class SpotlightNode3DS extends Node3DS 
	{
		
		public var pos: Array = Vertex3DS.create();
		public var color: Array = Color3DS.create();
		public var hotspot: Number = 0;
		public var falloff: Number = 0;
		public var roll: Number = 0;
		public var posTrack: Track3DS = new Track3DS( Track3DSType.VECTOR );
		public var colorTrack: Track3DS = new Track3DS( Track3DSType.VECTOR );
		public var hotspotTrack: Track3DS = new Track3DS( Track3DSType.FLOAT );
		public var falloffTrack: Track3DS = new Track3DS( Track3DSType.FLOAT );
		public var rollTrack: Track3DS = new Track3DS( Track3DSType.FLOAT );
		
		public function SpotlightNode3DS() 
		{
			super( Node3DSType.SPOTLIGHT );
		}
		
	}

}