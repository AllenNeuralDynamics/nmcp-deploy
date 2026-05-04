# Neuron Morphology Community Portal Deployment
The Neuron Morphology Community Portal is a collection of services for managing annotated neuron data.

## Installation
The current implementation uses [Docker](https://www.docker.com/) with Docker Compose to manage the multiple independent services.  The containers should also
be compatible with [Podman](https://podman.io/) however this is untested.

### Docker
A standard installation of Docker is sufficient.

The databases (PostgreSQL and InfluxDB) use Data Volumes. Starting, stopping, and removing/updating the service containers will not remove database contents.

### Configuration
Copy `.env-template` to `.env` and set the following values:

* `NMCP_DATABASE_PW` - password for the PostgreSQL database
* `NMCP_INFLUX_DB_PASSWORD` - password for the InfluxDB admin user
* `NMCP_COMPOSE_PROJECT` - Docker Compose project/container prefix, *e.g.,* `nmcp`
* `NMCP_LOG_VOLUME` - host path mapped to `/var/log/nmcp` in service containers (can be set to `/tmp` for testing)
* `NMCP_SERVICES_FILE` - compose file for application services (default `docker-compose.services.yml`)
  * `docker-compose.services.staging.yml` is an alternate that uses images from the develop branch rather than main
* `NMCP_AUTH_CLIENT_ID=xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx`
  * a secret key used between services internally, *e.g.,* a random uuid or similar
* `NMCP_ONTOLOGY_LOCATION` and `NMCP_ONTOLOGY_PATH` must be set
  * can be set to `/tmp` for deployment testing
  * otherwise, set to actual host locations for the data on the host machine
* `NMCP_PRECOMPUTED_OUTPUT`
  * a location url supported by the [cloud-volume package](https://github.com/seung-lab/cloud-volume) for saving data sets generated in the Neuroglancer precomputed format
* `NMCP_SECRETS_VOLUME`
  * host location of any required secrets files for cloud-volume to be mapped into the necessary containers
* `NMCP_AUTHENTICATION_CLIENT_ID` - AAD application (client) ID for authentication
* `NMCP_DOI_URL` - URL of the NMCP website that generated DOI urls will reference, *e.g.,* `https://morphology.allenneuraldynamics.org/`
* `NMCP_DOI_HOST` - host of the DataCite API server (production or test)
* `NMCP_DOI_PREFIX` - DOI prefix (production or test value as appropriate)
* `NMCP_DOI_USER` - DataCite API user credential
* `NMCP_DOI_PASSWORD` - DataCite API password credential
* `NMCP_DOI_HANDLER` - DOI handler base URL, *e.g.,* `https://dois.org` for production or `https://handle.test.datacite.org` for test

## Operation
Most Docker Compose operations are wrapped in batch scripts to ensure the required flags are correct, e.g., test vs. 
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

## Local Development

### Development-only services

```
./dev.sh
```
will start only those services that are not developed as part of the project, *e.g.,* generic database instances.  The rest of
the services are presumed to be run locally from code, etc.

#### Precomputed Storage

Precomputed skeletons and other system-generated Neuroglancer data sources that are typically stored in S3 or similar can be
hosted locally via an S3-compatible service, setting `NMCP_PRECOMPUTED_OUTPUT` for `nmcp-client`, and configuring `nmcp-precomputed` 
for this service.

One option is to run a local [MinIO](https://www.min.io/) Docker container as an S3-compatible destination.  By default, the MinIO
container will run on port 9000.

* Create a bucket in MinIO
* Set the expected env var `NMCP_PRECOMPUTED_OUTPUT` to `http://localhost:9000/<your-bucket>/ngv01` when running `nmcp-client`
* In your Python environment for `nmcp-precomputed`, use the `cloudfiles` command line interface to configure the MinIO instance as an alias
* Configure a minio-secrets.json files for this instance, as described in the `cloudvolume` and `cloudfiles` documentation
* Pass the MinIO alias as the output location (`-o` argument) when running `nmcp-precomputed`

Additional details on using an alias with `cloudfiles` can be found in the `nmcp-computed` README.
