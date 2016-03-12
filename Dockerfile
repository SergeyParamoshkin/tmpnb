FROM centos:6.6

RUN yum update -y
RUN yum install -y epel-release
RUN yum groupinstall -y 'Development tools'
RUN yum install -y python-devel openssl-devel python-pip wget tar libcurl.x86_64 libcurl-devel.x86_64
RUN pip install --upgrade pip

#WORKDIR /usr/local/src
#RUN wget https://www.python.org/ftp/python/3.5.1/Python-3.5.1.tgz
#RUN tar -xvf Python-3.5.1.tgz
#WORKDIR /usr/local/src/Python-3.5.1
#RUN ./configure
#RUN make
#RUN make install
#RUN rm -rf /usr/local/src/Python-3.5.1*



ENV PYTHON_VERSION 3.5.1

# if this is called "PIP_VERSION", pip explodes with "ValueError: invalid truth value '<VERSION>'"
ENV PYTHON_PIP_VERSION 7.1.2

RUN set -x
RUN mkdir -p /usr/src/python
RUN curl -SL "https://www.python.org/ftp/python/${PYTHON_VERSION%%[a-z]*}/Python-$PYTHON_VERSION.tar.xz" -o python.tar.xz
#RUN curl -SL "https://www.python.org/ftp/python/${PYTHON_VERSION%%[a-z]*}/Python-$PYTHON_VERSION.tar.xz.asc" -o python.tar.xz.asc
#RUN gpg --verify python.tar.xz.asc
RUN tar -xJC /usr/src/python --strip-components=1 -f python.tar.xz
RUN rm python.tar.xz*
WORKDIR /usr/src/python
RUN ./configure
RUN make -j$(nproc)
RUN make altinstall
RUN ldconfig
RUN pip3.5 install --no-cache-dir --upgrade --ignore-installed pip==$PYTHON_PIP_VERSION
#RUN find /usr/local ( -type d -a -name test -o -name tests ) -o ( -type f -a -name '*.pyc' -o -name '*.pyo' ) -exec rm -rf '{}'
RUN rm -rf /usr/src/python

# make some useful symlinks that are expected to exist
WORKDIR /usr/local/bin
RUN ln -s easy_install-3.5 easy_install3
RUN ln -s idle3.5 idle3
RUN ln -s pydoc3.5 pydoc3
RUN ln -s python3.5 python3
RUN ln -s python-config3.5 python-config3



RUN mkdir -p /opt/tmpnb


WORKDIR /opt/tmpnb/

# Copy the requirements.txt in by itself first to avoid docker cache busting
# any time any file in the project changes
COPY requirements.txt /opt/tmpnb/requirements.txt
RUN pip3.5 install --upgrade pip
RUN pip3.5 install -r requirements.txt

# Now copy in everything else
COPY . /opt/tmpnb/

ENV DOCKER_HOST unix://docker.sock

CMD python3 orchestrate.py --image='serg3091/minimal-notebook'
