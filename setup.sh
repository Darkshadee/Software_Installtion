#!/bin/bash
#!/bin/sh

cra(){

    IFS='|' read user pw domi  < <( zenity --width=300  --height=190 --forms --title="Credentials" --text="Login Details"    --add-entry="Username"    --add-password="Password"    --add-entry="Domain" )

    dom=`echo $domi | awk '{print toupper($0)}'`
    us=$user

    if [[ $? -eq 1 ]]; then
            zenity --width=200 --height=25 --error \
            --text="Login Failed !!!"
            # cra
            exit;
    fi

}

rsrt(){
    timeout=30
    for (( i=0 ; i <= $timeout ; i++ )) do
        echo "# Restart in $[ $timeout - $i ]..."
        echo $[ 100 * $i / $timeout ]
        sleep 1
    done | zenity  --progress --title="Restart automatically..."  \
        --window-icon=warning --width=500 --auto-close

    if [ $? = 0 ] ; then
        /sbin/reboot
    else
        zenity --info --width=280 --height=100 --timeout 60  --title="Restart" --text "<b>Restart manually ...</b>"
    fi
}

ti(){

        timeout=10
        for (( i=0 ; i <= $timeout ; i++ )) do
        echo "# Restart in $[ $timeout - $i ] ..."
        echo $[ 100 * $i / $timeout ]
        sleep 1
        done
}

cl(){
    pkgs='curl'
	if ! dpkg -s $pkgs >/dev/null 2>&1; then
		apt install curl -y >/dev/null
    fi
}

mld(){

    apt-get install meld -y >/dev/null 2>&1
}

domainjoin(){

        cra
    (
        echo "5" ; sleep 3
        echo "# Creating tmp ... "
        cd /tmp
        echo "10" ; sleep 3
        echo "# Downloading Packages ..."
        wget https://github.com/Darkshadee/pbis-open/releases/download/9.1.0/pbis-open-9.1.0.551.linux.x86_64.deb.sh 2>&1 | sed -u 's/.* \([0-9]\+%\)\ \+\([0-9.]\+.\) \(.*\)/\1\n# Downloading at \2\/s, ETA \3/' | zenity --progress --width=500 --auto-close  --title="Domain Joining"
        echo "15" ; sleep 3
        echo "# Running Script ..."
        sh pbis-open-9.1.0.551.linux.x86_64.deb.sh >/dev/null 2>&1
        echo "20" ; sleep 3
        echo "# Pbis Running ..."
        # cd pbis-open-9.1.0.551.linux.x86_64.deb
        echo "30" ; sleep 3
        echo "# Permission Changing ..."
        # chmod +x pbis-open-9.1.0.551.linux.x86_64.deb/install.sh
        echo "50" ; sleep 3
        echo "# Running Script ..."
        # sh pbis-open-9.1.0.551.linux.x86_64.deb/install.sh  >/dev/null 2>&1
        echo "65" ; sleep 3
        echo "# Domain Joining ..."
        domainjoin-cli join --disable ssh $dom $us $pw
        echo "75" ; sleep 3
        echo "# Almost Done ..."
        #echo $us
        cd /
        echo "80" ; sleep 3
        echo "# Removing Packages ..."
        rm -rf /tmp/pbis-open-9.1.0.551.linux.x86_64.*
        echo "85" ; sleep 3
        echo "# Installing ssh ..."
        apt-get install ssh -y >/dev/null 2>&1
        echo "90" ; sleep 3
        echo "# Domain Joined Sucessfully ..."
        echo "95" ; sleep 3
        echo "# Rebooting system ..."
        echo "100" ; sleep 10
        rsrt
        ) |
        zenity --width=500 --progress \
        --title="Domain Joining" \
        --text="Domain Joining..." \
        --percentage=0 --auto-close

        if [[ $? == 1 ]]; then
            zenity --width=200 --error \
            --text="Installtion canceled."
        else

            (
            ti
            ) |
            zenity  --progress --title="Restart automatically..."  \
            --window-icon=warning --auto-close --width=400

            if [[ $? -eq 0 ]]; then
            # /sbin/reboot
            echo "Test"

            else
            zenity --width=200 --error \
            --text="Restart canceled."

            fi

        fi

}

domain(){

            ListType=`zenity --width=400 --height=200 --list --radiolist \
                --title 'Installaion'\
                --text 'Select Software to install:' \
                --column 'Select' \
                --column 'Actions' TRUE "Join" FALSE "Remove"`

            if [[ $? -eq 1 ]]; then

                # they pressed Cancel or closed the dialog window
                zenity --error --title="Declined" --width=200 \
                    --text="Installtion Canceled "
                exit 1

            elif [ $ListType == "Join" ]; then

                # they selected the short radio button
                    Flag="--Domain-Join"
                    domainjoin

            elif [ $ListType == "Remove" ]; then

                # they selected the short radio button
                    Flag="--Domain-Remove"


            else

                # they selected the long radio button
                Flag=""
            fi

}

