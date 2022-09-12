FROM tomcat:9.0
RUN apt-get update && apt-get -y upgrade
WORKDIR /usr/local/tomcat
User root
RUN mv /usr/local/tomcat/webapps /usr/local/tomcat/webapps2
RUN mv /usr/local/tomcat/webapps.dist/ webapps
ADD /var/lib/jenkins/workspace/pipeline3/target/demo.war /usr/local/tomcat/webapps/login-app.war
#COPY tomcat-users.xml /usr/local/tomcat/conf/
COPY context.xml /usr/local/tomcat/webapps/manager/META-INF/
COPY context.xml /usr/local/tomcat/webapps/host-manager/META-INF/
EXPOSE 8080
CMD ["catalina.sh", "run"]
