FROM debian:11-slim AS builder

ARG TREE_SITTER_VERSION=0.26.10

RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y \
      build-essential \
      ca-certificates \
      clang \
      curl \
      git \
      libclang-dev \
      pkg-config \
      binutils && \
    rm -rf /var/lib/apt/lists/*

RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs \
    | sh -s -- -y --profile minimal

ENV PATH="/root/.cargo/bin:${PATH}"

RUN cargo install \
      --locked \
      --version "${TREE_SITTER_VERSION}" \
      tree-sitter-cli

RUN strip /root/.cargo/bin/tree-sitter && \
    /root/.cargo/bin/tree-sitter --version

FROM debian:11-slim

COPY --from=builder \
  /root/.cargo/bin/tree-sitter \
  /usr/local/bin/tree-sitter

ENTRYPOINT ["/usr/local/bin/tree-sitter"]
CMD ["--version"]
