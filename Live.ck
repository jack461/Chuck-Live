/*

Live Set -- Version 1

Jean-Jacques Girardot - May/June 2017

License : WTFPL
http://www.wtfpl.net


*/
<<< "\n\n\n\n\nLive Play", "\n\n\n" >>>;


// Shared Global Structure [class] -- Load First
Machine.add(me.dir() + "Progs/Globals.ck");
second => now;
// Utilities for PAD launched programs [class]
Machine.add(me.dir() + "Progs/Utils.ck");
second => now;
// Receiver test
Machine.add(me.dir() + "Progs/TRACE-OSC-Rec.ck");
second => now;
// Beat Manager : keep programs synchronized [class]
Machine.add(me.dir() + "Progs/BM-MGR.ck");
second => now;
// Sound Manager [class]
Machine.add(me.dir() + "Progs/SOUND-MGR.ck");
second => now;
// Korg MS 20 USB Control surface Manager
Machine.add(me.dir() + "Progs/MS_20_Korg-MGR.ck");
second => now;
// FCB1010 through USB Interface Control surface Manager
Machine.add(me.dir() + "Progs/FCB1010-Mgr.ck");
second => now;
// QuNexus USB Control surface Manager
Machine.add(me.dir() + "Progs/QuNexus-Mgr.ck");
second => now;
// Samson Carbon 49 USB Control surface Manager
// Machine.add(me.dir() + "Progs/Carbon-Mgr.ck");
second => now;
// Korg nanoPAD2 USB Control Surface Manager
Machine.add(me.dir() + "Progs/nPAD2-MGR-01.ck");
second => now;
// Korg nanoKONTROL2 USB Control Surface Manager
Machine.add(me.dir() + "Progs/nK2-MGR-01.ck");
second => now;
// Arturia BeatStep USB Control surface MANAGER
Machine.add(me.dir() + "Progs/Art-BeatStep-MGR.ck");
second => now;
// "Vintage Synthesizer" class
Machine.add(me.dir() + "Progs/VSynth-Inst.ck");
second => now;
// "Ticker Instrument" class
Machine.add(me.dir() + "Progs/Ticker-Inst.ck");
second => now;
// "VSynth Player"
Machine.add(me.dir() + "Progs/VSynth-Player.ck:StudioKonnekt");
second => now;
// "PAD launcher"
Machine.add(me.dir() + "Progs/PAD-Player-01.ck");
second => now;
// "Tick Player"
Machine.add(me.dir() + "Progs/Tick-Player-2.ck");
second => now;
// "Tick Player"
Machine.add(me.dir() + "Progs/Tick-Sequencer-2.ck");
second => now;
// Blip sequencer
Machine.add(me.dir() + "Progs/BLIP-OSC-Rec-01.ck");
second => now;
// The Live Set FX managers
Machine.add(me.dir() + "Progs/FX-Live-MGR.ck");
5::second => now;
Machine.add(me.dir() + "Progs/Conf-Infos.ck");
second => now;


/*

Machine.add(me.dir() + "Progs/StudioKonnekt-MGR-TEST.ck");
second => now;

*/

<<< "\n\nLive:done initializing",  "-- good luck.\n\n" >>>;

while (true) {
    hour => now;
}

