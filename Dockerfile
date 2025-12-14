# WineReaper - Windows Reaper DAW in Wine with GPU support
FROM nvidia/cuda:12.8.0-runtime-ubuntu24.04

# Set environment variables
ENV DEBIAN_FRONTEND=noninteractive \
    DISPLAY=:1 \
    RESOLUTION=1920x1080x24 \
    VNC_PORT=5900 \
    NOVNC_PORT=6080 \
    WINEDEBUG=-all \
    WINEARCH=win64 \
    WINEPREFIX=/home/reaper/.wine

# Create reaper user
RUN useradd -m -s /bin/bash reaper && \
    echo "reaper:reaper" | chpasswd && \
    usermod -aG audio reaper

# Install system dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    # Wine and Windows support
    wine64 \
    wine32 \
    winetricks \
    # GUI and desktop environment
    xvfb \
    x11vnc \
    xterm \
    fluxbox \
    # Audio support
    pulseaudio \
    pulseaudio-utils \
    jackd2 \
    # VNC web client
    websockify \
    net-tools \
    # Utilities
    wget \
    curl \
    unzip \
    git \
    # Fonts for better Windows app compatibility
    fonts-wine \
    ttf-mscorefonts-installer \
    && rm -rf /var/lib/apt/lists/* \
    && apt-get clean

# Install noVNC
RUN git clone https://github.com/novnc/noVNC.git /opt/noVNC && \
    git clone https://github.com/novnc/websockify /opt/noVNC/utils/websockify && \
    ln -s /opt/noVNC/vnc.html /opt/noVNC/index.html

# Download and install Reaper
RUN mkdir -p /tmp/reaper && cd /tmp/reaper && \
    wget -q "https://www.reaper.fm/files/6.x/reaper681_x64-install.exe" -O reaper-install.exe && \
    chmod +x reaper-install.exe

# Configure Wine and install Reaper as reaper user
USER reaper
WORKDIR /home/reaper

# Set up Wine prefix
RUN wine wineboot --init && \
    winetricks -q corefonts && \
    winetricks -q vcrun2019 && \
    winetricks -q dotnet48

# Install Reaper silently
RUN wine /tmp/reaper/reaper-install.exe /S

# Create startup script
RUN echo '#!/bin/bash\n\
# Start Xvfb\n\
Xvfb :1 -screen 0 ${RESOLUTION} &\n\
\n\
# Start Fluxbox window manager\n\
fluxbox &\n\
\n\
# Start x11vnc\n\
x11vnc -display :1 -noxdamage -forever -shared -rfbport ${VNC_PORT} -bg -o /tmp/x11vnc.log\n\
\n\
# Start noVNC\n\
/opt/noVNC/utils/novnc_proxy --vnc localhost:${VNC_PORT} --listen ${NOVNC_PORT} &\n\
\n\
# Set up PulseAudio for audio\n\
pulseaudio --start --log-target=syslog\n\
\n\
# Wait for X to be ready\n\
sleep 2\n\
\n\
# Start Reaper\n\
wine "C:\\\\Program Files\\\\REAPER\\\\reaper.exe"\n\
\n\
# Keep container running\n\
tail -f /dev/null' > /home/reaper/start.sh && \
    chmod +x /home/reaper/start.sh

# Clean up
USER root
RUN rm -rf /tmp/reaper

# Expose ports
EXPOSE ${VNC_PORT} ${NOVNC_PORT}

# Set volumes for persistent data
VOLUME ["/home/reaper/projects", "/home/reaper/.wine", "/home/reaper/.config"]

# Switch back to reaper user
USER reaper
WORKDIR /home/reaper

# Default command
CMD ["/home/reaper/start.sh"]
