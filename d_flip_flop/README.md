# Step 1: Compile
```
docker run --rm -v ${PWD}:/work -w /work verilator/verilator:latest --binary --trace design.sv testbench.sv --top test
```

# Step 2: Execute
```
docker run --rm -v ${PWD}:/work -w /work --entrypoint ./obj_dir/Vtest verilator/verilator:latest
```

# Step 3: Open the .vcd file inside the GTKWave
```
docker run -it --rm -e DISPLAY=host.docker.internal:0.0 -v ${PWD}:/home/gtkuser/workspace gtkwave-gui gtkwave /home/gtkuser/workspace/test.vcd
```

# Use Docker Compose to Compile and Execute
```
docker-compose run --rm verilator
```

# Use Docker Compose to View Simulation Results
```
docker-compose run --rm gtkwave
```