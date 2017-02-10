
#
# Run Apt-Get Update & Upgrade 
#
function apt_get_update_upgrade {		
	sudo apt-get update
	sudo apt-get upgrade
	commit_changes "Apt-get update and upgrade"
}

#
# Setup the default directories for PressBoxx
#
function setup_default_directories {
	mkdir ~/App 
	mkdir ~/App/www 
	mkdir ~/App/log
	mkdir ~/Projects
	mkdir ~/Config
	sudo chown -R "$BOXX_USER":www-data ~/App
	chownsudo  -R "$BOXX_USER":www-data ~/Projects
	echo Hello PressBoxx User! > ~/App/www/index.html	
	commit_changes "Setup default directories"
}

#
# Install and configure Nginx
#
function setup_utilities {		
	sudo apt-get -y install expect
	commit_changes "Utilities installed."
}

#
# Install and configure SSHFS
#
function setup_sshfs {		
    sudo apt-get -y install sshfs
	sudo sed -i 's/#user_allow_other/user_allow_other/' /etc/fuse.conf
	sudo cp "${BOXX_INSTALL_FILES_DIR}/mount-host" "${BOXX_COMMAND_ROOT}"
	sudo chmod +x "${BOXX_COMMAND_ROOT}/mount-host"
	/bin/sh "${BOXX_COMMAND_ROOT}/mount-host"

	sudo systemctl start mysql
	sudo systemctl status mysql
}

#
# Install and configure MySQL
#
function setup_mysql {		

	sudo apt update
	sudo apt upgrade
	sudo apt -y install mysql-server mysql-client

    MYSQL_CONF="/etc/mysql/mysql.conf.d/mysqld.cnf"
    sudo sed -i 's#bind-address\s*=\s*127.0.0.1#bind-address = 0.0.0.0#' $MYSQL_CONF
    sudo sed -i 's/# Instead of skip-networking the default is now to listen only on//' $MYSQL_CONF
    sudo sed -i 's#localhost which is more compatible and is not less secure.#Listen on any IP address to make remote access easy#' $MYSQL_CONF

	mysql -u root -pboxx < "${BOXX_INSTALL_FILES_DIR}/initial-setup.sql"

	sudo systemctl stop mysql

	sudo rsync -av /var/lib/mysql/ "${BOXX_DATA_DIR}"

	USER_ID=$(id -u mysql)
	GROUP_ID=$(id -g mysql)
	RAM_DISK="tmpfs /var/lib/mysql tmpfs rw,nosuid,nodev,uid=${USER_ID},gid=${GROUP_ID},size=1G 0 0"
	sudo sed -i -e "\$a${RAM_DISK}" /etc/fstab

	sudo cp "${BOXX_INSTALL_FILES_DIR}/boxx.service" /etc/systemd/system/boxx.service
	sudo chmod +x "${BOXX_CONFIG_DIR}/boxx.sh"

	commit_changes "Mysql installed."

}

#
# Install and configure PHP 7.0
#
function setup_php70 {		

	sudo apt-get update
	sudo apt-get -y upgrade

	sudo apt-get -y install php7.0-common 
	sudo apt-get -y install php7.0-fpm 
	sudo apt-get -y install php7.0-mysql 
	sudo apt-get -y install php7.0-gd 
	sudo apt-get -y install php7.0-json  
	sudo apt-get -y install php7.0-cli  
	sudo apt-get -y install php7.0-curl
	sudo apt-get -y install php7.0-bcmath
	sudo apt-get -y install php7.0-intl
	sudo apt-get -y install php7.0-mbstring
	sudo apt-get -y install php7.0-mcrypt
	sudo apt-get -y install php7.0-pspell
	sudo apt-get -y install php7.0-xml
	sudo apt-get -y install php7.0-zip
	sudo apt-get -y install php-xdebug

	sudo sed -i 's#;cgi.fix_pathinfo=1#cgi.fix_pathinfo=0#' /etc/php/7.0/fpm/php.ini

	sudo systemctl restart php7.0-fpm
	sudo systemctl status php7.0-fpm
	
	commit_changes "PHP 7.0 installed."
}

#
# Install and configure Nginx
#
function setup_nginx {		
	sudo apt-get -y install -y nginx
	sudo cp "${BOXX_INSTALL_FILES_DIR}/nginx/default" /etc/nginx/sites-available/default
	sudo cp "${BOXX_INSTALL_FILES_DIR}/nginx/example.dev" /etc/nginx/sites-available/example.dev
	sudo ln -s /etc/nginx/sites-available/example.dev /etc/nginx/sites-enabled/example.dev

	name="server_names_hash_bucket_size"
	sudo sed -i "s/# ${name}/${name}/" /etc/nginx/nginx.conf
	
	sudo sed -ir '/sendfile on;/i \\tfastcgi_read_timeout 99999;' /etc/nginx/nginx.conf

	sudo systemctl start nginx
	sudo systemctl status nginx	
	
	commit_changes "Nginx installed."
}


function setup_auto_login {		
	#
	# Update /etc/inittab
	# See https://docs.oracle.com/cd/E19683-01/806-4073/6jd67r96e/index.html
	#
	sudo echo "1:2345:respawn:/bin/login -f boxx tty1 </dev/tty1 >/dev/tty1 2>&1" > /etc/inittab
}

function setup_hostname {		
	#
	# Replace /etc/hostname
	#
	sudo cp "${BOXX_INSTALL_FILES_DIR}/hostname" /etc/hostname

	#
	# Update /etc/hosts
	#
	sudo sed -i 's/amlogic-s905x/$BOXX_HOSTNAME $BOXX_HOSTNAME.local/' /etc/hosts
}

function commit_changes {		
	cd /	
	sudo git add .
	sudo git commit -m "$1"
}

function setup_version_control {		
	cd /lost+found
	sudo rm -rf .
	cd /	
	sudo cp "${BOXX_INSTALL_FILES_DIR}/.gitignore" /.gitignore
	sudo git config --global user.email "team@pressboxx.io"
	sudo git config --global user.name "PressBoxx Team"
	sudo git init
	commit_changes "Initial commit after Ubuntu 16.04 LTS install"
}

function setup_boxx_user {		

	#
	# Set "boxx" user
	#
	sudo nmtui
}

#
# See: https://docs.getchip.com/chip.html#zero-configuration-networking
#
function setup_zero_config_networking {		

	#
	# Install Zero Configuration networking
	#
	sudo apt-get -y install avahi-daemon

	#
	# Copy over configuration file
	#
	sudo mv "${BOXX_INSTALL_FILES_DIR}/afpd.service" /etc/avahi/services/afpd.service

	#
	# Restart to 
	#
	sudo /etc/init.d/avahi-daemon restart

	#
	# Need to reboot
	#
	sudo reboot now 

}

#
# Delete cruft left around when opening SD cards on Mac OS
#
function clean_macos_files {		
	sudo rm -rf .fseventsd/
	sudo rm -rf .Trashes/
	sudo chmod 777 ._.Trashes
	sudo rm -f ._.Trashes
}
