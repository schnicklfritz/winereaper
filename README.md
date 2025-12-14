# WineReaper - Windows Reaper DAW in Docker with GPU Support

Run the Windows version of Reaper Digital Audio Workstation in a Docker container using Wine, with GPU acceleration for plugins and web-based GUI access.

## Features

- **Windows Reaper in Wine**: Full Reaper DAW running in Wine compatibility layer
- **GPU Acceleration**: NVIDIA GPU support for GPU-accelerated plugins
- **Web GUI**: Access via browser with noVNC (VNC over HTML5)
- **Audio Support**: PulseAudio and JACK audio routing
- **Persistent Storage**: Save projects and configurations
- **Easy Deployment**: One-command Docker deployment

## Quick Start

### Prerequisites

- Docker with NVIDIA Container Toolkit installed
- NVIDIA GPU with proper drivers
- Git

### Run with Docker

```bash
# Create directory for projects
mkdir -p ~/reaper-projects

# Run WineReaper container
docker run --gpus all \
  -p 6080:6080 \
  -p 5900:5900 \
  -v ~/reaper-projects:/home/reaper/projects \
  --device /dev/snd \
  schnicklbob/winereaper:latest
```

### Access the GUI

Open your browser and navigate to:
```
http://localhost:6080/vnc.html
```

Default password: (none, press "Connect")

## Advanced Usage

### With Docker Compose

Create `docker-compose.yml`:

```yaml
version: '3.8'

services:
  winereaper:
    image: schnicklbob/winereaper:latest
    container_name: winereaper
    runtime: nvidia
    ports:
      - "6080:6080"
      - "5900:5900"
    volumes:
      - ./projects:/home/reaper/projects
      - ./wine-prefix:/home/reaper/.wine
      - ./config:/home/reaper/.config
    devices:
      - /dev/snd
    environment:
      - RESOLUTION=1920x1080x24
      - DISPLAY=:1
    restart: unless-stopped
```

Run with:
```bash
docker-compose up -d
```

### Custom Resolution

```bash
docker run --gpus all \
  -p 6080:6080 \
  -e RESOLUTION=2560x1440x24 \
  -v $(pwd)/projects:/home/reaper/projects \
  schnicklbob/winereaper:latest
```

### Audio Configuration

For better audio performance, pass through audio devices:

```bash
docker run --gpus all \
  -p 6080:6080 \
  --device /dev/snd \
  -e PULSE_SERVER=unix:/tmp/pulseaudio.socket \
  -v /tmp/pulseaudio.socket:/tmp/pulseaudio.socket \
  -v ~/.config/pulse:/home/reaper/.config/pulse \
  schnicklbob/winereaper:latest
```

## Building from Source

### Clone and Build

```bash
git clone https://github.com/schnicklfritz/winereaper.git
cd winereaper
docker build -t winereaper:latest .
```

### Build with GitHub Actions

The image is automatically built and pushed to Docker Hub on every push to the main branch.

## GPU Configuration

### NVIDIA GPU Requirements

1. Install NVIDIA drivers on host
2. Install NVIDIA Container Toolkit:
   ```bash
   distribution=$(. /etc/os-release;echo $ID$VERSION_ID)
   curl -s -L https://nvidia.github.io/nvidia-docker/gpgkey | sudo apt-key add -
   curl -s -L https://nvidia.github.io/nvidia-docker/$distribution/nvidia-docker.list | sudo tee /etc/apt/sources.list.d/nvidia-docker.list
   sudo apt-get update && sudo apt-get install -y nvidia-container-toolkit
   sudo systemctl restart docker
   ```

### Verify GPU Access

```bash
# Test GPU access in container
docker run --gpus all nvidia/cuda:12.8.0-base-ubuntu24.04 nvidia-smi
```

## Plugin Installation

### Install VST Plugins

1. Access the container via VNC
2. Download Windows VST installers
3. Run installers in Wine (they will install to the Wine prefix)
4. Rescan plugins in Reaper

### Persistent Plugin Storage

Mount the Wine prefix to persist installed plugins:

```bash
docker run --gpus all \
  -p 6080:6080 \
  -v $(pwd)/wine-prefix:/home/reaper/.wine \
  -v $(pwd)/projects:/home/reaper/projects \
  schnicklbob/winereaper:latest
```

## Troubleshooting

### No Audio

Check audio device permissions:
```bash
# Add user to audio group on host
sudo usermod -aG audio $USER
```

### GPU Not Detected

Verify NVIDIA Container Toolkit installation:
```bash
docker run --gpus all nvidia/cuda:12.8.0-base-ubuntu24.04 nvidia-smi
```

### VNC Connection Issues

Check if ports are available:
```bash
# Check if ports are in use
sudo lsof -i :6080
sudo lsof -i :5900
```

## Development

### Dockerfile Structure

- Base: `nvidia/cuda:12.8.0-runtime-ubuntu24.04`
- Wine installation with 64-bit support
- X11 + VNC + noVNC for GUI
- PulseAudio for audio
- Reaper Windows installer

### Testing Changes

```bash
# Build test image
docker build -t winereaper-test .

# Run test
docker run --gpus all -p 6080:6080 winereaper-test
```

## License

MIT License - see LICENSE file for details.

## Support

- GitHub Issues: [schnicklfritz/winereaper/issues](https://github.com/schnicklfritz/winereaper/issues)
- Reaper Documentation: [www.reaper.fm](https://www.reaper.fm)

## Acknowledgments

- [Reaper DAW](https://www.reaper.fm) by Cockos
- [Wine](https://www.winehq.org) compatibility layer
- [noVNC](https://novnc.com) for HTML5 VNC client
- [NVIDIA Container Toolkit](https://github.com/NVIDIA/nvidia-container-toolkit)
