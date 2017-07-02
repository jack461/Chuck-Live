/*

Play the VSynth
This is "unit 2" of my set.

Accept "Unit 2" commands, and some "unit 0"

Accept any keyboard on units
entries 2, 4, 7

Has 4 channels (0 to 3) with separate volume
adjustments.

Receive various OSC Commands


Jean-Jacques Girardot - May/June 2017

License : WTFPL
http://www.wtfpl.net


*/
//3 => GL.tVSP; // debug for now
32 => int fP; // first v synth parameter

2 => int GroupNumber;
// This is the Jack to use on the MS-20 
// to activate the code
2 => int UnitSwitch;
4 => int UnitSwitch2;
7 => int UnitSwitch3;


// Various options
2 => int UnitNumber; // unit number
me.id() => int me_id;
"VSyntPl:" + me_id => string ModuleIdt;


// Declare one instance of our "Vintage Synthesizer"
VSynth synth;


0.0008 => synth.fastness => float newFst;
// Initialize with values large enough
0.01 => synth.volAttack;
0.003 => synth.volDecay;
0.5 => synth.freqLFactor;
64 => synth.freqHFactor;
20 => synth.QFactor;
0 => synth.Ktransp;
0.006 => synth.Gdetune;
0.2 => synth.dgain;
synth.setPars(newFst);


0 => int konnected;

fun void KonneKtUnit() {
    if (konnected == 0) {
        // we are on ! konnect to the output
        if (GL.tTPly & 2) <<< ModuleIdt, ":", "connecting outputs." >>>;
        for (0 => int i; i<2; i++) {
            synth.out() => SOUND.SKG[i];
            synth.out() => SOUND.SKG[i+4];
            <<< ModuleIdt, ":", "connecting output" , i >>>;
        }
        1 => konnected;
    }
}

fun void DisKonnectIt() {
    if (konnected == 1) {
        // we are off ! diskonnect the output
        0.0003 => synth.volDecay;
        synth.stop();
        5000::ms => now;
        if (GL.tTPly & 2) <<< ModuleIdt, ":", "disconnecting outputs." >>>;
        for (0 => int i; i<2; i++) {
            synth.out() !=> SOUND.SKG[i];
            synth.out() !=> SOUND.SKG[i+4];
        }
        0 => konnected; // diskonnected
    }
}

// create our OSC receiver
OscIn oin;
// create our OSC message
OscMsg msg;
// 
// oin.port(port);
8641 => oin.port;
// create an address in the receiver
"/midi/ctl0" => string Controller0;
"/midi/ctl" + UnitNumber => string ControllerX;
oin.addAddress(Controller0 + ", iiii");
oin.addAddress(ControllerX + ", iiii");

"/midi/keyb" => string KeyBoard;
oin.addAddress(KeyBoard + ", iiii");

[63, 63, 63, 63] @=> int sensitivity[]; // global sensitivity for each channel
[2, 2, 2, 2, 1, 1, 1, 1,
0, 0, 0, 0, 1, 1, 1, 1] @=> int kScale[]; // global scale for current channel
[0.5, 1.0, 3.0, 31.0] @=> float detuneLevels[];

float upTune, downTune;
1 => upTune;
1 => downTune;
0 => int SelectedChannel;
1 => int detuneIdx;


0 => int doWork;

int cha, cmd, ctl, val;

// Give info every minute or so
now => time infoDate;

// The "armed channels" that accept mini notes
[0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0] @=> int armedChs[];
[0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0] @=> int prevChs[];

fun void recomputeChs()
{
    // The magical formula for 3 entries...
    (GL.Btn[UnitSwitch] | (GL.Btn[UnitSwitch2] <<1) | (GL.Btn[UnitSwitch3] << 2) 
    | (((GL.Btn[UnitSwitch] * GL.Knkt[UnitSwitch]) & 0x3f) << 4)
    | (((GL.Btn[UnitSwitch2] * GL.Knkt[UnitSwitch2]) & 0x3f) << 10) 
    | (((GL.Btn[UnitSwitch3] * GL.Knkt[UnitSwitch3]) & 0x3f) << 16)) & 0xffffff  => int z;
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
    if ((GL.Btn[UnitSwitch3] => w) != 0)
    {
        // There is a plug here. ?
        GL.Knkt[UnitSwitch3] => j;
        if ((j >= 0) && (GL.UChans[j] >= 0))
        {
            1 => armedChs[GL.UChans[j]];
        }
    }
    <<< ModuleIdt, ":", "NOW CONNEKTED [", doWork, "]"
    , armedChs[0], armedChs[1], armedChs[2], armedChs[3]
    , armedChs[4], armedChs[5], armedChs[6], armedChs[7] >>>;
    // Are we disconnecting some channel ? Is so, send note off
    for (0 => int i; i<16; i++) {
        if (prevChs[i] == 1 && armedChs[i] == 0)  synth.stop(i);
        armedChs[i] => prevChs[i];
    } 
}



GL.Asig | 0x10000 => GL.Asig; // VSynth Player OK

/*
    The main loop
*/


