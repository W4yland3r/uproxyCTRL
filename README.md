
# uproxyCTRL
A tool to control *uproxy v0.91* by Alessandro Staltari from the command line.  

Thrown together quickly. Use with caution.

## Features
- Get status of uproxy.
- Start, stop and restart uproxy.
- Show port usage.

## Installation
- Get [uproxy v0.91](http://way.toxik.info/ctfpug/uproxy_v0.91.zip).
- Put uproxyCTRL.sh and uproxyCTRL.conf in the same directory as uproxy.
- Make sure both uproxyCTRL.sh and  uproxy are executable.
- Add your servers to the uproxyCTRL.conf configuration file by following the instructions given there. It’s probably sensible to use ports that are close to and resemble the actual target server’s ports.

## Usage
```
./uproxyCTRL.sh (-)[option] (-y)

Options:
├─ help            Display this help.
├─ ports           Display all ports uproxy is using.
├─ restart         Restart uproxy.
│                  (Use a trailing -y to affirm any questions. Caution advised!)
├─ start           Start uproxy.
├─ status          Display status of uproxy.
└─ stop            Stop uproxy.
                   (Use a trailing -y to affirm any questions. Caution advised!)
```

## Version history
```
v1.2
- [FIXED] Symbols for putty users now showing correctly.
- [ADDED] External configuration file (supports # for comments, empty lines are ignored, empty configuration file triggers error).
- [CHANGED] Made status information permanent and added number of clients to its output.
- [CHANGED] Merged -listenports and -usedports to -ports and displaying additional info.
- [CHANGED] Made -help more complete.
- Cleaned up the code to the best of my abilities.

v1.1
- [ADDED] The option -restart now asks if it should start uproxy if it detects it not to be running.
- [ADDED] The options -stop and -restart now support a trailing -y for automation. Caution advised!
- [CHANGED] Renamed.
- [CHANGED] Better and clearer output.
- Cleaning up.

v1.0
- Initial stable.
```

## License
[CC BY-SA 4.0.](http://creativecommons.org/licenses/by-sa/4.0/)
