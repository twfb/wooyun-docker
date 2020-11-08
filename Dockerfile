FROM ubuntu:16.04

ENV MYSQL_PWD mysqlpass

ADD config/server-3.4.asc /tmp
ADD config/sources.list /etc/apt/sources.list

RUN apt-key add /tmp/server-3.4.asc
RUN apt-get -y update
RUN apt-get -y install software-properties-common
RUN add-apt-repository -y ppa:webupd8team/java
RUN echo "deb [ arch=amd64 ] http://repo.mongodb.org/apt/ubuntu trusty/mongodb-org/3.4 multiverse" | tee /etc/apt/sources.list.d/mongodb-org-3.4.list
RUN apt-get -y update
RUN echo "mysql-server mysql-server/root_password password $MYSQL_PWD" | debconf-set-selections
RUN echo "mysql-server mysql-server/root_password_again password $MYSQL_PWD" | debconf-set-selections
RUN apt-get install -y openjdk-8-jdk mongodb-org python python-pip apache2 mysql-server php libapache2-mod-php php-mysql
RUN pip install flask pymongo elasticsearch -i https://pypi.tuna.tsinghua.edu.cn/simple

CMD service mysql start \
&&  service apache2 start \
&&  "/var/www/wooyun/elasticsearch-2.3.4/bin/elasticsearch" -d -Des.insecure.allow.root=true \
&&  mongod --dbpath /var/www/wooyun/mongodb/data --fork --logpath /var/www/wooyun/mongodb/mongodb.log \
&&  /var/www/wooyun/wooyun_public/flask/app.py
