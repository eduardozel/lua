 local wx = require("wx")
 require("COMPORT")


stx = string.char( 0x7E)
ver = string.char( 0xFF)
etx = string.char( 0xEF)
siz = string.char( 0x06)
nll = string.char( 0x00)

send = { stx, ver, siz, nll, nll, nll, nll, nll, nll, etx };
recv = { '1', '2', '3', '4', '5', '6', '7', '8', '8', '10'};

function panelPlayer()

    panelMP3 = wx.wxPanel(notebook, wx.wxID_ANY)
    sizerBC = wx.wxBoxSizer(wx.wxVERTICAL)

	btnSize = wx.wxSize( 60, 30)

	ID_PN_Play		= 4001
	ID_BUTTON_Play		= 4034
	ID_SPIN_Track		= 4035
-- ----
	pnPLAY = wx.wxStaticBox(panelMP3, ID_PN_Play, "play track", wx.wxPoint( 10, 10), wx.wxSize( 320, 50) )	

    btnPlay = wx.wxButton( pnPLAY, ID_BUTTON_Play, "play",  wx.wxPoint( 150, 10), btnSize )
    frame:Connect( ID_BUTTON_Play, wx.wxEVT_COMMAND_BUTTON_CLICKED, OnPlay)	

    spnTrack = wx.wxSpinCtrl( pnPLAY, ID_SPIN_Track, "1", wx.wxPoint( 15, 15), wx.wxSize( 60, 30) )
    spnTrack:SetToolTip("track")

	
    notebook:AddPage(panelMP3, "player")

end -- panelPHONE

function DEC_HEX(IN)
--	local hx ="0123456789ABCDEF"
--	local t0 = t % 16
--	local t1 = math.floor( t / 16 )
--string.sub( hx,D,D)
	return string.format("%x", IN )
end -- DEC_HEX

function HEX_DEC(IN)
	local t1 = string.sub(IN,  1, 1)
	local t0 = string.sub(IN, -1)
	local hx ="0123456789ABCDEF"
	local d1 = string.find( hx, t1) -1
	local d0 = string.find( hx, t0) -1
	local ou =d1*16+d0
	return ou
end -- DEC_HEX


function getRply(
)
	local rd_len = 1
	local timeout = 4000
	local rply

	for i = 1, #recv, 1 do
		err, rply,  size = pHOST:read( rd_len, timeout )
		recv[i] = rply
	end -- while
end -- getRply

function get_checksum (
)
	local sum = 0
	for i = 2, 7, 1 do
		sum = sum + string.byte( send[i] )
	end -- for
	local t = string.sub( string.format("%X", -sum ), - 4 )
	local s1 = string.sub( t, 1, 2)
	local s0 = string.sub( t, -2)
	local sm1 = string.char( HEX_DEC(s1) )
	local sm0 = string.char( HEX_DEC(s0) )

	send[8] = sm1 -- chSm1
	send[9] = sm0 -- chSm0

end -- get_checksum 

function mp3_next (
)
--	mp3_send_cmd (0x01);
end

function mp3_prev (
)
--	mp3_send_cmd (0x02);
end


--mp3_play_physical (uint16_t num) {
--	mp3_send_cmd (0x03, num);
--}


function SendCommand(
)
	get_checksum()
	for i = 1, 10, 1 do
		sendCOM_HOST( send[i] )
	end
end -- SendCommand

-- Handle the button event

function OnPlay(event)
	local track = spnTrack:GetValue()
	print ("play track "..track)
	openCOM_HOST()
	send[4] = string.char( 0x03) -- cmd

	send[5] = string.char( 0x00) -- feedback

	send[6] = string.char( 0x00) -- para1
	send[7] = string.char( track )  -- para2

	SendCommand()

	getRply()

	closeCOM_HOST()
	local t = string.byte( recv[4] )
	local t3 = DEC_HEX( t )
	t = string.byte( recv[7] )
	local t6 = DEC_HEX( t )
end -- OnPlay(event)
