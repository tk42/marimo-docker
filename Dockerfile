FROM python:3.14-slim-bookworm

RUN apt update && apt upgrade -y && apt install -y sudo curl

# Add sudo user
RUN groupadd -g 1000 python && \
    useradd  -g      python -G sudo -m -s /bin/bash python && \
    echo 'python:python' | chpasswd
RUN echo 'Defaults visiblepw'             >> /etc/sudoers
RUN echo 'python ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers

# Install uv
ADD https://astral.sh/uv/install.sh /uv-installer.sh
RUN env UV_INSTALL_DIR="/home/python/.local/bin" sh /uv-installer.sh && rm /uv-installer.sh
ENV PATH="/home/python/.local/bin:$PATH"
RUN chown -Rh python:python /home/python

# Install marimo as the python user so the shim lands in /home/python/.local/bin
USER python
RUN uv tool install marimo
USER root

RUN apt install -y fonts-noto-cjk

ENV PS1="[\u@\h:\w]$"
CMD ["marimo", "edit", "--host", "0.0.0.0", "--port", "2718"]
