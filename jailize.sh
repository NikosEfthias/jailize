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
baseDir=$(pwd)
nameDir="jail"
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
  $(mkdir $baseDir/$nameDir)
  printf "\033[32m$nameDir is created creating config folder inside\033[0m\n"
  $(eval "mkdir $baseDir/$nameDir/{bin,lib,dev,etc,lib64}")
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
    printf "\033[32m cp $binAddr --> $nameDir/bin\033[0m\n"
    $(mkdir -p $baseDir/$nameDir$(dirname $binAddr))
    $(cp  $binAddr $baseDir/$nameDir$binAddr)
    ldd=$(ldd $binAddr |cut -d ">" -f2|cut -d "(" -f1)
    for l in $ldd ;do
      if [[ -n $l ]]; then
          $(mkdir -p $baseDir/$nameDir$(dirname $l))
          printf "\033[32m cp $l --> $baseDir/$nameDir$l\033[0m\n"
          $(cp $l $baseDir/$nameDir/.$l)
      fi
  done
  else
    printf "\033[31m$i cannot be found You may need to copy it manually\033[0m
Hit enter to continue or ctrl+c to quit script\n"
read
  fi
done
}
################
###Parse Command Line Args########
while [[ -n $1 ]];do
# run wcript with -h flag to see help text
   if [[ $1 =~ ^[^-].* ]] ; then
     printf "\033[31mI dont understand what you meant with \033[7m$1\033[0m\n"
     exit 1
   fi
case $1 in
  -h)
  params=("-n" "--name" "-d" "-b" "-a" "--add-rec" "-h")
  printf "\nCreate Chroot Jails
\nUsage jailize.sh [options]
  Options
    %s            name of the folder default=jail
    %s            same as n oprion but more verbose
    %s            Base directory if no given current working directory is default
    %s            Whitespace seperated binary list string to put each with dependent libraries into jails
          default value is 'su ls rm mv bash'
    %s            Append a binary to include into binary list
          format :  jailize -a 'bin1 bin2 bin3'
    %s            Show this help text\n\n" ${params[@]}
    exit 1
    ;;
    -n|--name|-name)
      reqinp $1 $2
      nameDir=$2
      shift 2
      ;;
    -d)
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
Name of the Jail                  : $nameDir
\033[35mHit enter to continue or ctrl -c to purge config and start over\033[1A\033[0m\n"
read
dirMake
printf "dirs succesfully created continuing to copy binaries\n"
cpBins
