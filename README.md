# Neuron Morphology Community Portal Deployment
The Neuron Morphology Community Portal is a collection of services for managing annotated neuron data.

## Service Repositories
The application services in `docker-compose.services.yml` are built from the following repositories, each published as a
versioned container image under `ghcr.io/allenneuraldynamics`.

* [nmcp-api](https://github.com/AllenNeuralDynamics/nmcp-api) (`api` service) - GraphQL backend for specimen, neuron, and
  reconstruction management and search; owns the PostgreSQL and InfluxDB connections, DOI minting, and access requests
* [nmcp-client](https://github.com/AllenNeuralDynamics/nmcp-client) (`client` service) - the user-facing portal web
  application, including the embedded Neuroglancer viewer
* [nmcp-export](https://github.com/AllenNeuralDynamics/nmcp-export) (`export` service) - exports reconstructions as SWC
  or Parquet, individually or as ZIP archives with citation metadata
* [nmcp-precomputed](https://github.com/AllenNeuralDynamics/nmcp-precomputed) (`precomputed-worker` service, image
  `nmcp-precomputed-worker`) - polls the API and generates Neuroglancer precomputed skeletons for reconstructions
* [nmcp-qc](https://github.com/AllenNeuralDynamics/nmcp-qc) (`quality-api` service) - quality control service for
  reconstruction data

The general, user-facing backend workflow is documented in the
[nmcp-api publish workflow](https://github.com/AllenNeuralDynamics/nmcp-api/blob/main/doc/publish-workflow.md).

## Installation
The current implementation uses [Docker](https://www.docker.com/) with Docker Compose to manage the multiple independent services.  The containers should also
be compatible with [Podman](https://podman.io/) however this is untested.

### Docker
A standard installation of Docker is sufficient.

The databases (PostgreSQL and InfluxDB) use Data Volumes. Starting, stopping, and removing/updating the service containers will not remove database contents.

### Configuration
Copy `.env-template` to `.env` and set the following values:

* `NMCP_DATABASE_PW` - password for the PostgreSQL database (required)
* `NMCP_INFLUX_DB_PASSWORD` - password for the InfluxDB admin user (required)
* `NMCP_INFLUX_DB_TOKEN` - InfluxDB admin token, used to initialize InfluxDB and by `nmcp-api` to write metrics
* `NMCP_COMPOSE_PROJECT` - Docker Compose project/container prefix (default `nmcp`)
* `NMCP_LOG_VOLUME` - host path mapped to `/var/log/nmcp` in service containers (required; can be set to `/tmp` for testing)
* `NMCP_SERVICES_FILE` - compose file for application services (default `docker-compose.services.yml`)
  * `docker-compose.services.staging.yml` is an alternate that always pulls the `leapscientific/*:latest` development
    images rather than the pinned release images
* `NMCP_SERVER_KEY=xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx`
  * a secret key used between services internally, *e.g.,* a random uuid or similar
* `NMCP_ONTOLOGY_LOCATION` and `NMCP_ONTOLOGY_PATH` must be set
  * can be set to `/tmp` for deployment testing
  * otherwise, set to actual host locations for the data on the host machine
* `NMCP_PRECOMPUTED_OUTPUT`
  * a location url supported by the [cloud-volume package](https://github.com/seung-lab/cloud-volume) where
    `precomputed-worker` writes data sets in the Neuroglancer precomputed format and from which `client` loads them
* `NMCP_QC_SKELETON_OUTPUT` - base location for raw reconstruction quality control skeletons (required for raw uploads)
  * a location url supported by the cloud-volume package; each upload's skeleton is written to `<base>/raw-qc/<qc-tag>`
  * written by the precomputed service and read by the quality control service, so both must be able to reach it
  * must not be at or under `NMCP_PRECOMPUTED_OUTPUT`, which the precomputed service refuses
* `NMCP_QC_BLOB_OUTPUT` - host directory for raw upload hand-off files and quality control documents (required)
  * mapped into `nmcp-api` at the same path; files are written under `raw/`
  * must persist across container restarts so pending quality control can resume
* `NMCP_AIND_METADATA_URL` - AIND metadata portal base url, including any prefix, used to link raw upload quality
  control results (required for raw uploads)
* `NMCP_AUTHENTICATION_API_APP_ID` - Entra application ID of the `nmcp-api` app registration, not that of the `nmcp-client` front end
* `NMCP_AUTHENTICATION_TENANT_ID` - Entra directory (tenant) ID the API accepts tokens from
* `NMCP_DOI_URL` - URL of the NMCP website that generated DOI urls will reference, *e.g.,* `https://morphology.allenneuraldynamics.org/`
* `NMCP_DOI_HOST` - host of the DataCite API server (production or test)
* `NMCP_DOI_PREFIX` - DOI prefix (production or test value as appropriate)
* `NMCP_DOI_USER` - DataCite API user credential
* `NMCP_DOI_PASSWORD` - DataCite API password credential
* `NMCP_DOI_HANDLER` - DOI handler base URL, *e.g.,* `https://doi.org` for production or `https://handle.test.datacite.org` for test
* `NMCP_ACCESS_REQUEST_SNS_TOPIC_ARN` - AWS SNS topic `nmcp-api` publishes access request notifications to
* `NMCP_ACCESS_REQUEST_REVIEW_URL` - URL included in access request notifications for reviewing the request
* `NMCP_GOOGLE_ANALYTICS_TAG` - Google Analytics tag for the client (optional)
* `NMCP_EXPERIMENTAL_ENV` - enables experimental features in services (optional; used only by `docker-compose.services.staging.yml`)

## Operation
Most Docker Compose operations are wrapped in shell scripts to ensure the required flags are correct, e.g., test vs.
production.

### Starting or Restarting the Services
```bash
./up.sh
```

### Stopping Services
```bash
./stop.sh
```

### Tearing Down Services (Retains Data)
```bash
./down.sh
```
destroys existing service containers *but does not remove any data volumes.*  Newer container images can then be pulled 
and the services restarted with the *up* script.

### Logs

```bash
./logs.sh
```
will bring up the correct set of Compose logs for this container set (vs. test or any other deployment on the same host).

## Local Development

### Development-Only Services

```bash
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
* Configure a minio-secrets.json file for this instance, as described in the `cloudvolume` and `cloudfiles` documentation
* Pass the MinIO alias as the output location (`-o` argument) when running `nmcp-precomputed`

Additional details on using an alias with `cloudfiles` can be found in the `nmcp-precomputed` README.
