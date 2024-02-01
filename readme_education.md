Чтение - изучение
=================

Решил почитать в связи с интересом к лямбда исчислению и верификации программ.

Подготовка окружения
--------------------

Установка `ruby` через `rbenv`, `rvm` не поддерживает новые версии, попытка поставить последнюю
доступную версию 2 ветки - ошибка компиляции. `rbenv` ставит все без проблем.

```bash
brew install rbenv
rbenv insatll 2.7.8
rbenv install 3.3.0
rbenv versions
rbenv global 2.7.8
```

После установки стали доступны в IDE после переоткрытия проекта.

```bash
# Обновление lockfile для Bundler 2
bundle update --bundler
bundle outdated
bundle update
```

rspec
-----

```bash
# run tests in the ./the_meaning_of_programs 
bundle exec rspec ./the_meaning_of_programs 
```

Тесты пришлось немного изменять для обровленных `gems`.
Много изменений в добавленной `javascript` версии.

Глава 2. Семантика программ
---------------------------

