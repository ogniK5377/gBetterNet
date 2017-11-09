module( "GNet", package.seeall )

DEBUG_MESSAGES = true
if SERVER then
	AddPacketID = util.AddNetworkString
end

/* @brief Calculate the maximum required bits needed to network a number.
 * @returns Amount of bits required
 * 
 * This function calculates the amount of bits required to network a number, it takes
 * two arguments. The maximum number which will ever be networked and if the integer is
 * signed or not.
*/
function CalculateRequiredBits( max_number, signed )
	return math.max( math.ceil( math.log( max_number ) / math.log( 2 ) ) + Either( signed, 1, 0 ), 1 )
end

local dataTypes = {
	BIT = 0,
	STRING = 1,
	UINT = 2,
	INT = 3,
	FLOAT = 4,
	DOUBLE = 5,
}

local objPacket = {}
objPacket.__index = objPacket
objPacket.__tostring = function(self)
	return string.format( 'Packet("%s") %d bits', self.packet_id, self.total_bits )
end

/* @brief Networks a string
 * 
 * The string which is network must NOT have a NUL character. This function writes
 * a string 1 char at a time and NUL terminates it automatically.
*/
function objPacket.WriteString( self, str )
	table.insert( self.network, {
		t = dataTypes.STRING,
		v = str,
	} )
	self.total_bits = self.total_bits + ( str:len() + 1 ) * 8
end


/* @brief Networks an unsigned character
 * 
 * Networks 1 unsigned byte/8 bits/1 character which has a range from 0->255
*/
function objPacket.WriteUChar( self, x )
	table.insert( self.network, {
		t = dataTypes.UINT,
		v = x,
		bits = 8,
	} )
	self.total_bits = self.total_bits + 8
end

/* @brief Networks an signed character
 * 
 * Networks 1 signed byte/8 bits/1 character which has a range from -128 -> 127
*/
function objPacket.WriteChar( self, x )
	table.insert( self.network, {
		t = dataTypes.INT,
		v = x,
		bits = 8,
	} )
	self.total_bits = self.total_bits + 8
end

/* @brief Networks an unsigned short
 * 
 * Networks 2 unsigned byte/16 bits which has a range from 0->65535
*/
function objPacket.WriteUShort( self, x )
	table.insert( self.network, {
		t = dataTypes.UINT,
		v = x,
		bits = 16,
	} )
	self.total_bits = self.total_bits + 16
end

/* @brief Networks an signed short
 * 
 * Networks 2 signed byte/16 bits which has a range from -32768 -> 32767
*/
function objPacket.WriteShort( self, x )
	table.insert( self.network, {
		t = dataTypes.INT,
		v = x,
		bits = 16,
	} )
	self.total_bits = self.total_bits + 16
end

/* @brief Networks an unsigned long
 * 
 * Networks 4 unsigned byte/32 bits which has a range from 0->4294967295
*/
function objPacket.WriteULong( self, x )
	table.insert( self.network, {
		t = dataTypes.UINT,
		v = x,
		bits = 32,
	} )
	self.total_bits = self.total_bits + 32
end

/* @brief Networks an signed long
 * 
 * Networks 4 signed byte/32 bits which has a range from -2147483648 -> 2147483647
*/
function objPacket.WriteLong( self, x )
	table.insert( self.network, {
		t = dataTypes.INT,
		v = x,
		bits = 32,
	} )
	self.total_bits = self.total_bits + 32
end

/* @brief Networks an unsigned integer
 * 
 * Networks ceil(n/4) unsigned bytes which has a range from 0 -> 2^n-1
 * where n = bits
*/
function objPacket.WriteUInt( self, x, bits )
	table.insert( self.network, {
		t = dataTypes.UINT,
		v = x,
		bits = bits,
	} )
	self.total_bits = self.total_bits + bits
end

/* @brief Networks an signed integer
 * 
 * Networks ceil(n/4) signed bytes which has a range from -2^(n-1) -> 2^(n-1)-1
 * where n = bits
*/
function objPacket.WriteInt( self, x, bits )
	table.insert( self.network, {
		t = dataTypes.INT,
		v = x,
		bits = bits,
	} )
	self.total_bits = self.total_bits + bits
end

/* @brief Networks a float
 * 
 * Networks 4 signed byte/32 bits which has a range from -3.4E+38 -> +3.4E+38 with
 * approxmently with 7 decimal places
*/
function objPacket.WriteFloat( self, x )
	table.insert( self.network, {
		t = dataTypes.FLOAT,
		v = x,
	} )
	self.total_bits = self.total_bits + 32
end

/* @brief Networks a float
 * 
 * Networks 4 signed byte/32 bits which has a range from -3.4E+38 -> 3.4E+38 with
 * approxmently with 7 decimal places
*/
function objPacket.WriteFloat( self, x )
	table.insert( self.network, {
		t = dataTypes.FLOAT,
		v = x,
	} )
	self.total_bits = self.total_bits + 32
end

/* @brief Networks a double
 * 
 * Networks 8 signed bytes/64 bits which has a range from -1.7E+308 -> 1.7E+308 with
 * approxmently with 16 decimal places
*/
function objPacket.WriteDouble( self, x )
	table.insert( self.network, {
		t = dataTypes.DOUBLE,
		v = x,
	} )
	self.total_bits = self.total_bits + 64
end

