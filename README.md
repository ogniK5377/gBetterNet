## GNet Library
The networking lib has lots of helper functions which are mainly rewrites of some of the original Garry's mods `net` library. It's mostly built up with dynamic bit counting and `net.WriteInt` and `net.WriteUInt`. This allows us to keep track of everything a lot easier and add logging of everything if needed in the future without overwriting the default functions. Many of the functions in our in house networking library also save bits on networking vs the default Garry's mod networking library. Please take care of networking, you should rarely need to send anything from the client to the server. *Never trust the client*. The networking lib is completely shared so each function can both be called on the server and the client EXCEPT adding messages to the network message pool.

### Functions ###
#### GNet.AddPacketID( string packet_id ) *server* ####
	GNet.AddPacketID( 'UpdatePlayer' )
This function should be called at init. This can be when a script file loads or  in `GM:Initialize`. You **cannot** send a packet without pooling it first. This function is just an alias of `util.AddNetworkString`.

#### `number` GNet.CalculateBits( number max_number, `optional` boolean signed ) *shared* ####
	GNet.CalculateBits( 255 )
	GNet.CalculateBits( 255, true )
This function returns the minimum required bits you'd need to use **IF** you know the maximum value you would ever need for a variable. The second argument decides if you're using a signed or an unsigned integer. What a signed int basically is that it means that your range can potentially go below 0. An unsigned 8 bit int range is from `0-255`. A signed 8 bit int range is `-128-127`.

#### GNet.OnPacketReceive( string packet_id, function callback ) *shared* ####
	GNet.OnPacketReceive( 'ReadAString', function( packet )
		print( packet:ReadString() )
	end )
This function adds a callback to the `packet_id` specified. It takes two argument, the `packet_id` and a callback function. The callback function has 1 argument which is a `PacketReader` metaclass. See below for reading packets.

### Packet Metatable ###

#### `packet` GNet.Packet( string packet_id ) *shared* ####
	local packet = GNet.Packet( 'EmptyPacketLol' )
	packet:Send()
Returns a packet object. This object is what's used to count the bits and use the internal optimized networking functions.

#### packet:WriteString( string str ) *shared* ####
	local packet = GNet.Packet( 'WriteZehString' )
		packet:WriteString( 'hard' )
	packet:Send()
Saves a string to the packets networking table to be networked later on. Please note that your string should **not** contain any null bytes. If for any reason it contains null bytes then consider using `packet:WriteData`. The networking module writes `8 * number of chars + 8` bits.

#### packet:WriteUChar( number char ) *shared* ####
#### packet:WriteUChar( character char ) *shared*
	packet:WriteUChar( 'A' )
	packet:WriteUChar( 48 )
Saves an unsigned character to the networking table to be networked later on. This is an **UNSIGNED** data type which is **8 BITS**, meaning the range of the data which can be sent is `0-255`.

#### packet:WriteChar( number char ) *shared* ####
#### packet:WriteChar( character char ) *shared* ####
	packet:WriteChar( 'A' )
	packet:WriteChar( 48 )
Saves an unsigned character to the networking table to be networked later on. This is an **SIGNED** data type which is **8 BITS**, meaning the range of the data which can be sent is `-128-127`.

#### packet:WriteBit( boolean state ) *shared* ####
#### packet:WriteBit( number state ) *shared* ####
	packet:WriteBit( true )
	packet:WriteBit( 1 )
Saves a bit to the networking table to be sent to the client. This function can take either a number or a boolean as an argument.

#### packet:WriteUShort( number short ) *shared* ####
	packet:WriteUShort( 511 )
Saves an unsigned short to the networking table to be networked later on. This is a **UNSIGNED** data type which is **16 BITS**, meaning the range of the data which can be sent it `0-65535`.

#### packet:WriteShort( number short ) *shared* ####
	packet:WriteShort( -511 )
Saves an short to the networking table to be networked later on. This is a **SIGNED** data type which is **16 BITS**, meaning the range of the data which can be sent it `-32768-32767`.

#### packet:WriteUInt( number int, number bits ) *shared* ####
	packet:WriteUInt( 8912374, GNet.CalculateBits( 9000000 ) )
	packet:WruteUInt( 256, 9 )
Saves an unsigned integer to the networking table to be networked later on. This is a **UNSIGNED** data type. You determine the bits needed, if you're unsure of this refer to the `GNet.CalculateBits` function.

#### packet:WriteInt( number int, number bits ) *shared* ####
	packet:WriteInt( 8912374, GNet.CalculateBits( 9000000, true ) )
	packet:WruteInt( -256, 9 )
Saves an integer to the networking table to be networked later on. This is a **SIGNED** data type. You determine the bits needed, if you're unsure of this refer to the `GNet.CalculateBits` function.

#### packet:WriteFloat( decimal num ) *shared* ####
	packet:WriteFloat( 123.4567 )
