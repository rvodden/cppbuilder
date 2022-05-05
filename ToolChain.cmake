link_directories( /usr/local/lib/x86_64-pc-linux-gnu/   )
include_directories( /usr/local/include/c++/v1   )
set(CMAKE_CXX_COMPILER /usr/local/bin/clang++)
set(CMAKE_CXX_FLAGS_INIT "-stdlib=libc++")
set(CMAKE_EXE_LINKER_FLAGS_INIT "-fuse-ld=lld -L/usr/local/lib/x86_64-pc-linux-gnu/")
set(CMAKE_MODULE_LINKER_FLAGS_INIT "-fuse-ld=lld -L/usr/local/lib/x86_64-pc-linux-gnu/")
set(CMAKE_SHARED_LINKER_FLAGS_INIT "-fuse-ld=lld -L/usr/local/lib/x86_64-pc-linux-gnu/")

set(CMAKE_C_COMPILER /usr/local/bin/clang)
