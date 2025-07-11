# verilator_gtkwave_learning

# Build
```
docker build -t ubuntu-desktop .
```

# Run
```
docker run -p 6080:6080 -p 6080:6080 ubuntu-desktop
```

# Stop container
```
docker stop ubuntu-desktop
```

# Remove container
```
docker rm ubuntu-desktop
```

# Run with more allocated resources
```
docker run -d --name ubuntu-desktop -p 5901:5901 -p 6080:6080 --cpus="4.0" --memory="8g" --memory-swap="12g" --shm-size="2g" ubuntu-desktop
```

# Run with more allocated resources and an attached volume
```
docker run -d --name ubuntu-desktop -p 5901:5901 -p 6080:6080 --cpus="4.0" --memory="8g" --memory-swap="12g" --shm-size="2g" -v ${PWD}:/home/developer/Desktop/systemverilog_learning ubuntu-desktop
```

# Build the GTKWave docker container
```
docker build -f Dockerfile.gtkwave -t gtkwave-gui .
```

# Run the GTKWave docker container
```
docker run -it --rm -e DISPLAY=host.docker.internal:0.0 -v ${PWD}:/home/gtkuser/workspace gtkwave-gui
```