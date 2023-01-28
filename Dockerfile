FROM python:3.9-alpine3.13
LABEL maintainer="recipeappdeveloper.com"
# You don't want to buffer the output
# The output from Pythojn will be printed directly
# to the console which prevents any delays of messages
ENV PYTHONNUBUFFERED 1

COPY ./requirements.txt /tmp/requirements.txt
COPY ./requirements.dev.txt /tmp/requirements.dev.txt
COPY ./app /app
WORKDIR /app
EXPOSE 8000


# At line 20 we want to add a new user
# So that not to use the root user
# In order to reduce any risks of attacking because root user
# Has all the privileges to execute any type of commands.
ARG DEV=false
RUN python -m venv /py && \
    /py/bin/pip install --upgrade pip && \
    apk add --update --no-cache postgresql-client && \
    apk add --update --no-cache --virtual .tmp-build-deps \
        build-base postgresql-dev musl-dev && \
    /py/bin/pip install -r /tmp/requirements.txt && \
    if [ $DEV = "true" ]; \
        then /py/bin/pip install -r /tmp/requirements.dev.txt ; \
    fi && \
    rm -rf /tmp && \
    apk del .tmp-build-deps && \
    adduser \
    --disabled-password \
    --no-create-home \
    django-user
ENV PATH="/py/bin:$PATH"

USER django-user