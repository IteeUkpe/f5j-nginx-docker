# syntax=docker/dockerfile:1
# For Ubuntu 20.04:
FROM ubuntu:focal

# for referencing this files on git repository tree 
ARG OS_TYPE
ARG IMAGE_TYPE
# for access NMS to install NGINX agent
ARG NMS_URL

# Install prerequisite packages:
RUN apt-get update && apt-get install -y apt-transport-https lsb-release ca-certificates wget gnupg2

# Download and add the NGINX signing keys:
RUN wget https://cs.nginx.com/static/keys/nginx_signing.key && apt-key add nginx_signing.key \
    && wget https://cs.nginx.com/static/keys/app-protect-security-updates.key && apt-key add app-protect-security-updates.key

# Add NGINX Plus repository:
RUN printf "deb https://pkgs.nginx.com/plus/ubuntu `lsb_release -cs` nginx-plus\n" | tee /etc/apt/sources.list.d/nginx-plus.list

# Download the apt configuration to `/etc/apt/apt.conf.d`:
RUN wget -P /etc/apt/apt.conf.d https://cs.nginx.com/static/files/90pkgs-nginx

# Update the repository and install the most recent version of the NGINX Plus , Lua , NJS Modules:
RUN --mount=type=secret,id=nginx-crt,dst=/etc/ssl/nginx/nginx-repo.crt,mode=0644 \
    --mount=type=secret,id=nginx-key,dst=/etc/ssl/nginx/nginx-repo.key,mode=0644 \
    apt-get update && DEBIAN_FRONTEND="noninteractive" \
    apt-get install -y nginx-plus \
                       nginx-plus-module-njs \
                       nginx-plus-module-lua \
# NMS Agent installation
                   && bash -c 'wget --no-check-certificate $NMS_URL/install/nginx-agent -O - | sh' && echo "Agent installed from NMS"


# Forward request logs to Docker log collector:
RUN ln -sf /dev/stdout /var/log/nginx/access.log \
    && ln -sf /dev/stderr /var/log/nginx/error.log

# Copy configuration files:
RUN  mv /etc/nginx/conf.d/default.conf /etc/nginx/conf.d/default.conf-
COPY ${OS_TYPE}/${IMAGE_TYPE}/nginx.conf /etc/nginx/
COPY ${OS_TYPE}/${IMAGE_TYPE}/conf.d /etc/nginx/conf.d/
COPY ${OS_TYPE}/${IMAGE_TYPE}/entrypoint.sh /root/

CMD ["sh", "/root/entrypoint.sh"]