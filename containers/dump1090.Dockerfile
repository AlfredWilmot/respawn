FROM debian:bookworm-slim AS builder

# gather deps
RUN <<EOF
apt-get update
apt-get install -y build-essential debhelper librtlsdr-dev \
pkg-config libncurses5-dev libbladerf-dev git

git clone https://github.com/flightaware/dump1090.git

EOF

WORKDIR /dump1090
RUN make

FROM debian:bookworm-slim AS deploy
RUN apt-get update && apt-get install -y librtlsdr-dev libncurses5-dev libbladerf-dev
COPY --from=builder /dump1090/dump1090 .
ENTRYPOINT ["./dump1090"]
