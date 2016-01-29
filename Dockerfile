FROM zoncoen/plagger

RUN cpanm Redis

ENTRYPOINT ["plagger"]
