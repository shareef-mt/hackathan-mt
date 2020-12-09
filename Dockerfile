FROM tomcat:8.0.20-jre8
# Dummy text to test 
COPY target/hackathan-mt*.war /usr/local/tomcat/webapps/hackathan-mt.war
