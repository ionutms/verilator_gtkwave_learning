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

# Update and install remaining packages
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
    && apt-get clean

# Add Microsoft GPG key and repository for VS Code
RUN wget -qO- https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > packages.microsoft.gpg && \
    install -o root -g root -m 644 packages.microsoft.gpg /etc/apt/trusted.gpg.d/ && \
    echo "deb [arch=amd64,arm64,armhf signed-by=/etc/apt/trusted.gpg.d/packages.microsoft.gpg] https://packages.microsoft.com/repos/code stable main" > /etc/apt/sources.list.d/vscode.list

# Update package list and install VS Code
RUN apt-get update && apt-get install -y code && apt-get clean

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

# Set up startup script
RUN echo "#!/bin/bash\n\
# Switch to developer user and set up environment\n\
export USER=developer\n\
export HOME=/home/developer\n\
export DISPLAY=:1\n\
export NO_AT_BRIDGE=1\n\
export ELECTRON_DISABLE_SECURITY_WARNINGS=true\n\
\n\
# Set VNC password as developer user\n\
su - developer -c '\n\
mkdir -p /home/developer/.vnc\n\
echo \"password\" | vncpasswd -f > /home/developer/.vnc/passwd\n\
chmod 600 /home/developer/.vnc/passwd\n\
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
export ELECTRON_DISABLE_SECURITY_WARNINGS=true\n\
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
# Keep the script running\n\
tail -f /dev/null\n\
" > /usr/local/bin/start-vnc.sh && \
chmod +x /usr/local/bin/start-vnc.sh

# Create a workspace directory for the developer user
RUN mkdir -p /home/developer/workspace && \
    chown -R developer:developer /home/developer/workspace

# Set working directory
WORKDIR /home/developer

# Expose VNC port
EXPOSE 5901

# Start the VNC server
CMD ["/usr/local/bin/start-vnc.sh"]