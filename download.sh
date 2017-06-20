#!/bin/bash
# Function that checks if the user has the needed packages
check_packages(){
	echo "Dear $USER make sure you are running bash shell before launching this installation script!"
	while true; do
		read -r -p "Are you running bash shell? [y/n] " response
		if [[ "$response" =~ ^([nN][oO]|[nN])+$ ]]; then
			exit
		elif [[ "$response" =~ ^([yY][eE][sS]|[yY])+$ ]]; then
			break
		else
			echo "Acceptable answers y/yes/no/n"
		fi
	done
	echo -e "=======================================\nChecking packages!\n=======================================\n---------------------------------------\nChecking wget command..."
	if ! type -p "wget"; then
		echo -e "You must install wget before launching this install script.\n---------------------------------------"
		exit
	fi
	echo -e "wget found!\n---------------------------------------\nChecking bzip2..."
	if ! type -p "bzip2"; then
		echo -e "You must install bzip2 before launching this install script.\n---------------------------------------"
		exit
	fi
	echo -e "bzip2 found!\n---------------------------------------\nChecking rpm..."
	if ! type -p "rpm"; then
		echo -e "You must install rpm before launching this install script.\n---------------------------------------"
		exit
	fi
	echo -e "rpm found!\n---------------------------------------\nChecking openssl-devel..."
	if [ -z "rpm -qa | grep openssl-devel" ]; then
		echo -e "You must install openssl-devel before launching this install script.\n---------------------------------------"
		exit
	fi
	echo -e "openssl-devel found!\n---------------------------------------\nChecking glibc-devel..."
	if [ -z "rpm -qa | grep glibc-devel" ]; then
		echo -e "You must install glibc-devel before launching this install script.\n---------------------------------------"
		exit
	fi
	echo -e "glibc-devel found!\n---------------------------------------\nChecking tee..."
	if ! type -p "tee"; then
		echo -e "You must install glibc-devel before launching this install script.\n---------------------------------------"
		exit
	fi
	echo -e "tee found!\n---------------------------------------\nChecking awk..."
	if ! type -p "awk"; then
		echo -e "You must install awk before launching this install script.\n---------------------------------------"
		exit
	fi
	echo -e "awk found!\n---------------------------------------\n=======================================\nPackage checking complete!\n=======================================\n"
	echo -e "---------------------------------------\nChecking Internet Connection"
	wget -q --tries=10 --timeout=20 --spider http://google.com
	if [[ $? -eq 0 ]]; then
		echo -e "Online - Internet connection found!\n---------------------------------------"
	else
		echo -e "Offline - Check your internet connection!\n---------------------------------------"
		exit
	fi
}
check_packages
# Checking if the user has Linux or Darwin
distribution="$(uname -a | awk '{print $1}')"
if [ "$distribution" == 'Darwin' ]; then
	echo "Unix name: Darwin"
	os="Darwin"
	release="$(sw_vers -productVersion | awk -F'.' '{print $1"." $2}')"
elif [ "$distribution" == 'Linux' ]; then
	echo -e "Unix name: Linux\n---------------------------------------\nChecking lsb_release"
	if ! type -p "lsb_release"; then
		echo -e "You must install lsb_release binary before launching this install script.\n---------------------------------------"
		exit
	fi
	echo -e "lsb_release found!\n---------------------------------------\n"
	version="$(lsb_release -r | awk '{print $2}' | awk -F'.' '{print $1}')"
	os="$(lsb_release -d | awk '{print $2}')"
else
	echo -e "Only Darwin & Linux!"
	exit
fi
# Checking the software version and assigning the corresponding qualifiers
if [ "$os" == 'CentOS' ] || [ "$os" == 'Scientific' ]; then
	if [ "$version" == "7" ]; then
			ver="slf7"
			qualifier="e14"
	elif [ "$version" == "6" ]; then
			ver="slf6"
			qualifier="e14"
	else
		echo -e "This version of Scientific Linux is not supported!\nOnly Scientific Linux 6 and Scientific Linux 7"
		exit
	fi
elif [ "$os" == 'Ubuntu' ]; then
	if [ "$version" == "14" ]; then
		ver="u14"
		qualifier="e10"
		echo -e "Ubuntu 14 detected!\nPlease visit https://dune.bnl.gov/wiki/DUNE_LAr_Software_Releases in order to check the latest stable LArSoft version!"
	else
		echo -e "This version of Ubuntu is not supported!\nOnly Ubuntu 14!"
		exit
	fi
