FROM python:3.9-alpine3.13
# Utilise l'image officielle Python 3.9 basée sur Alpine Linux 3.13 comme image de base.

LABEL maintainer="zachzic"
# Ajoute une étiquette pour indiquer le mainteneur de l'image.

ENV PYTHONUNBUFFERED=1
# Définit la variable d'environnement PYTHONUNBUFFERED à 1 pour désactiver le buffering de la sortie standard.
# Configure Python pour ne pas mettre en tampon les sorties, utile pour le logging en temps réel.

COPY ./requirements.txt /tmp/requirements.txt
# Copie le fichier requirements.txt dans le dossier temporaire de l'image.

COPY ./requirements.dev.txt /tmp/requirements.dev.txt
# Copie le fichier requirements-dev.txt dans le dossier temporaire de l'image.

COPY ./app /app
# Copie le dossier de l'application dans le dossier /app de l'image.

WORKDIR /app
# Définit le répertoire de travail par défaut à /app.

EXPOSE 8000
# Expose le port 8000 pour permettre à l'application d'écouter sur ce port.

ARG DEV=false
# Définit une variable d'argument "DEV" avec une valeur par défaut de "false".

RUN python -m venv /py && \ 
    # Crée un environnement virtuel Python dans le dossier /py.
    /py/bin/pip install --upgrade pip && \
    # Met à jour pip dans l'environnement virtuel.
    apk add --update --no-cache postgresql-client && \
    apk add --update --no-cache --virtual .tmp-build-deps \
        build-base postgresql-dev musl-dev &&\ 
    /py/bin/pip install -r /tmp/requirements.txt && \
    # Installe les dépendances listées dans requirements.txt dans l'environnement virtuel.
    if [ $DEV = "true" ]; \
        then /py/bin/pip install -r /tmp/requirements.dev.txt ; \
    fi && \
    # Si l'argument DEV est vrai, installe également les dépendances de développement.
    rm -rf /tmp &&\
    # Supprime le dossier temporaire pour réduire la taille de l'image.
    apk del .tmp-build-deps && \
    adduser \
        --disabled-password \
        --no-create-home \  
        django-user
    # Crée un utilisateur nommé "django-user" sans mot de passe ni répertoire personnel.

ENV PATH="/py/bin:$PATH" 
# Ajoute le dossier /py/bin à la variable d'environnement PATH pour utiliser les outils Python de l'environnement virtuel.

USER django-user 
# Définit "django-user" comme utilisateur par défaut pour exécuter les commandes suivantes.