/* @brief Networks a Vector
 * 
 * Networks the x, y, z components as floats. Takes a total of 96 bits or 12 bytes of
 * data
*/
function objPacket.WriteVector( self, x )
	table.insert( self.network, {t = dTypes.FLOAT, v = x.x} )
	table.insert( self.network, {t = dTypes.FLOAT, v = x.y} )
	table.insert( self.network, {t = dTypes.FLOAT, v = x.z} )
	self.total_bits = self.total_bits + 96
end

/* @brief Networks a Color
 * 
 * Worst case for this function is to network 33 bits and the best case is 25 bits.
 * The r, g, b components of the color table is networked as unsigned chars which 
 * are ceiled to remove the decimal points. There's an extra bit added to determain
 * if an alpha of something besides 255 was networked or not. If the bit is set 
 * to 0/false, the alpha isn't networked. However if the bit is true,
 * the alpha is networked. No extra input is needed as this all happens
 * behind the scenes if the alpha is set to anything which isn't 255.
*/
function objPacket.WriteColor( self, color )
	table.insert(self.network, {t = dTypes.UINT, v = math.ceil(color.r), bits = 8})
	table.insert(self.network, {t = dTypes.UINT, v = math.ceil(color.g), bits = 8})
	table.insert(self.network, {t = dTypes.UINT, v = math.ceil(color.b), bits = 8})
	self.total_bits = self.total_bits + 25
	if color.a ~= 255 then
		table.insert(self.network, {t = dTypes.BIT, v = true})
		table.insert(self.network, {t = dTypes.UINT, v = math.ceil(color.a), bits = 8})
		self.total_bits = self.total_bits + 8
	else
		table.insert(self.network, {t = dTypes.BIT, v = false})
	end
end

/* @brief Networks an Entity
 * 
 * Networks 2 unsigned byte/16 bits which has a range from 0->65535. The item networked
 * is the entity index. On the client you simply can do Entity( ENT_INDEX )
*/
function objPacket.WriteEntity( self, x )
	local ent_index = 0
	if IsValid( x ) then
		ent_index = x:EntIndex()
	end
	table.insert(self.network, {
		t = dTypes.UINT,
		v = ent_index,
		bits = 16
	})
	self.total_bits = self.total_bits + 16
end

/* @brief Networks raw data
 * 
 * Raw data is passed as a string and the length of the data is provided. The packet 
 * writes the total size of the data as an unsigned short. Next the data is written as
 * ( unsigned char * len ) of the data.
*/
function objPacket.WriteData( self, data, len )
	len = len or data:len()
	table.insert(self.network, {
		t = dTypes.UINT,
		v = len,
		bits = 16 -- Max net message size is 64kb. 16 bits = ~65kb 
	})
	self.total_bits = self.total_bits + 16
	for i = 1, len do
		table.insert(self.network, {t = dTypes.UINT, v = data:sub(i, i), bits = 8})
	end
	self.total_bits = self.total_bits + ( 8 * len )
end

-- Aliases
objPacket.WriteNormal = objPacket.WriteVector
objPacket.WriteBool = objPacket.WriteBit
objPacket.WritePlayer = objPacket.WriteEntity

/* @brief Get the total size of the network packet in bits.
 * @returns Amount of bits being sent
*/
function objPacket.GetBits( self )
	return self.total_bits
end

/* @brief Get the total size of the network packet in bytes.
 * @returns Amount of bytes being sent
*/
function objPacket.GetBytes( self )
	return math.ceil( self:GetBits() / 8 )
end

/* @brief Get the total size of the network packet in KB.
 * @returns Amount of kilobytes being sent
*/
function objPacket.GetBytes( self )
	return math.floor( self:GetBytes() / 1024 )
end

/* @brief Networks packet
 * @returns Amount of bits being sent
 * 
 * Iterates through the "network" table and constructs the net message to be sent. The
 * "clients" argument is optional, if it's not specified on the SERVER, the packet is
 * broadcasted to everyone. If it's specified it will network to specific clients. The
 * clients argument can be either a single player or a table of players. Lastly the clients
 * argument is completely ignored on the CLIENT and will just send to the server. The 
 * packet will fail to send if the net message size is too big! The max net message size
 * is 64KB.
*/
function objPacket.Send( self, clients )
	if DEBUG_MESSAGES then
		print( '[gNetwork] Sending Packet ' .. self.packet_id )
	end

	if self:GetKB() > 64 then
		Error( tostring( self ) .. ' is greater than 64KB!\n' )
	end

	net.Start( self.packet_id )

	for _, v in pairs( self.network ) do
		if v.t == dTypes.BIT then
			net.WriteBit( Either( type(v.v) ~= 'boolean', v.v == 1, v.v ) )
		end
		if v.t == dTypes.STRING then
			local len = v.v:len()
			for i = 1, len do net.WriteUInt(v.v:sub(i, i):byte(), 8) end
			net.WriteUInt(0, 8)
		end
		if v.t == dTypes.UINT then
			if type( v.v ) == 'string' then v.v = v.v:byte() end
			net.WriteUInt(v.v, v.bits)
		end
		if v.t == dTypes.INT then
			net.WriteInt(v.v, v.bits)
		end
		if v.t == dTypes.FLOAT then
			net.WriteFloat(v.v)
		end
		if v.t == dTypes.DOUBLE then
			net.WriteDouble(v.v)
		end
	end

	if SERVER then
		if clients then
			net.Send(clients)
		else
			net.Broadcast()
		end
	else
		net.SendToServer()
	end
	return self.total_bits
end

/* @brief Creates a packet
 * @returns objPacket
*/
function Packet( packet_id )
	return setmetatable({
		packet_id = packet_id,
		total_bits = 0,
		network = {},
	}, objPacket)
end
