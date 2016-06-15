FROM debian:stable

RUN apt-get update
RUN apt-get install -y openssh-server rssh \
 && rm -f /etc/ssh/ssh_host_*

RUN useradd --uid 1000 --shell /usr/bin/rssh data \
 && chmod 0700 /home/data

ENV SSH_DIR	/home/data/.ssh
ENV AUTHORIZED_KEYS_FILE authorized_keys
RUN echo "AuthorizedKeysFile $SSH_DIR/$AUTHORIZED_KEYS_FILE" >>/etc/ssh/sshd_config \
 && mkdir -p $SSH_DIR \
 && chown data $SSH_DIR \
 && chmod 0700 $SSH_DIR \
 && touch $SSH_DIR/$AUTHORIZED_KEYS_FILE \
 && chown data $SSH_DIR/$AUTHORIZED_KEYS_FILE \
 && chmod 0600 $SSH_DIR/$AUTHORIZED_KEYS_FILE
RUN mkdir /var/run/sshd && chmod 0755 /var/run/sshd

RUN echo "KexAlgorithms curve25519-sha256@libssh.org,ecdh-sha2-nistp256,ecdh-sha2-nistp384,ecdh-sha2-nistp521,diffie-hellman-group-exchange-sha256,diffie-hellman-group14-sha1,diffie-hellman-group-exchange-sha1,diffie-hellman-group1-sha1" >> /etc/ssh/sshd_config

RUN echo "allowscp" >> /etc/rssh.conf
RUN echo "allowsftp" >> /etc/rssh.conf

ADD entrypoint.sh /

CMD ["/entrypoint.sh"]
EXPOSE 22
VOLUME /home/data
