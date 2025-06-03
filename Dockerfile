FROM ubuntu:24.04

# Avoid prompts during package installation
ENV DEBIAN_FRONTEND=noninteractive

# Switch to a more reliable Ubuntu mirror
RUN sed -i 's|http://security.ubuntu.com/ubuntu|http://archive.ubuntu.com/ubuntu|g' /etc/apt/sources.list

# Update and install software-properties-common first
RUN apt-get update && apt-get install -y software-properties-common && apt-get clean

# Add Mozilla PPA for Firefox
RUN add-apt-repository ppa:mozillateam/ppa -y

# Set Firefox PPA priority to avoid Snap version
RUN echo 'Package: firefox*\nPin: release o=LP-PPA-mozillateam\nPin-Priority: 1001' > /etc/apt/preferences.d/mozilla-firefox

# Update and install remaining packages including locales
RUN apt-get update && apt-get install -y \
    xfce4 \
    xfce4-goodies \
    tigervnc-standalone-server \
    tigervnc-common \
    x11-xserver-utils \
    xterm \
    dbus-x11 \
    wget \
    gnupg \
    ca-certificates \
    git \
    sudo \
    firefox \
    yaru-theme-gtk \
    yaru-theme-icon \
    fonts-ubuntu \
    gnome-themes-extra \
    verilator \
    gtkwave \
    stress \
    htop \
    python3 \
    python3-pip \
    python3-numpy \
    python3-websockify \
    net-tools \
    xauth \
    unzip \
    locales \
    && apt-get clean

# Configure locales to fix Perl warnings
RUN locale-gen en_US.UTF-8 && \
    update-locale LC_ALL=en_US.UTF-8 LANG=en_US.UTF-8

# Set locale environment variables
ENV LANG=en_US.UTF-8
ENV LC_ALL=en_US.UTF-8
ENV LANGUAGE=en_US:en

# Install noVNC and websockify
RUN cd /opt && \
    git clone https://github.com/novnc/noVNC.git && \
    git clone https://github.com/novnc/websockify.git && \
    ln -sf /opt/noVNC/vnc.html /opt/noVNC/index.html

# Create a non-root user
RUN useradd -m -s /bin/bash -G sudo developer && \
    echo "developer:password" | chpasswd && \
    echo "developer ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

# Set up XFCE configuration for the developer user
RUN mkdir -p /home/developer/.config/xfce4/xfconf/xfce-perchannel-xml && \
    echo '<?xml version="1.0" encoding="UTF-8"?>\n\
<channel name="xsettings" version="1.0">\n\
  <property name="Net" type="empty">\n\
    <property name="ThemeName" type="string" value="Yaru"/>\n\
    <property name="IconThemeName" type="string" value="Yaru"/>\n\
    <property name="FontName" type="string" value="Ubuntu 11"/>\n\
  </property>\n\
</channel>' > /home/developer/.config/xfce4/xfconf/xfce-perchannel-xml/xsettings.xml && \
    echo '<?xml version="1.0" encoding="UTF-8"?>\n\
<channel name="xfwm4" version="1.0">\n\
  <property name="general" type="empty">\n\
    <property name="theme" type="string" value="Yaru"/>\n\
  </property>\n\
</channel>' > /home/developer/.config/xfce4/xfconf/xfce-perchannel-xml/xfwm4.xml && \
    chown -R developer:developer /home/developer/.config

# Create VNC directory and set up startup script
RUN mkdir -p /home/developer/.vnc && \
    chown developer:developer /home/developer/.vnc

# Set up startup script with noVNC support
RUN echo "#!/bin/bash\n\
# Switch to developer user and set up environment\n\
export USER=developer\n\
export HOME=/home/developer\n\
export DISPLAY=:1\n\
export NO_AT_BRIDGE=1\n\
\n\
# Set VNC password as developer user\n\
su - developer -c '\n\
mkdir -p /home/developer/.vnc\n\
echo \"password\" | vncpasswd -f > /home/developer/.vnc/passwd\n\
chmod 600 /home/developer/.vnc/passwd\n\
\n\
# Create .Xauthority file to fix xauth warning\n\
touch /home/developer/.Xauthority\n\
chmod 600 /home/developer/.Xauthority\n\
\n\
# Create proper xstartup script\n\
cat > /home/developer/.vnc/xstartup << \"EOL\"\n\
#!/bin/sh\n\
# Start up the standard system desktop\n\
unset SESSION_MANAGER\n\
unset DBUS_SESSION_BUS_ADDRESS\n\
\n\
export DISPLAY=:1\n\
export NO_AT_BRIDGE=1\n\
\n\
# Start D-Bus session\n\
eval \$(dbus-launch --sh-syntax --exit-with-session)\n\
\n\
# Start XFCE4\n\
/usr/bin/startxfce4 &\n\
\n\
# Keep session alive\n\
wait\n\
EOL\n\
\n\
chmod +x /home/developer/.vnc/xstartup\n\
\n\
# Start VNC server as developer user\n\
vncserver :1 -geometry 1024x600 -depth 32 -SecurityTypes VncAuth -localhost no\n\
'\n\
\n\
# Wait a moment for VNC server to start\n\
sleep 5\n\
\n\
# Start noVNC web server in background - FIXED: Use correct websockify syntax\n\
echo \"Starting noVNC web server...\"\n\
cd /opt/noVNC && /usr/bin/websockify --web . 6080 localhost:5901 &\n\
\n\
# Wait for websockify to start\n\
sleep 2\n\
\n\
echo \"Services started:\"\n\
echo \"  VNC Server: localhost:5901 (password: password)\"\n\
echo \"  noVNC Web:  http://localhost:6080/vnc.html\"\n\
echo \"  Connect to noVNC using password: password\"\n\
\n\
# Show process status for debugging\n\
echo \"Active processes:\"\n\
ps aux | grep -E 'vnc|websockify' | grep -v grep\n\
\n\
# Show listening ports for debugging\n\
echo \"Listening ports:\"\n\
netstat -tlnp 2>/dev/null | grep -E ':590[0-9]|:608[0-9]' || ss -tlnp | grep -E ':590[0-9]|:608[0-9]' || echo \"Port check tools not available\"\n\
\n\
# Keep the script running\n\
tail -f /dev/null\n\
" > /usr/local/bin/start-vnc.sh && \
chmod +x /usr/local/bin/start-vnc.sh

# Create a workspace directory for the developer user
RUN mkdir -p /home/developer/workspace && \
    chown -R developer:developer /home/developer/workspace

# Set working directory
WORKDIR /home/developer

# Expose VNC and noVNC ports
EXPOSE 5901 6080

# Start the VNC server
CMD ["/usr/local/bin/start-vnc.sh"]