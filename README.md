### Disclaimer

An effort to make the installation of a LArSoft version to a PC "easier" and more convenient for the users perspective.<br>
Users are not obligated to use these scripts instead of the official methods that can be found here.

### Supported Operating Systems

The supported operating systems are:

* Scientific Linux 6
* Scientific Linux 7
* mac OS X 10.9 Mavericks
* mac OS X 10.10 Yosemite
* mac OS X 10.11 El Capitan
* macOS 10.12 Sierra
* Ubuntu 14

More information about the supported operating systems can be found at the official [website](https://dune.bnl.gov/wiki/DUNE_LAr_Software_Releases#Finding_and_downloading_DUNE_releases).<br>
<b><i>Note</i></b>: mac OS X 10.9 Mavericks and Ubuntu 14 are not using the latest DUNE bundle version!

### Technologies

Both scripts were developed with the scripting language <b><i>shell script</i></b>.<br>
The download process is using [pullProducts](http://scisoft.fnal.gov/scisoft/bundles/tools/pullProducts).

### Most common missing packages

Most common missing packages are

* bzip2
* openssl-devel
* glibc-devel
* libicu

For more information about the needed packages can be found [here](http://scisoft.fnal.gov/scisoft/bundles/tools/checkPrerequisites).

### Tips

Always install the latest bundle version!<br>
More information on the DUNE bundle versions can be found [here](http://scisoft.fnal.gov/scisoft/packages/).

### How to run the scripts

In order to run the scripts first you must download them then give them execution permissions
```sh
$ chmod +x /path/to/script
```
Then run the download.sh
```sh
$ ./download.sh
```
and follow the steps.<br>
<b><i>Note</i></b>: the download process takes a while!<br>

After the download is complete run the install.sh and follow the steps.<br>
<b><i>Note</i></b>: the installation process takes a while!

### License

MIT

### Todos

Additional testing on Darwin Systems.