elif [ "$os"== 'Darwin' ];then
	# mac OS X 10.9 Mavericks
	if [ "$release" == '10.9' ]; then
		ver="d13"
		qualifier="e10"
		echo -e "Mavericks detected!\nPlease visit https://dune.bnl.gov/wiki/DUNE_LAr_Software_Releases in order to check the latest stable LArSoft version!"
	# mac OS X 10.10 Yosemite
	elif [ "$release" == '10.10' ]; then
		ver="d14"
		qualifier="e14"
	# mac OS X 10.11 El Capitan
	elif [ "$release" == '10.11' ]; then
		ver="d15"
		qualifier="e14"
	# macOS 10.12 Sierra
	elif [ "$release" == '10.12' ]; then
		ver="d16"
		qualifier="e14"
	else
		echo -e "This versions of mac OS is not supported!\nOnly mac OS X 10.9 Mavericks, mac OS X 10.10 Yosemite, mac OS X 10.11 El Capitan & macOS 10.12 Sierra are supported!"
	fi
else
	echo -e "This operating system is not supported.\nThe operating systems that are supported are:\n1. Scientific Linux 6\n2. Scientific Linux 7\n3. mac OS X 10.9 Mavericks\n4. mac OS X 10.10 Yosemite\n5. mac OS X 10.11 El Capitan\n6. macOS 10.12 Sierra\n7. Ubuntu 14"
	exit
fi
# Printing the 5 latest DUNE versions
# The user must provide an index withing the threshold
echo -e "\nGive the index of the version you want to download\nLatest 5 DUNE versions"
content=$(curl -s scisoft.fnal.gov/scisoft/bundles/dune/ | sed -n 's/.*href="\([^"]*\).*/\1/p')
versions=()
for word in $content
do
	version=$(echo $word | awk -F'/' '{print $6}')
	if [[ $version =~ .*v.* ]]; then
		versions=("${versions[@]}" "$version")
	fi
done
size=${#versions[@]}
for (( i=$(( $size - 5 )); i<= $(( $size - 1 )); i++ ))
do
	echo "$i.dune-${versions[$i]}"
done
while true; do
	read -r -p "Do you want to list all the DUNE versions? [y/n] " response
	if [[ "$response" =~ ^([yY][eE][sS]|[yY])+$ ]]; then
		for (( i=0; i<= $(( $size - 1 )); i++ ))
		do
			echo "$i.dune-${versions[$i]}"
		done
		break
	elif [[ "$response" =~ ^([nN][oO]|[nN])+$ ]]; then
		break
	else
		echo "Acceptable answers y/yes/no/n"
	fi
done
while true; do
	read -r -p "Give the index of the version you want(0~$(( $size - 1))): " index
	if [[ "$index" =~ ^[0-9]+$ ]]; then
		if [ "$index" -ge 0 -a "$index" -le "$size" ]; then
			break
		else
			echo "Please give an integer within the threshold 0~$(( $size - 1))"
		fi
	else
		echo "Please give an integer!"
	fi
done
# User must provide a path in order to install the selected DUNE version
while true; do
	read -r -p "Provide a path to install the DUNE version: " -i "$home/" -e path
	if [ -d "$path" ]; then
		break;
	else
		read -r -p "Do you want to create the folder $path? [y/n] " response
		if [[ "$response" =~ ^([yY][eE][sS]|[yY])+$ ]]; then
			mkdir -p "$path";
			break
		else
			echo "Please provide an existing path!"
		fi
	fi
done
# Creating the folders that are in need
# Downloading pullProducts în order to install the selected version
cd $path
mkdir -p "dune-${versions[$index]}"
mkdir -p "dune-${versions[$index]}-installation"
cd "dune-${versions[$index]}-installation"
echo -e "\nDownloading pullProducts...\n"
wget scisoft.fnal.gov/scisoft/bundles/tools/pullProducts
chmod +x pullProducts
./pullProducts ../"dune-${versions[$index]}" ${ver} "dune-${versions[$index]}" ${qualifier} prof | tee  ${path}/bundle.txt
echo -e "./pullProducts ../"dune-${versions[$index]}" ${ver} "dune-${versions[$index]}" ${qualifier} prof" > ${path}/pull.txt
# Checking if there are any errors on the downloaded packages
counter_bundle=0
while read NAME
do
	counter_bundle=$((counter_bundle+1))
done < ${path}/bundle.txt
cbundle=$(($counter_bundle-10))
manifest="$(ls ${path}/dune-${versions[$index]}-installation | grep MANIFEST)"
counter_manifest=0
while read NAME
do
	counter_manifest=$((counter_manifest+1))
done < $manifest
if [ "$cbundle" -eq "$counter_manifest" ]; then
	echo -e "\n=======================================\nDownloading seems complete!\n=======================================\n"
else
	echo -e "\n=======================================\nDownloading seems incomplete!\nPlease run the command that you find at ${path}/pull.txt\n=======================================\n"
fi
echo -e "At the path ${path} a file named pull.txt was created with the command that was used in order to download the dune bundle that was chosen!\n";