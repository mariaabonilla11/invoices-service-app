# Use an official Ruby image as the base, based on Debian Bookworm (stable)
FROM --platform=linux/amd64 ruby:3.2.0 AS base 

# --- Configuration Variables ---
ENV ORACLE_HOME=/opt/oracle/instantclient
ENV LD_LIBRARY_PATH=$ORACLE_HOME
ENV PATH=$ORACLE_HOME:$PATH

# Set a working directory for the Rails app
WORKDIR /app

# --- Install System Dependencies ---
RUN apt-get update && apt-get install -y \
    build-essential libaio1 libpq-dev default-libmysqlclient-dev \
    && rm -rf /var/lib/apt/lists/*

# --- Copy and Configure Oracle Instant Client ---

# 1. Create the final destination directory inside the container
RUN mkdir -p $ORACLE_HOME

# 2. Copy the *contents* of your locally unzipped folder into the container
#    NOTE: Adjust the source path 'instantclient_linux/instantclient_21_20/' if your local folder name is different
COPY instantclient_linux/instantclient_21_20/ $ORACLE_HOME/

# 3. Configure the libraries and symbolic links
RUN cd $ORACLE_HOME && \
    # Remove the existing link if it exists (handles previous errors)
    rm -f libclntsh.so && \
    # Create the mandatory symbolic link with the EXACT version 21.1
    ln -s libclntsh.so.21.1 libclntsh.so && \
    # Update the OS runtime linker configuration/cache
    sh -c "echo $ORACLE_HOME > /etc/ld.so.conf.d/oracle-instantclient.conf" && \
    ldconfig

# --- Install Ruby Gems and Application Code ---
# Copy the Gemfile and Gemfile.lock to leverage Docker caching
COPY Gemfile* ./

# Install the ruby-oci8 gem and the oracle-enhanced adapter gem
RUN gem install bundler && bundle install 

# Copy the rest of the application code
COPY . /app

# Script de arranque
CMD ["bash", "-c", "sleep 5 && rm -f tmp/pids/server.pid && bundle exec rails s -b 0.0.0.0 -p 3002 && sleep 5 && bundle exec rails db:migrate"]