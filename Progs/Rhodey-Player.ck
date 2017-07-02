/*

Play a STK instrument






Receive various OSC Commands


Jean-Jacques Girardot - June 2017

License : WTFPL
http://www.wtfpl.net







*/
3 => int UnitSwitch; // This unit switch
8 => int UnitSwitch2; // This unit other switch
// =================

// What we will be reading from
1 => int UnitNumber; // unit number
me.id() => int me_id;
"Rh.Pl:" + me_id => string ModuleIdt;



// create our OSC receiver
OscIn oin;
// create our OSC message
OscMsg msg;
// 
// oin.port(port);
8641 => oin.port;
// create an address in the receiver
"/midi/ctl" + UnitNumber => string ControllerX;
"/midi/keyb" => string KeyBoard;
"/midi/ctl" + 0 => string Controller0;

oin.addAddress(ControllerX + ", iiii");
oin.addAddress(Controller0 + ", iiii");
oin.addAddress(KeyBoard + ", iiii");


// Autoriser un peu de multi timbralite
12 => int Nnotes; 
Rhodey piano[Nnotes];
NRev rev[2]; // 2 reverbs, canaux gauche et droit
int pitches[Nnotes];
0.1 => float defRev;
defRev => rev[0].mix;
defRev => rev[1].mix;
0=>float alpha;
1=>float beta;

for (0 => int i; i<Nnotes; i++)
{
    piano[i] => rev[i%2]; // connexion des generateurs a une des 2 reverbs
    -1 => pitches[i];
}


int kn;

fun void play(int note, int val) {
    -1 => int n; // quel generateur est disponible ?
    for (0 => int i; i<Nnotes && n<0; i++)
    {
        (kn+1) % Nnotes => kn; // select a different generator
        if (pitches[kn] == -1)
        {
            kn => n;
        }
    }
    if (n < 0)
    {
        // on est deja en train de jouer toutes les notes...
        // on en "lache" une au hasard
        Math.random2(0,Nnotes-1) => n;
        1 => piano[n].noteOff;
    }
    note => pitches[n];
    Std.mtof(note) => piano[n].freq;
    alpha + beta* val/127.0 => piano[n].gain;
    1 => piano[n].noteOn;
}

fun void stop(int note) {
    1 => int flag;
    for (0 => int i; i<Nnotes && flag; i++)
    {
        if (pitches[i] == note)
        {
            1 => piano[i].noteOff;
            -1 => pitches[i];
            0 => flag;
        }
    }
}

// Stop all notes
fun void stop() {
    for (0 => int i; i<Nnotes; i++)
    {
        if (pitches[i] >= 0)
        {
            1 => piano[i].noteOff;
            -1 => pitches[i];
        }
    }
}

0 => int doPlay;
0 => int doWork;
0 => int konnected;
// The "armed channels" that accept mini notes
[0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0] @=> int armedChs[];

fun void KonneKtUnit() {
    if (konnected == 0) {
        // we are on ! konnect to the output
        if (GL.tRhP & 2) <<< ModuleIdt, ":", "connecting outputs." >>>;
        for (0 => int i; i<2; i++) {
            rev[i] => SOUND.SKG[i];
            0.4 => rev[i].gain;
            <<< ModuleIdt, ":", "connecting output" , i >>>;
        }
        1 => konnected;
    }
}

fun void DisKonnectIt() {
    if (konnected == 1) {
        // we are off ! diskonnect the output
        stop();
        500::ms => now;
        if (GL.tRhP & 2) <<< ModuleIdt, ":", "disconnecting outputs." >>>;
        for (0 => int i; i<2; i++) {
            0.0 => rev[i].gain;
            rev[i] !=> SOUND.SKG[i];
        }
        0 => konnected; // diskonnected
    }
}

fun void recomputeChs()
{
    // The magical formula for 2 entries...
    (GL.Btn[UnitSwitch] | (GL.Btn[UnitSwitch2] <<1) 
    | (((GL.Btn[UnitSwitch] * GL.Knkt[UnitSwitch]) & 0x3f) << 4)
    | (((GL.Btn[UnitSwitch2] * GL.Knkt[UnitSwitch2]) & 0x3f) << 10)) & 0xffffff  => int z;
    if (z == doWork)
        return;
    z => doWork;
    for (0 => int i; i<16; i++)
        0 => armedChs[i];
    int w, j;
    if ((GL.Btn[UnitSwitch] => w) != 0)
    {
        // There is a plug here. ?
        GL.Knkt[UnitSwitch] => j;
        if ((j >= 0) && (GL.UChans[j] >= 0))
        {
            1 => armedChs[GL.UChans[j]];
        }
    }
    if ((GL.Btn[UnitSwitch2] => w) != 0)
    {
        // There is a plug here. ?
        GL.Knkt[UnitSwitch2] => j;
        if ((j >= 0) && (GL.UChans[j] >= 0))
        {
            1 => armedChs[GL.UChans[j]];
        }
    }
    <<< ModuleIdt, ":", "NOW CONNEKTED [", doWork, "]"
    , armedChs[0], armedChs[1], armedChs[2], armedChs[3]
    , armedChs[4], armedChs[5], armedChs[6], armedChs[7] >>>;
}

int cha, cmd, ctl, val;

// Give info every minute or so
now => time infoDate;


while (true)
{
    // Recompute active channels
    recomputeChs();
    if (doWork && konnected)
    {
        // wait for event to arrive
        oin => now;
        
        // grab the next message from the queue. 
        while (oin.recv(msg) != 0)
        {
            msg.getInt(0) => cha;
            msg.getInt(1) => cmd;
            msg.getInt(2) => ctl;
            msg.getInt(3) => val;
            /// 
            if (GL.tRhP & 1) {
                <<< ModuleIdt, ":", msg.address, cha, cmd, ctl, val >>>;
            }
            if ((msg.address == KeyBoard))
            {
                if (armedChs[cha]) {
                    if (val == 0) 
                    {
                        stop(ctl);
                    }
                    else
                    {
                        if (GL.tRhP & 2) <<< ModuleIdt, ":*** Note:", cha, ctl, val >>>;
                        play(ctl,val);
                    }
                }
                continue;
            }
            if (msg.address == ControllerX)
            {
                if ((ctl == 96)) {
                    val/127.0 => float u;
                    u * u => u => rev[0].gain; u => rev[1].gain;
                    if (GL.tRhP & 4) <<< ModuleIdt, ":Synth volume", u >>>;
                }
                continue;
            }
            if (msg.address == Controller0)
            {
                if (cmd == 3) {
                    if (ctl == 34) {
                        <<< ModuleIdt, ":*** STOP ***" >>>;
                        0 => doPlay;
                    }
                }
            }
        }
    }
    else
    {
        500::ms => now;
        if (doWork) {
            KonneKtUnit();
        } else {
            DisKonnectIt();
        }
    }
    
    if (now >= infoDate) {
        minute + now => infoDate;
        if (konnected) {
            <<< "     **** ", ModuleIdt, me_id, ":          ", "[", UnitSwitch,  
            UnitSwitch2, UnitNumber,
            "]", doWork, konnected >>>;
        } else {
            <<< "     ---- ", ModuleIdt, me_id, ":          ", "[", UnitSwitch, 
            UnitSwitch2, UnitNumber,
            "]", doWork, konnected >>>;
        }
    }
    
}


