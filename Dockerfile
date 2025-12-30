# Pull base image
FROM consol/tomcat-7.0:7.0.62-usermode

# Maintainer
MAINTAINER "rajusw804@gmail.com"
COPY target/*.war /opt/tomcat/webapps