Saves a single precision floating point number to be networked later on. This function uses 32 bits of data.

#### packet:WriteDouble( decimal num ) *shared* ####
	packet:WriteDouble( 123.456789912 )
Saves a double precision floating point number to be networked later on. This function uses 64 bits of data.

#### packet:WriteVector( vector vec ) *shared* ####
	packet:WriteVector( 123, 45.67, 8723 )
Saves a vector to be networked later on. This function sends the X,Y,Z competent of a vector as SINGLE PRECISION FLOATING POINTS. so be careful as some insignificant data will be lost.

#### packet:WriteColor( Color col ) *shared* ####
	packet:WriteColor( Color( 255, 0, 213 ) )
	packet:WriteColor( Color( 255, 0, 111, 231 ) )
Saves a color table to be networked later on. The values passed into this function are rounded up MEANING. `Color( 231.2, 214.9, 201 )` will become `Color( 232, 215, 201 )`. If the alpha in this function is equal to 255*(the default value)*, then only 25 bits are networked. 24 bits for the r,g,b values which are sent as unsigned characters and 1 bit which determines if alpha is `255` or not. If the alpha is not `255` then 33 bits will be networked.

#### packet:WriteEntity( Entity ent ) *shared* ####
	packet:WriteEntity( Entity( 1 ) )
Saves a entity to be networked later on. This function is essentially `packet:WriteUShort( ent:EntIndex() )`. So it sends 16 bits of data.

#### packet:WriteAngle( Angle ang ) *shared* ####
	packet:WriteAngle( 123, 45.67, 8723 )
Saves a angle to be networked later on. This function sends the P,Y,R competent of a angle as SINGLE PRECISION FLOATING POINTS. so be careful as some insignificant data will be lost.

#### packet:WriteData( string data, number len ) *shared* ####
	packet:WriteData( 'this is \x00 some sick \x21\x82\x82\x11\x01 data', 30 )
Saves some raw data to be networked later on. This function can take all types of binary data INCLUDING null terminated strings.

#### packet:WriteNormal( Vector normal ) *shared* ####
	packet:WriteNormal( Vector( 0, 1, 0 ) )
This function is an alias of `packet:WriteVector`

#### packet:WriteBool( boolean bool ) *shared* ####
	packet:WriteBool( true )
This function is an alias of `packet:WriteBit`

#### packet:WritePlayer( Player ply ) *shared* ####
	packet:WritePlayer( player.GetAll()[1] )
This function is an alias of `packet:WriteEntity`

#### packet:GetBits() *shared* ####
	print( 'This packet has %d bits'%packet:GetBits() )
Returns the amount of bits which will be sent to the client/server.

#### packet:GetBytes() *shared* ####
	print( 'This packet has %d bytes'%packet:GetBits() )
Returns the amount of bytes which will be sent to the client/server.

#### packet:GetKB() *shared* ####
	print( 'The packet is %dkb'%packet:GetKB() )
Returns the size of the packet which will be sent to the client/server in kilobytes.

#### `number` packet:Send( `optional` Player ply ) *shared* ####
#### `number` packet:Send( `optional` table plyList ) *shared* ####
	packet:Send()
	packet:Send( ply )
	packet:Send( { ply1, ply2 } )
This is the main function in the networking library. It actually handles the sending of the data to the client/server. it can be called in various different ways to preform different functions. The **first argument is completely optional on the server** HOWEVER, on the **client, there is no first argument** as you can only send to the server. The first argument can send data to a specific player if only 1 `Player` entity is there, it can send to multiple players if there is a `table of players` such as `player.GetAll()`, OR if the **first argument is completely blank it networks to all clients**. Once the data is networked, the function returns how many bits were actually sent to the client.

### PacketReader Metatable ###
#### `PacketReader` GNet.PacketReader( string packet_id, number len, Player ply ) *shared* ####
	GNet.PacketReader(packet_id, len, ply)
This is an internal function which shouldn't be called. It's automatically called with `GNet.OnPacketReceive` and passed into the callback. The function returns the `PacketReader` metatable.

#### `Player` PacketReader:GetPlayer() *shared* ####
	print( 'Player %s sent the packet'%PacketReader:GetPlayer():Nick() )
Returns the player which sent the packet on the server realm. However in the client realm `LocalPlayer()` is returned.

#### `number` PacketReader:RemainingBits() *shared* ####
	print( 'There is still %d unread bits'%PacketReader:RemainingBits() )
Returns how many bits are still remaining to be read in the packet. If this value is 0 then there is no more data to be read in the packet.

#### `boolean` PacketReader:HasData() *shared* ####
	while PacketReader:HasData() do
		table.insert( itemIDList, PacketReader:ReadUInt( 32 ) )
	end
This function uses `PacketReader:RemainingBits` to determine if there is still data in the packet to be read. This is extremely useful for reading large chunks of predictable data as we never have to send the length of how much we have to read. This saves us on networking extra bits.

