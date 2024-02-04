# Neuron Morphology Community Toolbox Internal Deployment
The Neuron Morphology Community Toolbox is a collection of services for managing annotated neuron data.

## Installation
The current implementation uses Docker with Docker Compose to manage the multiple independent services.

### Docker
A standard installation of Docker is sufficient.

The databases use Data Volumes. Starting, stopping, and removing/updating the service containers will not remove database 
contents.

### Operation
Most Docker Compose operations are wrapped in batch scripts to ensure the required flags are correct, e.g. test vs. 
production.

0. Backing up data

If this is not the first launch of the services, and the services are currently running, you can back up all database 
contents from the Data Volumes:
```
./backup.sh
```

Output goes to /opt/data/backup unless unless that mapping has been changed in the compose file.

1. Starting or restarting the services
```
./up.sh
```

2. Stopping services
```
./stop.sh
```

3. Tearing down services (retains data)
```
./down.sh
```
destroys existing service containers *but does not remove any data volumes.*  Newer container images can then be pulled 
and the services restarted with the *up* script.

4. Migration
```
./migrate.sh
```

5. Logs

```
./logs
```
will bring up the correct set of Compose logs for this container set (vs. test or any other deployment on the same host).