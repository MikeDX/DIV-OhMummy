/*
 * ohmummy.prg by MikeDX
 * (c) 2016 DX Games
 */

PROGRAM ohmummy;

GLOBAL

s_music;
s_music_r;

s_move;
gid = 0;
BEGIN

//Write your code here, make something amazing!
set_mode(640480);
s_music = load_wav("music.ogg",0);
s_music_r = load_wav("music.ogg",1);
s_move = load_wav("move.ogg",0);
load_fpg("ohmummy.fpg");
put_screen(file,2);
x = sound(s_music,256,256);
while(is_playing_sound(x))
frame;
end
write_int(0,0,0,0,&gid);

guardian(72,88);
guardian(552,88);
//for(x=0;x<10;x++)
guardian(72,88);
guardian(72,88);
//end

LOOP

FRAME;

END



END

process guardian(x,y)

private
x1=0;
y1=0;
hm = 0;
valid = false;
dir = 0;
olddir = 0;
ix = 0;
BEGIN

graph = 200;

loop

hm = map_get_pixel(file,5,x,y);
if(hm==54)
// we can change direction
valid = false;
ix = 0;
while(valid == false)
    ix++;
    dir = rand(1,4);
    // check for reverse direction
    if(ix<10)
        if((dir == 1 && olddir == 2) || (dir == 2 && olddir == 1))
            dir = rand(3,4);
        end
        if((dir == 3 && olddir == 4) || (dir == 4 && olddir == 3))
            dir = rand(1,2);
        end
    end

    switch(dir)
    case 1: // LEFT
        if(map_get_pixel(file,5,x-16,y)!=20)
            x1=-1;
            y1=0;
            valid = true;
        end

    end
    case 2: // RIGHT
        if(map_get_pixel(file,5,x+16,y)!=20)
            x1=1;
            y1=0;
            valid = true;
        end

    end
    case 3: // DOWN
        if(map_get_pixel(file,5,x,y+16)!=20)
            x1=0;
            y1=1;
            valid = true;
        end

    end
    case 4: // UP
        if(map_get_pixel(file,5,x,y-16)!=20)
            x1=0;
            y1=-1;
            valid = true;
        end

    end
    end    // end switch

end // end while
olddir = dir;
end // end if

//for (ix = 0;ix<16;ix++)

x=x+x1*16;
y=y+y1*16;
//frame(10);
//end
//size = 100;
if(smallbro==0)
    sound(s_move,256,256);
    gid = id;
//    size = 200;
end

if(collision(type guardian))
return;
end


frame;
end

end