while (true)
{
    GL.tVSP => synth.trace;
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
            /// Le canal est accepté en entrée
            if (GL.tVSP & 1) {
                <<< ModuleIdt, ":Addr:", msg.address, cha, cmd, ctl, val, "/", konnected, doWork >>>;
            }
            // Accept notes from keyboard
            if ((msg.address == KeyBoard))
            {
                if (armedChs[cha]) {
                    // we use channels 0 to 3 
                    cha % 4 => cha;
                    ctl + (kScale[cha] -2) * 12 => ctl; // actual played note
                    if (val == 0) 
                    {
                        synth.stop(cha,ctl);
                    }
                    else
                    {
                        if (GL.tVSP & 2) <<< ModuleIdt, ":*** Note:", cha, ctl, sensitivity[cha] >>>;
                        synth.play(cha,ctl,sensitivity[cha]);
                    }
                }
                continue;
            }
            if (msg.address == Controller0)
            {
                if (cmd == 16) {
                    if ((ctl == 6)) {
                        // vibrato
                        val/127.0 => float u;
                        u * u => u => synth.vibExcur;
                        (u > 0.0) => synth.flagVib;
                        if (GL.tVSP & 4) <<< ModuleIdt, ":vibrato amp", synth.flagVib, u >>>;
                        UT.xVal(fP+8, u);
                    } 
                    if ((ctl == 7)) {
                        // vibrato freq.
                        val/127.0 => float u;
                        u * u / 20.0 + 0.00005 => u => synth.vibEps;
                        u * Math.sgn(synth.vDelta) => synth.vDelta; // keep correct phase
                        if (GL.tVSP & 4) <<< ModuleIdt, ":vibrato freq", u >>>;
                        UT.xVal(fP+9, u*20);
                    } 
                    // Using "global" modulation for Reverb Mix
                    if ((ctl == 8)) {
                        // reverb mix
                        val/127.0 => float u;
                        u * u => u => synth.rev.mix;
                        if (GL.tVSP & 4) <<< ModuleIdt, ":Synth reverb mix", u >>>;
                        UT.xVal(fP+12, u);
                    } 
                    if ((ctl == 9)) {
                        // tremolo
                        val/127.0 => float u;
                        u => synth.tremExcur;
                        if ((u > 0.0)) {
                            1 => synth.flagTrem;
                        }
                        else {
                            0 => synth.flagTrem; 
                        }
                        if (GL.tVSP & 4) {
                            <<< ModuleIdt, ":tremolo amp", synth.flagTrem, u >>>;
                        }
                        UT.xVal(fP+13, u);
                    } 
                    if ((ctl == 10)) {
                        // trem freq.
                        val/127.0 => float u;
                        u * u * u / 10.0 + 0.00002 => u => synth.tremEps;
                        u * Math.sgn(synth.tDelta) => synth.tDelta; // keep correct phase
                        if (GL.tVSP & 4) {
                            <<< ModuleIdt, ":tremolo freq", u >>>;
                        }
                        UT.xVal(fP+14, u*10);
                    } 
                    continue;
                }
                
                if (cmd == 3) {
                    if (ctl == 28) {
                        <<< ModuleIdt, ":",  "*** STOP ***" >>>;
                        0 => doWork;
                    }
                    continue;
                }
                
                if (cmd == 176) {
                    if ((ctl == 124)) {
                        val => kScale[SelectedChannel]; // change scale in current channel
                        if (GL.tVSP & 4) { 
                            <<< ModuleIdt, ":0:Changed scale", SelectedChannel, "to", val >>>;
                        }
                    }
                    if ((ctl == 125)) {
                        val => SelectedChannel; // change current channel
                        if (GL.tVSP & 4) {
                            <<< ModuleIdt, ":0:SelectedChannel", SelectedChannel >>>;
                        }
                    }
                    if ((ctl == 98)) {
                        val/127.0 => float u;
                        u * u * u * 0.05 + 0.0001 => u;
                        if (GL.tVSP & 4) {
                            <<< ModuleIdt, ":0:SModulation", u >>>;
                        }
                        u => synth.Gdetune;
                    }
               } else {
                    // Other type of message
                    if (GL.tVSP & 4) {
                        <<< ModuleIdt, ":got Controller0", cha, cmd, ctl, val >>>;
                    }
                }
                continue;
            }
            if (msg.address == ControllerX)
            {
                if (cmd == 176) {
                    if ((ctl == 96)) {
                        val/127.0 => float u;
                        u * u => u => synth.gGain;
                        u * synth.globTremolo => synth.globg.gain;
                        if (GL.tVSP & 4) {
                            <<< ModuleIdt, ":Synth volume", u >>>;
                        }
                        continue;
                    }
                    if ((ctl == 7)) {
                        // Band Pass voices filter
                        // Upper excusion
                        val/127.0 => float u;
                        u * u * u * 511 + 1.0 => synth.freqHFactor;
                        // Lower excusion
                        1.0/(u * 31 + 1.0) => synth.freqLFactor;
                        if (GL.tVSP & 4) {
                            <<< ModuleIdt, ":Up/down exc.", synth.freqHFactor, synth.freqLFactor >>>;
                        }
                        UT.xVal(fP, u);
                        continue;
                    }    
                    if ((ctl == 6)) {
                        // Up detune
                        val/127.0 => float u;
                        u * u * detuneLevels[detuneIdx] + 1.0 => upTune;
                        upTune / downTune => synth.cmdDetune;
                        if (GL.tVSP & 4) {
                            <<< ModuleIdt, ":globDetune", upTune / downTune >>>;
                        }
                        UT.xVal(fP+5, u);
                        continue;
                    }    
                    if ((ctl == 5)) {
                        // Down detune
                        val/127.0 => float u;
                        u * u * detuneLevels[detuneIdx] + 1.0 => downTune;
                        upTune / downTune => synth.cmdDetune;
                        if (GL.tVSP & 4) {
                            <<< ModuleIdt, ":globDetune", upTune / downTune >>>;
                        }
                        UT.xVal(fP+10, u);
                        continue;
                    }    
                    if ((ctl == 4)) {
                        // Decay time
                        1.0 - val/127.0 => float u;
                        u * u * u * 0.03 + 0.00001 => synth.volDecay;
                        if (GL.tVSP & 4) {
                            <<< ModuleIdt, ":Decay", synth.volDecay >>>;
                        }
                        UT.xVal(fP+11, 1.0-u);
                        continue;
                    }    
                    if ((ctl == 3)) {
                        // Attack time
                        1.0 - val/127.0 => float u;
                        u * u * u * 0.08 + 0.00004 =>  synth.volAttack;
                        if (GL.tVSP & 4) {
                            <<< ModuleIdt, ":Attack", synth.volAttack >>>;
                        }
                        UT.xVal(fP+6, 1.0-u);
                        continue;
                    }    
                    if ((ctl == 22)) {
                        // Modulation speed
                        val/127.0 => float u;
                        u * u * u * 0.04 + 0.0000001 => newFst;
                        if (GL.tVSP & 4) {
                            <<< ModuleIdt, ":Fastn", newFst >>>;
                        }
                        synth.setPars(newFst);
                        UT.xVal(fP+1, u);
                        continue;
                    }    
                    if ((ctl == 20)) {
                        // portamento
                        1.0 - val/127.0 => float u;
                        u * u => u => synth.portemento;
                        if (GL.tVSP & 4) {
                            <<< ModuleIdt, ":Portamento", u >>>;
                        }
                        UT.xVal(fP+3, 1.0-u);
                        continue;
                    }
                    if ((ctl == 14)) {
                        // Filter Q-Factor.
                        val + 1.0 => float u;
                        u => synth.QFactor; // QFactor in [1 128]
                        if (GL.tVSP & 4) {
                            <<< ModuleIdt, ":QFactor", u >>>;
                        }
                        UT.xVal(fP+4, u/128.0);
                        continue;
                    } 
                    if ((ctl == 13)) {
                        // Instrument Keyb2 velocity.
                        32 + (val * 96) / 128 => int u;
                        u => sensitivity[2];
                        if (GL.tVSP & 4) {
                            <<< ModuleIdt, ":Sensitivity", 2, " => ", u >>>;
                        }
                        continue;
                    } 
                    if ((ctl == 12)) {
                        // Instrument Keyb3 velocity.
                        32 + (val * 96) / 128 => int u;
                        u => sensitivity[3];
                        if (GL.tVSP & 4) {
                            <<< ModuleIdt, ":Sensitivity", 3, " => ", u >>>;
                        }
                        continue;
                    } 
                    // Very special "non MIDI" controls - sent by the ms20-USB   
                    if ((ctl == 126)) {
                        /// All notes off
                        if (GL.tVSP & 4) {
                            <<< ModuleIdt, ":all notes off", "" >>>;
                        }
                        synth.stop();
                        continue;
                    }    
                    if ((ctl == 124)) {
                        val => kScale[SelectedChannel]; // change scale in current channel
                        if (GL.tVSP & 4) {
                            <<< ModuleIdt, ":Changed scale", SelectedChannel, "to", val >>>;
                        }
                        UT.xVal(fP+2, val);
                        continue;
                    }
                    if ((ctl == 125)) {
                        val => SelectedChannel; // change current channel
                        continue;
                    }
                    if ((ctl == 123)) {
                        val => detuneIdx; // change detune level
                        if (GL.tVSP & 4) {
                            <<< ModuleIdt, ":detuneIdx", detuneIdx >>>;
                        }
                        UT.xVal(fP+7, val);
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
        if (GL.signalActivity) {
            if (konnected) {
                <<< "     **** ", ModuleIdt, ":          ", "[", UnitSwitch, UnitSwitch2, UnitSwitch3, UnitNumber,
                "]", doWork, konnected >>>;
            } else {
                <<< "     ---- ", ModuleIdt, ":          ", "[", UnitSwitch, UnitSwitch2, UnitSwitch3, UnitNumber,
                "]", doWork, konnected >>>;
            }
        }
    }
    
}


