
# uproxyCTRL
A tool to control *uproxy v0.91* by Alessandro Staltari from the command line.  

Thrown together quickly. Use with caution.

## Features
- Get status of uproxy.
- Start, stop and restart uproxy.
- Show listening and used ports.

## Installation
- Get [uproxy](http://way.toxik.info/ctfpug/uproxy.zip).
- Put uproxyCTRL.sh in the same directory as uproxy.
- Make sure everything that needs to be is executable.

## Usage
```
./uproxyCTRL.sh [option]

Options:
├─ help            Display this help.
├─ listenports     Display all ports uproxy is listening on.
├─ restart         Restart uproxy.
├─ start           Start uproxy.
├─ status          Display status of uproxy.
├─ stop            Stop uproxy.
└─ usedports       Display all ports uproxy is using.
```
Supports trailing  -y to answer questions with "yes" automatically.

## Version history
```
v1.1
- Renamed.
- The option "restart" now asks if it should start uproxy if it detects it not to be running,
- The options "stop" and "restart" now support a trailing -y for automation.
- Better and clearer output.
- Cleaning up.

v1.0
- Initial stable.
```

## License
[CC BY-SA 4.0.](http://creativecommons.org/licenses/by-sa/4.0/)
