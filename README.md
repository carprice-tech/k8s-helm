# k8s-helm

Дев-сервер для отдельно взятого разработчика представляет собой однонодовый kubernetes кластер в виде minikube на отдельной виртуальной машине.

Описание сервисов представляет собой шаблон helm, в который последовательно подставляются переменные шаблонизации (по возрастанию приоритета): дефолтные, переменные пользователя (сервера), переменные задачи. В итоге получается набор описаний kubernetes сущностей в виде набора yaml файлов, которые отправляются в api kubernetes cluster.

## Описание
Основная команда для деплоя сервисов: ./devserver/bin/deploy.sh

Формат команды:
```
./devserver/bin/deploy.sh <namespace> "<service1 service2>" <developer> <task> run
```
namespace=default

service1,service2 - сервисы, которые нужно обновить(установить).
Для каждого сервиса должна быть папка в ./Сharts. Вместо списка сервисов, можно указать ключевое слово all, тогда обновятся все сервисы.

developer - используется для настроек пользователя, ищет файлы в ./developers/users_ivanov.yaml

task - описание настроек задачи, ищет файл ./developers/tasks/TASK-877.yaml

Пример: 
```
./devserver/bin/deploy.sh default "exampleservice1 exampleservice2" ivanov TASK-877 run
```
Переменные, которые используются для деплоя сервиса можно найти в файлах ./Сharts/

Дефолтные настройки хранятся в файле ./dev/exampleservice1.yaml

Файлы задач (./devserver/tasks/<task>.yaml) должны повторять формат файла дефолтных настроек, но указывать нужно только изменяемые значения.

Например в подавляющем большинстве случаев, настроек базы в файле задачи быть недолжно.

Например:

./tasks/TASK-877.yaml
```
exampleservice:
  fpm_image: "registry.gitlab.com/exampleservice/fpm:TASK-877"
  nginx_image: "registry.gitlab.com/exampleservice/nginx:TASK-877"
  cron_image: "registry.gitlab.com/exampleservice/fpm-cron:TASK-877"
```

