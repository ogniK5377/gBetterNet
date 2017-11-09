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
