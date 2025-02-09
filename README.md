## Docker コンテナを使用した Laravel 環境構築手順

1. main ブランチからローカルにクローンする

2. .env.example をコピーして.env ファイルを作成する

3. `docker-compose build`を実行して、ビルドする

4. `docker exec -it laravel_app composer install --no-dev --optimize-autoloader`を実行して、Laravel 依存関係をインストールする

5. `docker-compose up -d`を実行して、docker-compose を立ち上げ

- 以下のように表示されれば OK

```
[+] Running 4/4
 ⠿ Container 20250112_laravel-mailpit-1  Started                                                                   0.6s
 ⠿ Container laravel_db                  Started                                                                   0.4s
 ⠿ Container laravel_app                 Started                                                                   0.9s
 ⠿ Container laravel_web                 Started                                                                   1.2s
```

6. `docker exec -it laravel_app php artisan migrate`実行して、マイグレーションを実行する

- 以下のように表示されれば OK

```
INFO  Preparing database.

  Creating migration table .............................................................................. 76.40ms DONE

   INFO  Running migrations.

  0001_01_01_000000_create_users_table ................................................................. 168.69ms DONE
  0001_01_01_000001_create_cache_table .................................................................. 44.52ms DONE
  0001_01_01_000002_create_jobs_table .................................................................. 172.29ms DONE
```

7. ブラウザで`http://localhost:8080`を入力して、Laravel 画面が開けることを確認する

- (もし付与されていない場合)`chmod -R 775 storage bootstrap/cache`実行して、キャッシュディレクトリに書き込み権限を付与する

8. ブラウザで`http://localhost:8025`を入力して、mailpit が開けることを確認する(メール送信はこちらで確認する)

## 1 から Docker-compose 準備する場合

以下に、参考として今回 1 から Docker-compose 関連ファイルを準備した際の手順を記載する

- プロジェクト用のフォルダ作成

例.mkdir 20250112_laravel

- docker desktop 立ち上げる

docker info で確認
docker desktop 立ち上げていないとエラーになる

- ルートが違う場合は以下を実行

`export DOCKER_HOST=unix:///var/run/docker.sock`

- 20250112_laravel 配下に docker-compose.yml 作成
  app、web、mysql、mailpit を設定

- 20250112_laravel 配下に nginx フォルダ作成して default.conf 作成(nginx 設定)

- 20250112_laravel 配下に php フォルダ作成して Dockerfile 作成(PHP 設定)

### docker 環境で Laravel プロジェクト作成

- 20250112_laravel フォルダで以下を実行する
  `docker run --rm -v $(pwd)/laravel:/app composer create-project --prefer-dist laravel/laravel .`

- .env を docker-compose.yml と同じ階層に移動する
  docker-compose.yml にて「- ./.env:/var/www/html/.env」を記載
  volumes: - ./laravel:/var/www/html - ./.env:/var/www/html/.env

### コンテナ内にアクセスして以下 2 つ実行

docker exec -it laravel_app bash 実行
/var/www/html に移動
pwd で確認

1. 暗号化キーを生成

- php artisan key:generate を実行

Application key set successfully.が出て
env で APP_KEY が設定されていることを確認する

2. マイグレーション実行

- php artisan migrate を実行

以下のように出れば OK
Preparing database.

Creating migration table ........................................... 17.40ms DONE

INFO Running migrations.

0001_01_01_000000_create_users_table ............................... 43.80ms DONE
0001_01_01_000001_create_cache_table ............................... 12.91ms DONE
0001_01_01_000002_create_jobs_table ................................ 40.13ms DONE

※エラー事例も参照する

### コンテナ起動

docker-compose up -d

### エラー事例

1. 他で 3306 ポート使用している場合
   Error response from daemon: driver failed programming external connectivity on endpoint laravel_db (xxxxxxxxx): Bind for 0.0.0.0:3306 failed: port is already allocated

- docker ps にて 3306 を使用している CONTAINER ID 確認

- docker stop xxxxx 実行して、3306 使用している他のポートを止める

※ホスト側を 3307 に変える手段も出てくるがうまくいかなそう

2. storage/laravel.log や config/cache.php に書き込み権限がない
   Chmod で権限変更が必要な可能性あり

※やったけど必要なかったかも

- ./laravel/init.sql:/docker-entrypoint-initdb.d/init.sql
  Init.sql に USE laravel;記載
