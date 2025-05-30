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
    && apt-get clean

# Set up XFCE to use Yaru theme and Ubuntu fonts
RUN mkdir -p /root/.config/xfce4/xfconf/xfce-perchannel-xml && \
    echo '<?xml version="1.0" encoding="UTF-8"?>\n\
<channel name="xsettings" version="1.0">\n\
  <property name="Net" type="empty">\n\
    <property name="ThemeName" type="string" value="Yaru"/>\n\
    <property name="IconThemeName" type="string" value="Yaru"/>\n\
    <property name="FontName" type="string" value="Ubuntu 11"/>\n\
  </property>\n\
</channel>' > /root/.config/xfce4/xfconf/xfce-perchannel-xml/xsettings.xml && \
    echo '<?xml version="1.0" encoding="UTF-8"?>\n\
<channel name="xfwm4" version="1.0">\n\
  <property name="general" type="empty">\n\
    <property name="theme" type="string" value="Yaru"/>\n\
  </property>\n\
</channel>' > /root/.config/xfce4/xfconf/xfce-perchannel-xml/xfwm4.xml

# Set up startup script
RUN mkdir -p /root/.vnc && \
echo "#!/bin/bash\n\
# Set VNC password\n\
mkdir -p /root/.vnc\n\
echo 'password' | vncpasswd -f > /root/.vnc/passwd\n\
chmod 600 /root/.vnc/passwd\n\
\n\
# Create proper xstartup script\n\
cat > /root/.vnc/xstartup << 'EOL'\n\
#!/bin/sh\n\
# Start up the standard system desktop\n\
unset SESSION_MANAGER\n\
unset DBUS_SESSION_BUS_ADDRESS\n\
\n\
/usr/bin/startxfce4\n\
\n\
[ -x /etc/vnc/xstartup ] && exec /etc/vnc/xstartup\n\
[ -r $HOME/.Xresources ] && xrdb $HOME/.Xresources\n\
EOL\n\
\n\
chmod +x /root/.vnc/xstartup\n\
\n\
# Start VNC server\n\
vncserver :1 -geometry 1024x600 -depth 32 -SecurityTypes VncAuth -localhost no\n\
\n\
# Keep the script running\n\
tail -f /dev/null\n\
" > /usr/local/bin/start-vnc.sh && \
chmod +x /usr/local/bin/start-vnc.sh

# Expose VNC port
EXPOSE 5901

# Start the VNC server
CMD ["/usr/local/bin/start-vnc.sh"]