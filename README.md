# SSH Ubuntu Docker Image

This README provides instructions on how to build and run a Docker image for an Ubuntu container with SSH access. This setup allows you to securely connect to the container using SSH.

## Table of Contents
- [Prerequisites](#prerequisites)
- [Dockerfile Overview](#dockerfile-overview)
- [Building the Docker Image](#building-the-docker-image)
- [Running the Docker Container](#running-the-docker-container)
- [Accessing the Container via SSH](#accessing-the-container-via-ssh)

## Prerequisites
- Docker installed on your machine
- An SSH public key generated (e.g., using `ssh-keygen`)

Ensure your public key (e.g., `id_rsa.pub`) is located in the `./ssh/` directory relative to this README.

## Dockerfile Overview
The provided Dockerfile does the following:

1. **Base Image**: Starts with the latest Ubuntu image.
2. **Install OpenSSH**: Installs the OpenSSH server.
3. **Create User**: Creates a user named `sshuser` and a group named `sshgroup`.
4. **Setup SSH Keys**: Copies your SSH public key to the authorized keys for the `sshuser`.
5. **Set Permissions**: Configures the correct permissions for the authorized keys.
6. **Expose Port**: Exposes port 22 for SSH connections.
7. **Start SSH Service**: Runs the SSH daemon in the foreground.

### Dockerfile Example

```dockerfile
FROM ubuntu:latest
RUN apt update && apt install openssh-server sudo -y

# Create a user “sshuser” and group “sshgroup”
RUN groupadd sshgroup && useradd -ms /bin/bash -g sshgroup sshuser

# Create sshuser directory in home
RUN mkdir -p /home/sshuser/.ssh

# Copy the ssh public key in the authorized_keys file
COPY idkey.pub /home/sshuser/.ssh/authorized_keys

# Change ownership of the key file
RUN chown sshuser:sshgroup /home/sshuser/.ssh/authorized_keys && chmod 600 /home/sshuser/.ssh/authorized_keys

# Start SSH service
RUN service ssh start

# Expose docker port 22
EXPOSE 22

CMD ["/usr/sbin/sshd", "-D"]
```

## Building the Docker Image

To build the Docker image, run the following command in the same directory as the Dockerfile:

```bash
docker build -t sshubuntu .
```

**Note**: If you're on a Linux client, you may need to prefix the command with `sudo`.

## Running the Docker Container

To run the Docker container, use the command below, which maps Docker's port 22 to the host's port 2022:

```bash
docker run -d -p 2022:22 sshubuntu
```

You can verify that the container is running with:

```bash
docker ps
```

You should see an output similar to this:

```
CONTAINER ID   IMAGE       COMMAND               CREATED        STATUS        PORTS                                   NAMES
2a443e5592b0   sshubuntu   "/usr/sbin/sshd -D"   14 hours ago   Up 14 hours   0.0.0.0:2022->22/tcp, :::2022->22/tcp   friendly_nash
```

## Accessing the Container via SSH

To SSH into the running container, use the following command:

```bash
ssh -i ./ssh/id_rsa sshuser@localhost -p 2022
```

### Note:
- Ensure you specify the correct path to your private key (`id_rsa`).
- The container's IP can also be used if you want to connect directly, but `localhost` should work in most cases.

Once connected, you can run commands inside the container as the `sshuser`.

## Conclusion

You now have a Docker container running Ubuntu with SSH access. This setup is useful for development, testing, or any scenario where you need to remotely access a containerized environment. If you have any issues or questions, feel free to reach out!