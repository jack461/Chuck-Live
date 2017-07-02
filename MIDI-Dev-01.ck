/*

Test d'une unité MIDI en entrée

*/

MidiIn MIDIDev;

// 
"USB Midi" => string devName;
// "Arturia BeatStep" => string devName;

<<< "About to open", devName, "input" >>>;

if(!MIDIDev.open(devName))
{
    <<< "Error: MIDI port did not open on port: ", devName >>>;
    me.exit();
}

<<< devName, "open." >>>;

MidiMsg msg;

while( true )
{
    MIDIDev => now;
    while(MIDIDev.recv(msg))
    {
        <<< msg.data1, msg.data2, msg.data3 >>>;
    }
}

