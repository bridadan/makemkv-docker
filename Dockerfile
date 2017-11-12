FROM buildpack-deps:xenial

WORKDIR /usr/src/makemkv

# Install build prereqs
RUN apt-get update
RUN apt-get install -y build-essential pkg-config libc6-dev libssl-dev libexpat1-dev libavcodec-dev libgl1-mesa-dev libqt4-dev less eject

# Get makemkv version
RUN echo $(curl --silent 'http://www.makemkv.com/forum2/viewtopic.php?f=3&t=224' | grep MakeMKV.*for.Linux.is | head -n 1 | sed -e 's/.*MakeMKV //g' -e 's/ .*//g') > makemkv_version.txt

# Download makemkv and ffmpeg sources
RUN curl -o ffmpeg.tar.bz2 https://ffmpeg.org/releases/ffmpeg-2.8.tar.bz2
RUN curl -o makemkv-bin.tar.gz http://www.makemkv.com/download/makemkv-bin-$(cat makemkv_version.txt).tar.gz
RUN curl -o makemkv-oss.tar.gz http://www.makemkv.com/download/makemkv-oss-$(cat makemkv_version.txt).tar.gz

# Uncompress makemkv and ffmpeg sources
RUN tar -xjf ffmpeg.tar.bz2; mv ffmpeg-2.8 ffmpeg
RUN tar -xzf makemkv-bin.tar.gz; mv makemkv-bin-$(cat makemkv_version.txt) makemkv-bin
RUN tar -xzf makemkv-oss.tar.gz; mv makemkv-oss-$(cat makemkv_version.txt) makemkv-oss

# Get CPU core count for parallel build
RUN grep -c ^processor /proc/cpuinfo > cpu_count.txt

# Build ffmpeg
RUN cd ffmpeg; ./configure --prefix=/tmp/ffmpeg --enable-static --disable-shared --enable-pic --disable-yasm
RUN cd ffmpeg; make -j $(cat ../cpu_count.txt) install

# Build makemkv
# Sources first
RUN cd makemkv-oss; PKG_CONFIG_PATH=/tmp/ffmpeg/lib/pkgconfig ./configure
RUN cd makemkv-oss; make -j $(cat ../cpu_count.txt)
RUN cd makemkv-oss; make install

# Binaries last
RUN cd makemkv-bin; echo yes | make -j $(cat ../cpu_count.txt)
RUN cd makemkv-bin; make install

# Cleanup ffmpeg
RUN rm -rf /tmp/ffmpeg

# Copy rip script
COPY rip.sh .
