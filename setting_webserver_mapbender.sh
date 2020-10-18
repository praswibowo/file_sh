# Update
sudo apt-get update -y 
sudo apt-get upgrade -y 
sudo apt install -y software-properties-common unzip gzip wget

# Install Firewall
echo "Install Firewall"
sudo apt-get install -y firewalld

sudo systemctl enable firewalld
sudo systemctl start firewalld
sudo firewall-cmd --permanent --zone=public --add-port=8080/tcp
sudo firewall-cmd --permanent --zone=public --add-port=80/tcp
sudo firewall-cmd --permanent --zone=public --add-port=5432/tcp
sudo firewall-cmd --permanent --zone=public --add-port=8000/tcp
sudo firewall-cmd --reload

# Install Postgres 9.6
echo "Install Postgres 9.6"
# Create the file repository configuration:
sudo sh -c 'echo "deb http://apt.postgresql.org/pub/repos/apt $(lsb_release -cs)-pgdg main" > /etc/apt/sources.list.d/pgdg.list'

# Import the repository signing key:
wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | sudo apt-key add -

# Update the package lists:
sudo apt-get update -y 

# Install the latest version of PostgreSQL.
# If you want a specific version, use 'postgresql-12' or similar instead of 'postgresql':
sudo apt install -y postgresql-9.6 postgresql-contrib-9.6 postgresql-9.6-postgis-3-scripts

sudo sed -ie "s/#listen_addresses = 'localhost'/listen_addresses = '*'/g" /etc/postgresql/9.6/main/postgresql.conf
sudo sed -ie "s/#port = 5432/port = 5432/g" /etc/postgresql/9.6/main/postgresql.conf
sudo sed -ie "s/max_connections = 100/max_connections = 1000/g" /etc/postgresql/9.6/main/postgresql.conf

sudo sed -ie "s/local   all             all                                     peer/local   all             all                                     ident/g" /etc/postgresql/9.6/main/pg_hba.conf
sudo sed -ie "s/host    all             all             127.0.0.1\/32            ident/host    all             all             127.0.0.1\/32            md5/g" /etc/postgresql/9.6/main/pg_hba.conf
sudo sed -ie "/host    all             all             127.0.0.1\/32            md5/ i host    all             all             0.0.0.0\/0        md5" /etc/postgresql/9.6/main/pg_hba.conf

sudo systemctl enable postgresql
sudo systemctl start postgresql

echo "Install PGAdmin4"
sudo apt install pgadmin4 pgadmin4-apache2

echo "username : postgres@jarkom.net"
echo "password : postgres"

echo "Change Password Postgres 9.6"

sudo sed -ie "s/local   all             postgres                                peer/local   all             postgres                                trust/g" /etc/postgresql/9.6/main/pg_hba.conf

sudo systemctl reload postgresql

sudo -u postgres psql -U postgres -d postgres -c "alter user postgres with password 'postgres';"

echo "Change Password Is Done"

sudo sed -ie "s/local   all             postgres                                trust/local   all             postgres                                md5/g" /etc/postgresql/9.6/main/pg_hba.conf

sudo systemctl reload postgresql

# Install Apache 2 - Tomcat 8.5.59
echo "Install Apache 2 - Tomcat 8.5.59"
sudo apt-get install -y apache2 default-jdk
cd /tmp

wget https://www-us.apache.org/dist/tomcat/tomcat-8/v8.5.59/bin/apache-tomcat-8.5.59.tar.gz

sudo useradd -m -U -d /opt/tomcat -s /bin/false tomcat

sudo mkdir /opt/tomcat
sudo tar xzvf apache-tomcat-8.5.59.tar.gz -C /opt/tomcat --strip-components=1

sudo chown -R tomcat: /opt/tomcat
sudo sh -c 'chmod +x /opt/tomcat/bin/*.sh'

wget https://raw.githubusercontent.com/praswibowo/file_sh/master/Webserver%20Ubuntu%2018.04/tomcat.service
sudo mv tomcat.service /etc/systemd/system/tomcat.service

