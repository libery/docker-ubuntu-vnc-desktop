FROM ubuntu:14.04.3
MAINTAINER VOICE1 <voice1me@gmail.com>

ENV DEBIAN_FRONTEND=noninteractive \
    HOME=/home/ubuntu \
    CRASHPLAN_VERSION=5.3.0 \
    CRASHPLAN_SERVICE=Code42CrashPlan \
    CRASHPLAN_INSTALLER=http://hosted.dfatech.ca:4280/client/installers/Code42CrashPlan_5.3.0_1452924000530_344_Linux.tgz \
    LC_ALL=C.UTF-8  \
    LANG=C.UTF-8    \
    LANGUAGE=C.UTF-8

# built-in packages
RUN apt-get update \
    && apt-get install -y --force-yes --no-install-recommends software-properties-common curl \
    && sudo sh -c "echo 'deb http://download.opensuse.org/repositories/home:/Horst3180/xUbuntu_16.04/ /' >> /etc/apt/sources.list.d/arc-theme.list" \
    && curl -SL http://download.opensuse.org/repositories/home:Horst3180/xUbuntu_16.04/Release.key | sudo apt-key add - \
    && add-apt-repository ppa:fcwu-tw/ppa \
    && apt-get update \
    && apt-get install -y --force-yes --no-install-recommends \
        supervisor \
        openssh-server pwgen sudo vim-tiny \
        net-tools \
        libnotify4 \
        libgconf-2-4 \
        libnss3 \
        expect \
        wget \
        lxde x11vnc xvfb \
        gtk2-engines-murrine ttf-ubuntu-font-family \
        firefox \
        fonts-wqy-microhei \
        language-pack-zh-hant language-pack-gnome-zh-hant firefox-locale-zh-hant libreoffice-l10n-zh-tw \
        nginx \
        python-pip python-dev build-essential \
        mesa-utils libgl1-mesa-dri \
        gnome-themes-standard gtk2-engines-pixbuf gtk2-engines-murrine pinta arc-theme \
    && apt-get autoclean \
    && apt-get autoremove \
    && rm -rf /var/lib/apt/lists/*

ADD /files /tmp/installation
# Increase max file watches
# ADD /files/installation/60-max-user-watches.conf /etc/sysctl.d/60-max-user-watches.conf
RUN chmod +x /tmp/installation/install.sh && sync && /tmp/installation/install.sh && rm -rf /tmp/installation


ADD web /web/
RUN pip install setuptools wheel && pip install -r /web/requirements.txt

# tini for subreap                                   
ENV TINI_VERSION v0.9.0
ADD https://github.com/krallin/tini/releases/download/${TINI_VERSION}/tini /bin/tini
RUN chmod +x /bin/tini

ADD noVNC /noVNC/
ADD nginx.conf /etc/nginx/sites-enabled/default
ADD startup.sh /
ADD supervisord.conf /etc/supervisor/conf.d/
ADD doro-lxde-wallpapers /usr/share/doro-lxde-wallpapers/
ADD gtkrc-2.0 /home/ubuntu/.gtkrc-2.0

VOLUME [ "/var/crashplan", "/storage" ]

EXPOSE 6080 4243 4242
WORKDIR /usr/local/crashplan

ENTRYPOINT ["/entrypoint.sh"]
CMD ["/crashplan.sh", "/startup.sh"]
