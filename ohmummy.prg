/*
 * ohmummy.prg by MikeDX
 * (c) 2016 DX Games
 */

PROGRAM ohmummy;

GLOBAL

s_music;
s_music_r;

s_move;
playmap=0;
playfield=0;
ohfont;

started = false;
contents[]=0,0,0,0,0,0, // 6 nothings
            5,5,5,5,5,5,5,5,5,5, // 10 treasures
            2, // 1 mummy
            3, // 1 scroll
            4, // 1 key
            1; // 1 awoken guardian

mummy = false;
ckey = false;
cscroll = false;
completed = false;
guardians = 0;
lives = 0;
score = 0;
dead = true;
speed = 3;

string keytext = "<<<";
string mummytext = ">>>>> +";


BEGIN

    //Write your code here, make something amazing!
    set_mode(640480);
    s_music = load_wav("music.ogg",0);
    s_music_r = load_wav("music.ogg",1);
    s_move = load_wav("move.ogg",0);
    load_fpg("ohmummy.fpg");
    ohfont = load_fnt("oh.fnt");
    write(ohfont,312,48,1,"  1983 - GEM SOFTWARE");

    // main loop
    loop
        graph=0;
        // put title screen
        put_screen(file,2);

        // play music
        x = sound(s_music,256,256);
        // create "hardness" map
        if(playmap!=0)
            unload_map(playmap);
        end
        playmap=new_map(640,480,320,240,11);
        // create playfield map
        if(playfield!=0)
            unload_map(playfield);
        end
        playfield=new_map(640,480,320,240,0);

        // wait until sound stops playing
        while(is_playing_sound(x) && !key(_space))
            frame;
        end

        stop_sound(x);
        clear_screen();
        x=320;
        y=240;
        graph = 2;

        demo();

        game();

    end

END

function demo()
BEGIN
    x=320;
    y=240;
    graph = 2;
    // setup hardness map
    map_put(file,playmap,5,320,240);
   // put_screen(file,playmap);

    guardian(72,88);
    guardian(552,88);
    //for(x=0;x<10;x++)
    guardian(72,88);
    guardian(72,88);
//end
    delete_text(all_text);
    write(ohfont,312,48,1,"/ 1983 - GEM SOFTWARE");

    while(!key(_space))
        FRAME;
    END

    signal(type guardian,s_kill);

END

function blocks()
private r,r2;
begin

    for(x=0;x<1000;x++)
        r=rand(0,19);
        r2=rand(0,19);
        y=contents[r];
        contents[r]=contents[r2];
        contents[r2]=y;
    end

    r=0;

    for (x=0;x<5;x++)
        for(y=0;y<4;y++)
            block(120+x*96,128+y*80,300+contents[r]);
            r++;
        end
    end

end


function game()
private i;
begin
    x=320;
    y=240;
    z=50;

    lives = 5;
    guardians = 20;
    score = 0;

    signal(type guardian, s_kill);
    signal(type player, s_kill);
    signal(type block, s_kill);

    delete_text(all_text);
    //write(ohfont,296,48,1,"SCORE:00200 MEN:4 MUMMY + KEY");
    write_int(ohfont,240,48,2,&score);
    write_int(ohfont,336,48,2,&lives);
    write(ohfont,64,48,0,"SCORE:");
    write(ohfont,256,48,0,"MEN:");
    write(ohfont,352,48,0,&mummytext);
    write(ohfont,480,48,0,&keytext);

    // new level
    while(lives>0)
    // kill old stuff
    signal(type spawn_guardian, s_kill);
    cscroll = false;
    ckey = false;
    mummy = false;
    mummytext = ">>>>> +";
    keytext = "<<<";

    completed = false;
    // increase guardians in chamber
    guardians ++;
    // setup display
//    put_screen(file,4);
    unload_map(playfield);
    playfield=new_map(640,480,320,240,0);
    map_put(file,playfield,4,320,240);

    graph = playfield;
    // setup hardness map
    map_put(file,playmap,3,320,240);
    //put_screen(file,playmap);
    while(lives>0 && !completed)
    started = false;
    dead = false;
    player(264,72);

    blocks();

    while(!started)
        frame;
    end

//    guardian(72,88);
//    guardian(552,88);
    for(x=0;x<guardians;x++)

        guardian(552,408);
    end
    guardians = 0;

    x=320;
//    guardian(72,408);


    while(!key(_enter) && !completed && lives>0)
        if(dead)
            signal(type guardian, s_freeze);
            signal(type spawn_guardian, s_freeze);

//   signal(type player, s_freeze);
            lives--;
            frame(4800);
            dead = false;
            signal(type guardian, s_wakeup);
            signal(type spawn_guardian, s_wakeup);

//            signal(type player, s_wakeup);
        end
        frame;
    end
    frame(200);

    signal(type player, s_kill);
    frame;
    if(lives>0)
        // new level
        for(i=0;i<480;i+=16)
            map_block_copy(file,playfield,0,i,11,0,i,640,16);
            frame;
        end

    else
        // game over
    end
    end
//    signal(type guardian, s_kill);
    signal(type block, s_kill);

    end
    signal(type guardian, s_kill);
    signal(type spawn_guardian, s_kill);


end

process block(x,y,tgraph)

private
checking=true;


begin
// put blocks behind player
    z=25;

    graph = 0;//300;
    // don't bother to check if we don't contain treasure
    if(tgraph==300)
        checking = false;
    end

