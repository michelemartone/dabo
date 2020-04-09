# Start with a configurable base image
ARG IMG="debian:unstable"
FROM "${IMG}"

# Install required packages
RUN apt-get update; yes | apt-get install bsd-mailx make vim;

# Set up dirs
COPY "." "/mnt"
WORKDIR "/mnt"

# Set up environment
RUN useradd "user"
RUN chown --recursive "user:user" "."
USER "user"
ENV USER user

# Build and test
RUN make
