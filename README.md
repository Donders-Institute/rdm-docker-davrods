# rdm-docker-davrods

A docker container of https-only [DavRods](https://github.com/UtrechtUniversity/davrods) service.

## For the demonstration

For the demonstration purpose, this package includes a iCAT server with the PAM authentication support.  Two PAM plugins ([pam_oath](http://www.nongnu.org/oath-toolkit/pam_oath.html) and [pam_script](https://github.com/jeroennijhof/pam_script)) are also installed and configured.  The orchestration of the iCAT and the DavRods servers is done by using the [docker-compose](https://docs.docker.com/compose/).

### Build the containers

```bash
$ docker-compose -f docker-compose.yml build --force-rm --no-cache
```

### Start the containers

```bash
$ docker-compose -f docker-compose.yml up -d
```

The `docker-compose ps` should show two running containers, e.g.

```bash
$ docker-compose ps
           Name                         Command               State           Ports          
--------------------------------------------------------------------------------------------
rdmdockerdavrods_davrods_1   /opt/run-httpd.sh                Up      0.0.0.0:443->443/tcp   
rdmdockerdavrods_icat_1      /opt/irods/bootstrap.sh de ...   Up      0.0.0.0:1247->1247/tcp 
```

### The demo

1. Login to iRODS as the rodsadmin and create a new user called `demouser` 

    ```bash
    $ docker exec -u irods -i -t rdmdockerdavrods_icat_1 iinit
    Enter your current iRODS password:
    ```

    The password of the rodsadmin is `demo.123`.  The password may be changed in the `docker-compose.yml` when starting the containers.

    ```bash
    $ docker exec -u irods -i -t rdmdockerdavrods_icat_1 iadmin mkuser demouser rodsuser
    ```
    
2. Retrieve the one-time password of the `demouser`

    ```bash
    $ docker exec -u irods -i -t rdmdockerdavrods_icat_1 irule -F /opt/irods/getUserNextHOTP.r '*userName="demouser"'
    *out = {"otp":"424751", "ec":0, "errmsg":""}
    ```
    
    On success, you should see an output containing a valid one-time password as the example above.
    
3. Connect to the WebDAV server and login with username `demouser` and the one-time password just retrieved.  The example below uses the `cadaver` WebDAV client on Linux. You may use Finder on MacOSX or File Explorer on Windows as DavRods supports the WebDAV level-2 protocol.  For the demonstration purpose, just accept the self-signed server certificate.

    ```bash
    $ cadaver https://localhost:443
    WARNING: Untrusted server certificate presented for `davrods.dccn.nl':
    Certificate was issued to hostname `davrods.dccn.nl' rather than `localhost'
    This connection could have been intercepted.
    Issued to: Donders Institute, Radboud University, Nijmegen, Gelderland, NL
    Issued by: Donders Institute, Radboud University, Nijmegen, Gelderland, NL
    Certificate is valid from Wed, 31 Aug 2016 08:39:18 GMT to Sat, 29 Aug 2026 08:39:18 GMT
    Do you wish to accept the certificate? (y/n) y
    Authentication required for DAV on server `localhost':
    Username: demouser
    Password: 
    ```
    
4. After login, you should be able to perform the WebDav operations (e.g. create collection, put/get files, etc.) without being asked again for the password.  What happened behind the scene is that upon the first successful login with the one-time password, the [pam_script](https://github.com/jeroennijhof/pam_script) plugin caches an authentication token as a user attribute (i.e. `authToken`).  The `authToken` looks like the example below:

    ```bash
    $ docker exec -u irods -i -t rdmdockerdavrods_icat_1 imeta ls -u demouser
    AVUs defined for user demouser#tempZone:
    attribute: authToken
    value: cd8a62f2b7cc57a36c81913e445b662f:1473211559
    units: 
    ```

    The string in front of the colon (`:`) is a one-way hash generated from the given username/password pair, while the number after indicates the token's validity (in timestamp).  As long as the token is valid, the WebDAV operations associated with the same pair of username and one-time password will be authorised.
    
    You may force a connected user to "logout" by removing the tokens associated with the user, e.g.
     
    ```bash
    $ docker exec -u irods -i -t rdmdockerdavrods_icat_1 imeta rmw -u demouser authToken %
    ```
    
    The WebDAV operation following the removal will become `Unauthorised`.  In cadaver, it will request the client to login again with a fresh one-time password.  For example,
    
    ```bash
    dav:/test/> ls
    Listing collection `/test/': Authentication required for DAV on server `localhost':
    Username:
    ```

## Running the DavRods container against a production iCAT

For the production (in which the iCAT server is provided elsewhere), the DavRods container can be launched by using the [docker engine](https://www.docker.com/products/docker-engine).  In order to connect properly to your iCAT server, you would have to modify (or provide) the configuration files as they are in the directory `davrods/config`, and map the directory to the `/config` volume in the container.

### Build the container

Assuming that you want to build DavRods 1.1 for iRODS 4.1.9 

```bash
$ cd davrods
$ docker build --force-rm -t davrods:1.1 --build-arg irods_version=4.1.9 --build-arg davrods_github_tag=1.1 --build-arg davrods_version=1.1.0 .
```

When it's done you should see a docker image like below:

```bash
docker images | grep davrods
davrods                      1.1                 509b30163d1e        About a minute ago   583.2 MB
```

### Modify the configuration files

Examples of configuration files can be found in the directory of `davrods/config`.  Hereafter is a summary of the configuration files:

- `davrods-vhost.conf`: the Apache virtual host configuration for the DavRods.
- `irods_environment.json`: the client configuration for DavRods service to connect to the iCAT server.
- `icat.pem`: the SSL public key of the iCAT service.
- `server.crt`, `server.key`, `server-ca-chain.crt`: SSL certificate/private key and CA chain for the Apache Https servicer.

### Run the container

Once you have done it, simply run the container as the following example command

```bash
$ docker run -v `pwd`/config:config -p 443:443 -d davrods:1.1
```

The WebDAV client will have to connect to port `443` of the docker host (i.e. the one runs the docker engine).
