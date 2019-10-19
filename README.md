# Notes
Notice board application using a micro-service architectural style
# Setting up
### Setting up docker
```sudo apt install docker.io docker-compose
sudo groupadd docker
sudo usermod -aG docker $USER
newgrp - docker
```

### Build the service
``` ballerina build main.bal ```

Run command 5 times while changing myPort, mylistener and notes{number}
e.g.
```
Run #1
myPort = 9090
mylistener -> 9090
notes0

Run #2
myPort = 9091
mylistener -> 9091
notes1
etc.
```
### Running the containers
Working directory: ```noter-service/src/noter```

```docker-compose up -d```

### Extras
```docker ps  ``` to view the instances

```docker-compose down   ``` to stop all instances