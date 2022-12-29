#!/bin/bash

#################################
# Thrown together by Waylander. #
#    Not guaranteed to work.    #
#       Use with caution.       #
#################################

Version="1.1"
ReleaseDate="2022-12-29"

BLUE='\033[38;2;0;135;255m'
GREEN='\033[38;2;0;95;0m'
RED='\033[38;2;255;0;0m'
NC='\033[0m'
YELLOW='\033[38;2;255;221;0m'

ActiveConnectionsMSG="There are active connections."
NoActiveConnectionsMSG="There are no active connections."
NotFoundMSG="Uproxy could not be found."
NotRestarted="Uproxy could not be restarted."
NotRunningMSG="Uproxy is not running."
NotStarted="Uproxy could not be started."
NotStoppedMSG="Uproxy could not be stopped."
RestartedMSG="Uproxy restarted."
RestartingMSG="Restarting uproxy"
RunningMSG="Uproxy is running."
StartedMSG="Uproxy started."
StartingMSG="Starting uproxy"
StoppedMSG="Uproxy stopped."
StoppingMSG="Stopping uproxy"

if [[ $LC_ALL =~ \.[Uu][Tt][Ff]-?8 || $LANG =~ \.[Uu][Tt][Ff]-?8 || $LC_MESSAGES =~ \.[Uu][Tt][Ff]-?8 || $LC_CTYPE =~ \.[Uu][Tt][Ff]-?8 ]]; then
  DoneMSG=" ${GREEN}[ \u2714 ]${NC}"
  ErrorMSG=" ${RED}[ \u2715 ]${NC}"
  InfoMSG=" ${BLUE}[ \u2139 ]${NC}"
  WarningMSG=" ${YELLOW}[ \u0021 ]${NC}"
  UTF8="1"
else
  DoneMSG=" ${BLUE}[INFO]${NC}"
  ErrorMSG=" ${RED}[ERROR]${NC}"
  InfoMSG=" ${BLUE}[INFO]${NC}"
  WarningMSG=" ${YELLOW}[WARNING]${NC}"
  UTF8="0"
fi

function PrintDots ()
{
for ((i=1;i<=$1;i++)); do
  echo -n "."
  sleep 0.5
done
}

function GetStatus()
{
MyDIR=$(dirname "$0")
if [[ -f "$MyDIR/uproxy" && -f "$MyDIR/uproxy.sh" ]]; then
  top -b -n 1  | grep -w uproxy > /dev/null
  if [ $? -eq 0 ]; then
    UproxyPortsTotal=`cat $MyDIR/uproxy.sh | grep uproxy | sed -n '$='`
    UproxyPortsStart=`sort -n $MyDIR/uproxy.sh | grep uproxy | head -n 1 | awk '{print $3}'`
    UproxyPortsEnd=`sort -n $MyDIR/uproxy.sh | grep uproxy | tail -n 1 | awk '{print $3}'`
    UProxyPortsUsed=`netstat -an --programs 2>/dev/null | grep -w uproxy | grep -c '.'`
    if [[ $UProxyPortsUsed > $UproxyPortsTotal ]]; then
      Status="up2" #running with active connections
    else
      Status="up1" #running without active connections
    fi
  else
    Status="down" #stopped
  fi
else
  Status="gone" #not present
fi
}

function DisplayStatus()
{
GetStatus
if [[ $Status == down ]]; then
  echo -e "$InfoMSG $NotRunningMSG"
fi
if [[ $Status == up1 ]]; then
  echo -e "$DoneMSG $RunningMSG\n$InfoMSG Listening on ${BLUE}$UproxyPortsTotal${NC} ports from ${BLUE}$UproxyPortsStart${NC} to ${BLUE}$UproxyPortsEnd${NC}.\n$InfoMSG $NoActiveConnectionsMSG"
fi
if [[ $Status == up2 ]]; then
  echo -e "$DoneMSG $NotRunningMSG\n$InfoMSG Listening on ${BLUE}$UproxyPortsTotal${NC} ports from ${BLUE}$UproxyPortsStart${NC} to ${BLUE}$UproxyPortsEnd${NC}.\n$InfoMSG $ActiveConnectionsMSG"
fi
if [[ $Status == gone ]]; then
  echo -e "$ErrorMSG $NotFoundMSG"
fi
}