sudo update-java-alternatives -l
sudo systemctl daemon-reload
sudo systemctl start tomcat

sudo systemctl enable tomcat
sudo systemctl enable apache2
sudo systemctl start tomcat
sudo systemctl start apache2

# Install Geoserver 2.18.0
echo "Install Geoserver 2.18.0"
sudo apt-get update -y 

cd /tmp

wget https://nchc.dl.sourceforge.net/project/geoserver/GeoServer/2.18.0/geoserver-2.18.0-war.zip

unzip geoserver-2.18.0-war.zip -d geoserver  
sudo cp geoserver/geoserver.war /opt/tomcat/webapps/geoserver.war

sudo systemctl restart tomcat
sudo systemctl restart apache2

# Install Mapbender
echo "Install Mapbender"
sudo apt-get update	-y 

cd /tmp

sudo add-apt-repository ppa:ondrej/php -y

sudo apt-get install -y php7.1 php7.1-pgsql libapache2-mod-php7.1 php7.1-common php7.1-ldap php7.1-gd php7.1-mysql php7.1-fpm php7.1-mcrypt php7.1-opcache php7.1-curl php7.1-cli php7.1-xml php7.1-sqlite3 php7.1-intl openssl php7.1-zip php7.1-mbstring php7.1-bz2 php7.1-xmlrpc php7.1-soap php7.1-bcmath php7.1-json php-pear

sudo a2enmod proxy_fcgi setenvif
sudo a2enconf php7.1-fpm
sudo systemctl restart apache2

wget https://mapbender.org/builds/mapbender-starter-current.tar.gz -O /var/www/mapbender-starter-current.tar.gz
tar -zxf /var/www/mapbender-starter-current.tar.gz -C /var/www
mv $(ls -d /var/www/*/ | grep mapbender) /var/www/mapbender/

wget https://raw.githubusercontent.com/praswibowo/file_sh/master/Webserver%20Ubuntu%2018.04/mapbender.conf
sudo mv mapbender.conf /etc/apache2/sites-available/mapbender.conf

sudo a2ensite mapbender.conf
sudo a2enmod rewrite
sudo service apache2 reload

echo "Install Mapbender chmod/chown"
sudo chown -R www-data:www-data /var/www/mapbender/app/logs
sudo chown -R www-data:www-data /var/www/mapbender/app/cache
sudo chown -R www-data:www-data /var/www/mapbender/web/uploads

sudo chmod -R ug+w /var/www/mapbender/app/logs
sudo chmod -R ug+w /var/www/mapbender/app/cache
sudo chmod -R ug+w /var/www/mapbender/web/uploads

sudo chmod -R ug+w /var/www/mapbender/app/db/demo.sqlite

echo "Checking Mapbender"
cd /var/www/mapbender/
sudo app/console mapbender:config:check

echo "Install database Mapbender"

sudo sed -ie "s/database_driver:   pdo_sqlite/database_driver:   pdo_pgsql/g" /var/www/mapbender/app/config/parameters.yml
sudo sed -ie "s/database_host:     ~/database_host:     localhost/g" /var/www/mapbender/app/config/parameters.yml
sudo sed -ie "s/database_port:     ~/database_port:     5432/g" /var/www/mapbender/app/config/parameters.yml
sudo sed -ie "s/database_name:     ~/database_name:     mapbender/g" /var/www/mapbender/app/config/parameters.yml
sudo sed -ie "s/database_path:     %kernel.root_dir%\/db\/demo.sqlite/database_path:     ~/g" /var/www/mapbender/app/config/parameters.yml
sudo sed -ie "s/database_user:     ~/database_user:     postgres/g" /var/www/mapbender/app/config/parameters.yml
sudo sed -ie "s/database_password: ~/database_password: postgres/g" /var/www/mapbender/app/config/parameters.yml

echo "Install App Console Mapbender"

sudo app/console doctrine:database:create
sudo app/console doctrine:schema:create
sudo app/console mapbender:database:init -v
sudo app/console doctrine:fixtures:load --fixtures=./mapbender/src/Mapbender/CoreBundle/DataFixtures/ORM/Application/ --append