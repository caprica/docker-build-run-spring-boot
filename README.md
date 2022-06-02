# docker-test

A minimal project showing how to use Docker to build and run a Spring Boot application.

## Dockerfile

The Dockerfile is a multi-stage Dockerfile with a "build" stage and a run stage.

This Dockerfile requires the Docker "buildkit" to be enabled.

If using Docker Desktop, this is enabled by default, otherwise it has to be explicitly enabled by some means - this can
be set as an environment variable, passed on the command-line directly when building the image, or configured in the
Docker daemon configuration file in `/etc/docker/daemon.json`.

### build stage

The first stage builds the maven project.

To achieve this, a base image for Maven is used, matching the JDK we want to use.

In this stage, it creates a "/build" directory, copies the current directory to it (thereby copying all of the project
files to the image) and runs the Maven package command.

When it runs the Maven package command it uses a cache for the Maven local repository, which means that the Maven
dependencies wlll be cached and reused rather than downloading them again every time the image changes.

### run stage

The second stage prepares the runtime environment for the project.

To achieve this, a base OpenJDK image is used, matching the JDK we want to use.

In this stage, it creates an "/app" directory and copies the executable Spring Boot jar file that was built by the
previous stage (when invoking the COPY command it specifies the _container_ to copy from).

Finally, it simply declares the exposed server port (which by default is 8080) and declares the Spring Boot application
entry point.

## Building the image

For this example we use "test:latest" as the tag for the image.

If buildkit is already enabled:

```
docker build . -t test:latest
```

If buildkit is not enabled:

```
DOCKER_BUILDKIT=1 docker build . -t test:latest
```

The first time this builds it will take some time as the image and all of the required Maven dependencies are
downloaded.

Subsequent builds will be _much_ faster.

## Running a container

Again, for this example we use the same "test:latest" image tag as was used to build the image.

To use the standard Spring Boot server port:

```
docker run -it -p8080:8080 test:latest
```

To use a different server port, change the first part of the port argument - e.g. to use 8888:

```
docker run -it -p8888:8080 test:latest
```

To automatically delete the container after it exits:

```
docker run --rm -it -p8080:8080 test:latest
```

## Custom Maven settings.xml

If you need to use a custom Maven `settings.xml` file, this should be copied to the project directory (if it should not
be commited to the repository then it should be added to the `.gitignore` file).

Maven must then be told to use this file:

```
RUN --mount=type=cache,target=/root/.m2 mvn clean package -B -s ./settings.xml
```

## Docker Compose

Pending...

