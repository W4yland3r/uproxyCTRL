
# uproxyCTRL

A tool to control uproxy from the command line.\
Thrown together quickly. Use with caution.


## Features

- Get status of uproxy.
- Start, stop and restart uproxy.
- Show listening and used ports.


## Installation

Get uproxy and put uproxyCTRL in the same directory. 
## Usage
```bash
./uproxyctrl.sh [option]

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
## License

[CC BY-SA 4.0.](http://creativecommons.org/licenses/by-sa/4.0/)
