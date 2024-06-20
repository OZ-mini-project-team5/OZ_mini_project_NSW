# FROM 베이스 이미지를 선택한다.
# Python 3.11이 설치된 Alpine Linux 3.19
# Alpine Linux는 경량화된 리눅스 배포판으로, 컨테이너 환경에 적합
#
FROM python:3.11-alpine3.19

# LABEL 명령어는 이미지에 메타데이터를 추가합니다. 여기서는 이미지의 유지 관리자를 "nohsungwoo"로 지정하고 있습니다.
LABEL maintainer="nohsungwoo"

# ENV 명령어는 이미지에서 사용할 환경 변수 값을 지정한다.
# 환경 변수 PYTHONUNBUFFERED를 1로 설정합니다. 
# 이는 Python이 표준 입출력 버퍼링을 비활성화하게 하여, 로그가 즉시 콘솔에 출력되게 합니다. 
# 이는 Docker 컨테이너에서 로그를 더 쉽게 볼 수 있게 합니다.
ENV PYTHONUNBUFFERED 1

# COPY는 build 명령어 실행 중 호스트 파일이나 폴더를 이미지에 가져온다.
# 로컬 파일 시스템의 requirements.txt 파일을 컨테이너의 /tmp/requirements.txt로 복사합니다. 
# 이 파일은 필요한 Python 패키지들을 명시합니다.
COPY ./requirements.txt /tmp/requirements.txt
COPY ./requirements.dev.txt /tmp/requirements.dev.txt
COPY ./app /app

# WORKDIR 작업 디렉토리를 지정한다. 해당 디렉토리가 없다면 새로 생성한다.
WORKDIR /app
# Dockerfile의 빌드로 생성된 ㅇㅇ
EXPOSE 8000

# build 시점에만 사용되는 변수
ARG DEV=false

# 새로운 레이어에서 명령어를 실행하고, 새로운 이미지를 생성한다.
RUN python -m venv /py && \ 
    /py/bin/pip install --upgrade pip && \
    /py/bin/pip install -r /tmp/requirements.txt && \
    if [ $DEV = "true" ]; \
        then /py/bin/pip install -r /tmp/requirements.dev.txt ; \
    fi && \
    rm -rf /tmp && \
    adduser \
        --disabled-password \
        --no-create-home \
        django-user

ENV PATH="/py/bin:$PATH"

# User를 설정한다. 
USER django-user