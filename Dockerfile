FROM nvidia/cuda:12.1.0-cudnn8-devel-ubuntu20.04

ARG PIPENV_PYTHON_VERSION

# 必要なライブラリをインストール（追加はお好みで）
ENV DEBIAN_FRONTEND=noninteractive
ENV TZ=Asia/Tokyo
RUN apt update \
  && apt install -y software-properties-common \ 
  && add-apt-repository ppa:deadsnakes/ppa \
  && apt update \
  && apt install -y vim sudo zip git curl libopencv-dev \
                    python${PIPENV_PYTHON_VERSION} \
                    python${PIPENV_PYTHON_VERSION}-dev \
                    python${PIPENV_PYTHON_VERSION}-distutils \
  && rm /usr/bin/python3 \
  && ln -s /usr/bin/python${PIPENV_PYTHON_VERSION} /usr/bin/python3 \
  && ln -s /usr/bin/python3 /usr/bin/python \
  && curl -sS https://bootstrap.pypa.io/get-pip.py | python3 \
  && apt -y autoremove \
  && apt -y clean \
  && apt -y autoclean \
  && rm -rf /var/lib/apt/lists/*

# ユーザの追加と設定
ENV USER_NAME=user
RUN adduser --disabled-password --gecos '' $USER_NAME \
  && adduser $USER_NAME sudo \
  && echo '%sudo ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers
COPY entrypoint.sh /home/$USER_NAME

# CUDAのパスを設定
ENV CUDA_ROOT /usr/local/cuda
ENV PATH $PATH:$CUDA_ROOT/bin
ENV LD_LIBRARY_PATH $LD_LIBRARY_PATH:$CUDA_ROOT/lib64:$CUDA_ROOT/lib:/usr/local/nvidia/lib64:/usr/local/nvidia/lib
ENV LIBRARY_PATH /usr/local/nvidia/lib64:/usr/local/nvidia/lib:/usr/local/cuda/lib64/stubs:/usr/local/cuda/lib64:/usr/local/cuda/lib$LIBRARY_PATH

USER $USER_NAME
WORKDIR /home/$USER_NAME

# Pythonの環境構築
RUN git clone https://github.com/LiheYoung/Depth-Anything \
  && cd Depth-Anything \
  && pip install -r requirements.txt

EXPOSE 7860
ENV GRADIO_SERVER_NAME="0.0.0.0"