php-comp(){
    (
        lst_ph=$(curl -s https://github.com/composer/composer/tags | grep "/composer/composer/releases/tag/" | grep "<a href=" | sed 's|.*/||' | sed 's/.$//' | sed 's/.$//' | sort -Vr)
        choices=()
        mode="true"
        for name in $lst_ph ; do
            choices=("${choices[@]}" "$mode" "$name")
            mode="false"
        done

        choice=`zenity --width=300 --height=380 \
            --list \
            --separator="$IFS" \
            --radiolist \
            --text="Select Versions:" \
            --column "Select" \
            --column "Versions" \
            "${choices[@]}"`
        IFS="$OLDIFS"
        #echo $choice
        url="https://github.com/composer/composer/releases/download/$choice/composer.phar"
        echo "25";
        echo "# Downloading php-composer ..." ; sleep 3
        wget $url -P /tmp/ 2>&1 | sed -u 's/.* \([0-9]\+%\)\ \+\([0-9.]\+.\) \(.*\)/\1\n# Downloading at \2\/s, ETA \3/' | zenity --progress --width=500 --auto-close  --title="Downloading Php-composer..."
        echo "70";
        echo "# Installing Php-composer ..." ; sleep 3
        mkdir /usr/local/bin/composer >/dev/null 2>&1
        echo "60";
        mv /tmp/composer.phar /usr/local/bin/composer/ >/dev/null 2>&1
        echo "70":
        #fusn=$(ls -t /home | awk 'NR==1 {print $1}')
        printf "alias composer='php /usr/local/bin/composer/composer.phar'" >> /etc/bash.bashrc
        echo "80";
        source /etc/bash.bashrc >/dev/null 2>&1
        echo "95";
        echo "# Installation Done ..." ;
        rm -rf /tmp/composer.phar >/dev/null 2>&1
        zenity --info --width=280 --height=100 --timeout 60  --title="PHP-Composer" --text "<b>PHP Composer has been installed !</b>"
    ) |
            zenity --width=500 --progress \
            --title="Installing PHP-Composer" \
            --text="Please wait ..." \
            --percentage=0 --auto-close

            if [[ $? -eq 1 ]]; then

                zenity --width=200 --error \
                --text="Installtion canceled."

            fi
}

php_comp_chk(){
	    file="/usr/bin/php"
       # file1="/usr/local/bin/node"

        if [[ ! -e "$file" ]]; then
        	zenity --width=200 --error \
                --text="<b>PHP is not installed!</b>"
        else
      		php-comp
      	fi
}


lan_las(){
    (
        echo "25";
        echo "# Getting Data from lando ..." ; sleep 3
        lan_lat=$(curl -s https://github.com/lando/lando/tags | grep "/lando/lando/releases/tag/v" | grep "<a href=" | sed 's|.*/||' | sed 's/.$//' | sed 's/.$//' | awk 'NR==1 {print $1}')

        selver=`echo "lando-$lan_lat.deb"`
        url="https://github.com/lando/lando/releases/download/$lan_lat/$selver"
        echo "50";
        echo "# Downloading Lando ..." ; sleep 3
        wget $url -P /tmp/ 2>&1 | sed -u 's/.* \([0-9]\+%\)\ \+\([0-9.]\+.\) \(.*\)/\1\n# Downloading at \2\/s, ETA \3/' | zenity --progress --width=500 --auto-close  --title="Downloading Lando..."
        echo "70";
        echo "# Installing Lando ..." ; sleep 3
        dpkg -i --ignore-depends=docker-ce /tmp/$selver > /dev/null 2>&1
        echo "95";
        echo "# Installation Done ..." ; sleep 3
        rm -rf /tmp/$selver
        LAN_VER=$(dpkg -s lando | grep "Version:" | awk '{print $2}')
        zenity --info --width=150 --height=100 --timeout 60 --title="Version Details" --text "<b>Lando Ver : </b> $LAN_VER"
    ) |
            zenity --width=500 --progress \
            --title="Installing Lando" \
            --text="Please Wait ..." \
            --percentage=0 --auto-close

            if [[ $? -eq 1 ]]; then

                zenity --width=200 --error \
                --text="Installtion canceled."

            fi

}

lan_spc(){
    (
        lst_l=$(curl -s https://github.com/lando/lando/tags | grep "/lando/lando/releases/tag/v" | grep "<a href=" | sed 's|.*/||' | sed 's/.$//' | sed 's/.$//' )

        choices=()
        mode="true"
        for name in $lst_l ; do
            choices=("${choices[@]}" "$mode" "$name")
            mode="false"
        done

        choice=`zenity --width=300 --height=380 \
            --list \
            --separator="$IFS" \
            --radiolist \
            --text="Select Versions:" \
            --column "Select" \
            --column "Versions" \
            "${choices[@]}"`
        IFS="$OLDIFS"

        selver=`echo "lando-$choice.deb"`
        url="https://github.com/lando/lando/releases/download/$choice/$selver"
        echo "50";
        echo "# Downloading Lando ..." ; sleep 3
        wget $url -P /tmp/ 2>&1 | sed -u 's/.* \([0-9]\+%\)\ \+\([0-9.]\+.\) \(.*\)/\1\n# Downloading at \2\/s, ETA \3/' | zenity --progress --width=500 --auto-close  --title="Downloading Lando..."
        echo "70";
        echo "# Installing Lando ..." ; sleep 3
        dpkg -i --ignore-depends=docker-ce /tmp/$selver > /dev/null 2>&1
        echo "95";
        echo "# Installation Done ..." ; sleep 3
        rm -rf /tmp/$selver
        LAN_VER=$(dpkg -s lando | grep "Version:" | awk '{print $2}')
        zenity --info --width=150 --height=100 --timeout 60 --title="Version Details" --text "<b>Lando Ver : </b> $LAN_VER"
    ) |
            zenity --width=500 --progress \
            --title="Installing Lando" \
            --text="Please Wait ..." \
            --percentage=0 --auto-close

            if [[ $? -eq 1 ]]; then

                zenity --width=200 --error \
                --text="Installtion canceled."

            fi

}

lan_rm(){
    (
    echo "30";
    echo "# Removing Lando ..." ; sleep 3
    dpkg -P lando  >/dev/null 2>&1
    echo "95";
    echo "# Removed Lando ..." ; sleep 3
    ) |
            zenity --width=500 --progress \
            --title="Removing Lando" \
            --text="Lando..." \
            --percentage=0 --auto-close

            if [[ $? -eq 1 ]]; then

                zenity --width=200 --error \
                --text="Installtion canceled."

            fi

}


lan_chk(){
    pkgs='lando'
	if  dpkg -s $pkgs >/dev/null 2>&1; then
		lan_rm
    fi
}


lan(){
        lan_chk
     ListType=`zenity --width=170 --height=170 --list --radiolist \
                --title 'Lando Installaion'\
                --text 'Select Version to install:' \
                --column 'Select' \
                --column 'Actions' TRUE "Latest" FALSE "Specific"`

            if [[ $? -eq 1 ]]; then

                # they pressed Cancel or closed the dialog window
                zenity --error --title="Declined" --width=200 \
                    --text="Installtion Canceled "
                exit 1

            elif [ $ListType == "Latest" ]; then

                # they selected the short radio button
                    Flag="--Lando-Latest"
                    lan_las

            elif [ $ListType == "Specific" ]; then

                # they selected the short radio button
                    Flag="--Lando-Specific"
                    lan_spc

            else

                # they selected the long radio button
                Flag=""
            fi
}


nj_rm(){
    (
    echo "30";
    echo "# Removing NodeJs ..." ; sleep 3
    apt-get purge --auto-remove nodejs -y  >/dev/null 2>&1
    echo "50";
    echo "# Removing Related File ..." ; sleep 3
    rm -rf /etc/apt/sources.list.d/nodesource.list
    echo "95";
    echo "# Removed NodeJs ..." ; sleep 3
    ) |
            zenity --width=500 --progress \
            --title="Removing NodeJs" \
            --text="NodeJs..." \
            --percentage=0 --auto-close

            if [[ $? -eq 1 ]]; then

                zenity --width=200 --error \
                --text="Installtion canceled."

            fi

}

npm_bichk(){
    (
        file="/usr/local/bin/npm"
        file1="/usr/local/bin/node"

        if [[ -e "$file" || -e $file1 ]]; then
            echo "30";
            echo "# Removing NodeJs ..." ; sleep 3
            rm -rf /usr/local/lib/node_modules &>/dev/null
            rm -rf /usr/local/share/man/man1/node* &>/dev/null
            rm -rf /usr/local/lib/dtrace/node.d &>/dev/null
            rm -rf ~/.npm &>/dev/null
            echo "50";
            echo "# Removing Related File ..." ; sleep 3
            rm -rf ~/.node-gyp &>/dev/null
            rm -rf /opt/local/bin/node &>/dev/null
            rm -rf opt/local/include/node &>/dev/null
            rm -rf /opt/local/lib/node_modules &>/dev/null
            echo "70";
            echo "# Removing Related File ..." ; sleep 3
            rm -rf /usr/local/lib/node* &>/dev/null
            rm -rf /usr/local/include/node* &>/dev/null
            rm -rf /usr/local/bin/node* &>/dev/null
            echo "95";
            echo "# Removed NodeJs ..." ; sleep 3
        fi
    ) |
            zenity --width=500 --progress \
            --title="Removing NodeJs" \
            --text="NodeJs..." \
            --percentage=0 --auto-close

            if [[ $? -eq 1 ]]; then

                zenity --width=200 --error \
                --text="Installtion canceled."

            fi

}

npm_in(){
    zenity --question --width=350  --text="Did you want to install  <b>NPM Latest Version</b> ?" --ok-label="Yes" --cancel-label="No"
    if [ $? = 0 ] ; then
    echo "yes"
    npm install -g npm@latest &>/dev/null
    fi
}

nj_chk(){
    pkgs='nodejs'
	if  dpkg -s $pkgs >/dev/null 2>&1; then
		nj_rm
    fi
}

nj(){
    (
        nj_chk
        npm_bichk
        lst=$(curl -s "https://nodejs.org/dist/" | grep "latest" | awk -F 'latest-' '{print $2 FS "/"}' | grep "v" | awk -F "/" '{print $1}'  | sort -Vr )
        choices=()
        mode="true"
        for name in $lst ; do
            choices=("${choices[@]}" "$mode" "$name")
            mode="false"
        done

        choice=`zenity --width=300 --height=380 \
            --list \
            --separator="$IFS" \
            --radiolist \
            --text="Select Versions:" \
            --column "Select" \
            --column "Versions" \
            "${choices[@]}"`
        IFS="$OLDIFS"

        echo "25";
        echo "# Getting Data from NodeJs ..." ; sleep 3
        ver=$(curl -s "https://nodejs.org/dist/latest-$choice/" | grep "node" | awk -F 'node-' '{print $2 FS "/"}' | grep "v" | awk -F "/" '{print $1}' | grep "linux-x64.tar.gz" | awk -F "-" '{print $1}')
        selver=`echo "node-$ver-linux-x64.tar.gz"`

        url="https://nodejs.org/dist/latest-$choice/$selver"
        curl -o /tmp/$selver $url 2>&1 | stdbuf -oL tr '\r' '\n' | sed -u 's/^ *\([0-9][0-9]*\).*\( [0-9].*$\)/\1\n#Download Speed\:\2/' | zenity --width=500 --progress --auto-close --title "Downloading Lando"
        echo "70";
        echo "# Installing NodeJs ..." ; sleep 3
        tar -C /usr/local --strip-components 1 -xzf /tmp/$selver >/dev/null
        echo "80";
        echo "# Installing NPM ..." ; sleep 3
        npm_in
        echo "95"
        echo "# Installation Done ..." ; sleep 3
        rm -rvf /tmp/$selver
        NODE_VER=$(node -v)
        NPM_VER=$(npm -v)

        zenity --info --width=150 --height=100 --timeout 60  --title="Version Details" --text "<b>NodeJS :</b> $NODE_VER\n \n <b>Npm :</b> $NPM_VER"

    ) |
            zenity --width=500 --progress \
            --title="Installing NodeJs" \
            --text="Please Wait ..." \
            --percentage=0 --auto-close

            if [[ $? -eq 1 ]]; then

                zenity --width=200 --error \
                --text="Installtion canceled."

            fi

}

MYS_CHK(){
    pkgs='mariadb-server'
    if ! dpkg -s $pkgs >/dev/null 2>&1; then
        MY_INS
    else
        MYSQL_VER=$(mysql --version | awk '{print $5}')
        zenity --info --timeout 10 --width=250 --height=100 --title="MariaDB" --text "<b>MariaDB is already installed ! 😊 \n\n Version is :</b> $MYSQL_VER"
    fi
}

MY_INS(){
    (
        echo "25" ;
        echo "# Updating Packages ..." ;
        apt-get autoremove -y >/dev/null
        dpkg --configure -a
        apt-get update -y >/dev/null
        echo "35"
        echo "# Installing MariaDB ..." ;
        apt-get install -y $pkgs >/dev/null
        echo "50" ;
        echo "# Configuring MariaDB ..." ; sleep 3

        db_root_password=root
cat <<EOF | mysql_secure_installation
y
y
$db_root_password
$db_root_password
y
y
y
y
y
EOF

        echo "75" ;
        echo "# Changing Permission ...";
        MYSQL=`which mysql`
        Q1="grant all privileges on *.* to 'root'@'%' identified by 'root';"
        Q2="FLUSH PRIVILEGES;"
        SQL="${Q1}${Q2}"
        MYSQL_VER=$(mysql --version | awk '{print $5}')
        echo "85";
        echo "# Almost Done ..."
        $MYSQL -uroot -p$db_root_password -e "$SQL"
        echo "100";
        echo  "# MariaDb has been Installed ...";
        zenity --info --timeout 10 --width=250 --height=100 --title="MariaDB" --text "<b>MariaDB Installed ! 😊 \n\n Version is :</b> $MYSQL_VER"

    ) |
         zenity --width=500 --progress \
            --title="Installing MariaDB" \
            --text="Installing MariaDB..." \
            --percentage=0 --auto-close

            if [[ $? -eq 1 ]]; then

                zenity --width=200 --error \
                --text="Uninstallation canceled."

            fi
}

MY_RMV(){

        (
        pkgs='mariadb-server'
        if ! dpkg -s $pkgs >/dev/null 2>&1; then
            zenity --info --timeout 10 --width=250 --height=100 --title="MariaDB" --text "<b> ⚠️  No MariaDB Found  ⚠️ </b>"

        else

        echo "10" ;
        echo "Killing Process" ;
        killall -KILL mysql mysqld_safe mysqld
        echo "25" ;
        echo "# Removing Mysql ..." ;
        dpkg --configure -a
        echo "30"
        service mysql stop
        echo "35"
        dpkg --configure -a
        apt-get  remove "mysql*"  -y >/dev/null
        echo "40"
        apt-get --yes autoremove --purge >/dev/null
        apt-get autoclean >/dev/null
        echo "45"
        deluser --remove-home mysql >/dev/null
        delgroup mysql >/dev/null
        rm -rf /etc/apparmor.d/abstractions/mysql /etc/apparmor.d/cache/usr.sbin.mysqld /etc/mysql /var/lib/mysql /var/log/mysql* /var/log/upstart/mysql.log* /var/run/mysql
        echo "50" ;
        echo "# Removing MariaDB-Server ..." ; sleep 3
        apt-get --purge remove  "mariadb*" -y >/dev/null
        echo "75" ;
        echo "# Removing Files ..." ; sleep 3
        rm -rf /var/lib/mysql/ >/dev/null
        echo "100" ;
        echo "# MariaDB Removed ... " ; sleep 5
        fi
        ) |
         zenity --width=500 --progress \
            --title="Removing MariaDB" \
            --text="Removing MariaDB..." \
            --percentage=0 --auto-close

            if [[ $? -eq 1 ]]; then

                zenity --width=200 --error \
                --text="Uninstallation canceled."

            fi


}

MYS(){

            ListType=`zenity --width=400 --height=200 --list --radiolist \
                --title 'Installaion'\
                --text 'Select Software to install:' \
                --column 'Select' \
                --column 'Actions' TRUE "Install" FALSE "Remove"`

            if [[ $ListType == "Install" ]]; then

                # they selected the short radio button
                    MYS_CHK

            elif [[ $ListType == "Remove" ]]; then

                # they selected the short radio button
                    MY_RMV

            else
                zenity --error --title="Declined" --width=200 \
                    --text="Installtion Canceled "

            fi

}

php5_6(){

    (
        echo "5";
        echo "# Checking Repository ..."; sleep 3

	pkgs='software-properties-common'
	if ! dpkg -s $pkgs >/dev/null 2>&1; then
        echo "15";
        echo "# Installing Repository ...";
		apt install software-properties-common -y >/dev/null
 		echo "20";
        echo "# Adding Packages ...";
        add-apt-repository ppa:ondrej/php -y >/dev/null
		echo "50";
        echo "# Updating ..."
        apt-get update -y >/dev/null
        echo "60";
        echo "# Installing PHP 5.6 ...";
        sudo apt-get install php5.6-fpm php5.6-bcmath php5.6-cli php5.6-common php5.6-curl php5.6-gd php5.6-intl php5.6-imap php5.6-json php5.6-ldap php5.6-mbstring php5.6-mysql php5.6-sqlite3 php5.6-mcrypt php5.6-pspell php5.6-soap php5.6-tidy php5.6-xml php5.6-xsl php5.6-zip -y >/dev/null
		echo "75";
        echo "# Configuring ..."; sleep 3
        sudo sed -i -e 's/listen =.*/listen = 127.0.0.1:9002/g' /etc/php/5.6/fpm/pool.d/www.conf
        echo "90";
        echo "# Almost Done ...";
		sudo update-rc.d php5.6-fpm defaults >/dev/null
        echo "100";
        echo "# PHP 5.6 Installed ..."; sleep 3
	else
        echo "20";
        echo "# Adding Packages ...";
        add-apt-repository ppa:ondrej/php -y >/dev/null
        echo "50";
        echo "# Updating ..."
		apt-get update -y >/dev/null
        echo "60";
        echo "# Installing PHP 5.6 ...";
		sudo apt-get install php5.6-fpm php5.6-bcmath php5.6-cli php5.6-common php5.6-curl php5.6-gd php5.6-intl php5.6-imap php5.6-json php5.6-ldap php5.6-mbstring php5.6-mysql php5.6-sqlite3 php5.6-mcrypt php5.6-pspell php5.6-soap php5.6-tidy php5.6-xml php5.6-xsl php5.6-zip -y >/dev/null
		echo "75";
        echo "# Configuring ..."; sleep 3
        sudo sed -i -e 's/listen =.*/listen = 127.0.0.1:9002/g' /etc/php/5.6/fpm/pool.d/www.conf
		echo "90";
        echo "# Almost Done ...";
        sudo update-rc.d php5.6-fpm defaults >/dev/null
        echo "100";
        echo "# PHP 5.6 Installed ..."; sleep 3
    fi
    ) |
        zenity --width=500 --progress \
            --title="PHP 5.6 Installing" \
            --text="PHP 5.6 Installing..." \
            --percentage=0 --auto-close

            if [[ $? -eq 1 ]]; then

                zenity --width=200 --error \
                --text="Installation canceled."

            fi

}

php7_0(){

    (
        echo "5";
        echo "# Checking Repository ..."; sleep 3

	pkgs='software-properties-common'
	if ! dpkg -s $pkgs >/dev/null 2>&1; then
        echo "15";
        echo "# Installing Repository ...";
		apt install software-properties-common -y >/dev/null
		echo "20";
        echo "# Adding Packages ...";
        add-apt-repository ppa:ondrej/php -y >/dev/null
		echo "50";
        echo "# Updating ..."
        apt-get update -y >/dev/null
        echo "60";
        echo "# Installing PHP 7.0 ...";
        sudo apt-get install php7.0-fpm php7.0-bcmath php7.0-cli php7.0-common php7.0-curl php7.0-gd php7.0-intl php7.0-imap php7.0-json php7.0-ldap php7.0-mbstring php7.0-mysql php7.0-sqlite3 php7.0-mcrypt php7.0-pspell php7.0-soap php7.0-tidy php7.0-xml php7.0-xsl php7.0-zip -y >/dev/null
        echo "75";
        echo "# Configuring ..."; sleep 3
        sudo sed -i -e 's/listen =.*/listen = 127.0.0.1:9001/g' /etc/php/7.0/fpm/pool.d/www.conf
        echo "90";
        echo "# Almost Done ...";
        sudo update-rc.d php7.0-fpm defaults >/dev/null
        echo "100";
        echo "# PHP 7.0 Installed ..."; sleep 3
	else
		echo "20";
        echo "# Adding Packages ...";
        add-apt-repository ppa:ondrej/php -y >/dev/null
		echo "50";
        echo "# Updating ..."
        apt-get update -y >/dev/null
        echo "60";
        echo "# Installing PHP 7.0 ...";
        sudo apt-get install php7.0-fpm php7.0-bcmath php7.0-cli php7.0-common php7.0-curl php7.0-gd php7.0-intl php7.0-imap php7.0-json php7.0-ldap php7.0-mbstring php7.0-mysql php7.0-sqlite3 php7.0-mcrypt php7.0-pspell php7.0-soap php7.0-tidy php7.0-xml php7.0-xsl php7.0-zip -y >/dev/null
        echo "75";
        echo "# Configuring ..."; sleep 3
        sudo sed -i -e 's/listen =.*/listen = 127.0.0.1:9001/g' /etc/php/7.0/fpm/pool.d/www.conf
        echo "90";
        echo "# Almost Done ..."; sleep 3
        sudo update-rc.d php7.0-fpm defaults >/dev/null
        echo "100";
        echo "# PHP 7.0 Installed ..."; sleep 3
	fi

    ) |
        zenity --width=500 --progress \
            --title="PHP 7.0 Installing" \
            --text="PHP 7.0 Installing..." \
            --percentage=0 --auto-close

            if [[ $? -eq 1 ]]; then

                zenity --width=200 --error \
                --text="Installation canceled."

            fi
}

php7_1(){

    (
        echo "5";
        echo "# Checking Repository ..."; sleep 3

	pkgs='software-properties-common'
	if ! dpkg -s $pkgs >/dev/null 2>&1; then
        echo "15";
        echo "# Installing Repository ...";
		apt install software-properties-common -y >/dev/null
		echo "20";
        echo "# Adding Packages ...";
        add-apt-repository ppa:ondrej/php -y >/dev/null
		echo "50";
        echo "# Updating ..."
        apt-get update -y >/dev/null
        echo "60";
        echo "# Installing PHP 7.1 ...";
        sudo apt-get install php7.1-fpm php7.1-bcmath php7.1-cli php7.1-common php7.1-curl php7.1-gd php7.1-intl php7.1-imap php7.1-json php7.1-ldap php7.1-mbstring php7.1-mysql php7.1-sqlite3 php7.1-mcrypt php7.1-pspell php7.1-soap php7.1-tidy php7.1-xml php7.1-xsl php7.1-zip -y >/dev/null
        echo "75";
        echo "# Configuring ...";
        sudo sed -i -e 's/listen =.*/listen = 127.0.0.1:9000/g' /etc/php/7.1/fpm/pool.d/www.conf
        echo "90";
        echo "# Almost Done ..."; sleep 3
        sudo update-rc.d php7.1-fpm defaults >/dev/null
        echo "100";
        echo "# PHP 7.1 Installed ..."; sleep 3
	else
		echo "20";
        echo "# Adding Packages ...";
        add-apt-repository ppa:ondrej/php -y >/dev/null
		echo "50";
        echo "# Updating ..."
        apt-get update -y >/dev/null
        echo "60";
        echo "# Installing PHP 7.1 ...";
        sudo apt-get install php7.1-fpm php7.1-bcmath php7.1-cli php7.1-common php7.1-curl php7.1-gd php7.1-intl php7.1-imap php7.1-json php7.1-ldap php7.1-mbstring php7.1-mysql php7.1-sqlite3 php7.1-mcrypt php7.1-pspell php7.1-soap php7.1-tidy php7.1-xml php7.1-xsl php7.1-zip -y >/dev/null
        echo "75";
        echo "# Configuring ...";
        sudo sed -i -e 's/listen =.*/listen = 127.0.0.1:9000/g' /etc/php/7.1/fpm/pool.d/www.conf
        echo "90";
        echo "# Almost Done ..."; sleep 3
        sudo update-rc.d php7.1-fpm defaults >/dev/null
        echo "100";
        echo "# PHP 7.1 Installed ..."; sleep 3
	fi

    ) |
        zenity --width=500 --progress \
            --title="PHP 7.1 Installing" \
            --text="PHP 7.1 Installing..." \
            --percentage=0 --auto-close

            if [[ $? -eq 1 ]]; then

                zenity --width=200 --error \
                --text="Installation canceled."

            fi

}

php7_2(){

	(
        echo "5";
        echo "# Checking Repository ..."; sleep 3

	pkgs='software-properties-common'
	if ! dpkg -s $pkgs >/dev/null 2>&1; then
        echo "15";
        echo "# Installing Repository ...";
		apt install software-properties-common -y >/dev/null
		echo "20";
        echo "# Adding Packages ...";
        add-apt-repository ppa:ondrej/php -y >/dev/null
		echo "50";
        echo "# Updating ..."
        apt-get update -y >/dev/null
        echo "60";
        echo "# Installing PHP 7.2 ...";
        apt-get install php7.2-fpm php7.2-bcmath php7.2-cli php7.2-common php7.2-curl php7.2-gd php7.2-intl php7.2-imap php7.2-json php7.2-ldap php7.2-mbstring php7.2-mysql php7.2-sqlite3  php7.2-pspell php7.2-soap php7.2-tidy php7.2-xml php7.2-xsl php7.2-zip -y >/dev/null
        echo "75";
        echo "# Configuring ...";
        sudo sed -i -e 's/listen =.*/listen = 127.0.0.1:9003/g' /etc/php/7.2/fpm/pool.d/www.conf
        echo "90";
        echo "# Almost Done ..."; sleep 3
        sudo update-rc.d php7.2-fpm defaults >/dev/null
        echo "100";
        echo "# PHP 7.2 Installed ..."; sleep 3
	else
		echo "20";
        echo "# Adding Packages ...";
        add-apt-repository ppa:ondrej/php -y >/dev/null
		echo "50";
        echo "# Updating ..."
        apt-get update -y >/dev/null
        echo "60";
        echo "# Installing PHP 7.2 ...";
        apt-get install php7.2-fpm php7.2-bcmath php7.2-cli php7.2-common php7.2-curl php7.2-gd php7.2-intl php7.2-imap php7.2-json php7.2-ldap php7.2-mbstring php7.2-mysql php7.2-sqlite3  php7.2-pspell php7.2-soap php7.2-tidy php7.2-xml php7.2-xsl php7.2-zip -y >/dev/null
        echo "75";
        echo "# Configuring ...";
        sudo sed -i -e 's/listen =.*/listen = 127.0.0.1:9003/g' /etc/php/7.2/fpm/pool.d/www.conf
        echo "90";
        echo "# Almost Done ..."; sleep 3
        sudo update-rc.d php7.2-fpm defaults >/dev/null
        echo "100";
        echo "# PHP 7.2 Installed ..."; sleep 3
	fi
    ) |
        zenity --width=500 --progress \
            --title="PHP 7.2 Installing" \
            --text="PHP 7.2 Installing..." \
            --percentage=0 --auto-close

            if [[ $? -eq 1 ]]; then

                zenity --width=200 --error \
                --text="Installation canceled."

            fi
}


php_install(){

if ! [ -x "$(command -v php5.6)"  ]; then

	php5_6
	php_install
elif ! [ -x "$(command -v php7.0)"  ]; then

	php7_0
	php_install
elif ! [ -x "$(command -v php7.1)"  ]; then
	php7_1
	php_install
elif ! [ -x "$(command -v php7.2)"  ]; then
	php7_2
	php_install

else

    zenity --info --timeout 10 --width=190 --height=100 --title="Version Details" --text "<b>PHP Already Installed:\n\n</b> <b>Versions : </b> 5.2, 7.0, 7.1, 7.2"


fi
}

NG(){


    (
        echo "10";
        echo "# Checking Package ..."; sleep 3
        pkgs='nginx'
        if ! dpkg -s $pkgs >/dev/null 2>&1; then
            echo "30";
            echo "# Updating Package ...";
            cd /tmp/
            wget http://nginx.org/keys/nginx_signing.key >/dev/null
            apt-key add nginx_signing.key >/dev/null
            sh -c "echo 'deb http://nginx.org/packages/ubuntu/ '$(lsb_release -cs)' nginx' > /etc/apt/sources.list.d/Nginx.list" >/dev/null
            apt-get update -y >/dev/null
            echo "50";
            echo "# Installing Nginx ...";
            apt-get install -y $pkgs >/dev/null
            echo "80";
            echo "Setting up ..."; sleep 3
            update-rc.d nginx defaults >/dev/null
            rm -rf /tmp/nginx*
            echo "100";
            echo "# Nginx Installed ..."; sleep 3

            zenity --info --timeout 10 --width=200  --no-wrap --title="NginX" --text "<b>Nginx Installed Sucessfully ! 😊 </b>"
        else

            zenity --info --timeout 10 --width=200  --no-wrap --title="NginX" --text "<b>Nginx is Already Installed ! 😊 </b>"
        fi

    ) |
         zenity --width=500 --progress \
            --title="Installing Nginx" \
            --text="Installing Nginx..." \
            --percentage=0 --auto-close

            if [[ $? -eq 1 ]]; then

                zenity --width=200 --error \
                --text="Installation canceled."

            fi
}

mar(){

        (
            echo "10" ; sleep 3
            echo "# Updating mail logs" ; sleep 3
            echo "20" ; sleep 3
            echo "# Resetting cron jobs" ; sleep 3
            echo "50" ; sleep 3
            echo "This line will just be ignored" ; sleep 3
            echo "75" ; sleep 3
            echo "# Rebooting system" ; sleep 3
            echo "100" ; sleep 3
        ) |
        zenity --width=500 --progress \
        --title="Installing NodeJs" \
        --text="NodeJs..." \
        --percentage=0

        if [[ $? -eq 1 ]]; then
            zenity --width=200 --error \
            --text="Installtion canceled."
        fi

}

DOCK_COMP(){
    (
        echo "10";
        echo "# Checking Package ...";
        echo "25";
        echo "# Downloading Docker-compose ...";
        curl -s -L "https://github.com/docker/compose/releases/download/1.24.0/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose > /dev/null
        chmod +x /usr/local/bin/docker-compose
        echo "50";
        echo "# Installing Docker-compose ...";
        apt-get install -y docker-compose >/dev/null
        echo "100";
        echo "# Docker-compose Installed ..."; sleep 3

    ) |
        zenity --width=500 --progress \
            --title="Installing Docker-Compose-" \
            --text="Installing Docker-Compose..." \
            --percentage=0 --auto-close

            if [[ $? -eq 1 ]]; then

                zenity --width=200 --error \
                --text="Installation canceled."

            fi
}

DOCK_CHK(){

    if [ ! -x "$(command -v docker)" ]; then

        DOCK_IN
        DOCK_CHK

    elif [ ! -x "$(command -v docker-compose)" ]; then

        DOCK_COMP
        DOCK_CHK

    else

        DOCOM_VER=$(docker-compose --version | awk '{print $3}' | sed 's/.$//')
        DOCK_VER=$(docker --version | awk '{print $3}' | sed 's/.$//')
        zenity --info --timeout 15 --width=300 --height=100 --title="Installation" --text "<b>Packages installed successful ! 👍 \n\n Docker Version : </b> $DOCK_VER  \n\n<b> Docker-compose Version : </b> $DOCOM_VER"

    fi

}

DOCK_IN(){

    # optr=`zenity --list --radiolist --column="Select" --column="Actions" $(ls  /home/local/RAGE/  | awk -F'\n' '{print NR, $1}')`

    if [[ $? -eq 0 ]]; then

        (
            per='RAGE\'
            domain='RAGE\domain^users'
            path=' /home/local/RAGE/'"$optr"
            echo "10";
            echo "# Collecting Data ..."; sleep 5
            # cd $path
            #"Permission Changing"
            echo "23";
            echo "# Changing Project Permission ..."; sleep 5
            # chown -R $per''$optr:$domain projects/
            echo "32";
            echo "# Installing dependencies ...";
            apt-get install \
            apt-transport-https \
            ca-certificates \
            curl \
            gnupg-agent \
            software-properties-common -y >/dev/null
            echo "40";
            echo "# Adding Docker Repo ...";
            curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -  >/dev/null

            add-apt-repository \
            "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
            $(lsb_release -cs) \
            stable"  -y  >/dev/null
            echo "53";
            echo "# Updating and Installing Docker-ce ...";
            apt-get update -y  >/dev/null
            apt-get install docker-ce docker-ce-cli containerd.io -y  >/dev/null
            systemctl start docker
            systemctl enable docker
            echo "80";
            echo "# Configuring Docker Setup ...";
            sudo sed -i -e 's/SocketMode=.*/SocketMode=0666/g' /lib/systemd/system/docker.socket
            systemctl daemon-reload
            systemctl stop docker.socket
            systemctl start docker.socket
            echo "100"; sleep 5
            echo "# Docker Installed ...";

        ) |
            zenity --width=500 --progress \
            --title="Docker Installation" \
            --text="Docker Installation..." \
            --percentage=0 --auto-close

            if [[ $? -eq 1 ]]; then

                zenity --width=200 --error \
                --text="Installation canceled."

            fi

    else

        zenity --error --title="Declined" --width=200 \
                        --text="Installtaion Canceled "

        exit 1 ;

    fi
}


ins(){


    clear
    if [ `whoami` != root ]; then

            zenity --width=350 --error \
            --text="Please Run This Scripts As <b>root</b> Or As <b>Sudo User</b>"
            exit
    else

            # apt-get install -y zenity >/dev/null

            ListType=$(zenity --width=400 --height=350 --checklist --list \
                --title='Installaion'\
                --text="<b>Select Software to install :</b>\n <span color=\"red\" font='10'> ⚠️ NOTE : Don't select Domain-join in multi selection. ⚠️ </span>"\                --column="Select" --column="Software List" \
                " " "Domain-Join" \
                " " "NodeJs" \
                " " "MariaDB" \
                " " "PHP" \
                " " "Composer (php)" \
                " " "Nginx" \
                " " "Docker" \
                " " "Lando"
                )

            if [[ $? -eq 1 ]]; then

                # they pressed Cancel or closed the dialog window
                zenity --error --title="Declined" --width=200 \
                    --text="Canceled Installtion"
                exit 1
            fi

            if [[ $ListType == *"Domain-Join"* ]]; then

                # they selected the short radio button
                Flag="--Domain-Join"
                domain
            fi

            if [[ $ListType == *"NodeJs"* ]]; then

                # they selected the short radio button
                Flag="--NodeJs"
                nj
            fi

            if [[ $ListType == *"MariaDB"* ]]; then

                # they selected the short radio button
                Flag="--MariaDB"
                MYS
            fi

            if [[ $ListType == *"PHP"* ]]; then

                # they selected the short radio button
                Flag="--PHP"
                php_install
            fi

            if [[ $ListType == *"Composer"* ]]; then

                # they selected the short radio button
                Flag="--Composer"
                php_comp_chk
            fi

            if [[ $ListType == *"Nginx"* ]]; then

                # they selected the short radio button
                Flag="--Nginx"
                NG
            fi

            if [[ $ListType == *"Docker"* ]]; then

                # they selected the short radio button
                Flag="--Docker"
                DOCK_CHK
            fi

            if [[ $ListType == *"Lando"* ]]; then

                # they selected the short radio button
                Flag="--Lando"
                lan
            fi

            # exit 0
    fi
}

ins