#### `string` PacketReader:ReadString() *shared* ####
	print( PacketReader:ReadString() )
Reads a string from the packet. It reads `(StrLen * 8) + 8 bits` of data.

#### `string` PacketReader:ReadData() *shared* ####
	print( PacketReader:ReadData() )
Reads binary data from the packet. It reads `(DataLen * 8) + 16 bits` of data.

#### `boolean` PacketReader:ReadBit() *shared* ####
Reads a single bit from the packet.

#### `number` PacketReader:ReadUShort() *shared* ####
Reads an unsigned short from the packet. It reads `16 bits` of data.

#### `number` PacketReader:ReadShort() *shared* ####
Reads an short from the packet. It reads `16 bits` of data.

#### `number` PacketReader:ReadUInt( number n ) *shared* ####
Reads an unsigned int from the packet. It reads `n bits` of data.

#### `number` PacketReader:ReadInt( number n ) *shared* ####
Reads an int from the packet. It reads `n bits` of data.

#### `number` PacketReader:ReadUChar() *shared* ####
Reads an unsigned character from the packet. It reads `8 bits` of data.

#### `number` PacketReader:ReadChar() *shared* ####
Reads an character from the packet. It reads `8 bits` of data.

#### `decimal` PacketReader:ReadFloat() *shared* ####
Reads an single precision floating point number from the packet. It reads `32 bits` of data.

#### `decimal` PacketReader:ReadDouble() *shared* ####
Reads an double precision floating point number from the packet. It reads `64 bits` of data.

#### `Vector` PacketReader:ReadVector() *shared* ####
Reads an vector from the packet. It reads `96 bits` of data.

#### `Color` PacketReader:ReadColor() *shared* ####
Reads an color from the packet. It reads `25 bits` of data IF the alpha is `255`. If the alpha is not `255` then it reads `33 bits` of data.

#### `Entity` PacketReader:ReadEntity() *shared* ####
Reads an entity from the packet. It reads `8 bits` of data.

#### `Angle` PacketReader:ReadAngle() *shared* ####
Reads an angle from the packet. It reads `96 bits` of data.

#### `Vector` PacketReader:ReadNormal() *shared* ####
Reads an normal from the packet. This function is an alias of `PacketReader:ReadVector`.

#### `boolean` PacketReader:ReadBool() *shared* ####
Reads an boolean from the packet. This function is an alias of `PacketReader:ReadBit`.

#### `Player` PacketReader:ReadPlayer() *shared* ####
Reads an player from the packet. This function is an alias of `PacketReader:ReadEntity`.

### Network module example ###
	if SERVER then
		GNet.AddPacketID( 'a_packet_test' )
		concommand.Add("net_test", function()
			local p = GNet.Packet( 'a_packet_test' )
				p:WriteString('this is a string')
				p:WriteUChar( 254 )
				p:WriteBit( true )
				p:WriteBit( 1 )
				p:WriteUShort( 271 )
				p:WriteUInt( 12345, 32 )
				p:WriteInt( 12345, 32 )
				p:WriteChar( 254 )
				p:WriteShort( 271 )
				p:WriteFloat( 123.45 )
				p:WriteDouble( 123.45 )
				p:WriteVector( Vector( 123, 456, 789 ) )
				p:WriteColor( Color( 213, 211, 91, 221 ) )
				p:WriteEntity( player.GetAll()[1] )
				p:WriteAngle( Angle( 123, 456, 789 ) )
				p:WriteNormal( Vector( 1, 0, 1 ) )
				p:WriteBool( false )
				p:WritePlayer( player.GetAll()[1] )
				for i = 1, math.random(5, 10) do
					local c = math.random(0, 255)
					p:WriteUChar( c )
					print(c)
				end
			p:Send()
		end )
	else
		GNet.OnPacketReceive( 'a_packet_test', function( packet )
	
			print( packet:ReadString() )
			print( packet:ReadUChar() )
			print( packet:ReadBit() )
			print( packet:ReadBit() )
			print( packet:ReadUShort() )
			print( packet:ReadUInt( 32 ) )
			print( packet:ReadInt( 32 ) )
			print( packet:ReadChar() )
			print( packet:ReadShort() )
			print( packet:ReadFloat() )
			print( packet:ReadDouble() )
			print( packet:ReadVector() )
			print( packet:ReadColor() )
			print( packet:ReadEntity() )
			print( packet:ReadAngle() )
			print( packet:ReadNormal() )
			print( packet:ReadBool() )
			print( packet:ReadPlayer() )
			
			while packet:HasData() do
				Msg('%s '%packet:ReadUChar())
			end
			MsgN()
			
			print( '%d bits still need to be read'%( packet:RemainingBits() ) ) // this returns 0
		end )
	end
This is a working example of the network lib in action.