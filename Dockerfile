# DOCKER-VERSION 1.3.1
# VERSION 0.1
FROM debian:jessie
MAINTAINER Maximilian Güntner <maximilian.guentner@gmail.com>

ENV OSM_CARTO_VERSION 2.24.0
ENV OSM_BRIGHT_VERSION master
ENV MOD_TILE_VERSION master
ENV PARALLEL_BUILD 4

RUN touch /etc/inittab
RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -y -q autoconf libtool libmapnik-dev apache2-dev curl unzip gdal-bin mapnik-utils node-carto node-millstone apache2 wget runit sudo

RUN cd /tmp && wget https://github.com/gravitystorm/openstreetmap-carto/archive/v$OSM_CARTO_VERSION.tar.gz && tar -xzf v$OSM_CARTO_VERSION.tar.gz
RUN mkdir /usr/share/mapnik && mv /tmp/openstreetmap-carto-$OSM_CARTO_VERSION /usr/share/mapnik/
RUN cd /usr/share/mapnik/openstreetmap-carto-$OSM_CARTO_VERSION/ && ./get-shapefiles.sh && cp project.mml project.mml.orig
# Delete zip files
RUN find /usr/share/mapnik/openstreetmap-carto-$OSM_CARTO_VERSION/data \( -type f -iname "*.zip" -o -iname "*.tgz" \) -delete

RUN cd /tmp && wget https://github.com/mapbox/osm-bright/archive/$OSM_BRIGHT_VERSION.tar.gz && tar -xzf $OSM_BRIGHT_VERSION.tar.gz && rm $OSM_BRIGHT_VERSION.tar.gz
RUN mv /tmp/osm-bright-$OSM_BRIGHT_VERSION /usr/share/mapnik
# Create symlink for shapefiles
RUN ln -s /usr/share/mapnik/openstreetmap-carto-$OSM_CARTO_VERSION/data /usr/share/mapnik/osm-bright-$OSM_BRIGHT_VERSION/shp

RUN cd /tmp && wget https://github.com/openstreetmap/mod_tile/archive/$MOD_TILE_VERSION.tar.gz && tar -xzf $MOD_TILE_VERSION.tar.gz && rm $MOD_TILE_VERSION.tar.gz
RUN cd /tmp/mod_tile-$MOD_TILE_VERSION/ && ./autogen.sh && ./configure && make -j $PARALLEL_BUILD && make install && make install-mod_tile

RUN mkdir -p /var/lib/mod_tile && chown www-data:www-data /var/lib/mod_tile
RUN mkdir -p /var/run/renderd  && chown www-data:www-data /var/run/renderd

RUN mkdir -p /etc/service/renderd && mkdir -p /etc/service/apache2
COPY ./apache2/run /etc/service/apache2/run
COPY ./renderd/run /etc/service/renderd/run
RUN chown root:root /etc/service/renderd/run /etc/service/apache2/run
RUN chmod u+x       /etc/service/renderd/run /etc/service/apache2/run

COPY ./tile.load /etc/apache2/mods-available/tile.load
COPY ./apache2/000-default.conf /etc/apache2/sites-enabled/000-default.conf
RUN ln -s /etc/apache2/mods-available/tile.load /etc/apache2/mods-enabled/
COPY ./renderd/renderd.conf /usr/local/etc/renderd.conf

COPY runit_bootstrap /usr/sbin/runit_bootstrap
RUN chmod 755 /usr/sbin/runit_bootstrap

RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

EXPOSE 80
ENTRYPOINT ["/usr/sbin/runit_bootstrap"]
