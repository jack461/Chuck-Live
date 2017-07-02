/*

Send MIDI commands to the Arturia

Ne marche pas vraiment...

*/

MidiOut MOUT;
MidiMsg msg;

"Arturia" => string devName;

<<< "About to open", devName, "output" >>>;

if(!MOUT.open(devName))
{
    <<< "Error: MIDI port did not open on port: ", devName >>>;
    me.exit();
}

<<< devName, "open." >>>;


while (true)
{
    0xF8 => msg.data1;
    139 => msg.data2;
    19 => msg.data3;
    MOUT.send(msg);
    250::ms => now;
}
