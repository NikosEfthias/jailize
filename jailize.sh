#!/bin/bash
####COLORS#####
red="\033[31m"
green="\033[32m"
yellow="\033[33m"
blue="\033[34m"
bold="\033[1m"
reset="\033[0m"
################
###defaults#####
dirNum=1;#default number of jails to build
baseDir=$(pwd)
cmd=$(whoami)
bins="su ls rm mv bash"
if [[ $cmd != "root" ]]; then
  printf "$red\bPlease run the script as root user$reset\n"
  exit 1
fi
#####################
######make dirs######
dirMake(){
  echo "Creating Jails"
$(eval "mkdir $baseDir/jail{1..$dirNum}")
  for i in $(eval "echo {1..$dirNum}") ;do
    printf "\033[32mjail$i is created creating config folder inside\033[0m\n"
    $(eval "mkdir $baseDir/jail$i/{bin,lib,dev,etc,lib64}")
    # $(chmod -R 0111 $baseDir/jail$i)
  done
}
###################
###input required##
reqinp(){
  if [[ -z $2  || $2 =~ ^\-.* ]];then
      printf "\033[31m$1 flag requires an argument\033[0m\n"
      exit 1; fi
}
################
#####cp bins#####
cpBins(){
  printf "copying binaries and dependencies\n"
for i in $bins
do
  echo $i
  binAddr=$(which $i)
  if [[ $? = 0 ]]; then
    printf "\033[32m cp $binAddr --> jail/bin\033[0m\n"
    $(eval "mkdir -p jail{1..$dirNum}$(dirname $binAddr)")
    $(eval "cp $binAddr $baseDir/jail{1..$dirNum}$binAddr")
    ldd=$(ldd $binAddr |cut -d ">" -f2|cut -d "(" -f1)
    for l in $ldd ;do
      if [[ $l ]]; then
          $(eval "mkdir -p $baseDir/jail{1..$dirNum}$(dirname $l)")
        printf "\033[32m cp $l --> jail$l\033[0m\n"
      $(eval "cp $l $baseDir/jail{1..$dirNum}$l")
      fi
    done
  else
    printf "\033[31m$i cannot be found You may need to copy it manually\033[0m
Hit enter to continue or ctrl+c to quit script\n"
read
  fi
done
# $(eval "ln -s $baseDir/jail1/lib/* $baseDir/jail{1..$dirNum}/lib64/")
}
################
###Parse Command Line Args########
while [[ -n $1 ]];do
# while getopts "n:hd:b:a:" flg
#n number folders;
# h help text; d basedir;
#b whitespace seperated binary list to put into jail
# append binary to defaults

   if [[ $1 =~ ^[^-].* ]] ; then
     printf "\033[31mI dont understand what you meant with \033[7m$1\033[0m\n"
     exit 1
   fi
case $1 in
  -n)
  reqinp $1 $2
  dirNum=$2
  shift 2 ;;
  -h)
  params=("-n" "-d" "-b" "-a" "--add-rec" "-h")
  printf "\nCreate Chroot Jails
\nUsage jailize.sh [options]
  Options
    %s            Number of parallel chroot jail folders default is 1
    %s            Base directory if no given current working directory is default
    %s            Whitespace seperated binary list string to put each with dependent libraries into jails
          default value is 'su ls rm mv bash'
    %s            Append a binary to include into binary list
          format :  jailize -a 'bin1 bin2 bin3'
    %s            Show this help text\n\n" ${params[@]}
    exit 1
    ;;

    -d)
      reqinp $1 $2
     if [[ -d $2 ]]; then
      baseDir=$2
      shift 2
    else
      printf "\033[31m$2 is not a directory.\033[0m\n"
      exit 1
    fi
    ;;
    -a)
    reqinp $1 $2
    bins+=" $2";shift 2 ;;
    -b)
    if [[ -z $2  || $2 =~ ^\-.* ]];then
      printf "\033[31m$1 flag requires an argument\033[0m\n"
      exit 1; fi
    bins=$2;shift 2
    ;;
    *)
    printf "\033[31mI dont understand what you meant with \033[7m$1\033[0m\n"
    exit 1 ;;
esac
done
###########################
#######Action##############
printf "\033[32mStarting ...\033[0m\n"
printf "\033[36mProgram variables$reset
Base Dir                          : $baseDir
Binaries to put into jail         : $bins
Numbers of parallel Jails         : $dirNum
\033[35mHit enter to continue or ctrl -c to purge config and start over\033[1A\033[0m\n"
read
dirMake
printf "dirs succesfully created continuing to copy binaries\n"
cpBins
