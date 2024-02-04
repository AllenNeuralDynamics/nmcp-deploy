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

These actions require copying .env-template to .env, copying options-template.sh to options.sh and at least setting the following values

* .env: `NMCP_AUTH_CLIENT_ID=72c4d4a0-2130-45e2-ad74-cbeb046e034a`
  * (this is a temporary value during testing)
* .env: `NMCP_SLICE_LOCATION`, `NMCP_ONTOLOGY_LOCATION`, and `NMCP_ONTOLOGY_PATH` must be set
  * can just be set to `/tmp` for deployment testing
  * Otherwise, set to actual host locations for the data on the host machine
* options.sh: `DATABASE_PW` can be set to any value
* options.sh: `NMCP_COMPOSE_PROJECT` can be set to any value as a docker container prefix, e.g., `nmcp`
* options.sh: `NMCP_LOG_VOLUME` can just be set to /tmp for testing deployment, otherwise to any desired permanent log location 

Any other values in the files can be left blank.

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