FROM ubuntu:latest

# Install OpenSSH server and sudo
RUN apt update && apt install openssh-server sudo -y

# Create a user “sshuser” and group “sshgroup”
RUN groupadd sshgroup && useradd -ms /bin/bash -g sshgroup sshuser

# Set password for sshuser
RUN echo 'sshuser:kocak' | chpasswd

# Create sshuser directory in home
RUN mkdir -p /home/sshuser/.ssh

# Copy the ssh public key in the authorized_keys file
COPY idkey.pub /home/sshuser/.ssh/authorized_keys

# Change ownership of the key file and set permissions
RUN chown sshuser:sshgroup /home/sshuser/.ssh/authorized_keys && chmod 600 /home/sshuser/.ssh/authorized_keys

# Start SSH service
RUN service ssh start

# Expose Docker port 22
EXPOSE 22

# Command to run SSH daemon
CMD ["/usr/sbin/sshd", "-D"]
