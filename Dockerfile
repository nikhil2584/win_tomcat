# This is the Windows 2016 server edition.
# docker file suppose to install tomcat & run the webserver.

FROM mcr.microsoft.com/windows/servercore:1809

SHELL ["powershell", "-Command", "$ErrorActionPreference = 'Stop'; $ProgressPreference = 'SilentlyContinue';"]

# Apparently Windows Server 2016 disables TLS 1.2 by default - this enables it so we can talk to GitHub
RUN [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12; \
    mkdir /config; \
    mkdir /data; \
    mkdir /etc/tomcat; \
    mkdir /usr/share/tomcat; \
  #  Invoke-WebRequest \
  #      -Uri "https://github.com/caddyserver/dist/raw/979e498d6d01e1fe7c22db848a3e3bc65369183f/config/Caddyfile" \
   #     -OutFile "/etc/tomcat/tomcatfile"; \
   # Invoke-WebRequest \
        #-Uri "https://github.com/caddyserver/dist/raw/979e498d6d01e1fe7c22db848a3e3bc65369183f/welcome/index.html" \
       # -OutFile "/usr/share/tomacat/index.html"

# https://github.com/caddyserver/caddy/releases
ENV TOMCAT_VERSION v9.0.65

RUN [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12; \
    Invoke-WebRequest \
        -Uri "https://dlcdn.apache.org/tomcat/tomcat-9/v9.0.65/bin/apache-tomcat-9.0.65-windows-x64.zip" \
        -OutFile "/tomcat.zip"; \
    #if (!(Get-FileHash -Path /caddy.zip -Algorithm SHA512).Hash.ToLower().Equals('b104d364a458f457bab24f12f97470612035f705fceb170ce16b567e18e0429a18a726f6b1bb435f92d28a659aee52c08c0bac3be41b7f23887b8e7307507482')) { exit 1; }; \
    Expand-Archive -Path "/tomcat.zip" -DestinationPath "/" -Force; \
    Remove-Item "/tomcat.zip" -Force

# See https://caddyserver.com/docs/conventions#file-locations for details
ENV XDG_CONFIG_HOME c:/config
ENV XDG_DATA_HOME c:/data

#LABEL org.opencontainers.image.description="a powerful, enterprise-ready, open source web server with automatic HTTPS written in Go"
#Image.documentation=https://caddyserver.com/docs
#LABEL org.opencontainers.image.vendor="Light Code Labs"
#LABEL org.opencontainers.image.licenses=Apache-2.0
#LABEL org.opencontainers.image.source="https://github.com/caddyserver/caddy-docker"

EXPOSE 8081
EXPOSE 443
EXPOSE 2019

# Make sure it runs and reports its version
RUN ["catalina", "version"]

CMD ["tomcat", "run", "--config", "/etc/caddy/tomcatfile", "--adapter", "tomcatfile"]
