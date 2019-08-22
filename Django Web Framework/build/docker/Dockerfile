#if( ${containerObject} )
#set( $appName = "Container-${containerObject.getName()}" )
#else
#set( $appName = $aib.getApplicationNameFormatted() )
#end
FROM python:3
# Install Python and Package Libraries
RUN apt-get update && apt-get upgrade -y && apt-get autoremove && apt-get autoclean
RUN apt-get install -y \
    curl \
    wget \
    net-tools \
    dos2unix \
    nano
# Project Files and Settings
ARG PROJECT=${appName}
ARG PROJECT_DIR=/var/www/${appName}
RUN mkdir -p $PROJECT_DIR
ADD ./ $PROJECT_DIR/
RUN cd $PROJECT_DIR && ls
WORKDIR $PROJECT_DIR
RUN pip install --upgrade pip
RUN pip install -U pipenv
RUN pipenv install
RUN pipenv install django=='2.2.*'
# Server
EXPOSE 8000
STOPSIGNAL SIGINT
RUN dos2unix /var/www/${appName}/entrypoint.sh
RUN chmod +x /var/www/${appName}/entrypoint.sh
ENTRYPOINT ["/var/www/${appName}/entrypoint.sh"]
