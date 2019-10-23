# Notes
Notice board application using a micro-service architectural style
# Instructions

### Install docker
```
sudo apt install docker.io docker-compose 
```

### Running the containers
Working directory: [noter-service/src/noter](noter-service/src/noter)

```
sudo build.sh
```
## API Gateway
Working directory: [graphql](graphql)
```
node app
```

### Extras
```docker ps  ``` to view the instances

```docker-compose down   ``` to stop all instances
# Architecture design overview (abstract)
![architecture](arch.png?raw=true "Architecture design overview (abstract)")
# Some info
Languages used:
* [Ballerina](https://ballerina.io/) -> backend
* Javascript -> Graphql API gateway
* Python -> Ease building of project
* Shell -> Execute commands
