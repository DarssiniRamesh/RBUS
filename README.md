# RBUS

RDK Bus (RBUS) is a lightweight, fast and efficient bus messaging system.
It allows interprocess communication (IPC) and remote procedure call (RPC)
between multiple processes running on a hardware device. It supports a data model,
which is a hierarchical tree of named objects with properties, events, and methods.

Repository root: This top-level RBUS directory is the project root. There is no nested RBUS/RBUS path. All examples assume running commands from this directory and use cmake -S . (source is the current directory).

## Quick Start: Configure, Build, Install, Test (from repository root)

These commands are the canonical steps to configure, build, install, and run unit tests from the repository root.

1) Configure:
```
cmake -S . -B build/rbus -DCMAKE_INSTALL_PREFIX="$PWD/install/usr" -DBUILD_FOR_DESKTOP=ON -DENABLE_UNIT_TESTING=ON -DCMAKE_BUILD_TYPE=Debug
```

2) Build and install:
```
cmake --build build/rbus --target install --parallel
```

3) Run unit tests directly (best-effort):
```
if [ -x build/rbus/unittests/rbus_gtest.bin ]; then build/rbus/unittests/rbus_gtest.bin || exit 1; fi
```

Alternatively, use the helper script which performs all the above steps without changing directories:
```
scripts/build_and_test.sh
```

Environment variables for the helper script:
- BUILD_DIR: relative path for the build directory (default: build/rbus)
- INSTALL_PREFIX: installation prefix (default: "$PWD/install/usr")
- BUILD_TYPE: build type (default: Debug)

Example:
```
BUILD_TYPE=Release scripts/build_and_test.sh
```

## Desktop Build (Linux) - Legacy Instructions

For historical context, some documentation uses environment variables to set an installation prefix:

```
export RBUS_ROOT=$PWD
export RBUS_INSTALL_DIR=${RBUS_ROOT}/install
mkdir -p "$RBUS_INSTALL_DIR"
cmake -S . -B build/rbus -DCMAKE_INSTALL_PREFIX="${RBUS_INSTALL_DIR}/usr" -DBUILD_FOR_DESKTOP=ON -DCMAKE_BUILD_TYPE=Debug
cmake --build build/rbus --target install --parallel
```

Note: Ensure you are at the repository root (this directory). Do not attempt to cd into RBUS/RBUS; that path does not exist in this repository layout.

## Run RBUS Apps (after install to local prefix)

Set up your environment (adjust paths if you used a different INSTALL_PREFIX):

```
export RBUS_INSTALL_DIR="$PWD/install"
export PATH="${RBUS_INSTALL_DIR}/usr/bin:${PATH}"
export LD_LIBRARY_PATH="${RBUS_INSTALL_DIR}/usr/lib:${LD_LIBRARY_PATH}"
```

### Start rtrouted

In one terminal, run rtrouted (must be running for RBUS apps to communicate):
```
rtrouted -f -l DEBUG
```

To restart later:
```
killall -9 rtrouted; rm -fr /tmp/rtroute*; rtrouted -f -l DEBUG
```

### Run a sample app

In a second terminal:
```
rbusSampleProvider
```

In a third terminal:
```
rbusSampleConsumer
```

Sample pairs include:
1. rbusSampleProvider / rbusSampleConsumer
2. rbusEventProvider / rbusEventConsumer
3. rbusGeneralEventProvider / rbusGeneralEventConsumer
4. rbusValueChangeProvider / rbusValueChangeConsumer
5. rbusMethodProvider / rbusMethodConsumer
6. rbusTableProvider / rbusTableConsumer

### Using rbuscli

In one terminal:
```
rbuscli -i
> reg prop A.B
```

In another terminal:
```
rbuscli -i
> set A.B string "hello"
> get A.B
> log events
> sub A.B
```

Back in the first terminal:
```
> set A.B string "hello again"
```

Use `help` in rbuscli for more commands, and `quit` to exit.

## Test Harness

Terminal 1:
```
rbusTestProvider
```

Terminal 2:
```
rbusTestConsumer -a
```

The run takes ~5–10 minutes. For detailed logs, rerun with `-l debug` for both provider and consumer.

## Valgrind Example

Provider:
```
valgrind --leak-check=full --show-leak-kinds=all rbusSampleProvider
```

Consumer:
```
valgrind --leak-check=full --show-leak-kinds=all rbusSampleConsumer
```

## Dependencies

Ensure required dependencies for your platform are installed (e.g., toolchain, cmake, g++, and external deps like rdk-logger).
Refer to cmake/ modules for specifics.

## License

See LICENSE for details.
