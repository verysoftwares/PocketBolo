-- title:   PocketBolo
-- author:  verysoftwares
-- desc:    tribute to BoloBall
-- script:  lua

demo=false

t=0

active={}
coll={}

turn=1

scores={}

SP_BALLOON=34
SP_PURSE=68
SP_CONV_LEFT1=64
SP_CONV_LEFT2=98
SP_CONV_RIGHT1=96
SP_CONV_RIGHT2=130

function update()

    cls(12)
    
    handle_mouse()

    game_tick()
          
    draw_bg()
    
    draw_scores()

    draw_map()    
  
    if gameover() then
        view_results()
    end
    
    t=t+1
end

function handle_mouse()
    local mox,moy=get_mouse()   
    mox,moy=snap_to_grid(mox,moy)
    rect(mox,moy,16,16,0)
    select_active(mox,moy)
end

function game_tick()
    if t%16==0 then
        process_active()

        if (turnstart and #active==0) 
        or (ai_select(turn)<0 and not gameover()) then
            end_turn()
        end
    end
end

function draw_bg()
    rect(0,0,240,4,13)
    rect(0,136-4,240,4,13)
    rect(0,4,6*8,136-8,13)
    rect(240-6*8,0,6*8,136,14)
    for i=0,(240-12*8),32 do
        rect(6*8+i,0,16,4,14)
        rect(6*8+16+i,136-4,16,4,14)
    end
end

function draw_scores()
    -- borders
    -- flashing if your turn
        if turn==1 then
            local col=3
            if t%32>=16 then col=1 end
            rectb(0,4,6*8,136-8,col)
            rectb(240-6*8,4,6*8,136-8,6)
        elseif turn==2 then
            local col=6
            if t%32>=16 then col=1 end
            rectb(240-6*8,4,6*8,136-8,col)
            rectb(0,4,6*8,136-8,3)
        end

    -- vertical numbers   
        for j=1,2 do
            local msg=string.format('%.5d',get_score(j))
            local col=3
            if j==2 then col=6 end
            for c=1,#msg do
                print(string.sub(msg,c,c),6*8/2-3+(j-1)*(240-6*8),48+c*6,col)
            end
        end
end

function draw_map()
    for mx=30-12-1,0,-1 do for my=16-1,0,-1 do
        local id=mget(mx,my)
        local sp1,sp2
        if id==SP_CONV_LEFT1 then
            sp1=32; sp2=128
        end
        if id==SP_CONV_RIGHT1 then
            sp1=32; sp2=160
        end
        if id==SP_CONV_LEFT2 then
            sp1=100; sp2=128
        end
        if id==SP_CONV_RIGHT2 then
            sp1=100; sp2=160
        end
        if fget(id,2) then
            spr(sp1,6*8+mx*8,4+my*8,0,1,0,0,2,2)
            clip(6*8+mx*8+1,4+my*8+2,14,12)
            if sp2==128 then
                spr(sp2,6*8+mx*8-t*0.2%16,4+my*8,0,1,0,0,2,2)
                spr(sp2,6*8+mx*8+16-t*0.2%16,4+my*8,0,1,0,0,2,2)
            elseif sp2==160 then
                spr(sp2,6*8+mx*8+t*0.2%16,4+my*8,0,1,0,0,2,2)
                spr(sp2,6*8+mx*8-16+t*0.2%16,4+my*8,0,1,0,0,2,2)
            end
            clip()
        elseif id==SP_PURSE and mx==tilex and my==tiley then
            spr(70,6*8+mx*8,4+my*8,0,1,0,0,2,2)
        elseif id==SP_BALLOON and mx==tilex and my==tiley then
            spr(38,6*8+mx*8,4+my*8,0,1,0,0,2,2)
        elseif not fget(id,3) then
            spr(id,6*8+mx*8,4+my*8,0)
        end

        -- score labels
            if id==SP_BALLOON or id==SP_PURSE then
                if scores[posstr(mx,my)] then 
                    local tw=print(scores[posstr(mx,my)],0,-6,0,false,1,true)
                    for i,v in ipairs({{-1,0},{1,0},{0,-1},{0,1}}) do
                        print(scores[posstr(mx,my)],6*8+mx*8+8-tw/2+v[1],4+my*8+6+v[2],1,false,1,true)
                    end
                    print(scores[posstr(mx,my)],6*8+mx*8+8-tw/2,4+my*8+6,4,false,1,true)
                end
                for i,a in ipairs(active) do
                    if a.x==mx and a.y==my and a.sc>0 then
                        local tw=print(a.sc,0,-6,0,false,1,true)
                        for i,v in ipairs({{-1,0},{1,0},{0,-1},{0,1}}) do
                            print(a.sc,6*8+mx*8+8-tw/2+v[1],4+my*8+6+v[2],1,false,1,true)                 
                        end
                        print(a.sc,6*8+mx*8+8-tw/2,4+my*8+6,4,false,1,true)                 
                    end
                end
            end
    end end
    
    -- explosions for recently destroyed objects
        for k,c in pairs(coll) do
            local cx,cy=strpos(k)
            spr(102,6*8+cx*8,4+cy*8,0,1,0,0,2,2)
            coll[k]=c+1
            if coll[k]>16 then coll[k]=nil end
        end
end

function gameover()
    return #active==0 and ai_select(1)<0 and ai_select(2)<0
end

function view_results()
    sc_t=sc_t or t
    if sc_t==t then
    		trace('----',4)
    		trace(string.format('Orange: %d',get_score(1)),3)
    		trace(string.format('Green: %d',get_score(2)),6)
    end
    
    rect(0,16-2,240,32,9)
    
    local tw
    local msg
    local col
    if get_score(1)>get_score(2) then
        msg='Orange wins!'
        col=3
    end
    if get_score(1)==get_score(2) then
        msg='It\'s a tie!'
        col=4
    end
    if get_score(2)>get_score(1) then
        msg='Green wins!'
        col=6
    end
    draw_logo(msg,3,col)
    
    tw=print('R to reset.',0,-6,0,false,1,false)
    print('R to reset.',240/2-tw/2,136/2-6-3+6*3+4+1-32-10,1,false,1,false)
    print('R to reset.',240/2-tw/2,136/2-6-3+6*3+4-32-10,4,false,1,false)
    if keyp(18) or (demo and t-sc_t>5*60) then 
    reset() 
    end
end

function end_turn()
    turn=turn+1
    if turn>2 then turn=1 end
    turnstart=false
    pers_mox=nil; pers_moy=nil
end

function select_active(mox,moy)
    tilex,tiley=(mox-6*8)/8,(moy-4)/8
    if left and not leftheld and #active==0 then
        if (turn==1 and mget(tilex,tiley)==SP_BALLOON) or (turn==2 and mget(tilex,tiley)==SP_PURSE) then
            turnstart=true
            local found=false
            for i,a in ipairs(active) do
                if a.x==tilex and a.y==tiley then found=true; break end
            end
            if not found then
            table.insert(active,{x=tilex,y=tiley,sc=0})

            -- inherit score from BG to new active
                if scores[posstr(tilex,tiley)] then
                    active[#active].sc=scores[posstr(tilex,tiley)]
                    scores[posstr(tilex,tiley)]=nil
                end
            end
        end
    end
end

function get_mouse()
    leftheld=left
    mox,moy,left=mouse()
    
    if chars[turn][chars[turn].i]=='AI' and not turnstart then 
        pers_mox,pers_moy=ai_select(turn) 
        left=true; leftheld=false 
    end

    if pers_mox and pers_moy then
        return pers_mox,pers_moy
    end
    
    return mox,moy
end

function ai_select(j)
    local avail={}
    for tx=0,18-1,2 do for ty=0,16-1,2 do
        if (j==1 and mget(tx,ty)==SP_BALLOON) or (j==2 and mget(tx,ty)==SP_PURSE) then
            if can_move(tx,ty,j) then
                table.insert(avail,{x=tx,y=ty})
            end
        end
    end end
    if #avail==0 then return -16,-16 end
    local sel=avail[math.random(#avail)]
    return 6*8+sel.x*8,4+sel.y*8
end

function can_move(tx,ty,j)
    local dy
    if j==1 then dy=-2 end
    if j==2 then dy= 2 end
    if ty+dy>=0 and ty+dy<16 and fget(mget(tx,ty+dy),1) then
        return true
    end
    return false
end

function snap_to_grid(mox,moy)
    return mox-mox%16,(moy-4)-(moy-4)%16+4
end

function process_active()
    table.sort(active,function(a,b) 
        if mget(a.x,a.y)==SP_BALLOON then return a.y<b.y end
        if mget(a.x,a.y)==SP_PURSE then return a.y>b.y end
    end)
    for i=#active,1,-1 do
        local a=active[i]
        local id=mget(a.x,a.y)
        if id==SP_BALLOON or id==SP_PURSE then
            local dy
            if id==SP_BALLOON then dy=-2 end
            if id==SP_PURSE   then dy= 2 end
            local id2=mget(a.x,a.y+dy)
            if id2==0 then
                move_vert(i,dy)
            elseif id2==SP_BALLOON or id2==SP_PURSE then
                obj_collide(i,id2,0,dy)
                rem_active(i)
            elseif id2==SP_CONV_LEFT1 or id2==SP_CONV_LEFT2 then
                move_horiz(i,id2,-2,dy)
            elseif id2==SP_CONV_RIGHT1 or id2==SP_CONV_RIGHT2 then
                move_horiz(i,id2, 2,dy)
            end
        end
    end
end

function move_vert(i,dy)
    local a=active[i]
    if a.y+dy<16 and a.y+dy>=0 then
    for sx=0,2-1 do for sy=0,2-1 do
        mset(a.x+sx,a.y+dy+sy,mget(a.x+sx,a.y+sy))
        mset(a.x+sx,a.y+sy,0)
    end end
    a.y=a.y+dy
    a.sc=a.sc+10
    sfx(19,'C-5',16,2)
    else
    rem_active(i)
    end
end

function move_horiz(i,id,dx,dy)
    local a=active[i]
    if dx<0 then 
        if id==SP_CONV_LEFT1 then
            local base=SP_CONV_RIGHT2
            for sx=0,2-1 do for sy=0,2-1 do
                mset(a.x+sx,a.y+dy+sy,base+sx+sy*16)
            end end
            sfx(19,'G-5',16,2)
        elseif id==SP_CONV_LEFT2 then
            for sx=0,2-1 do for sy=0,2-1 do
                mset(a.x+sx,a.y+dy+sy,0)
            end end
            coll[posstr(a.x,a.y+dy)]=0
            sfx(20,'A-5',32,2)
        end
    else
        if id==SP_CONV_RIGHT1 then
            local base=SP_CONV_LEFT2
            for sx=0,2-1 do for sy=0,2-1 do
                mset(a.x+sx,a.y+dy+sy,base+sx+sy*16)
            end end
            sfx(19,'G-5',16,2)
        elseif id==SP_CONV_RIGHT2 then
            for sx=0,2-1 do for sy=0,2-1 do
                mset(a.x+sx,a.y+dy+sy,0)
            end end
            coll[posstr(a.x,a.y+dy)]=0
            sfx(20,'A-5',32,2)
        end
    end
        
    a.sc=a.sc+10
    local id3=mget(a.x+dx,a.y)
    if id3==0 then
        if a.x+dx>=0 and a.x+dx<18 then
            for sx=0,2-1 do for sy=0,2-1 do
                mset(a.x+sx+dx,a.y+sy,mget(a.x+sx,a.y+sy))
                mset(a.x+sx,a.y+sy,0)
            end end
            a.x=a.x+dx
        else
            if (dx<0 and id==SP_CONV_LEFT1) or (dx>0 and id==SP_CONV_RIGHT1) then
                rem_active(i)
            end
        end
    else
        if id3==SP_BALLOON or id3==SP_PURSE then
            obj_collide(i,id3,dx,0)
            if mget(a.x,a.y)==0 or mget(a.x,a.y+dy)~=0 then
                rem_active(i)
            end
        else
            if (dx<0 and id==SP_CONV_LEFT1) or (dx>0 and id==SP_CONV_RIGHT1) then
            rem_active(i)
            end
        end
    end   
end

function obj_collide(i,id,dx,dy)
    local a=active[i]
    if mget(a.x,a.y)~=id then
    for sx=0,2-1 do for sy=0,2-1 do
        mset(a.x+sx,a.y+sy,0)
        mset(a.x+sx+dx,a.y+dy+sy,0)
    end end
    scores[posstr(a.x+dx,a.y+dy)]=nil
    coll[posstr(a.x,a.y)]=0
    coll[posstr(a.x+dx,a.y+dy)]=0
    sfx(20,'A-5',32,2)
    end
end

function rem_active(i)
    local a=active[i]
    if (mget(a.x,a.y)==SP_BALLOON or mget(a.x,a.y)==SP_PURSE) and a.sc>0 then 
        scores[posstr(a.x,a.y)]=a.sc 
    end
    table.remove(active,i)
end

chars={
    {'Human','AI',i=1},
    {'Human','AI',i=2},
}
fade=0
function titlescr()

    cls(12)
    
    leftheld=left
    mox,moy,left=mouse()
    
    select_players()

    start_game()

    draw_bg()

    draw_logo('PocketBolo',2,2)
        
    if fadeout then fade=fade+1
    if fade==60 then TIC=update; music(1) end
    end
end

function select_players()
    rect(6*8+12-fade*3,42+10,120,13,3)
    circ(6*8+12-fade*3,42+10+6,7,3)
    circ(6*8+12-fade*3+120,42+10+6,7,3)
    print('Orange player is...',6*8+12+4-fade*3,42+10-6,3,false,1,true)
    rect(6*8+12+fade*3,42+10+30,120,13,6)
    circ(6*8+12+fade*3,42+10+6+30,7,6)
    circ(6*8+12+fade*3+120,42+10+6+30,7,6)
    print('Green player is...',6*8+12+4+fade*3,42+10-6+30,6,false,1,true)

    for i,c in ipairs(chars) do
        for j,d in ipairs(c) do
            local tw=print(d,6*8+12+8+(j-1)*64+20-4,42+10+6-2+(i-1)*30,12,false,1,true)
            if left and not leftheld and not fadeout and AABB(6*8+12+8+(j-1)*64+20-4-2,42+10+6-2+(i-1)*30-2,tw+2+1,8+1,mox,moy,1,1) then
                c.i=j
                sfx(18,'A-6',20,2)
            end
            if j==c.i then
                rectb(6*8+12+8+(j-1)*64+20-4-2,42+10+6-2+(i-1)*30-2,tw+2+1,8+1,12)
            end
        end
    end
end

function start_game()
    rect(6*8+12+40-fade*3,42+10+30+30,120-40*2,13,13)
    circ(6*8+12+40-fade*3,42+10+6+30+30,7,13)
    circ(6*8+12+120-40-fade*3,42+10+6+30+30,7,13)
    tw=print('Start',0,-6,0)
    print('Start',6*8+12+60-tw/2-fade*3,42+10+6+30+30-2,4)
    if left and not leftheld and not fadeout and AABB(6*8+12+40,42+10+30+30,120-40*2,13,mox,moy,1,1) then
        sfx(16,'A-6',52,2)
        music()
        generate_map()
        fadeout=true
    end
end

function draw_logo(logo,scale,color)
    local tw=print(logo,0,-6*scale,0,false,scale,false)
    print(logo,240/2-tw/2,6*scale+scale,1,false,scale,false)
    print(logo,240/2-tw/2,6*scale,color,false,scale,false)
    rect(240/2-tw/2-2*scale,6*scale-scale,tw+4*scale,scale,color)
    rect(240/2-tw/2-2*scale,6*scale+6*scale,tw+4*scale,scale,1)
end

function get_score(j)
    local out=0 
    local tgt=SP_BALLOON
    if j==2 then tgt=SP_PURSE end
    for i,a in ipairs(active) do
    if mget(a.x,a.y)==tgt then out=out+a.sc end
    end
    for k,s in pairs(scores) do
    if mget(strpos(k))==tgt then out=out+s end
    end
    return out
end

function generate_map()
    for sx=0,18-1,2 do for sy=0,16-1,2 do
        if math.random()<0.4 and mget(sx,sy)==0 then
            local base=96
            if math.random()<0.5 then
            base=64
            end
            mset(sx,sy,base); mset(sx+1,sy,base+1)
            mset(sx,sy+1,base+16); mset(sx+1,sy+1,base+16+1)
        end
    end end
end

-- you give this the numbers 0 and 1, it will return a string '0:1'.
-- table keys use this format consistently. 
    function posstr(x,y)
        return string.format('%d:%d',math.floor(x),math.floor(y))
    end

-- you give this the string '0:1', it will return 0 and 1. 
    function strpos(pos)
        local delim=string.find(pos,':')
        local x=string.sub(pos,1,delim-1)
        local y=string.sub(pos,delim+1)
        --important tonumber calls
        --Lua will handle a string+number addition until it doesn't
        return tonumber(x),tonumber(y)
    end

-- basic AABB collision.
    function AABB(x1,y1,w1,h1, x2,y2,w2,h2)
        return (x1 < x2 + w2 and
                x1 + w1 > x2 and
                y1 < y2 + h2 and
                y1 + h1 > y2)
    end

TIC=titlescr
music(0)
if demo then
  TIC=update
  generate_map()
  music(1)
  chars[1].i=2
end
-- <TILES>
-- 001:eccccccccc888888caaaaaaaca888888cacccccccacc0ccccacc0ccccacc0ccc
-- 002:ccccceee8888cceeaaaa0cee888a0ceeccca0ccc0cca0c0c0cca0c0c0cca0c0c
-- 003:eccccccccc888888caaaaaaaca888888cacccccccacccccccacc0ccccacc0ccc
-- 004:ccccceee8888cceeaaaa0cee888a0ceeccca0cccccca0c0c0cca0c0c0cca0c0c
-- 017:cacccccccaaaaaaacaaacaaacaaaaccccaaaaaaac8888888cc000cccecccccec
-- 018:ccca00ccaaaa0ccecaaa0ceeaaaa0ceeaaaa0cee8888ccee000cceeecccceeee
-- 019:cacccccccaaaaaaacaaacaaacaaaaccccaaaaaaac8888888cc000cccecccccec
-- 020:ccca00ccaaaa0ccecaaa0ceeaaaa0ceeaaaa0cee8888ccee000cceeecccceeee
-- 032:98888888a9999999988888889888888898888888988888889888888898888888
-- 033:888888899999999a888888898888888988888889888888898888888988888889
-- 034:0000043300003333000333330043333300333333003333330033333300433333
-- 035:3340000033330000334340003444300033433400333333003333430033333300
-- 036:dddddddddeeeeeeedeeddddddededddddeddeddddedddedddeddddeddeddddde
-- 037:ddddddddeeeeeeeddddddecdddddedcddddeddcdddedddcddeddddcdedddddcd
-- 038:0000023300003333000333330023333300333333003333330033333300233333
-- 039:3320000033330000334320003444300033433200333333003333430033333300
-- 048:988888889888888898888888988888889888888898888888a999999998888888
-- 049:8888888988888889888888898888888988888889888888899999999a88888889
-- 050:000333330004333300003333000004330000000300000000000deed0000e0dee
-- 051:33333300333334003333300033334000333300004334000000e00000eed00000
-- 052:dedddddededdddeddedddedddeddeddddededddddeeddddddeccccccdddddddd
-- 053:edddddcddeddddcdddedddcddddeddcdddddedcddddddecdcccccccddddddddd
-- 054:000333330002333300003333000002330000000300000000000feef0000e0fee
-- 055:33333300333332003333300033332000333300002332000000e00000eef00000
-- 064:98888888a9999999988888889888888898884488988444889844488894448888
-- 065:888888899999999a888888898888888988844889884448898444888944488889
-- 066:0000056600006666000666660056666600666666006666660066666600566666
-- 067:6650000066660000665650006555600066566500666666006666660066666600
-- 068:0000044400004000000040000000406600004666000066660000666600056666
-- 069:4440000000040000000400006604000066640000665600006666000066665000
-- 070:0000044400004000000040000000406600004666000066660000666600076666
-- 071:4440000000040000000400006604000066640000665600006666000066667000
-- 080:944488889844488898844488988844889888888898888888a999999998888888
-- 081:4448888984448889884448898884488988888889888888899999999a88888889
-- 082:000666660005666600006666000005660000000600000000000deed0000e0dee
-- 083:66666600666665006666600066665000666600005665000000e00000eed00000
-- 084:0000666600566666056666660666666606666666066666660566666600566666
-- 085:6666000066666500666566506655566066656660666666606666665066666500
-- 086:0000666600766666076666660666666606666666066666660766666600766666
-- 087:6666000066666700666566706655566066656660666666606666667066666700
-- 096:98888888a9999999988888889888888898844888988444889888444898888444
-- 097:888888899999999a888888898888888988448889884448898884448988884449
-- 098:2111111132222222211111112111111121114411211444112144411124441111
-- 099:1111111222222223111111121111111211144112114441121444111244411112
-- 100:2111111132222222211111112111111121111111211111112111111121111111
-- 101:1111111222222223111111121111111211111112111111121111111211111112
-- 102:0040004000440044004440440004343300044343004443330443332344433332
-- 103:0000000000004440444434004333400033344000233444002332344422233334
-- 112:988884449888444898844488988448889888888898888888a999999998888888
-- 113:8888444988844489884448898844888988888889888888899999999a88888889
-- 114:2444111121444111211444112111441121111111211111113222222221111111
-- 115:4441111214441112114441121114411211111112111111122222222311111112
-- 116:2111111121111111211111112111111121111111211111113222222221111111
-- 117:1111111211111112111111121111111211111112111111122222222311111112
-- 118:0004432200004323000433330043333304443444000443340000044000000400
-- 119:2223344023223400233234403333334033344444433400004434000004400000
-- 128:0000000000000000000000000000000000004400000444000044400004440000
-- 129:0000000000000000000000000000000000004400000444000044400004440000
-- 130:2111111132222222211111112111111121144111211444112111444121111444
-- 131:1111111222222223111111121111111211441112114441121114441211114442
-- 144:0444000000444000000444000000440000000000000000000000000000000000
-- 145:0444000000444000000444000000440000000000000000000000000000000000
-- 146:2111144421114441211444112114411121111111211111113222222221111111
-- 147:1111444211144412114441121144111211111112111111122222222311111112
-- 160:0000000000000000000000000000000000440000004440000004440000004440
-- 161:0000000000000000000000000000000000440000004440000004440000004440
-- 176:0000444000044400004440000044000000000000000000000000000000000000
-- 177:0000444000044400004440000044000000000000000000000000000000000000
-- </TILES>

-- <MAP>
-- 000:445444544454445444544454445444544454000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
-- 001:455545554555455545554555455545554555000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
-- 014:223222322232223222322232223222322232000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
-- 015:233323332333233323332333233323332333000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
-- </MAP>

-- <WAVES>
-- 000:00000000ffffffff00000000ffffffff
-- 001:0123456789abcdeffedcba9876543210
-- 002:0123456789abcdef0123456789abcdef
-- 003:000ffffff00000000000000000000000
-- </WAVES>

-- <SFX>
-- 000:000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000304000000000
-- 001:0180014001b0017001e001a0010001000100010001000100010001000100010001000100010001000100010001000100010001000100010001000100347000000600
-- 002:015001b001d0010001000100010001000100010001000100010001000100010001000100010001000100010001000100010001000100010001000100343000000300
-- 003:0160017001b001c001000100010001000100010001000100010001000100010001000100010001000100010001000100010001000100010001000100349000000400
-- 004:04001400340054008400a400d400f4000400040004000400040004000400040004000400040004000400040004000400040004000400040004000400404000710000
-- 005:030003000300030003000300030003000300030003000300030003000300030003000300030003000300030003000300030003000300030003000300000000000000
-- 006:000020004000500070008000a000b000d000e000f0000000000000000000000000000000000000000000000000000000000000000000000000000000204000a10000
-- 007:040014001400240034004400640064007400740084008400a400b400c400c400d400e400f400f400f400f400f400f400f400f400f400f400f400f400000000000000
-- 016:036003b0039003d003b003100300030003000300030003000300030003000300030003000300030003000300030003000300030003000300030003005c9000005100
-- 017:03300360035003b0030003100300030003000300030003000300030003000300030003000300030003000300030003000300030003000300030003005c9000005100
-- 018:030003a003000300030003000300030003000300030003000300030003000300030003000300030003000300030003000300030003000300030003005c9000000200
-- 019:01300160018001b001700140017001c00160015001000100010001000100010001000100010001000100010001000100010001000100010001000100407000000a00
-- 020:041004300450048004a004d004f004000400040004000400040004000400040004000400040004000400040004000400040004000400040004000400409000000700
-- </SFX>

-- <PATTERNS>
-- 000:800016000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000b00016000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
-- 001:800026000000000000000000000000000000000000000000000000000000000000000000000000000000700026000000000000000000000000000000000000000000000000000000000000000000000000000000f00036000000000000000000000000000000000000000000000000000000000000000000000000000000400018000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
-- 002:800016000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000b00016000000000000000000000000000000000000000000000000000000000000000000000000000000f00016000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
-- 003:d0c25800000000000000000060005a000000000000000000e00058000000000000100000e0005800000090005800000070005a000000000000000000b0005a000000000000000000c0005a000000000000100000c0005a000000e0005a00000040005c000000000000000000c0005a00000000000000000070005c00000000000000000090005c00000000000000000040005c000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
-- 004:90005a70005a60005a010300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
-- 005:b0004c000000b0004a000000b0004a000000000000b0004ab0004c000000b0004a000000b0004a000000000000b0004ab0004ab0004ab0004a000000b0004a000000b0004c000000b0007c000000000000000000b0004a000000b0004a000000b0004c000000b0004a000000b0004a000000000000b0004ab0004c000000b0004a000000b0004a000000000000b0004ab0004ab0004ab0004a000000b0004a000000b0004c000000b0007c000000b0004ab0004ab0004cb0004cb0004a000000
-- 006:50c25c00000000000000000000000010000050005c00000000000000000040005c000000e0005a00000000000000000040005c00000090005a00000000000000000000000000000000000010000090005a000000b0005a000000c0005a00000070005a000000000000000000c0005a000000000000000000b0005a000000000000000000c0005a000000000000100000c0005a000000000000000000000000000000000000000000000000000000000000000000000000000000000000010300
-- 007:e0c258000000c00058000000b00058000000900058000000e00058000000c00058000000b00058000000900058000000700058000000b00058000000700058000000e00058000000700058000000000000100000e0005800000070005a00000070c25a00000050005a00000040005a000000e0005800000070005a00000050005a00000040005a000000e00058000000e0005800000040005a00000090005a00000050005a000000e00058000000900058000000b0005800000050005a000000
-- 008:e0c258000000c00058000000b00058000000900058000000e00058000000c00058000000b00058000000900058000000700058000000b00058000000700058000000e00058000000700058000000000000100000e0005800000070005a00000070c25a00000050005a00000040005a000000e0005800000070005a00000090005a000000b0005a00000090005a00000040005a00000060005a00000070005a00000060005a00000070005a000000000000000000000000000000000000100000
-- 009:700066000000e00064000000e00064000000e00064000000700066000000e00064000000e00064000000e00064000000b00064000000b00064000000e00064000000e00064000000700064000000000000000000700064000000700066000000400066000000400066000000400066000000500066000000700066000000700066000000700066000000900066000000b00066000000b00066000000c00066000000c00066000000e00066000000900066000000900066000000900066000000
-- 010:400066000000900064000000900064000000900064000000700066000000e00064000000e00064000000e00064000000500066000000700066000000900066000000b00066000000e00066000000c00066000000b00066000000900066000000400066000000400066000000400066000000400066000000700066000000700066000000700066000000900066000000900066000000700066000000400066000000e00064000000900064000000900064000000900066000000400066000000
-- 011:b0004c000000b0004a000000b0004a000000000000b0004ab0004c000000b0004a000000b0004a000000000000b0004ab0004ab0004ab0004a000000b0007c000000000000000000b0007c000000000000000000b0004a000000b0004a000000b0004c000000b0004a000000b0004a000000000000b0004ab0004c000000b0004a000000b0004a000000000000b0004ab0004ab0004ab0004a000000b0004c000000b0004ab0004ab0004c000000b0004ab0004ab0007c000000000000000000
-- </PATTERNS>

-- <TRACKS>
-- 000:100000300000200000000000000000000000000000000000000000000000000000000000000000000000000000000000808000
-- 001:5000008820819820034c20817c2003000000000000000000000000000000000000000000000000000000000000000000000000
-- </TRACKS>

-- <FLAGS>
-- 000:20000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000608000000000000000000000000000008080000000000000000000000000000060806080000000000000000000000000808080800000000000000000000000000000608000000000000000000000000000008080000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
-- </FLAGS>

-- <SCREEN>
-- 000:ddddddddddddddddddddddddddddddddddddddddddddddddeeeeeeeeeeeeeeeeddddddddddddddddeeeeeeeeeeeeeeeeddddddddddddddddeeeeeeeeeeeeeeeeddddddddddddddddeeeeeeeeeeeeeeeeddddddddddddddddeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
-- 001:ddddddddddddddddddddddddddddddddddddddddddddddddeeeeeeeeeeeeeeeeddddddddddddddddeeeeeeeeeeeeeeeeddddddddddddddddeeeeeeeeeeeeeeeeddddddddddddddddeeeeeeeeeeeeeeeeddddddddddddddddeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
-- 002:ddddddddddddddddddddddddddddddddddddddddddddddddeeeeeeeeeeeeeeeeddddddddddddddddeeeeeeeeeeeeeeeeddddddddddddddddeeeeeeeeeeeeeeeeddddddddddddddddeeeeeeeeeeeeeeeeddddddddddddddddeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
-- 003:ddddddddddddddddddddddddddddddddddddddddddddddddeeeeeeeeeeeeeeeeddddddddddddddddeeeeeeeeeeeeeeeeddddddddddddddddeeeeeeeeeeeeeeeeddddddddddddddddeeeeeeeeeeeeeeeeddddddddddddddddeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
-- 004:333333333333333333333333333333333333333333333333ccccc444444cccccccccc444444cccccccccc433334cccccccccc444444ccccccccccccccccccccccccccccccccccccc0000044444400000ccccc444444cccccccccc444444ccccc666666666666666666666666666666666666666666666666
-- 005:3dddddddddddddddddddddddddddddddddddddddddddddd3cccc4cccccc4cccccccc4cccccc4cccccccc33333333cccccccc4cccccc4cccccccccccccccccccccccccccccccccccc0000400000040000cccc4cccccc4cccccccc4cccccc4cccc6eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee6
-- 006:3dddddddddddddddddddddddddddddddddddddddddddddd3cccc4cccccc4cccccccc4cccccc4ccccccc3333333434ccccccc4cccccc4cccccccccccccccccccccccccccccccccccc0000400000040000cccc4cccccc4cccccccc4cccccc4cccc6eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee6
-- 007:3dddddddddddddddddddddddddddddddddddddddddddddd3cccc4c6666c4cccccccc4c6666c4cccccc43333334443ccccccc4c6666c4cccccccccccccccccccccccccccccccccccc0000406666040000cccc4c6666c4cccccccc4c6666c4cccc6eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee6
-- 008:3dddddddddddddddddddddddddddddddddddddddddddddd3cccc46666664cccccccc46666664cccccc333333334334cccccc46666664cccccccccccccccccccccccccccccccccccc0000466666640000cccc46666664cccccccc46666664cccc6eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee6
-- 009:3dddddddddddddddddddddddddddddddddddddddddddddd3cccc66666656cccccccc66666656cccccc313311333113cccccc66666656cccccccccccccccccccccccccccccccccccc0000666666560000cccc66666656cccccccc61666116cccc6eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee6
-- 010:3dddddddddddddddddddddddddddddddddddddddddddddd3cccc66666666cccccccc66666666cccccc141144131441cccccc66666666cccccccccccccccccccccccccccccccccccc0000666666660000cccc66666666cccccccc14161441cccc6eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee6
-- 011:3dddddddddddddddddddddddddddddddddddddddddddddd3ccc5666666665cccccc5666666665cccc1441311414141ccccc5666666665ccccccccccccccccccccccccccccccccccc0007666666667000ccc5666666665cccccc1441141415ccc6eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee6
-- 012:3dddddddddddddddddddddddddddddddddddddddddddddd3cccc66666666cccccccc66666666cccccc141314114141cccccc66666666cccccccccccccccccccccccccccccccccccc0000666666660000cccc66666666cccccccc14114141cccc6eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee6
-- 013:3dddddddddddddddddddddddddddddddddddddddddddddd3cc566666666665cccc566666666665cccc141141114141cccc566666666665cccccccccccccccccccccccccccccccccc0076666666666700cc566666666665cccc561411414165cc6eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee6
-- 014:3dddddddddddddddddddddddddddddddddddddddddddddd3c56666666665665cc56666666665665cc144414441441cccc56666666665665ccccccccccccccccccccccccccccccccc0766666666656670c56666666665665cc56144414415665c6eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee6
-- 015:3dddddddddddddddddddddddddddddddddddddddddddddd3c66666666655566cc66666666655566ccc11141113114cccc66666666655566ccccccccccccccccccccccccccccccccc0666666666555660c66666666655566cc66611161155566c6eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee6
-- 016:3dddddddddddddddddddddddddddddddddddddddddddddd3c66666666665666cc66666666665666cccccccc33333ccccc66666666665666ccccccccccccccccccccccccccccccccc0666666666656660c66666666665666cc66666666665666c6eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee6
-- 017:3dddddddddddddddddddddddddddddddddddddddddddddd3c66666666666666cc66666666666666ccccccccc4334ccccc66666666666666ccccccccccccccccccccccccccccccccc0666666666666660c66666666666666cc66666666666666c6eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee6
-- 018:3dddddddddddddddddddddddddddddddddddddddddddddd3c56666666666665cc56666666666665ccccdeedcccecccccc56666666666665ccccccccccccccccccccccccccccccccc0766666666666670c56666666666665cc56666666666665c6eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee6
-- 019:3dddddddddddddddddddddddddddddddddddddddddddddd3cc566666666665cccc566666666665cccccecdeeeedccccccc566666666665cccccccccccccccccccccccccccccccccc0076666666666700cc566666666665cccc566666666665cc6eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee6
-- 020:3dddddddddddddddddddddddddddddddddddddddddddddd398888888888888892111111111111112ccccccccccccccccccccccccccccccccccccccccccccccccccccc444444ccccc9888888888888889988888888888888921111111111111126eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee6
-- 021:3dddddddddddddddddddddddddddddddddddddddddddddd3a99999999999999a3222222222222223cccccccccccccccccccccccccccccccccccccccccccccccccccc4cccccc4cccca99999999999999aa99999999999999a32222222222222236eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee6
-- 022:3dddddddddddddddddddddddddddddddddddddddddddddd398888888888888892111111111111112cccccccccccccccccccccccccccccccccccccccccccccccccccc4cccccc4cccc9888888888888889988888888888888921111111111111126eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee6
-- 023:3dddddddddddddddddddddddddddddddddddddddddddddd398888888888888892111111111111112cccccccccccccccccccccccccccccccccccccccccccccccccccc4c6666c4cccc9888888888888889988888888888888921111111111111126eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee6
-- 024:3dddddddddddddddddddddddddddddddddddddddddddddd398884488888844892441111114411112cccccccccccccccccccccccccccccccccccccccccccccccccccc46666664cccc9888448888884489988844888888448921114411111144126eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee6
-- 025:3dddddddddddddddddddddddddddddddddddddddddddddd398884448888844492441111144411112cccccccccccccccccccccccccccccccccccccccccccccccccccc11666116cccc9888444888884449988844488888444921114441111144426eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee6
-- 026:3dddddddddddddddddddddddddddddddddddddddddddddd398888444888884492411111444111112ccccccccccccccccccccccccccccccccccccccccccccccccccc144161441cccc9888844488888449988884448888844921111444111114426eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee6
-- 027:3dddddddddddddddddddddddddddddddddddddddddddddd398888844488888492111114441111142ccccccccccccccccccccccccccccccccccccccccccccccccccc5114141415ccc9888884448888849988888444888884921111144411111426eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee6
-- 028:3dddddddddddddddddddddddddddddddddddddddddddddd398888844488888492111114441111142cccccccccccccccccccccccccccccccccccccccccccccccccccc14114141cccc9888884448888849988888444888884921111144411111426eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee6
-- 029:3dddddddddddddddddddddddddddddddddddddddddddddd398888444888884492411111444111112cccccccccccccccccccccccccccccccccccccccccccccccccc514111414165cc9888844488888449988884448888844921111444111114426eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee6
-- 030:3dddddddddddddddddddddddddddddddddddddddddddddd398884448888844492441111144411112ccccccccccccccccccccccccccccccccccccccccccccccccc56144414415665c9888444888884449988844488888444921114441111144426eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee6
-- 031:3dddddddddddddddddddddddddddddddddddddddddddddd398884488888844892441111114411112ccccccccccccccccccccccccccccccccccccccccccccccccc66611161155566c9888448888884489988844888888448921114411111144126eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee6
-- 032:3dddddddddddddddddddddddddddddddddddddddddddddd398888888888888892111111111111112ccccccccccccccccccccccccccccccccccccccccccccccccc66666666665666c9888888888888889988888888888888921111111111111126eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee6
-- 033:3dddddddddddddddddddddddddddddddddddddddddddddd398888888888888892111111111111112ccccccccccccccccccccccccccccccccccccccccccccccccc66666666666666c9888888888888889988888888888888921111111111111126eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee6
-- 034:3dddddddddddddddddddddddddddddddddddddddddddddd3a99999999999999a3222222222222223ccccccccccccccccccccccccccccccccccccccccccccccccc56666666666665ca99999999999999aa99999999999999a32222222222222236eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee6
-- 035:3dddddddddddddddddddddddddddddddddddddddddddddd398888888888888892111111111111112cccccccccccccccccccccccccccccccccccccccccccccccccc566666666665cc9888888888888889988888888888888921111111111111126eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee6
-- 036:3dddddddddddddddddddddddddddddddddddddddddddddd32111111111111112cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc2111111111111112cccccccccccccccccccccccccccccccccccccccccccccccc6eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee6
-- 037:3dddddddddddddddddddddddddddddddddddddddddddddd33222222222222223cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc3222222222222223cccccccccccccccccccccccccccccccccccccccccccccccc6eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee6
-- 038:3dddddddddddddddddddddddddddddddddddddddddddddd32111111111111112cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc2111111111111112cccccccccccccccccccccccccccccccccccccccccccccccc6eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee6
-- 039:3dddddddddddddddddddddddddddddddddddddddddddddd32111111111111112cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc2111111111111112cccccccccccccccccccccccccccccccccccccccccccccccc6eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee6
-- 040:3dddddddddddddddddddddddddddddddddddddddddddddd32441111114411112cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc2441111114411112cccccccccccccccccccccccccccccccccccccccccccccccc6eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee6
-- 041:3dddddddddddddddddddddddddddddddddddddddddddddd32441111144411112cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc2441111144411112cccccccccccccccccccccccccccccccccccccccccccccccc6eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee6
-- 042:3dddddddddddddddddddddddddddddddddddddddddddddd32411111444111112cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc2411111444111112cccccccccccccccccccccccccccccccccccccccccccccccc6eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee6
-- 043:3dddddddddddddddddddddddddddddddddddddddddddddd32111114441111142cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc2111114441111142cccccccccccccccccccccccccccccccccccccccccccccccc6eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee6
-- 044:3dddddddddddddddddddddddddddddddddddddddddddddd32111114441111142cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc2111114441111142cccccccccccccccccccccccccccccccccccccccccccccccc6eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee6
-- 045:3dddddddddddddddddddddddddddddddddddddddddddddd32411111444111112cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc2411111444111112cccccccccccccccccccccccccccccccccccccccccccccccc6eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee6
-- 046:3dddddddddddddddddddddddddddddddddddddddddddddd32441111144411112cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc2441111144411112cccccccccccccccccccccccccccccccccccccccccccccccc6eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee6
-- 047:3dddddddddddddddddddddddddddddddddddddddddddddd32441111114411112cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc2441111114411112cccccccccccccccccccccccccccccccccccccccccccccccc6eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee6
-- 048:3dddddddddddddddddddddddddddddddddddddddddddddd32111111111111112cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc2111111111111112cccccccccccccccccccccccccccccccccccccccccccccccc6eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee6
-- 049:3dddddddddddddddddddddddddddddddddddddddddddddd32111111111111112cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc2111111111111112cccccccccccccccccccccccccccccccccccccccccccccccc6eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee6
-- 050:3dddddddddddddddddddddddddddddddddddddddddddddd33222222222222223cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc3222222222222223cccccccccccccccccccccccccccccccccccccccccccccccc6eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee6
-- 051:3dddddddddddddddddddddddddddddddddddddddddddddd32111111111111112cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc2111111111111112cccccccccccccccccccccccccccccccccccccccccccccccc6eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee6
-- 052:3dddddddddddddddddddddddddddddddddddddddddddddd3cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc21111111111111122111111111111112211111111111111298888888888888896eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee6
-- 053:3dddddddddddddddddddddddddddddddddddddddddddddd3cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc322222222222222332222222222222233222222222222223a99999999999999a6eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee6
-- 054:3ddddddddddddddddddddd333dddddddddddddddddddddd3cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc21111111111111122111111111111112211111111111111298888888888888896eeeeeeeeeeeeeeeeeeeee666eeeeeeeeeeeeeeeeeeeeee6
-- 055:3dddddddddddddddddddd33d33ddddddddddddddddddddd3cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc21111111111111122111111111111112211111111111111298888888888888896eeeeeeeeeeeeeeeeeeee66e66eeeeeeeeeeeeeeeeeeeee6
-- 056:3dddddddddddddddddddd333d3ddddddddddddddddddddd3cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc21114411111144122111441111114412211144111111441298884488888844896eeeeeeeeeeeeeeeeeeee666e6eeeeeeeeeeeeeeeeeeeee6
-- 057:3dddddddddddddddddddd33dd3ddddddddddddddddddddd3cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc21114441111144422111444111114442211144411111444298884448888844496eeeeeeeeeeeeeeeeeeee66ee6eeeeeeeeeeeeeeeeeeeee6
-- 058:3ddddddddddddddddddddd333dddddddddddddddddddddd3cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc21111444111114422111144411111442211114441111144298888444888884496eeeeeeeeeeeeeeeeeeeee666eeeeeeeeeeeeeeeeeeeeee6
-- 059:3dddddddddddddddddddddddddddddddddddddddddddddd3cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc21111144411111422111114441111142211111444111114298888844488888496eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee6
-- 060:3ddddddddddddddddddddd333dddddddddddddddddddddd3cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc21111144411111422111114441111142211111444111114298888844488888496eeeeeeeeeeeeeeeeeeeee666eeeeeeeeeeeeeeeeeeeeee6
-- 061:3dddddddddddddddddddd33d33ddddddddddddddddddddd3cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc21111444111114422111144411111442211114441111144298888444888884496eeeeeeeeeeeeeeeeeeee66e66eeeeeeeeeeeeeeeeeeeee6
-- 062:3dddddddddddddddddddd333d3ddddddddddddddddddddd3cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc21114441111144422111444111114442211144411111444298884448888844496eeeeeeeeeeeeeeeeeeee666e6eeeeeeeeeeeeeeeeeeeee6
-- 063:3dddddddddddddddddddd33dd3ddddddddddddddddddddd3cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc21114411111144122111441111114412211144111111441298884488888844896eeeeeeeeeeeeeeeeeeee66ee6eeeeeeeeeeeeeeeeeeeee6
-- 064:3ddddddddddddddddddddd333dddddddddddddddddddddd3cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc21111111111111122111111111111112211111111111111298888888888888896eeeeeeeeeeeeeeeeeeeee666eeeeeeeeeeeeeeeeeeeeee6
-- 065:3dddddddddddddddddddddddddddddddddddddddddddddd3cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc21111111111111122111111111111112211111111111111298888888888888896eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee6
-- 066:3ddddddddddddddddddddd33ddddddddddddddddddddddd3cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc322222222222222332222222222222233222222222222223a99999999999999a6eeeeeeeeeeeeeeeeeeeee666eeeeeeeeeeeeeeeeeeeeee6
-- 067:3dddddddddddddddddddd333ddddddddddddddddddddddd3cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc21111111111111122111111111111112211111111111111298888888888888896eeeeeeeeeeeeeeeeeeee66e66eeeeeeeeeeeeeeeeeeeee6
-- 068:3ddddddddddddddddddddd33ddddddddddddddddddddddd3cccccccccccccccc9888888888888889cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc6eeeeeeeeeeeeeeeeeeee666e6eeeeeeeeeeeeeeeeeeeee6
-- 069:3ddddddddddddddddddddd33ddddddddddddddddddddddd3cccccccccccccccca99999999999999acccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc6eeeeeeeeeeeeeeeeeeee66ee6eeeeeeeeeeeeeeeeeeeee6
-- 070:3dddddddddddddddddddd3333dddddddddddddddddddddd3cccccccccccccccc9888888888888889cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc6eeeeeeeeeeeeeeeeeeeee666eeeeeeeeeeeeeeeeeeeeee6
-- 071:3dddddddddddddddddddddddddddddddddddddddddddddd3cccccccccccccccc9888888888888889cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc6eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee6
-- 072:3dddddddddddddddddddd3333dddddddddddddddddddddd3cccccccccccccccc9448888884488889cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc6eeeeeeeeeeeeeeeeeeee66666eeeeeeeeeeeeeeeeeeeee6
-- 073:3ddddddddddddddddddddddd33ddddddddddddddddddddd3cccccccccccccccc9448888844488889cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc6eeeeeeeeeeeeeeeeeeeeeee66eeeeeeeeeeeeeeeeeeeee6
-- 074:3ddddddddddddddddddddd333dddddddddddddddddddddd3cccccccccccccccc9488888444888889cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc6eeeeeeeeeeeeeeeeeeeeee66eeeeeeeeeeeeeeeeeeeeee6
-- 075:3dddddddddddddddddddd33dddddddddddddddddddddddd3cccccccccccccccc9888884448888849cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc6eeeeeeeeeeeeeeeeeeee6ee66eeeeeeeeeeeeeeeeeeeee6
-- 076:3dddddddddddddddddddd33333ddddddddddddddddddddd3cccccccccccccccc9888884448888849cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc6eeeeeeeeeeeeeeeeeeeee666eeeeeeeeeeeeeeeeeeeeee6
-- 077:3dddddddddddddddddddddddddddddddddddddddddddddd3cccccccccccccccc9488888444888889cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc6eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee6
-- 078:3ddddddddddddddddddddd333dddddddddddddddddddddd3cccccccccccccccc9448888844488889cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc6eeeeeeeeeeeeeeeeeeeee666eeeeeeeeeeeeeeeeeeeeee6
-- 079:3dddddddddddddddddddd33d33ddddddddddddddddddddd3cccccccccccccccc9448888884488889cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc6eeeeeeeeeeeeeeeeeeee66e66eeeeeeeeeeeeeeeeeeeee6
-- 080:3dddddddddddddddddddd333d3ddddddddddddddddddddd3cccccccccccccccc9888888888888889cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc6eeeeeeeeeeeeeeeeeeee666e6eeeeeeeeeeeeeeeeeeeee6
-- 081:3dddddddddddddddddddd33dd3ddddddddddddddddddddd3cccccccccccccccc9888888888888889cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc6eeeeeeeeeeeeeeeeeeee66ee6eeeeeeeeeeeeeeeeeeeee6
-- 082:3ddddddddddddddddddddd333dddddddddddddddddddddd3cccccccccccccccca99999999999999acccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc6eeeeeeeeeeeeeeeeeeeee666eeeeeeeeeeeeeeeeeeeeee6
-- 083:3dddddddddddddddddddddddddddddddddddddddddddddd3cccccccccccccccc9888888888888889cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc6eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee6
-- 084:3dddddddddddddddddddddddddddddddddddddddddddddd3cccccccccccccccc21111111111111122111111111111112cccccccccccccccccccccccccccccccc9888888888888889cccccccccccccccccccccccccccccccc98888888888888896eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee6
-- 085:3dddddddddddddddddddddddddddddddddddddddddddddd3cccccccccccccccc32222222222222233222222222222223cccccccccccccccccccccccccccccccca99999999999999acccccccccccccccccccccccccccccccca99999999999999a6eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee6
-- 086:3dddddddddddddddddddddddddddddddddddddddddddddd3cccccccccccccccc21111111111111122111111111111112cccccccccccccccccccccccccccccccc9888888888888889cccccccccccccccccccccccccccccccc98888888888888896eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee6
-- 087:3dddddddddddddddddddddddddddddddddddddddddddddd3cccccccccccccccc21111111111111122111111111111112cccccccccccccccccccccccccccccccc9888888888888889cccccccccccccccccccccccccccccccc98888888888888896eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee6
-- 088:3dddddddddddddddddddddddddddddddddddddddddddddd3cccccccccccccccc21114411111144122441111114411112cccccccccccccccccccccccccccccccc9448888884488889cccccccccccccccccccccccccccccccc98884488888844896eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee6
-- 089:3dddddddddddddddddddddddddddddddddddddddddddddd3cccccccccccccccc21114441111144422441111144411112cccccccccccccccccccccccccccccccc9448888844488889cccccccccccccccccccccccccccccccc98884448888844496eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee6
-- 090:3dddddddddddddddddddddddddddddddddddddddddddddd3cccccccccccccccc21111444111114422411111444111112cccccccccccccccccccccccccccccccc9488888444888889cccccccccccccccccccccccccccccccc98888444888884496eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee6
-- 091:3dddddddddddddddddddddddddddddddddddddddddddddd3cccccccccccccccc21111144411111422111114441111142cccccccccccccccccccccccccccccccc9888884448888849cccccccccccccccccccccccccccccccc98888844488888496eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee6
-- 092:3dddddddddddddddddddddddddddddddddddddddddddddd3cccccccccccccccc21111144411111422111114441111142cccccccccccccccccccccccccccccccc9888884448888849cccccccccccccccccccccccccccccccc98888844488888496eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee6
-- 093:3dddddddddddddddddddddddddddddddddddddddddddddd3cccccccccccccccc21111444111114422411111444111112cccccccccccccccccccccccccccccccc9488888444888889cccccccccccccccccccccccccccccccc98888444888884496eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee6
-- 094:3dddddddddddddddddddddddddddddddddddddddddddddd3cccccccccccccccc21114441111144422441111144411112cccccccccccccccccccccccccccccccc9448888844488889cccccccccccccccccccccccccccccccc98884448888844496eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee6
-- 095:3dddddddddddddddddddddddddddddddddddddddddddddd3cccccccccccccccc21114411111144122441111114411112cccccccccccccccccccccccccccccccc9448888884488889cccccccccccccccccccccccccccccccc98884488888844896eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee6
-- 096:3dddddddddddddddddddddddddddddddddddddddddddddd3cccccccccccccccc21111111111111122111111111111112cccccccccccccccccccccccccccccccc9888888888888889cccccccccccccccccccccccccccccccc98888888888888896eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee6
-- 097:3dddddddddddddddddddddddddddddddddddddddddddddd3cccccccccccccccc21111111111111122111111111111112cccccccccccccccccccccccccccccccc9888888888888889cccccccccccccccccccccccccccccccc98888888888888896eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee6
-- 098:3dddddddddddddddddddddddddddddddddddddddddddddd3cccccccccccccccc32222222222222233222222222222223cccccccccccccccccccccccccccccccca99999999999999acccccccccccccccccccccccccccccccca99999999999999a6eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee6
-- 099:3dddddddddddddddddddddddddddddddddddddddddddddd3cccccccccccccccc21111111111111122111111111111112cccccccccccccccccccccccccccccccc9888888888888889cccccccccccccccccccccccccccccccc98888888888888896eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee6
-- 100:3dddddddddddddddddddddddddddddddddddddddddddddd3cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc98888888888888896eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee6
-- 101:3dddddddddddddddddddddddddddddddddddddddddddddd3cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccca99999999999999a6eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee6
-- 102:3dddddddddddddddddddddddddddddddddddddddddddddd3cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc98888888888888896eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee6
-- 103:3dddddddddddddddddddddddddddddddddddddddddddddd3cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc98888888888888896eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee6
-- 104:3dddddddddddddddddddddddddddddddddddddddddddddd3cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc94488888844888896eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee6
-- 105:3dddddddddddddddddddddddddddddddddddddddddddddd3cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc94488888444888896eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee6
-- 106:3dddddddddddddddddddddddddddddddddddddddddddddd3cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc94888884448888896eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee6
-- 107:3dddddddddddddddddddddddddddddddddddddddddddddd3cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc98888844488888496eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee6
-- 108:3dddddddddddddddddddddddddddddddddddddddddddddd3cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc98888844488888496eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee6
-- 109:3dddddddddddddddddddddddddddddddddddddddddddddd3cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc94888884448888896eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee6
-- 110:3dddddddddddddddddddddddddddddddddddddddddddddd3cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc94488888444888896eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee6
-- 111:3dddddddddddddddddddddddddddddddddddddddddddddd3cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc94488888844888896eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee6
-- 112:3dddddddddddddddddddddddddddddddddddddddddddddd3cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc98888888888888896eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee6
-- 113:3dddddddddddddddddddddddddddddddddddddddddddddd3cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc98888888888888896eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee6
-- 114:3dddddddddddddddddddddddddddddddddddddddddddddd3cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccca99999999999999a6eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee6
-- 115:3dddddddddddddddddddddddddddddddddddddddddddddd3cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc98888888888888896eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee6
-- 116:3dddddddddddddddddddddddddddddddddddddddddddddd3ccccc433334cccccccccccccccccccccccccccccccccccccccccc433334cccccccccc433334cccccccccc433334cccccccccc433334cccccccccccccccccccccccccc433334ccccc6eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee6
-- 117:3dddddddddddddddddddddddddddddddddddddddddddddd3cccc33333333cccccccccccccccccccccccccccccccccccccccc33333333cccccccc33333333cccccccc33333333cccccccc33333333cccccccccccccccccccccccc33333333cccc6eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee6
-- 118:3dddddddddddddddddddddddddddddddddddddddddddddd3ccc3333333434cccccccccccccccccccccccccccccccccccccc3333333434cccccc3333333434cccccc3333333434cccccc3333333434cccccccccccccccccccccc3333333434ccc6eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee6
-- 119:3dddddddddddddddddddddddddddddddddddddddddddddd3cc43333334443ccccccccccccccccccccccccccccccccccccc43333334443ccccc43333334443ccccc43333334443ccccc43333334443ccccccccccccccccccccc43333334443ccc6eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee6
-- 120:3dddddddddddddddddddddddddddddddddddddddddddddd3cc333333334334cccccccccccccccccccccccccccccccccccc333333334334cccc333333334334cccc333333334334cccc333333334334cccccccccccccccccccc333333334334cc6eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee6
-- 121:3dddddddddddddddddddddddddddddddddddddddddddddd3cc333333333333cccccccccccccccccccccccccccccccccccc333333333333cccc333333333333cccc333333333333cccc333333333333cccccccccccccccccccc333333333333cc6eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee6
-- 122:3dddddddddddddddddddddddddddddddddddddddddddddd3cc333333333343cccccccccccccccccccccccccccccccccccc333333333343cccc333333333343cccc333333333343cccc333333333343cccccccccccccccccccc333333333343cc6eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee6
-- 123:3dddddddddddddddddddddddddddddddddddddddddddddd3cc433333333333cccccccccccccccccccccccccccccccccccc433333333333cccc433333333333cccc433333333333cccc433333333333cccccccccccccccccccc433333333333cc6eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee6
-- 124:3dddddddddddddddddddddddddddddddddddddddddddddd3ccc33333333333ccccccccccccccccccccccccccccccccccccc33333333333ccccc33333333333ccccc33333333333ccccc33333333333ccccccccccccccccccccc33333333333cc6eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee6
-- 125:3dddddddddddddddddddddddddddddddddddddddddddddd3ccc43333333334ccccccccccccccccccccccccccccccccccccc43333333334ccccc43333333334ccccc43333333334ccccc43333333334ccccccccccccccccccccc43333333334cc6eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee6
-- 126:3dddddddddddddddddddddddddddddddddddddddddddddd3cccc333333333ccccccccccccccccccccccccccccccccccccccc333333333ccccccc333333333ccccccc333333333ccccccc333333333ccccccccccccccccccccccc333333333ccc6eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee6
-- 127:3dddddddddddddddddddddddddddddddddddddddddddddd3ccccc43333334cccccccccccccccccccccccccccccccccccccccc43333334cccccccc43333334cccccccc43333334cccccccc43333334cccccccccccccccccccccccc43333334ccc6eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee6
-- 128:3dddddddddddddddddddddddddddddddddddddddddddddd3ccccccc33333ccccccccccccccccccccccccccccccccccccccccccc33333ccccccccccc33333ccccccccccc33333ccccccccccc33333ccccccccccccccccccccccccccc33333cccc6eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee6
-- 129:3dddddddddddddddddddddddddddddddddddddddddddddd3cccccccc4334cccccccccccccccccccccccccccccccccccccccccccc4334cccccccccccc4334cccccccccccc4334cccccccccccc4334cccccccccccccccccccccccccccc4334cccc6eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee6
-- 130:3dddddddddddddddddddddddddddddddddddddddddddddd3cccdeedccceccccccccccccccccccccccccccccccccccccccccdeedccceccccccccdeedccceccccccccdeedccceccccccccdeedccceccccccccccccccccccccccccdeedccceccccc6eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee6
-- 131:333333333333333333333333333333333333333333333333cccecdeeeedccccccccccccccccccccccccccccccccccccccccecdeeeedccccccccecdeeeedccccccccecdeeeedccccccccecdeeeedccccccccccccccccccccccccecdeeeedccccc666666666666666666666666666666666666666666666666
-- 132:ddddddddddddddddddddddddddddddddddddddddddddddddeeeeeeeeeeeeeeeeddddddddddddddddeeeeeeeeeeeeeeeeddddddddddddddddeeeeeeeeeeeeeeeeddddddddddddddddeeeeeeeeeeeeeeeeddddddddddddddddeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
-- 133:ddddddddddddddddddddddddddddddddddddddddddddddddeeeeeeeeeeeeeeeeddddddddddddddddeeeeeeeeeeeeeeeeddddddddddddddddeeeeeeeeeeeeeeeeddddddddddddddddeeeeeeeeeeeeeeeeddddddddddddddddeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
-- 134:ddddddddddddddddddddddddddddddddddddddddddddddddeeeeeeeeeeeeeeeeddddddddddddddddeeeeeeeeeeeeeeeeddddddddddddddddeeeeeeeeeeeeeeeeddddddddddddddddeeeeeeeeeeeeeeeeddddddddddddddddeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
-- 135:ddddddddddddddddddddddddddddddddddddddddddddddddeeeeeeeeeeeeeeeeddddddddddddddddeeeeeeeeeeeeeeeeddddddddddddddddeeeeeeeeeeeeeeeeddddddddddddddddeeeeeeeeeeeeeeeeddddddddddddddddeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
-- </SCREEN>

-- <PALETTE>
-- 000:1a1c2c5d275db13e53ef7d57ffcd75a7f07038b76425717929366f3b5dc941a6f673eff7f4f4f494b0c2566c86333c57
-- </PALETTE>

