FROM gcc:11
RUN apt update
RUN apt install -y git curl sudo flex

WORKDIR /opt

RUN curl -s -L https://github.com/Kitware/CMake/releases/download/v3.21.4/cmake-3.21.4.tar.gz -o cmake-3.21.4.tar.gz
RUN tar -xzf cmake-3.21.4.tar.gz 
WORKDIR /opt/cmake-3.21.4
RUN ./bootstrap && make -j4 && make install
WORKDIR /opt
RUN rm -rf cmake-3.21.4 cmake-3.21.4.tar.gz

RUN git clone --depth 1 https://github.com/ninja-build/ninja.git -b v1.10.2
WORKDIR /opt/ninja
RUN cmake -Bbuild -H.
RUN cmake --build build
RUN cp build/ninja /usr/local/bin/ninja
WORKDIR /opt
RUN rm -rf ninja

RUN apt install -y bison

RUN git clone --depth 1 https://github.com/doxygen/doxygen.git -b Release_1_9_3
RUN mkdir /opt/doxygen/build
WORKDIR /opt/doxygen/build
RUN cmake -G "Ninja" ..
RUN cmake --build .
RUN cmake --build . --target install
WORKDIR /opt
RUN rm -rf doxygen

RUN apt install -y gcc-multilib libncurses6 libncurses-dev libedit2 libedit-dev liblzma5 liblzma-dev libxml2-dev graphviz swig4.0 

RUN git clone --depth 1 https://github.com/llvm/llvm-project.git -b llvmorg-14.0.1
WORKDIR /opt/llvm-project
RUN cmake -S llvm -B build -G "Ninja" -DCMAKE_BUILD_TYPE=Release \
    -DLLVM_TARGETS_TO_BUILD=X86 \
    -DLLVM_ENABLE_PROJECTS="llvm;lldb;clang;lld;clang-tools-extra;polly" \
    -DLLVM_ENABLE_RUNTIMES="libc;libcxx;libcxxabi;libunwind;compiler-rt" \
    -DLLVM_RUNTIME_TARGETS="x86_64-pc-linux-gnu" \
    -DLLVM_ENABLE_RTTI=ON
WORKDIR /opt/llvm-project/build
RUN cmake --build .
RUN cmake --build . --target install
RUN echo "#define _LIBCPP_HAS_NO_VENDOR_AVAILABILITY_ANNOTATIONS" > /usr/local/include/c++/v1/__config_site
RUN ln -s /usr/local/lib/clang/14.0.1/lib/x86_64-pc-linux-gnu /usr/local/lib/clang/14.0.1/lib/linux
WORKDIR /usr/local/lib/clang/14.0.1/lib/linux
RUN find . -name "libclang_rt*.a" | sed "p;s/\(.*\)\.a/\1-x86_64.a/" | xargs -d '\n' -n 2 ln -s
WORKDIR /opt
RUN rm -rf llvm-project

RUN echo "/usr/local/lib/x86_64-pc-linux-gnu" >> /etc/ld.so.conf.d/x86_64-linux-gnu.conf && ldconfig

ADD ToolChain.cmake /etc/ToolChain.cmake
ENV CMAKE_TOOLCHAIN_FILE=/etc/ToolChain.cmake

RUN useradd -m rvodden
RUN adduser rvodden sudo
RUN echo '%sudo ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers

USER rvodden
