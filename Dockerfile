FROM rocker/tidyverse:3.6.1

RUN mkdir -p /usr/src/App
COPY shiny.tar.gz shiny.tar.gz
RUN R -e 'install.packages("packrat")'
RUN R -e 'packrat::unbundle("shiny.tar.gz", "/usr/src/App")'
WORKDIR /usr/src/App/shiny
RUN R -e 'packrat::restore()'
EXPOSE 8080
CMD R -e "packrat::on(); options('shiny.port'=8080,shiny.host='0.0.0.0'); shiny::runApp('app.R')"