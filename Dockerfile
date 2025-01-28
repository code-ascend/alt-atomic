FROM registry.altlinux.org/sisyphus/base:latest

# Копируем скрипты
COPY src /src

# Устанавливаем переменные окружения
ARG PKG_CONFIG_PATH="/usr/local/lib/pkgconfig:/usr/lib/pkgconfig"
ARG PATH="/root/.cargo/bin:${PATH}"

# Определяем тип сборки
ARG BUILD_TYPE="default"
ENV BUILD_TYPE=$BUILD_TYPE

WORKDIR /src
# Делаем один RUN запуск, потому что увеличние их числа добавляет ненужные слои и увеличивает обьем образа
RUN ./main.sh

WORKDIR /

# Помечаем образ как bootc совместимый
LABEL containers.bootc=1

# Оптимизация для Buildx
ARG BUILDKIT_INLINE_CACHE=1

CMD /sbin/init