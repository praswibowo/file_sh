# Update
sudo apt-get update
sudo apt-get upgrade

# Install Firewall
echo "Install Firewall"
sudo apt-get install firewalld

sudo systemctl enable firewalld
sudo systemctl start firewalld
sudo firewall-cmd --permanent --zone=public --add-port=8080/tcp
sudo firewall-cmd --permanent --zone=public --add-port=80/tcp
sudo firewall-cmd --permanent --zone=public --add-port=5432/tcp
sudo firewall-cmd --permanent --zone=public --add-port=8000/tcp
sudo firewall-cmd --reload

# Install Postgres 12
echo "Install Postgres 12"
# Create the file repository configuration:
sudo sh -c 'echo "deb http://apt.postgresql.org/pub/repos/apt $(lsb_release -cs)-pgdg main" > /etc/apt/sources.list.d/pgdg.list'

# Import the repository signing key:
wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | sudo apt-key add -

# Update the package lists:
sudo apt-get update

# Install the latest version of PostgreSQL.
# If you want a specific version, use 'postgresql-12' or similar instead of 'postgresql':
sudo apt install postgresql-12 postgresql-contrib-12 postgresql-12-postgis-3-scripts

sudo sed -ie "s/#listen_addresses = 'localhost'/listen_addresses = '*'/g" /etc/postgresql/12/main/postgresql.conf
sudo sed -ie "s/#port = 5432/port = 5432/g" /etc/postgresql/12/main/postgresql.conf
sudo sed -ie "s/max_connections = 100/max_connections = 1000/g" /etc/postgresql/12/main/postgresql.conf

sudo sed -ie "s/local   all             all                                     peer/local   all             all                                     ident/g" /etc/postgresql/9.6/main/pg_hba.conf
sudo sed -ie "s/host    all             all             127.0.0.1\/32            ident/host    all             all             127.0.0.1\/32            md5/g" /etc/postgresql/9.6/main/pg_hba.conf
sudo sed -ie "/host    all             all             127.0.0.1\/32            md5/ i host    all             all             0.0.0.0\/0        md5" /etc/postgresql/9.6/main/pg_hba.conf

sudo systemctl enable postgresql
sudo systemctl start postgresql

# Install Apache 2 - Tomcat 8.5.59
echo "Install Apache 2 - Tomcat 8.5.59"
sudo apt-get install apache2 default-jdk
cd /tmp

curl -O https://www-us.apache.org/dist/tomcat/tomcat-8/v8.5.59/bin/apache-tomcat-8.5.59.tar.gz

sudo useradd -m -U -d /opt/tomcat -s /bin/false tomcat

sudo mkdir /opt/tomcat
sudo tar xzvf apache-tomcat-8*tar.gz -C /opt/tomcat --strip-components=1

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
sudo apt-get update	

cd /tmp

wget https://nchc.dl.sourceforge.net/project/geoserver/GeoServer/2.18.0/geoserver-2.18.0-war.zip

unzip geoserver-2.18.0-war.zip -d geoserver  
sudo cp geoserver/geoserver.war /opt/tomcat/webapps/geoserver.war

sudo systemctl restart tomcat
sudo systemctl restart apache2