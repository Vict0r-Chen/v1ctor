---
title: Linux中部署PaddleOCR API以http的方式发起预测请求
tags:
  - PaddleOCR
categories:
  - OCR
abbrlink: 3501988402
date: 2023-01-06 00:24:31
---

前不久由于要做一个截图识别文字的功能，但阿里/腾讯云收费太高，最终认为开源的 [PaddleOCR](https://github.com/PaddlePaddle/PaddleOCR) 最合适，虽然由于识别速度不够快，一张截图需要1~2s才能识别成功——且在不考虑并发的情况下（可能由于我是用的CPU的版本，并且机器配置不够高），最终放弃了使用`PaddleOCR`，不过至少输出了一篇blog，也没算白费时间😒

<!--more-->

之所以要写这篇blog，一是想在后续再次搭建环境时方便查找，二是官方教程对于纯新手来说的确不够详细，明明按教程一个命令一个命令的执行，还是有各种问题（甚至官方提供的脚本还有错误的拼写，需要手动去改正....)

急着洗澡睡觉，便直接把之前记录的内容直接贴出来了，若有遗漏之处，请邮件联系😉

### 创建Debian系统

请自行google...

### 更新apt

`sudo apt update && sudo apt upgrade`

### 安装Python环境

**此步骤可参照[PaddleOCR官方教程](https://github.com/PaddlePaddle/PaddleOCR/blob/release/2.6/doc/doc_ch/environment.md#13-linux)**

#### 安装`Anaconda`

``` bash
sudo apt-get install wget

mkdir PaddleOCR
mkdir PaddleOCR/Resource

cd PaddleOCR/Resource

wget https://mirrors.tuna.tsinghua.edu.cn/anaconda/archive/Anaconda3-2021.05-Linux-x86_64.sh

sh Anaconda3-2021.05-Linux-x86_64.sh #接着一直按回车，最终输入yes回车

# 输入安装路径，回车
/home/lighthouse/anaconda3
# 提示是否执行`conda init`时按回车即可
conda info --envs # 验证是否能识别conda命令：
# 正常列出环境即没有问题
```

#### 安装Python

``` bash
# 在命令行输入以下命令，创建名为paddle_env的环境
# 此处为加速下载，使用清华源
conda create --name paddle_env python=3.8 --channel https://mirrors.tuna.tsinghua.edu.cn/anaconda/pkgs/free/

# 激活paddle_env环境
conda activate paddle_env
# 取消激活命令： conda deactivate
```

#### 安装Paddlehub

`pip3 install paddlehub==2.1.0 --upgrade -i https://mirror.baidu.com/pypi/simple`

#### 下载PaddleOCR项目

``` bash
apt install git #安装git
git clone https://github.com/PaddlePaddle/PaddleOCR.git /home/lighthouse/PaddleOCR #克隆仓库到目录 /home/lighthouse/PaddleOCR
```

#### 下载推理模型

``` bash
# 此处下载到Paddle的仓库根目录下： PaddleOCR/inference
mkdir /home/lighthouse/PaddleOCR/inference
cd /home/lighthouse/PaddleOCR/inference
```

1. [检测模型列表](https://github.com/PaddlePaddle/PaddleOCR/blob/release/2.6/doc/doc_ch/models_list.md#11-%E4%B8%AD%E6%96%87%E6%A3%80%E6%B5%8B%E6%A8%A1%E5%9E%8B)

``` bash
wget -P /home/lighthouse/PaddleOCR/inference https://paddleocr.bj.bcebos.com/PP-OCRv3/chinese/ch_PP-OCRv3_det_infer.tar
tar xvf ch_PP-OCRv3_det_infer.tar
```

2. [识别模型](https://github.com/PaddlePaddle/PaddleOCR/blob/release/2.6/doc/doc_ch/models_list.md#21-%E4%B8%AD%E6%96%87%E8%AF%86%E5%88%AB%E6%A8%A1%E5%9E%8B)

```bash
wget https://paddleocr.bj.bcebos.com/PP-OCRv3/chinese/ch_PP-OCRv3_rec_infer.tar
tar xvf ch_PP-OCRv3_rec_infer.tar
```
cfg.rec_model_dir = "./inference/ch_PP-OCRv3_rec_infer/"

3. [文本方向分类模型](https://github.com/PaddlePaddle/PaddleOCR/blob/release/2.6/doc/doc_ch/models_list.md#3-%E6%96%87%E6%9C%AC%E6%96%B9%E5%90%91%E5%88%86%E7%B1%BB%E6%A8%A1%E5%9E%8B)

```bash
wget https://paddleocr.bj.bcebos.com/dygraph_v2.0/ch/ch_ppocr_mobile_v2.0_cls_infer.tar
tar xvf ch_ppocr_mobile_v2.0_cls_infer.tar
```

### 安装服务模块（检测+识别串联服务模块）

```bash
cd /home/lighthouse/PaddleOCR

pip install paddlepaddle
pip install imgaug
pip install pyclipper
pip install lmdb

# 否则会提示ImportError: libGL.so.1: cannot open shared object file: No such file or directory
# https://stackoverflow.com/questions/55313610/importerror-libgl-so-1-cannot-open-shared-object-file-no-such-file-or-directo
apt-get install ffmpeg libsm6 libxext6  -y

hub install deploy/hubserving/ocr_system/
```

根据模型版本不一致，需要修改params.py中指定的文件夹名

```
vim /home/lighthouse/PaddleOCR/deploy/hubserving/ocr_system/params.py
```

### 启动

```bash
cd /home/lighthouse/PaddleOCR
hub serving start -m ocr_system
```