#!/usr/bin/env bash

# Will override all database passwords (optional).
export DATABASE_PW=

# Customize Compose project/container prefix.
export NMCP_COMPOSE_PROJECT=

# Environment variables that used both in the Docker Compose files and various scripts.  Env var that just used in the
# Docker Compose files are in the Compose specific .env file.

# Will be mapped to /var/log/mnb in most service containers for log files.  Could be a host location or a docker volume.
export NMCP_LOG_VOLUME=

# Location is mapped to the backup location in the data services container.  Backup files will appear in sample, swc,
# transform, and search subdirectories within this location.  Note that this is _not_ mapped to the BACKUP_PATH env var
# in the data services container.  It is used to map a local location to the default backup path in the container via a
# volume mapping.
export MNB_LOCAL_BACKUP_LOCATION=

# For remote backups it is not assumed that the host location can be directly mapped to the container backup path.  For
# instance, mounts that can not be accessed by docker containers launched as root.  The host path and the backup path in
# in the container are both set in this case.

# Typically set to the deepest path that can be mapped by docker.
export MNB_REMOTE_BACKUP_LOCATION=

# Overrides the container path where backups are saved.  If MNB_REMOTE_BACKUP_LOCATION can be set to the full backup
# location, this can be left empty and the container default will be used.
export MNB_REMOTE_BACKUP_PATH=

# The following are analogous to remote backup location/path.  If the additional redirection is not required for
# permissions or other reasons, MNB_RESTORE_PATH can be left empty and the default will be used.
export MNB_RESTORE_LOCATION=

export MNB_RESTORE_PATH=

# Additional Details - How Backups Work
#
# Backups in the container are saved to subdirectories within the directory specified by BACKUP_PATH within the
# container.  The default for this location if /opt/data/backup if that is not overridden in container environment
# variables.
#
# For example, mapping the host path /data/mnb to /opt/data in the container would result in backups to
# /data/mnb/backup/swc/, /data/mnb/backup/sample/, etc. on the host.
#
# For "local" backups, it is assumed to be on the host machine and that docker, as root, is able to mount any path on
# the host as read/write.  Therefore only MNB_LOCAL_BACKUP_LOCATION is required and this location is mapped to
# /opt/data in the container and backups will be to subdirectories in ${MNB_LOCAL_BACKUP_LOCATION}/backup/.
#
# For "remote" backups, it is not assumed that the full path of the backup location is usable by root.  For example,
# root may have access to the mount point of a network share at /mnt/foo but not have read/write access to the desired
# backup location on the share of /mnt/foo/projects/bar/backup/.  Therefore, for remote backups both a host path and the
# container backup path may be specified.
#
# In the example above, MNB_REMOTE_BACKUP_PATH would be set to /mnt/foo to allow the volume mapping to the container (it
# will be mapped to /opt/data) and and MNB_REMOTE_BACKUP_PATH (used to override BACKUP_PATH in the container) would be
# set to /opt/data/projects/bar/backup/ (it is assumed that unlike root on the host, the user in the data-services
# container has read/write access to the final location on the mounted share).
