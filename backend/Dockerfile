FROM reallibrephotos/librephotos-dependencies:dev

# install rust and a missing requirenment from pytorch
RUN apt install -y rustc libtinfo5
# actual project
ARG DEBUG
ARG TINI_VERSION v0.19.0
ADD https://github.com/krallin/tini/releases/download/${TINI_VERSION}/tini /tini
WORKDIR /code
RUN chmod +x /tini; \
  git clone --drone 1 https://github.com/LibrePhotos/librephotos .; \
  pip install -r requirements.txt; \
  [[ "$DEBUG" = 1 ]] && pip install -r requirements.dev.txt
EXPOSE 8001

COPY entrypoint.sh /entrypoint.sh

ENTRYPOINT ["/tini", "--"]
CMD ["/entrypoint.sh"]
