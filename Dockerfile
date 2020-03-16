FROM registry.access.redhat.com/ubi8/ubi

RUN ln -s /usr/bin/bash /usr/bin/bash2

ENTRYPOINT /usr/bin/bash2
