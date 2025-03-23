#!/bin/bash

# 必要なディレクトリを作成
mkdir -p project config/code-server/User

# サンプルのGoファイルをプロジェクトディレクトリにコピー
cp main.go project/

# VSCode設定ファイルを配置
cp settings.json config/code-server/User/

# Docker Buildxを使用してマルチアーキテクチャ対応ビルド
echo "Dockerイメージをビルドして起動しています..."
docker-compose build --no-cache
docker-compose up -d

echo "セットアップが完了しました！"
echo "ブラウザで http://localhost:8080 にアクセスしてください。"