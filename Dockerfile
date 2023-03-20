FROM rocker/r-ubuntu

RUN apt-get update          \
    && apt-get upgrade -y   \
    && apt-get install -y   \
    libpng-dev libgdal-dev  libgeos-dev libproj-dev libudunits2-dev \
    libssl-dev libcurl4-openssl-dev libssh2-1-dev libpq-dev zlib1g-dev

RUN R -e "install.packages( c('shiny',      \
    'shinydashboard', 'shinycssloaders',    \
    'dplyr', 'leaflet', 'leaflet.extras',   \
    'htmltools', 'DT', 'plotly'), repos='https://cloud.r-project.org/')"

ARG ARG_GIS_USER
ENV GIS_USER=$ARG_GIS_USER

ARG ARG_GIS_PWD
ENV GIS_PWD=$ARG_GIS_PWD

RUN mkdir /root/compost-collector

COPY . /root/compost-collector

EXPOSE 3838

CMD ["R", "-e", "shiny::runApp('/root/compost-collector', host = '0.0.0.0', port = 3838)"]
