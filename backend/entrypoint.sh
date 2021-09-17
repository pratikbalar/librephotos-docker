#!/bin/bash -e
[[ "$DEBUG" ]] && set -x

curl_flag='--connect-timeout 10 --max-time 10 --retry 5 --retry-delay 10 --retry-max-time 180 -SL'
curl ${curl_flag} \
  https://github.com/LibrePhotos/librephotos-docker/releases/download/0.1/places365.tar.gz | \
  tar -zxC /data_models/ &
curl ${curl_flag} \
  https://github.com/LibrePhotos/librephotos-docker/releases/download/0.1/im2txt.tar.gz | \
  tar -zxC /data_models/ &
curl ${curl_flag}
  https://github.com/LibrePhotos/librephotos-docker/releases/download/0.1/clip-embeddings.tar.gz | \
  tar -zxC /data_models/ &
curl ${curl_flag} https://download.pytorch.org/models/resnet152-b121ed2d.pth \
  -o /root/.cache/torch/hub/checkpoints/resnet152-b121ed2d.pth &

export PYTHONFAULTHANDLER=1 PYTHONUNBUFFERED=TRUE

mkdir -p /logs
service statd start
python image_similarity/main.py 2>&1 | tee /logs/gunicorn_image_similarity.log &
python manage.py showmigrations | tee /logs/show_migrate.log
python manage.py migrate | tee /logs/command_migrate.log
python manage.py showmigrations | tee /logs/show_migrate.log
python manage.py build_similarity_index 2>&1 | tee /logs/command_build_similarity_index.log
python manage.py clear_cache
python manage.py createadmin -u $ADMIN_USERNAME $ADMIN_EMAIL 2>&1 | tee /logs/command_createadmin.log

echo "###############################"
echo "#                             #"
echo "#  Running backend server...  #"
echo "#                             #"
echo "###############################"

python manage.py rqworker default 2>&1 | tee /logs/rqworker.log &

if [[ "$DEBUG" == 1 ]]; then
    echo "Development backend starting"
    gunicorn --worker-class=gevent --timeout 36000 --reload --bind 0.0.0.0:8001 --log-level=info ownphotos.wsgi 2>&1 | tee /logs/gunicorn_django.log
else
    echo "Production backend starting"
    gunicorn --worker-class=gevent --timeout 3600 --bind 0.0.0.0:8001 --log-level=info ownphotos.wsgi 2>&1 | tee /logs/gunicorn_django.log
fi