/*
map_put_pixel(file,playfield,x-48,y+10,25);
map_put_pixel(file,playfield,x+48,y+10,25);
map_put_pixel(file,playfield,x,y-40,25);
map_put_pixel(file,playfield,x,y+40,25);
*/
    while(checking)
        if(map_get_pixel(file,playfield,x-48,y+10)==11)
            if(map_get_pixel(file,playfield,x+48,y+10)==11)
                if(map_get_pixel(file,playfield,x,y-40)==11)
                    if(map_get_pixel(file,playfield,x,y+40)==11)
                        checking = false;
                    end
                end
            end
        end
        frame;
    end

    graph = tgraph;

    if(graph == 301)
        // spawn guardian
        graph = 300;
//        map_put(file,playfield,300,x,y);
        spawn_guardian(x,y-8);
        return;
    end

    if(graph == 302)
        mummy = true;
        mummytext = "MUMMY +";
        score+=100;
    end

    if(graph == 304)
        ckey = true;
        keytext = "KEY";
    end

    if(graph == 303)
        cscroll = true;
    end

    if(graph == 305)
        map_put(file,playmap,9,x,y+8);
        score+=10;

    end

    if(graph!=300)
        map_put(file,playfield,graph,x,y);
    end

end




process player(x,y)

private
x1=0;
y1=0;
hm = 0;
valid = false;
dir = 0;
olddir = 0;
ix = 0;
ox=0;
oy=0;
cid=0;
xspeed=0;

BEGIN
    ox=x;
    oy=y;

    graph = 100;
    xspeed = speed;


    while(!key(_down))
        FRAME;
    END

    started = true;

//map_put(file,father.graph,8,x,y);

//y=y+16;

    loop
        xspeed--;
        if(xspeed==0)
            xspeed = speed;

            if(key(_up) && map_get_pixel(file,playmap,x,y-16)!=20)
                y=y-16;

            else
                if(key(_down) && map_get_pixel(file,playmap,x,y+16)!=20)
                    y=y+16;
                else
                    if(key(_left) && map_get_pixel(file,playmap,x-16,y)!=20)
                        x=x-16;
                    else
                        if(key(_right) && map_get_pixel(file,playmap,x+16,y)!=20)
                            //552 392 = exit
                            if(x== 552 && y==392)
                                if(mummy == true && ckey == true)
                                    x=x+16;
                                    completed = true;
                                    frame;
                                end
                            else
                                x=x+16;
                            end
                        end
                    end
                end
            end

            if(x1!=x || y1!=y)
                if(!get_id(type guardian))
                    sound(s_move,256,256);
                end
            end

            x1=x;
            y1=y;

            if(map_get_pixel(file,playmap,x,y) == 54)
                if(fget_dist(ox,oy,x,y)>64)
                    drawdots(x,y,ox,oy);
                end
                ox=x;
                oy=y;
            end

            xspeed = speed;
        end

        cid = collision(type guardian);

        if(cid)
            signal(cid,s_kill);
            if(cscroll)
                cscroll = false;
            else
                dead = true;
                ix = 0;
                while(dead)
                    ix++;
                    if(ix==5)
                        if(graph == 100)
                            graph = 101;
                        else
                            graph = 100;
                        end

                        ix=0;
                    end
                    frame;
                end
                graph = 100;
            end
        end

        frame;

    end

END

function drawdots(sx,sy,ex,ey);

begin

    if(sx>ex)
        x=sx;
        sx=ex;
        ex=x;
    end

    if(sy>ey)
        x=sy;
        sy=ey;
        ey=x;
    end


    while(sx<ex || sy<ey)
        map_put(file,playfield,150,sx,sy);
        if(sx<ex)
            sx+=16;
        end
        if(sy<ey)
            sy+=16;
        end

    end
    // last one
    map_put(file,playfield,150,sx,sy);


end


process guardian(x,y)

private
x1=0;
y1=0;
hm = 0;
valid = false;
dir = 0;
olddir = 0;
ix = 0;
xspeed = 0;

BEGIN

    graph = 200;
    xspeed = speed;

    while(!completed)
        xspeed--;
        if(xspeed==0 || dir==0)

            hm = map_get_pixel(file,playmap,x,y);

            if(hm==54 || dir==0)
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
                            if(map_get_pixel(file,playmap,x-16,y)!=20)
                                x1=-1;
                                y1=0;
                                valid = true;
                            end
                        end

                        case 2: // RIGHT
                            if(map_get_pixel(file,playmap,x+16,y)!=20)
                                x1=1;
                                y1=0;
                                valid = true;
                            end
                        end

                        case 3: // DOWN
                            if(map_get_pixel(file,playmap,x,y+16)!=20)
                                x1=0;
                                y1=1;
                                valid = true;
                            end
                        end

                        case 4: // UP
                            if(map_get_pixel(file,playmap,x,y-16)!=20)
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
            end

//if(collision(type guardian))
//return;
//end

            xspeed = speed;
        end

        frame;

    end
    // additional guardian
    guardians++;

end


process spawn_guardian(x,y)
PRIVATE
steps = 1;
dir=1;
c=0;
d=0;
BEGIN

    graph = 201;
    map_put(file,playfield,10,x,y);

    while(steps<5)
        switch(dir)

            case 0:
                y-=16;
            end

            case 1:
                x+=16;
            end

            case 2:
                y+=16;
            end

            case 3:
                x-=16;
            end

        end

        c++;

        if(c==steps)
            c=0;

            dir++;

            if(dir==4)
                dir=0;
            end

            d++;

            if(d==2)
                steps++;
                d=0;
            end
        end

        if(steps<5)
            map_put(file,playfield,10,x,y);
        else
            graph = 200;
        end

        frame(speed*200);
    end

    guardian(x,y);

END
