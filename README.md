# Neuron Morphology Community Toolbox Deployment
The Neuron Morphology Community Toolbox is a collection of services for managing annotated neuron data.

## Installation
The current implementation uses [Docker](https://www.docker.com/) with Docker Compose to manage the multiple independent services.  The containers should also
be compatible with [Podman](https://podman.io/) however this is untested.

### Docker
A standard installation of Docker is sufficient.

The databases use Data Volumes. Starting, stopping, and removing/updating the service containers will not remove database 
contents.

### Configuration
Most provided scripts require copying `.env-template` to `.env`, copying `options-template.sh` to `options.sh` and setting the following values

#### .env
* `NMCP_AUTH_CLIENT_ID=xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx`
  * where this value is a secret key to be used between services internally, *e.g.,* a random uuid or similar
* `NMCP_SLICE_LOCATION`, `NMCP_ONTOLOGY_LOCATION`, and `NMCP_ONTOLOGY_PATH` must be set
  * can be set to `/tmp` for deployment testing
  * Otherwise, set to actual host locations for the data on the host machine
* `NMCP_PRECOMPUTED_OUTPUT`
  * A location url support by the [cloud-volume package](https://github.com/seung-lab/cloud-volume) for saving data sets generated in the Neuroglancer precomputed format
* `NMCP_SECRETS_VOLUME`
  * Host location of any required secrets files for cloud-volume to be mapped into the necessary containers

#### .options.sh
* `DATABASE_PW` can be set to any value
* `NMCP_COMPOSE_PROJECT` can be set to any value as a docker container prefix, e.g., `nmcp`
* `NMCP_LOG_VOLUME` can be set to /tmp for testing deployment, otherwise to any desired permanent log location on the host
* `NMCP_SERVICES_FILE`
  * An optional reference to an alternate compose file with the required services that the production one (`docker-compose.services.yml`)
  * `docker-compose.services.staging.yml` is one possible alternate value - it is included in this repository and uses images generated from the develop branch rather than main

## Operation
Most Docker Compose operations are wrapped in batch scripts to ensure the required flags are correct, e.g. test vs. 
production.

### Starting or restarting the services
```
./up.sh
```

### Stopping services
```
./stop.sh
```

### Tearing down services (retains data)
```
./down.sh
```
destroys existing service containers *but does not remove any data volumes.*  Newer container images can then be pulled 
and the services restarted with the *up* script.

### Logs

```
./logs.sh
```
will bring up the correct set of Compose logs for this container set (vs. test or any other deployment on the same host).

### Development-only services

```
./dev.sh
```
will start only those services that are not developed as part of the project, *e.g.,* generic database instances.  The rest of 
the services are presumed to be run locally from code, etc.
