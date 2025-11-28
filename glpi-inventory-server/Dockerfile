FROM php:8.2-fpm

# INTENT: Собирает единый образ Nginx + PHP-FPM с предустановленным GLPI.
# RESPONSIBILITIES: Установка системных пакетов, PHP-расширений и копирование конфигов.
# SIDE_EFFECTS: Модифицирует root-файловую систему образа, выставляет права на исходники.

# PATTERN: Layered build - минимизируем количество RUN слоёв.
RUN apt-get update && apt-get install -y \
    nginx \
    libzip-dev \
    unzip \
    && docker-php-ext-install pdo_mysql zip

# INTENT: Копируем подготовленные исходники GLPI и конфигурацию веб-сервера.
COPY glpi /var/www/html/glpi
COPY nginx.conf /etc/nginx/conf.d/default.conf

# INTENT: Выставляем безопасные права доступа для веб-процесса.
RUN chown -R www-data:www-data /var/www/html/glpi \
    && chmod -R 755 /var/www/html/glpi

EXPOSE 80

# SIDE_EFFECTS: Запускает Nginx и PHP-FPM внутри контейнера.
CMD nginx && php-fpm
