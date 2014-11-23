# docker-renderd-osm

A basic image for rendering/serving tiles using OpenStreetMap data from an external
PostgreSQL instance.

## Build instructions

Build using

    # docker build -t mguentner/renderd-osm github.com/mguentner/docker-renderd-osm.git

## Running

This container is designed to work together with
[openfirmware/docker-postgres-osm](https://registry.hub.docker.com/u/openfirmware/postgres-osm/).
This document assumes that OpenStreetMap data has already been imported.
If not build/pull [openfirmware/docker-osm2pgsql](https://registry.hub.docker.com/u/openfirmware/osm2pgsql/) and follow the instructions.

First, start the already configured PostgreSQL container:

    # docker start postgres-osm

Now, start the renderd container and link them together:

    # docker run -i -t -p 8080:80 --link postgres-osm:pg  mguentner/renderd-osm:latest

Once the container is up you should be able to see a small map of the
world once you point your browser to [http://127.0.0.1:8080/osm/0/0/0.png](http://127.0.0.1:8080/osm/0/0/0.png)

## Available Styles

 * [openstreetmap-carto](https://github.com/gravitystorm/openstreetmap-carto),
   available at [http://host/osm/0/0/0.png](http://host/osm/0/0/0.png)
 * [osm-bright](https://github.com/mapbox/osm-bright)
   available at [http://host/osmb/0/0/0.png](http://host/osmb/0/0/0.png)

## About

This Dockerfile has been put together using the [Debian Tileserver Install Guide](https://wiki.debian.org/OSM/tileserver/jessie)
