/*
Emission
*/

// Create the sender
"localhost" => string hostname;
3350 => int port;
OscOut xmit;
xmit.dest(hostname, port);

for (0 => int i; i<100; i++)
{
    for (1 => int j; j <= 20; j++)
    {
    xmit.start("/msg/xxx" + j);
    xmit.add(i);
    xmit.send();
}
    <<< "                Sending", i >>>;
    1::second => now;
}

<<< "*** Emission", "end." >>>;