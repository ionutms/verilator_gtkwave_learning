# Step 1: Compile
```
docker run --rm -v ${PWD}:/work -w /work verilator/verilator:latest --binary --trace design.sv testbench.sv --top test
```

# Step 2: Execute
```
docker run --rm -v ${PWD}:/work -w /work --entrypoint ./obj_dir/Vtest verilator/verilator:latest
```

# Use Docker Compose
```
docker-compose run --rm verilator-run
```