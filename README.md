# nexus


A Dockerfile for Sonatype Nexus Repository Manager 3, based on Alpine.

To run, binding the exposed port 8081 to the host.

```
$ docker run -d -p 8081:8081 --name nexus clearent/nexus
```


## Notes

*   Default credentials are: `admin` / `admin123`

*   It can take some time (2-3 minutes) for the service to launch in a
new container.  You can tail the log to determine once Nexus is ready:

```
$ docker logs -f nexus
```

*   Installation of Nexus is to `/opt/sonatype/nexus`.  

*   A persistent directory, `/nexus-data`, is used for configuration,
logs, and storage.

*   Two environment variables can be used to control the JVM arguments

    *   `JAVA_MAX_MEM`, passed as -Xmx.  Defaults to `1200m`.

    *   `JAVA_MIN_MEM`, passed as -Xms.  Defaults to `1200m`.

    These can be used supplied at runtime to control the JVM:

    ```
    $ docker run -d -p 8081:8081 --name nexus -e JAVA_MAX_MEM=2048M clearent/nexus
    ```


### SSL

If you want to run Nexus in SSL, you need to create a Java keystore file with your certificate. See the [Jetty documentation](http://www.eclipse.org/jetty/documentation/current/configuring-ssl.html) for help.

Unlike the clearent/nexus image, this will not allow you to host the image with ssl in a normal docker environment.
It requires you to run your docker daemon in [Swarm mode](https://docs.docker.com/engine/swarm/swarm-mode/) to utlize the [docker secrets](https://docs.docker.com/engine/swarm/secrets).

You have to supply two parameters to provide the required information for where the keystore and its password can be foud.

* *JKS_STORE*: the location of the keystore
* *JKS_PASSWORD_FILE*: the location of the keystore password file 

For creating the two secrets (keystore and password), you do it like this:

```bash
docker secret create keystore-nexus3 jetty-nexus3-keystore.jks
echo "MyAmazingPassword" | docker secret create keystore-nexus3-pass -
```

Docker allows you to give specific services rights to use the secrets and it allows you to target them to specific location.
The secrets will be mounted as a file in /run/secrets/${target}

And you can then run the docker service as follows:

```bash
 docker service create --name n3 \
     --secret source=keystore-nexus3,target=jks_store \
     --secret source=keystore-nexus3-pass,target=jks_pass \
     -e JKS_STORE="/run/secrets/jks_store"\
     -e JKS_PASSWORD_FILE="/run/secrets/jks_pass"\
     -p 8443:8443 \
      nexus3-image
```

Nexus will now serve its' UI on HTTPS on port 8443 and redirect HTTP requests to HTTPS.


### Persistent Data

There are two general approaches to handling persistent storage requirements
with Docker. See [Managing Data in Containers](https://docs.docker.com/userguide/dockervolumes/)
for additional information.

1.  *Use a data volume container*.  Since data volumes are persistent
    until no containers use them, a container can created specifically for
    this purpose.  This is the recommended approach.  

    ```
    $ docker run -d --name nexus-data clearent/nexus echo "data-only container for Nexus"
    $ docker run -d -p 8081:8081 --name nexus --volumes-from nexus-data clearent/nexus
    ```

2.  *Mount a host directory as the volume*.

    ```
    $ docker run -d -p 8081:8081 --name nexus -v /some/dir/nexus-data:/nexus-data clearent/nexus
    ```
