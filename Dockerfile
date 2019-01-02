# reference:
# https://hub.docker.com/r/robshad/handbrake-cli/dockerfile

FROM ubuntu:18.04

LABEL \
  org.asyla.release-date="2019-01-01" \
  org.asyla.maintainer="shepner@asyla.org" \
  org.asyla.description="Handbrake CLI"

RUN ["cpanm", "Term::ReadLine"]

RUN apt-get update -q
RUN apt-get install -qy apt-utils
RUN apt-get install -qy software-properties-common
#debconf: unable to initialize frontend: Dialog
#debconf: (TERM is not set, so the dialog frontend is not usable.)
#debconf: falling back to frontend: Readline
#debconf: unable to initialize frontend: Readline
#debconf: (Can't locate Term/ReadLine.pm in @INC (you may need to install the Term::ReadLine module) (@INC contains: /etc/perl /usr/local/lib/x86_64-linux-gnu/perl/5.26.1 /usr/local/share/perl/5.26.1 /usr/lib/x86_64-linux-gnu/perl5/5.26 /usr/share/perl5 /usr/lib/x86_64-linux-gnu/perl/5.26 /usr/share/perl/5.26 /usr/local/lib/site_perl /usr/lib/x86_64-linux-gnu/perl-base) at /usr/share/perl5/Debconf/FrontEnd/Readline.pm line 7, <> line 3.)
#debconf: falling back to frontend: Teletype
#dpkg-preconfigure: unable to re-open stdin: 

RUN apt-get install -qy perl
RUN apt-get install -qy wget
#debconf: unable to initialize frontend: Dialog
#debconf: (TERM is not set, so the dialog frontend is not usable.)
#debconf: falling back to frontend: Readline
#debconf: unable to initialize frontend: Readline
#debconf: (Can't locate Term/ReadLine.pm in @INC (you may need to install the Term::ReadLine module) (@INC contains: /etc/perl /usr/local/lib/x86_64-linux-gnu/perl/5.26.1 /usr/local/share/perl/5.26.1 /usr/lib/x86_64-linux-gnu/perl5/5.26 /usr/share/perl5 /usr/lib/x86_64-linux-gnu/perl/5.26 /usr/share/perl/5.26 /usr/local/lib/site_perl /usr/lib/x86_64-linux-gnu/perl-base) at /usr/share/perl5/Debconf/FrontEnd/Readline.pm line 7, <> line 3.)
#debconf: falling back to frontend: Teletype
#dpkg-preconfigure: unable to re-open stdin: 


#RUN add-apt-repository ppa:stebbins/handbrake-snapshots
# WARNING: These packages are obsolete and for archival purposes only.  This PPA will be deleted after a suitable transition period.
#
#IMPORTANT: As of Aug 25, 2015 the nightly builds have been moved to a new PPA. We migrated HandBrake from svn to github which caused a change in nightly build version numbering that is incompatible with the old PPAs versions.
#The new PPA is here:
#https://launchpad.net/~stebbins/+archive/ubuntu/handbrake-git-snapshots
#
#To access the new nightlies if you currently have this old PPA installed, you are going to have to:
#sudo apt-get remove handbrake-gtk handbrake-cli
#sudo add-apt-repository -r ppa:stebbins/handbrake-snapshots
#sudo add-apt-repository ppa:stebbins/handbrake-git-snapshots
#sudo apt-get update
#sudo apt-get install handbrake-gtk handbrake-cli
#
#Frequent snapshot builds of HandBrake SVN head. These are not stable releases. They are unstable (and undocumented) code which will one day lead to the next stable release of HandBrake. They are only recommended for experienced users and developers. Please visit HandBrake's home page http://handbrake.fr and the development wiki for more details http://trac.handbrake.fr/wiki/Development.
#
# More info: https://launchpad.net/~stebbins/+archive/ubuntu/handbrake-snapshots
#Hit:1 http://security.ubuntu.com/ubuntu bionic-security InRelease
#Ign:2 http://ppa.launchpad.net/stebbins/handbrake-snapshots/ubuntu bionic InRelease
#Err:3 http://ppa.launchpad.net/stebbins/handbrake-snapshots/ubuntu bionic Release
#  404  Not Found [IP: 91.189.95.83 80]
#Hit:4 http://archive.ubuntu.com/ubuntu bionic InRelease
#Hit:5 http://archive.ubuntu.com/ubuntu bionic-updates InRelease
#Hit:6 http://archive.ubuntu.com/ubuntu bionic-backports InRelease
#Reading package lists...
#E: The repository 'http://ppa.launchpad.net/stebbins/handbrake-snapshots/ubuntu bionic Release' does not have a Release file.
RUN add-apt-repository ppa:stebbins/handbrake-git-snapshots

RUN add-apt-repository ppa:kirillshkrogalev/ffmpeg-next

RUN apt-get update -q
RUN apt-get install -qy handbrake-cli
RUN apt-get install -qy ffmpeg

RUN apt-get clean




