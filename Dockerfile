# Pull base image
From consol/tomcat-7.0:7.0.55

# Maintainer
MAINTAINER "rajusw804@gmail.com"
COPY target/*.war /opt/tomcat/webapps
