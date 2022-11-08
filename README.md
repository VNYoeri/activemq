# Create and use new builder instance (BUILDX)
For detailed information: see [Docker's buildx create](https://docs.docker.com/engine/reference/commandline/buildx_create/)
```shell
docker buildx create --use
```
# Create image for multiple platforms for a specific activeMQ version
```shell
docker buildx build --platform linux/arm64,linux/amd64 -t <username>/activemq:<activemq-version>. --push
```
## Update the latest tag when using a newer activeMQ version
```shell
docker buildx build --platform linux/arm64,linux/amd64 -t <username>/activemq:latest. --push
```