function DoStart()
{
GetStatus
if [[ $Status == up1 || $Status == up2 ]]; then
  echo -e "$ErrorMSG $RunningMSG"
fi
if [[ $Status == down ]]; then
  echo -e -n "$InfoMSG $StartingMSG"
  $MyDIR/uproxy.sh > /dev/null
  PrintDots 6
  echo -e ""
  GetStatus
  if [[ $Status == up1 || $Status == up2 ]]; then
    echo -e "$DoneMSG $StartedMSG"
  else
    echo -e "$ErrorMSG $NotStarted"
  fi
fi
if [[ $Status == gone ]]; then
  echo -e "$ErrorMSG $NotFoundMSG"
fi
}

function DoStop()
{
GetStatus
if [[ $Status == down ]]; then
  echo -e "$ErrorMSG $NotRunningMSG"
fi
if [[ $Status == up1 ]]; then
  echo -e -n "$InfoMSG $RunningMSG\n$InfoMSG $NoActiveConnectionsMSG $StoppingMSG"
  pkill -x uproxy > /dev/null
  PrintDots 6
  echo -e ""
  GetStatus
  if [[ $Status == down ]]; then
    echo -e "$DoneMSG $StoppedMSG"
  else
    echo -e "$ErrorMSG $NotStoppedMSG"
  fi
fi
if [[ $Status == up2 ]]; then
  echo -e "$InfoMSG $RunningMSG"
  if [[ $SilentMode != 1 ]]; then
    echo -e -n "$WarningMSG $ActiveConnectionsMSG "
    read -r -p "Drop active connections and halt anyway? [y/N] " response
    response=${response,,}
  else
    echo -e "$WarningMSG $ActiveConnectionsMSG Drop active connections and halt anyway? [y/N] y"
    response="y"
  fi
  if [[ "$response" =~ ^(yes|y)$ ]]; then
      echo -e -n "$InfoMSG $StoppingMSG"
      pkill -x uproxy > /dev/null
      PrintDots 6
      echo -e ""
      GetStatus
      if [[ $Status == down ]]; then
        echo -e "$DoneMSG $StoppedMSG"
      else
        echo -e "$ErrorMSG $NotStoppedMSG"
      fi
  else
    echo -e "$InfoMSG Stopping uproxy aborted."
  fi
fi
if [[ $Status == gone ]]; then
  echo -e "$ErrorMSG $NotFoundMSG"
fi
}

function DoRestart()
{
GetStatus
if [[ $Status == up1 ]]; then
  echo -e -n "$InfoMSG $RunningMSG\n$InfoMSG $NoActiveConnectionsMSG $RestartingMSG"
  pkill -x uproxy > /dev/null
  PrintDots 3
  $MyDIR/uproxy.sh > /dev/null
  PrintDots 3
  echo -e ""
  if [ $? -eq 0 ]; then
    if [[ $Status == up1 || $Status == up2 ]]; then
      echo -e "$DoneMSG $RestartedMSG"
    fi
  else
    echo -e "$ErrorMSG $NotRestarted"
  fi
fi
if [[ $Status == up2 ]]; then
  echo -e "$InfoMSG $RunningMSG"
  if [[ $SilentMode != 1 ]]; then
    echo -e -n "$WarningMSG $ActiveConnectionsMSG "
    read -r -p "Drop active connections and restart anyway? [y/N] " response
    response=${response,,}
  else
    echo -e "$WarningMSG $ActiveConnectionsMSG Drop active connections and restart anyway? [y/N] y"
    response="y"
  fi
  if [[ "$response" =~ ^(yes|y)$ ]]; then
    echo -e -n "$InfoMSG $RestartingMSG"
    pkill -x uproxy > /dev/null
    PrintDots 3
    $MyDIR/uproxy.sh > /dev/null
    PrintDots 3
    echo -e ""
    if [ $? -eq 0 ]; then
      if [[ $Status == up1 || $Status == up2 ]]; then
        echo -e "$DoneMSG $RestartedMSG"
      fi
    else
      echo -e "$ErrorMSG $NotRestarted"
    fi
  else
    echo -e "$InfoMSG Restarting uproxy aborted."
  fi
fi
if [[ $Status == down ]]; then
  echo -e -n "$ErrorMSG $NotRunningMSG "
  if [[ $SilentMode != 1 ]]; then
    read -r -p "Start now? [y/N] " response
    response=${response,,}
  else
    echo -e "Start now? [y/N] y"
    response="y"
  fi
  if [[ "$response" =~ ^(yes|y)$ ]]; then
    echo -e -n "$InfoMSG $StartingMSG"
    $MyDIR/uproxy.sh > /dev/null
    PrintDots 6
    echo -e ""
    GetStatus
    if [[ $Status == up1 || $Status == up2 ]]; then
      echo -e "$DoneMSG $StartedMSG"
    else
      echo -e "$ErrorMSG $NotStarted"
    fi
  else
    echo -e "$InfoMSG Not starting uproxy."
  fi
fi
if [[ $Status == gone ]]; then
  echo -e "$ErrorMSG $NotFoundMSG"
fi
}

