pico-8 cartridge // http://www.pico-8.com
version 18
__lua__
-- count down clock for faust game jam 2018 https://itch.io/jam/faust-game-jam   modified by arch.jslin
-- original from 1stclock! by ultrabrite: https://www.lexaloffle.com/bbs/?tid=30199

--     yyyy mm dd hh mm ss
endt1={2023, 9, 2,14, 0, 0}
endt2={2023, 9, 2,20,30, 0}
endt3={2023, 9, 3,15, 0, 0}
stitle1="faust game jam"
stitle2="2023 timer"
sinfo1="concept"
sinfo2="presentation"
stover="time over"

function timestr(h,m,s)
	return (h<10 and '0' or '')..h..':'..(m<10 and '0' or '')..m..':'..(s<10 and '0' or '')..s
end

function cal_tleft(endt)
    local d,h,m,s=stat(92),stat(93),stat(94),stat(95)
    return (endt[3]-d)*864 + (endt[4]-h)*36 + (endt[5]-m)*0.6 + (endt[6]-s)*0.01 
    -- need to consider it's 16-bit fixedpoint number and will overflow over -32768 ~ 32767.99999
end

function tleft_to_hms(t)
    -- epsilon to compensate for sometimes things like 0.6 * 100 == 59.999x happen
    -- it's ok to make epsilon overcompensate a tiny bit, because we floor everything anyway
    local eps = 0.001
    return flr((t+eps)/36), flr(((t+eps)%36)*100/60), flr(((t+eps)%0.6)*100)
    -- need to consider it's 16-bit fixedpoint number and will overflow over -32768 ~ 32767.99999
    -- fortunately lua's modulo works with fixedpoint/floating point number
end

--months={'january','february','march','april','may','june','july','august','september','october','november','december'}
--[[function datestr()
	local y,m,d=stat(90),stat(91),stat(92)
	return y..' '..months[m]..' '..d
end]]

-- -- -- (sprite print) -- -- --

spl={}
lts=":0123456789abcdefghijklmnopqrstuvwxyz"
for i=1,#lts do spl[sub(lts,i,i)]=i-1 end

function sprint(str,fnt,sz,x,y)
	local dx=8*sz
	for i=1,#str do
		local c=sub(str,i,i)
		local sp=spl[c]
		if sp then
			local sx=sp%(16/sz)
			local sy=flr(sp/(16/sz))
 		local s=fnt+sx*sz+sy*16*sz
 		spr(s,x,y,sz,sz)
 	end
 	x+=((c==':') and (dx/2) or dx)
	end
end

-- -- -- (end of sprite print) -- -- --

ost95=-1

