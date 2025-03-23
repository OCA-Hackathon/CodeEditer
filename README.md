### setup.shで実行
chmod +x setup.sh
./setup.sh

### コンテナを停止
docker-compose down

### キャッシュを使わずに再ビルド
docker-compose build --no-cache

### コンテナを起動
docker-compose up -d

### コンテナに接続
docker-compose exec code-server bash