function DisplayPortsListen()
{
GetStatus
if [[ $Status == down ]]; then
  echo -e "$ErrorMSG $NotRunningMSG"
fi
if [[ $Status == up1 || $Status == up2 ]]; then
  echo -e "$InfoMSG Uproxy is listening on the following ${BLUE}$UproxyPortsTotal${NC} ports:"
  if [[ $UTF8 == 1 ]]; then sort -n uproxy.sh | grep uproxy | awk '{print "      ", $3}'
  else sort -n uproxy.sh | grep uproxy | awk '{print "       ", $3}'
  fi
fi
if [[ $Status == gone ]]; then
  echo -e "$ErrorMSG $NotFoundMSG"
fi
}

function DisplayPortsUsed()
{
GetStatus
if [[ $Status == down ]]; then
  echo -e "$ErrorMSG $NotRunningMSG"
fi
if [[ $Status == up1 || $Status == up2 ]]; then
  echo -e "$InfoMSG Uproxy is using the following ${BLUE}$UProxyPortsUsed${NC} ports:"
  if [[ $UTF8 == 1 ]]; then netstat -an --programs 2>/dev/null | grep -w uproxy | awk '{print $4}' | cut -d ":" -f 2 | awk '{print "      ", $1}'
  else netstat -an --programs 2>/dev/null | grep -w uproxy | awk '{print $4}' | cut -d ":" -f 2 | awk '{print "       ", $1}'
  fi
fi
if [[ $Status == gone ]]; then
  echo -e "$ErrorMSG $NotFoundMSG"
fi
}

function DisplayHelp()
{
echo -e ""
echo -e " uproxyCTRL v$Version ($ReleaseDate)."
echo -e ""
echo -e " A tool to control uproxy from the command line."
echo -e ""
echo -e " Usage: ./uproxyCTRL.sh [option]"
echo -e ""
echo -e " Options:"
echo -e " ├─ help            Display this help."
echo -e " ├─ listenports     Display all ports uproxy is listening on."
echo -e " ├─ restart         Restart uproxy."
echo -e " ├─ start           Start uproxy."
echo -e " ├─ status          Display status of uproxy."
echo -e " ├─ stop            Stop uproxy."
echo -e " └─ usedports       Display all ports uproxy is using."
echo -e ""
}

function DisplayNotFound()
{
echo -e "$ErrorMSG Command not found. Use \"-help\" for instructions."
}

if [[ $# = 0 ]]; then
  DisplayHelp
else
  case "${1}" in
    "help" | "-help" | "--help"       ) DisplayHelp;;
    "listenports" | "-listenports"    ) DisplayPortsListen;;
    "restart" | "-restart"            )
                                      if [[ $2 == "-y" ]]; then
                                        SilentMode=1
                                      else
                                        SilentMode=0
                                      fi
                                      DoRestart;;
    "start" | "-start"                )
                                      if [[ $2 == "-y" ]]; then
                                        SilentMode=1
                                      else
                                        SilentMode=0
                                      fi
                                      DoStart;;
    "status" | "-status"              ) DisplayStatus;;
    "stop" | "-stop"                  )
                                      if [[ $2 == "-y" ]]; then
                                        SilentMode=1
                                      else
                                        SilentMode=0
                                      fi
                                      DoStop;;
    "usedports" | "-usedports"        ) DisplayPortsUsed;;
    *                                 ) DisplayNotFound
  esac
fi