function _update()
    cls()
    local tleft1 = cal_tleft(endt1)
    local tleft2 = cal_tleft(endt2)
    local tleft3 = cal_tleft(endt3)
    local tleft  = 0
    if tleft3 > -3 then                    -- fall through, the relationship between tlefts has to be tleft3 > 2 > 1  
        tleft = tleft3
        sinfo1 = "until upload"
        sinfo2 = ""
    end                                      -- the -300 is a 300 second buffer when the timer should show "Time Over"
    if tleft2 > -3 then 
        tleft = tleft2 
        sinfo1 = "alpha demo"
        sinfo2 = ""
    end 
    if tleft1 > -3 then 
        tleft = tleft1
        sinfo1 = "concept"
        sinfo2 = "presentation"        
    end
    if tleft >= 0 then 
        local stim=timestr(tleft_to_hms(tleft))
        --local sdat=datestr()
        if tleft < 36 then
            sprint(stim,128,2,8,50)
        elseif tleft < 72 then
            sprint(stim,64,2,8,50)
        else
            sprint(stim,0,2,8,50)
        end
        sprint(stitle1,192,1,64-4*#stitle1,20)
        sprint(stitle2,192,1,64-4*#stitle2,30)
        sprint(sinfo1,192,1,64-4*#sinfo1,80)
        sprint(sinfo2,192,1,64-4*#sinfo2,90)
        --sprint(sdat,192,1,64-4*#sdat,70) keep one for reference
        if (stat(95)!=ost95) then -- just making sure the sound won't play every frame, instead of every second
          if tleft < 0.1 then
            sfx(1)
          elseif tleft < 0.6 then
            sfx(0)
          end      
          ost95=stat(95)
        end
    else
        sprint(stover,192,1,64-4*#stover,60)
    end
end
__gfx__
00000000000000000006666666666000000111111111100000066666666660000006666666666000000111111111100000066666666660000006666666666000
00000000000000000060666666660600001011111111060000106666666606000010666666660600006011111111060000606666666601000060666666660100
00000000000000000066066666606600001101111110660000110666666066000011066666606600006601111110660000660666666011000066066666601100
00000000000000000066600000066600001110000006660000111000000666000011100000066600006660000006660000666000000111000066600000011100
00066000000000000066600000066600001110000006660000111000000666000011100000066600006660000006660000666000000111000066600000011100
00666600000000000066600000066600001110000006660000111000000666000011100000066600006660000006660000666000000111000066600000011100
00066000000000000066011111106600001101111110660000110666666066000011066666606600006606666660660000660666666011000066066666601100
00000000000000000000111111110000000011111111000000006666666600000000666666660000000066666666000000006666666600000000666666660000
00000000000000000066011111106600001101111110660000660666666011000011066666606600001106666660660000110666666066000066066666606600
00066000000000000066600000066600001110000006660000666000000111000011100000066600001110000006660000111000000666000066600000066600
00666600000000000066600000066600001110000006660000666000000111000011100000066600001110000006660000111000000666000066600000066600
00066000000000000066600000066600001110000006660000666000000111000011100000066600001110000006660000111000000666000066600000066600
00000000000000000066600000066600001110000006660000666000000111000011100000066600001110000006660000111000000666000066600000066600
00000000000000000066066666606600001101111110660000660666666011000011066666606600001101111110660000110666666066000066066666606600
00000000000000000060666666660600001011111111060000606666666601000010666666660600001011111111060000106666666606000060666666660600
00000000000000000006666666666000000111111111100000066666666660000006666666666000000111111111100000066666666660000006666666666000
00066666666660000006666666666000000666666666600000000000000000000000000000000000000000000000000000000000000000000000000000000000
00106666666606000060666666660600006066666666060000000000000000000000000000000000000000000000000000000000000000000000000000000000
00110666666066000066066666606600006606666660660000000000000000000000000000000000000000000000000000000000000000000000000000000000
00111000000666000066600000066600006660000006660000000000000000000000000000000000000000000000000000000000000000000000000000000000
00111000000666000066600000066600006660000006660000000000000000000000000000000000000000000000000000000000000000000000000000000000
00111000000666000066600000066600006660000006660000000000000000000000000000000000000000000000000000000000000000000000000000000000
00110111111066000066066666606600006606666660660000000000000000000000000000000000000000000000000000000000000000000000000000000000
00001111111100000000666666660000000066666666000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00110111111066000066066666606600001106666660660000000000000000000000000000000000000000000000000000000000000000000000000000000000
00111000000666000066600000066600001110000006660000000000000000000000000000000000000000000000000000000000000000000000000000000000
00111000000666000066600000066600001110000006660000000000000000000000000000000000000000000000000000000000000000000000000000000000
00111000000666000066600000066600001110000006660000000000000000000000000000000000000000000000000000000000000000000000000000000000
00111000000666000066600000066600001110000006660000000000000000000000000000000000000000000000000000000000000000000000000000000000
00110111111066000066066666606600001106666660660000000000000000000000000000000000000000000000000000000000000000000000000000000000
00101111111106000060666666660600001066666666060000000000000000000000000000000000000000000000000000000000000000000000000000000000
00011111111110000006666666666000000666666666600000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000aaaaaaaaaa0000001111111111000000aaaaaaaaaa000000aaaaaaaaaa0000001111111111000000aaaaaaaaaa000000aaaaaaaaaa000
000000000000000000a0aaaaaaaa0a000010111111110a000010aaaaaaaa0a000010aaaaaaaa0a0000a0111111110a0000a0aaaaaaaa010000a0aaaaaaaa0100
000000000000000000aa0aaaaaa0aa00001101111110aa0000110aaaaaa0aa0000110aaaaaa0aa0000aa01111110aa0000aa0aaaaaa0110000aa0aaaaaa01100
000000000000000000aaa000000aaa0000111000000aaa0000111000000aaa0000111000000aaa0000aaa000000aaa0000aaa0000001110000aaa00000011100
000aa0000000000000aaa000000aaa0000111000000aaa0000111000000aaa0000111000000aaa0000aaa000000aaa0000aaa0000001110000aaa00000011100
00aaaa000000000000aaa000000aaa0000111000000aaa0000111000000aaa0000111000000aaa0000aaa000000aaa0000aaa0000001110000aaa00000011100
000aa0000000000000aa01111110aa00001101111110aa0000110aaaaaa0aa0000110aaaaaa0aa0000aa0aaaaaa0aa0000aa0aaaaaa0110000aa0aaaaaa01100
0000000000000000000011111111000000001111111100000000aaaaaaaa00000000aaaaaaaa00000000aaaaaaaa00000000aaaaaaaa00000000aaaaaaaa0000
000000000000000000aa01111110aa00001101111110aa0000aa0aaaaaa0110000110aaaaaa0aa0000110aaaaaa0aa0000110aaaaaa0aa0000aa0aaaaaa0aa00
000aa0000000000000aaa000000aaa0000111000000aaa0000aaa0000001110000111000000aaa0000111000000aaa0000111000000aaa0000aaa000000aaa00
00aaaa000000000000aaa000000aaa0000111000000aaa0000aaa0000001110000111000000aaa0000111000000aaa0000111000000aaa0000aaa000000aaa00
000aa0000000000000aaa000000aaa0000111000000aaa0000aaa0000001110000111000000aaa0000111000000aaa0000111000000aaa0000aaa000000aaa00
000000000000000000aaa000000aaa0000111000000aaa0000aaa0000001110000111000000aaa0000111000000aaa0000111000000aaa0000aaa000000aaa00
000000000000000000aa0aaaaaa0aa00001101111110aa0000aa0aaaaaa0110000110aaaaaa0aa00001101111110aa0000110aaaaaa0aa0000aa0aaaaaa0aa00
000000000000000000a0aaaaaaaa0a000010111111110a0000a0aaaaaaaa01000010aaaaaaaa0a000010111111110a000010aaaaaaaa0a0000a0aaaaaaaa0a00
0000000000000000000aaaaaaaaaa0000001111111111000000aaaaaaaaaa000000aaaaaaaaaa0000001111111111000000aaaaaaaaaa000000aaaaaaaaaa000
000aaaaaaaaaa000000aaaaaaaaaa000000aaaaaaaaaa00000000000000000000000000000000000000000000000000000000000000000000000000000000000
0010aaaaaaaa0a0000a0aaaaaaaa0a0000a0aaaaaaaa0a0000000000000000000000000000000000000000000000000000000000000000000000000000000000
00110aaaaaa0aa0000aa0aaaaaa0aa0000aa0aaaaaa0aa0000000000000000000000000000000000000000000000000000000000000000000000000000000000
00111000000aaa0000aaa000000aaa0000aaa000000aaa0000000000000000000000000000000000000000000000000000000000000000000000000000000000
00111000000aaa0000aaa000000aaa0000aaa000000aaa0000000000000000000000000000000000000000000000000000000000000000000000000000000000
00111000000aaa0000aaa000000aaa0000aaa000000aaa0000000000000000000000000000000000000000000000000000000000000000000000000000000000
001101111110aa0000aa0aaaaaa0aa0000aa0aaaaaa0aa0000000000000000000000000000000000000000000000000000000000000000000000000000000000
00001111111100000000aaaaaaaa00000000aaaaaaaa000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001101111110aa0000aa0aaaaaa0aa0000110aaaaaa0aa0000000000000000000000000000000000000000000000000000000000000000000000000000000000
00111000000aaa0000aaa000000aaa0000111000000aaa0000000000000000000000000000000000000000000000000000000000000000000000000000000000
00111000000aaa0000aaa000000aaa0000111000000aaa0000000000000000000000000000000000000000000000000000000000000000000000000000000000
00111000000aaa0000aaa000000aaa0000111000000aaa0000000000000000000000000000000000000000000000000000000000000000000000000000000000
00111000000aaa0000aaa000000aaa0000111000000aaa0000000000000000000000000000000000000000000000000000000000000000000000000000000000
001101111110aa0000aa0aaaaaa0aa0000110aaaaaa0aa0000000000000000000000000000000000000000000000000000000000000000000000000000000000
0010111111110a0000a0aaaaaaaa0a000010aaaaaaaa0a0000000000000000000000000000000000000000000000000000000000000000000000000000000000
0001111111111000000aaaaaaaaaa000000aaaaaaaaaa00000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000008888888888000000111111111100000088888888880000008888888888000000111111111100000088888888880000008888888888000
00000000000000000080888888880800001011111111080000108888888808000010888888880800008011111111080000808888888801000080888888880100
00000000000000000088088888808800001101111110880000110888888088000011088888808800008801111110880000880888888011000088088888801100
00000000000000000088800000088800001110000008880000111000000888000011100000088800008880000008880000888000000111000088800000011100
00088000000000000088800000088800001110000008880000111000000888000011100000088800008880000008880000888000000111000088800000011100
00888800000000000088800000088800001110000008880000111000000888000011100000088800008880000008880000888000000111000088800000011100
00088000000000000088011111108800001101111110880000110888888088000011088888808800008808888880880000880888888011000088088888801100
00000000000000000000111111110000000011111111000000008888888800000000888888880000000088888888000000008888888800000000888888880000
00000000000000000088011111108800001101111110880000880888888011000011088888808800001108888880880000110888888088000088088888808800
00088000000000000088800000088800001110000008880000888000000111000011100000088800001110000008880000111000000888000088800000088800
00888800000000000088800000088800001110000008880000888000000111000011100000088800001110000008880000111000000888000088800000088800
00088000000000000088800000088800001110000008880000888000000111000011100000088800001110000008880000111000000888000088800000088800
00000000000000000088800000088800001110000008880000888000000111000011100000088800001110000008880000111000000888000088800000088800
00000000000000000088088888808800001101111110880000880888888011000011088888808800001101111110880000110888888088000088088888808800
00000000000000000080888888880800001011111111080000808888888801000010888888880800001011111111080000108888888808000080888888880800
00000000000000000008888888888000000111111111100000088888888880000008888888888000000111111111100000088888888880000008888888888000
00088888888880000008888888888000000888888888800000000000000000000000000000000000000000000000000000000000000000000000000000000000
00108888888808000080888888880800008088888888080000000000000000000000000000000000000000000000000000000000000000000000000000000000
00110888888088000088088888808800008808888880880000000000000000000000000000000000000000000000000000000000000000000000000000000000
00111000000888000088800000088800008880000008880000000000000000000000000000000000000000000000000000000000000000000000000000000000
00111000000888000088800000088800008880000008880000000000000000000000000000000000000000000000000000000000000000000000000000000000
00111000000888000088800000088800008880000008880000000000000000000000000000000000000000000000000000000000000000000000000000000000
00110111111088000088088888808800008808888880880000000000000000000000000000000000000000000000000000000000000000000000000000000000
00001111111100000000888888880000000088888888000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00110111111088000088088888808800001108888880880000000000000000000000000000000000000000000000000000000000000000000000000000000000
00111000000888000088800000088800001110000008880000000000000000000000000000000000000000000000000000000000000000000000000000000000
00111000000888000088800000088800001110000008880000000000000000000000000000000000000000000000000000000000000000000000000000000000
00111000000888000088800000088800001110000008880000000000000000000000000000000000000000000000000000000000000000000000000000000000
00111000000888000088800000088800001110000008880000000000000000000000000000000000000000000000000000000000000000000000000000000000
00110111111088000088088888808800001108888880880000000000000000000000000000000000000000000000000000000000000000000000000000000000
00101111111108000080888888880800001088888888080000000000000000000000000000000000000000000000000000000000000000000000000000000000
00011111111110000008888888888000000888888888800000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000006666000666600006666660066666600600066006666660066666600666666006666660066666600066660006666600006666000666660006666660
00660000066600600006600000000060000006600600066006000000066000000000066006600060060006600660006006600060066000600660006006600000
00660000066600600006600000000060000006600600066006000000066000000000066006600060060006600660006006600060066000000660006006600000
00000000066060600006600006666660066666600666666006666660066666600000660006666660066666600666666006666600066000000660006006666600
00660000066006600006600006600000000006600000066000000660066000600000660006600060000006600660006006600060066000000660006006600000
00660000066006600006600006600000000006600000066000000660066000600006600006600060000006600660006006600060066000600660006006600000
00000000006666000666666006666660066666600000066006666660066666600006600006666660066666600660006006666600006666000666660006666660
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
06666660006666000660006006666660066666600660006006600000066000600600006000666600066666000066660006666600006666600666666006600060
06600000066000600660006000066000000006600660060006600000066606600660006006600060066000600660006006600060066000060006600006600060
06600000066000000660006000066000000006600660600006600000066060600666006006600060066000600660006006600060066000000006600006600060
06666600066066600666666000066000000006600666000006600000066000600606606006600060066666000660006006666600006666600006600006600060
06600000066000600660006000066000066006600660600006600000066000600600666006600060066000000660606006606000000000060006600006600060
06600000066000600660006000066000066006600660060006600000066000600600066006600060066000000660066006600600060000060006600006600060
06600000006666000660006006666660006666000660006006666660066000600600006000666600066000000066666006600060006666600006600000666600
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
06600060066000600600006006000060066666600000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
06600060066000600660006006000060000006600000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
06600060066000600066060000600600000066000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
06600060066000600006600000066000000660000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
06600060066060600060660000066000006600000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00660600066606600600066000066000066000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00066000066000600600006000066000066666600000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__label__
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000001111111111000000bbbbbbbbbb00000000000000bbbbbbbbbb000000bbbbbbbbbb00000000000000bbbbbbbbbb000000bbbbbbbbbb00000000000
000000000010111111110b0000b0bbbbbbbb0100000000000010bbbbbbbb0b0000b0bbbbbbbb01000000000000b0bbbbbbbb0b0000b0bbbbbbbb010000000000
00000000001101111110bb0000bb0bbbbbb011000000000000110bbbbbb0bb0000bb0bbbbbb011000000000000bb0bbbbbb0bb0000bb0bbbbbb0110000000000
0000000000111000000bbb0000bbb000000111000000000000111000000bbb0000bbb000000111000000000000bbb000000bbb0000bbb0000001110000000000
0000000000111000000bbb0000bbb00000011100000bb00000111000000bbb0000bbb00000011100000bb00000bbb000000bbb0000bbb0000001110000000000
0000000000111000000bbb0000bbb0000001110000bbbb0000111000000bbb0000bbb0000001110000bbbb0000bbb000000bbb0000bbb0000001110000000000
00000000001101111110bb0000bb0bbbbbb01100000bb00000110bbbbbb0bb0000bb0bbbbbb01100000bb00000bb01111110bb0000bb0bbbbbb0110000000000
0000000000001111111100000000bbbbbbbb0000000000000000bbbbbbbb00000000bbbbbbbb00000000000000001111111100000000bbbbbbbb000000000000
00000000001101111110bb0000110bbbbbb0bb000000000000110bbbbbb0bb0000110bbbbbb0bb000000000000bb01111110bb0000bb0bbbbbb0bb0000000000
0000000000111000000bbb0000111000000bbb00000bb00000111000000bbb0000111000000bbb00000bb00000bbb000000bbb0000bbb000000bbb0000000000
0000000000111000000bbb0000111000000bbb0000bbbb0000111000000bbb0000111000000bbb0000bbbb0000bbb000000bbb0000bbb000000bbb0000000000
0000000000111000000bbb0000111000000bbb00000bb00000111000000bbb0000111000000bbb00000bb00000bbb000000bbb0000bbb000000bbb0000000000
0000000000111000000bbb0000111000000bbb000000000000111000000bbb0000111000000bbb000000000000bbb000000bbb0000bbb000000bbb0000000000
00000000001101111110bb0000110bbbbbb0bb000000000000110bbbbbb0bb0000110bbbbbb0bb000000000000bb0bbbbbb0bb0000bb0bbbbbb0bb0000000000
000000000010111111110b000010bbbbbbbb0b00000000000010bbbbbbbb0b000010bbbbbbbb0b000000000000b0bbbbbbbb0b0000b0bbbbbbbb0b0000000000
000000000001111111111000000bbbbbbbbbb00000000000000bbbbbbbbbb000000bbbbbbbbbb00000000000000bbbbbbbbbb000000bbbbbbbbbb00000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000bbbbbb00bbbbbb00bbbb0000bbbbbb0000000000b0000b000bbbb000bb000b00bbbbbb00bb000b00bbbbb000bbbbbb00bbbbb00000000000bbbbbb00000
0000000000b00bb000b0000bb000000000b0000000000bb000b00bb000b00bb000b00bb000000bbb0bb00bb000b00bb000000bb000b0000000000bb000000000
0000000000b00bb000b0000bb000000000b0000000000bbb00b00bb000b00bb000b00bb000000bb0b0b00bb000b00bb000000bb000b0000000000bb000000000
00000bbbbbb00bb000b0000bb0000bbbbbb0000000000b0bb0b00bb000b00bb000b00bbbbb000bb000b00bbbbb000bbbbb000bbbbb00000000000bbbbbb00000
00000bb000000bb000b0000bb0000bb00000000000000b00bbb00bb000b00bb000b00bb000000bb000b00bb000b00bb000000bb0b000000000000bb000b00000
00000bb000000bb000b0000bb0000bb00000000000000b000bb00bb000b000bb0b000bb000000bb000b00bb000b00bb000000bb00b00000000000bb000b00000
00000bbbbbb00bbbbbb00bbbbbb00bb00000000000000b0000b000bbbb00000bb0000bbbbbb00bb000b00bbbbb000bbbbbb00bb000b0000000000bbbbbb00000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000bb000b000bbbb000b0000b00bbbbb0000bbbb000b0000b00000000000000000000000000000000000000000
00000000000000000000000000000000000000000bbb0bb00bb000b00bb000b00bb000b00bb000b00b0000b00000000000000000000000000000000000000000
00000000000000000000000000000000000000000bb0b0b00bb000b00bbb00b00bb000b00bb000b000b00b000000000000000000000000000000000000000000
00000000000000000000000000000000000000000bb000b00bb000b00b0bb0b00bb000b00bbbbbb0000bb0000000000000000000000000000000000000000000
00000000000000000000000000000000000000000bb000b00bb000b00b00bbb00bb000b00bb000b0000bb0000000000000000000000000000000000000000000
00000000000000000000000000000000000000000bb000b00bb000b00b000bb00bb000b00bb000b0000bb0000000000000000000000000000000000000000000
00000000000000000000000000000000000000000bb000b000bbbb000b0000b00bbbbb000bb000b0000bb0000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000

__sfx__
00010000270402103019030130300e0200b0200901006010030100100001000030000200001000010000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0010000031020000000230001300033001a1001e10022100261002c1002e1002e1002b1002810024100201001b1001710013100101000f1000e10001300013000140001400000000000000000000000000000000