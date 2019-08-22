#!/bin/bash
#set( $userId = "$aib.getParam("adminUserId")" )
#set( $email = "$aib.getParam("email")" )
#set( $password = "$aib.getParam("adminPassword")" )

pipenv run python manage.py migrate --run-syncdb
pipenv run python manage.py shell -c "from django.contrib.auth import get_user_model; User = get_user_model(); User.objects.create_superuser('${userId}', '${email}', '${password}')"
pipenv run python manage.py runserver 0.0.0.0:8000