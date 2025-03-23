# マルチアーキテクチャ対応ビルドステージ
FROM golang:1.20 AS gopls-builder

# goplsをインストール
RUN go install golang.org/x/tools/gopls@v0.14.2

# 最終ステージ
FROM codercom/code-server:latest

USER root

# アーキテクチャ検出（ARM/x86互換）
RUN apt-get update && apt-get install -y \
    wget \
    git \
    curl \
    && rm -rf /var/lib/apt/lists/*

# アーキテクチャに応じたGoのインストール
RUN arch=$(dpkg --print-architecture) && \
    case "${arch}" in \
        "arm64") \
            curl -Lo go.tar.gz https://golang.org/dl/go1.20.4.linux-arm64.tar.gz ;; \
        *) \
            curl -Lo go.tar.gz https://golang.org/dl/go1.20.4.linux-amd64.tar.gz ;; \
    esac && \
    tar -C /usr/local -xzf go.tar.gz && \
    rm go.tar.gz

# 環境変数の設定
ENV PATH=/usr/local/go/bin:$PATH
ENV GOPATH=/home/coder/go
ENV PATH=$GOPATH/bin:$PATH

# rootユーザーの.bashrcに環境変数を追加
RUN echo 'export PATH=/usr/local/go/bin:$PATH' >> ~/.bashrc && \
    echo 'export GOPATH=/home/coder/go' >> ~/.bashrc && \
    echo 'export PATH=$GOPATH/bin:$PATH' >> ~/.bashrc

# coderユーザーの.bashrcにも環境変数を追加
RUN echo 'export PATH=/usr/local/go/bin:$PATH' >> /home/coder/.bashrc && \
    echo 'export GOPATH=/home/coder/go' >> /home/coder/.bashrc && \
    echo 'export PATH=$GOPATH/bin:$PATH' >> /home/coder/.bashrc && \
    mkdir -p /home/coder/go && \
    chown -R coder:coder /home/coder/go

# ビルドステージからgoplsバイナリをコピー
COPY --from=gopls-builder /go/bin/gopls /usr/local/bin/

# Go拡張機能をプリインストール
RUN code-server --install-extension golang.go

# ユーザーをcoderに戻す
USER coder

# 作業ディレクトリの設定
WORKDIR /home/coder/project

# ポート8080を公開
EXPOSE 8080

# code-serverの起動
CMD ["code-server", "--bind-addr", "0.0.0.0:8080", "--auth", "none", "."]