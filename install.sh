#!/bin/bash
# Checking the Internet Connectivity
echo -e "=======================================\nChecking Internet Connection"
wget -q --tries=10 --timeout=20 --spider http://google.com
if [[ $? -eq 0 ]]; then
	echo -e "Online - Internet Connection found!\n=======================================\n"
else
	echo -e "Offline - Check your Internet Connection!\n======================================="
	exit
fi
# Getting the versions of dune bundle from scisoft.fnal.gov/scisoft/bundles/dune/
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
# Getting all the projects/repositories from cdcvs.fnal.gov/projects/
echo -e "=======================================\nGetting Repositories"
content=$(curl -s cdcvs.fnal.gov/projects/ | sed -n 's/.*href="\([^"]*\).*/\1/p')
projects=()
for word in $content
do
	project=$(echo $word | awk -F'/' '{print $1}')
	projects=("${projects[@]}" "$project")
done
echo -e "Repositories found!\n=======================================\n"
# Asking user to give the desired repositories
# Also checking if the repositories exist
# If not similar repositories are shown
size=${#projects[@]}
echo -e "Please give the repository names separated by space!"
while true; do
	read -r -p "Repositories you want to have: " -e repositories
	if [ ! -z "$repositories" ]; then
		echo -e "Checking repositories...."
		repo=($repositories)
		flag=0
		for i in ${repo[@]}
		do
			repo_found=0
			for j in ${projects[@]}
			do
				if [ "${j}" = "${i}" ]; then
					echo "Repository ${i} found!"
					repo_found=1
					break
				fi
			done
			if [[ "${repo_found}" -eq "0" ]]; then
				flag=1
				if [[ "${#i}" -lt "3" ]]; then
					delimiter=${i}
				else
					delimiter=${i:0:3}
				fi
				echo -e "\nRepository ${i} not found!"
				echo -e "Similar repositories are"
				for j in ${projects[@]}
				do
					echo $j | grep ${delimiter}
				done
			fi
		done
		if [[ "${flag}" -eq "0" ]]; then
			break
		fi
	else
		echo "Please provide an input!"
	fi
	echo -e "\n"
done
echo -e "\n=======================================\nRepositories accepted!\nContinuing to installation\n=======================================\n"
# Asking user to provide the path that contains the local DUNE version
while true; do
	read -r -p "Provide the path of the DUNE version: " -i "$home/" -e path
	if [ -d "$path" ]; then
		if [ -f "$path"/setup ];then
			break;
		else
			echo "This folder does not contain the setup!"
		fi
	else
		echo "Please provide an existing path!"

	fi
done
# Asking the user to provide a path in order to install the repositories
# If the folder that is provided does not exists then it creates the folder
# (The creation of the folder is optional and the user must agree first)
while true; do
	read -r -p "Provide a path to install the repositories: " -i "$home/" -e folder
	if [ -d "$folder" ]; then
		break;
	else
		echo "Please provide an existing path!"
	fi
done
cd $folder
source ${path}/setup
setup mrb
export MRB_PROJECT=larsoft
number=$(echo "$path" | cut -d '-' -f 2)
last_char=${number: -1}
if [ "$last_char" == "/" ]; then
	version="${number%?}"
else
	version="${number}"
fi
last_char=${folder: -1}
if [ "$last_char" == "/" ]; then
	installation_folder="${folder%?}"
else
	installation_folder="${number}"
fi
# Finding the version number
# If the folder that is given does not have the version number then the user must give the number of the version
# The input, for the version, from user must be: vXX_YY_ZZ were x,y,z are numbers
# Always checking if the version is the latest in order to check what arguments to provide to mrb
latest=0
if [[ "$version" =~ ^([vV][0-9][0-9][_][0-9][0-9][_][0-9][0-9])+$ ]]; then
	if [[ "${version}" == ${versions[${#versions[@]}-1]} ]]; then
		version_number="${version}"
	else
		if [[ "${versions[*]}" == *"$version"* ]]; then
			latest=1
			version_number="${version}"
			echo -e "Version accepted!\n"
		fi
	fi
else
	echo -e "The number version was not found in the folder name!\n"
	while true; do
		read -r -p "Please provide the number of the installed version[vXX_YY_ZZ]: " response
		if [[ "$response" =~ ^([vV][0-9][0-9][_][0-9][0-9][_][0-9][0-9])+$ ]]; then
			if [[ "${versions[*]}" == *"$response"* ]]; then
				echo -e "Version accepted!\n"
				if [[ "${response}" == ${versions[${#versions[@]}-1]} ]]; then
					echo "Version: latest"
					version_number="${response}"
					break
				else
					version_number="${response}"
					latest=1
					break
				fi
			else
				echo -e "Please provide a version that exists!\n"
			fi
		else
			echo -e "The format you provided is not accepted!\nAccepted format is vXX_YY_ZZ were x,y,z are numbers!"
		fi
	done
fi
# Setting up & Installing the repositories
mrb newDev -v ${version_number} -q e14:prof
source ${installation_folder}/localProducts_larsoft_${version_number}_e14_prof/setup
cd srcs/
for (( i=0;i<${#repo[@]};i++ )); do
	if [[ "${latest}" -eq "0" ]]; then
		mrb g ${repo[${i}]}
	else
		mrb g -t ${version_number} ${repo[${i}]}
	fi
done
echo -e "=======================================\nChecking mrbsetenv...."
mrbsetenv > ${installation_folder}/mrbsetenv.txt 2>&1
if grep -q ERROR "${installation_folder}/mrbsetenv.txt"; then
	echo -e "ERROR while executing command mrbsetenv\nAlso, file ${installation_folder}/mrbsetenv.txt was created for more information\n======================================="
	exit
fi
echo -e "mrbsetenv: OK\n=======================================\n\n=======================================\nStarting installation...\n"
mrb i -j4 > ${installation_folder}/mrbi.txt 2>&1
if ! grep -q "INFO: Stage install / package successful." "${installation_folder}/mrbi.txt"; then
	echo -e "ERROR while installing the software\nAlso, file ${installation_folder}/mrbi.txt was created for more information\n======================================="
	exit
fi
echo -e "Installation finished\n=======================================\n"
mrbslp > ${installation_folder}/mrbslp.txt 2>&1
if grep -q ERROR "${installation_folder}/mrbslp.txt"; then
	echo -e "ERROR while executing command mrbslp\nAlso, file ${installation_folder}/mrbslp.txt was created for more information\n=======================================\n"
	exit
fi
echo -e "source ${path}/setup\nsetup mrb\nsource ${installation_folder}/localProducts_larsoft_${version}_e14_prof/setup\nmrbslp" > ${installation_folder}/commands.txt
echo -e "At the path ${installation_folder} a file named commands.txt was created!\nYou need to run the commands that the file contains now and every time you log-in!";
