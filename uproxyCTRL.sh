#!/bin/bash

#########################################
#     Thrown together by Waylander.     #
#        Not guaranteed to work.        #
#           Use with caution.           #
#                                       #
#           http://git.txk.nf           #
#########################################

Version="1.2"
DateOfCrime="2022-12-31"

BLUE='\033[38;2;0;135;255m'
GREY='\033[38;2;88;88;88m'
ITALIC='\033[3m'
GREEN='\033[38;2;0;95;0m'
RED='\033[38;2;255;0;0m'
NC='\033[0m'
YELLOW='\033[38;2;255;221;0m'

ActiveConnectionsMSG="There are active connections."
NoActiveConnectionsMSG="There are no active connections."
NoEntriesInConfigMSG="There are no entries in uproxyCTRL.conf."
NotFoundMSG="Uproxy and/or uproxyCTRL.conf could not be found."
NotRestarted="Uproxy could not be restarted."
NotRunningMSG="Uproxy is not running."
NotStarted="Uproxy could not be started."
NotStoppedMSG="Uproxy could not be stopped."
RestartedMSG="Uproxy restarted."
RestartingMSG="Restarting uproxy"
RunningMSG="Uproxy is running."
StatusUnknown="Could not get info from uproxy."
StartedMSG="Uproxy started."
StartingMSG="Starting uproxy"
StoppedMSG="Uproxy stopped."
StoppingMSG="Stopping uproxy"

if [[ $LC_ALL =~ \.[Uu][Tt][Ff]-?8 || $LANG =~ \.[Uu][Tt][Ff]-?8 || $LC_MESSAGES =~ \.[Uu][Tt][Ff]-?8 || $LC_CTYPE =~ \.[Uu][Tt][Ff]-?8 ]]; then
  DoneMSG=" ${GREEN}[ ✓ ]${NC}"
  ErrorMSG=" ${RED}[ x ]${NC}"
  InfoMSG=" ${BLUE}[ i ]${NC}"
  WarningMSG=" ${YELLOW}[ ! ]${NC}"
else
  DoneMSG=" ${BLUE}[ i ]${NC}"
  ErrorMSG=" ${RED}[ E ]${NC}"
  InfoMSG=" ${BLUE}[ i ]${NC}"
  WarningMSG=" ${YELLOW}[ W ]${NC}"
fi

MyDIR=$(dirname "$0")

function PrintDots ()
{
for ((i=1;i<=$1;i++)); do
  echo -n "."
  sleep 0.5
done
}

function EmptyConfig ()
{
if [[ "$(grep -v "^$" "$MyDIR"/uproxyCTRL.conf | awk '!/^#/{ print $1 }' | grep -c '.')" == 0 ]]; then
  return 0
else
  return 1
fi
}

function SaveTempFile ()
{
sort -n "$MyDIR"/uproxyCTRL.conf | grep -v "^$" | awk '!/^#/{ print $1, $2, $3 }' > "$MyDIR"/.uproxyCTRL.tmp
}

function GetStatus()
{
if [[ -f "$MyDIR/uproxy" && -f "$MyDIR/uproxyCTRL.conf" ]]; then
  if top -b -n 1  | grep -w uproxy > /dev/null; then
    Status="up" #running with unknown status
    if [[ -f "$MyDIR/.uproxyCTRL.tmp" ]]; then
      UproxyPortsTotalTEMP=$(grep -v "^$" "$MyDIR"/.uproxyCTRL.tmp | awk '!/^#/{ print $1 }' | grep -c '.')
      UproxyPortsStartTEMP=$(sort -n "$MyDIR"/.uproxyCTRL.tmp | grep -v "^$" | awk '!/^#/{ print $1 }' | head -n 1)
      UproxyPortsEndTEMP=$(sort -n "$MyDIR"/.uproxyCTRL.tmp | grep -v "^$" | awk '!/^#/{ print $1 }' | tail -n 1 )
      UProxyPortsUsed=$(netstat -an --programs 2>/dev/null | grep -w uproxy | grep -c '.')
      if [[ $UProxyPortsUsed > $UproxyPortsTotalTEMP ]]; then
        Status="up2" #running with active connections
        UProxyClients=$(( "$UProxyPortsUsed" - "$UproxyPortsTotalTEMP"))
      else
        Status="up1" #running without active connections
      fi
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
  echo -e "$DoneMSG $RunningMSG\n$InfoMSG Listening on ${BLUE}$UproxyPortsTotalTEMP${NC} ports from ${BLUE}$UproxyPortsStartTEMP${NC} to ${BLUE}$UproxyPortsEndTEMP${NC}.\n$InfoMSG $NoActiveConnectionsMSG"
fi
if [[ $Status == up2 ]]; then
  echo -e "$DoneMSG $RunningMSG\n$InfoMSG Listening on ${BLUE}$UproxyPortsTotalTEMP${NC} ports from ${BLUE}$UproxyPortsStartTEMP${NC} to ${BLUE}$UproxyPortsEndTEMP${NC}.\n$InfoMSG $ActiveConnectionsMSG Apparently serving ${BLUE}$UProxyClients${NC} client(s)."
fi
if [[ $Status == gone ]]; then
  echo -e "$ErrorMSG $NotFoundMSG"
fi
if [[ $Status == up ]]; then
  echo -e "$DoneMSG $RunningMSG\n$ErrorMSG $StatusUnknown"
fi
}

function ExecuteUproxy()
{
UproxyPortsTotalCONF=$(grep -v "^$" "$MyDIR"/uproxyCTRL.conf | awk '!/^#/{ print $1 }' | grep -c '.')
for ((i=1;i<=UproxyPortsTotalCONF;i++)); do
  OwnPort=$(grep -v "^$" "$MyDIR"/uproxyCTRL.conf | awk '!/^#/{ print $1 }' | head -n $i | tail -n 1)
  TargetIP=$(grep -v "^$" "$MyDIR"/uproxyCTRL.conf | awk '!/^#/{ print $2 }'| head -n $i | tail -n 1)
  TargetPort=$(grep -v "^$" "$MyDIR"/uproxyCTRL.conf | awk '!/^#/{ print $3 }' | head -n $i | tail -n 1)
  nohup "$MyDIR"/uproxy "$OwnPort" "$TargetIP" "$TargetPort" >/dev/null 2>&1 2>&1 &
done
}

function DoStart()
{
GetStatus
if [[ $Status == up || $Status == up1 || $Status == up2 ]]; then
  echo -e "$ErrorMSG $RunningMSG"
fi
if [[ $Status == down ]]; then
  echo -e -n "$InfoMSG $StartingMSG"
  if EmptyConfig; then
    PrintDots 6
    echo -e "\n$ErrorMSG $NoEntriesInConfigMSG\n$ErrorMSG $NotStarted"
  else
    ExecuteUproxy
    PrintDots 6
    SaveTempFile
    GetStatus
    if [[ $Status == up1 || $Status == up2 ]]; then
      echo -e "\n$DoneMSG $StartedMSG"
    else
      echo -e "\n$ErrorMSG $NotStarted"
    fi
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
  if EmptyConfig; then
    PrintDots 6
    echo -e "\n$ErrorMSG $NoEntriesInConfigMSG\n$ErrorMSG $NotRestarted"
  else
    pkill -x uproxy > /dev/null
    PrintDots 3
    ExecuteUproxy
    PrintDots 3
    SaveTempFile
    GetStatus
    if [[ $Status == up1 || $Status == up2 ]]; then
        echo -e "\n$DoneMSG $RestartedMSG"
    else
      echo -e "\n$ErrorMSG $NotRestarted"
    fi
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
  if [[ $response =~ ^(yes|y)$ ]]; then
    echo -e -n "$InfoMSG $RestartingMSG"
    if EmptyConfig; then
      PrintDots 6
      echo -e "\n$ErrorMSG $NoEntriesInConfigMSG\n$ErrorMSG $NotRestarted"
    else
      pkill -x uproxy > /dev/null
      PrintDots 3
      ExecuteUproxy
      PrintDots 3
      SaveTempFile
      GetStatus
      if [[ $Status == up1 || $Status == up2 ]]; then
         echo -e "\n$DoneMSG $RestartedMSG"
      else
        echo -e "\n$ErrorMSG $NotRestarted"
      fi
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
  if [[ $response =~ ^(yes|y)$ ]]; then
    echo -e -n "$InfoMSG $StartingMSG"
    if EmptyConfig; then
      PrintDots 6
      echo -e "\n$ErrorMSG $NoEntriesInConfigMSG\n$ErrorMSG $NotStarted"
    else
      ExecuteUproxy
      PrintDots 6
      SaveTempFile
      GetStatus
      if [[ $Status == up1 || $Status == up2 ]]; then
        echo -e "\n$DoneMSG $StartedMSG"
      else
        echo -e "\n$ErrorMSG $NotStarted"
      fi
    fi
  else
    echo -e "$InfoMSG Not starting uproxy."
  fi
fi
if [[ $Status == gone ]]; then
  echo -e "$ErrorMSG $NotFoundMSG"
fi
if [[ $Status == up ]]; then
  echo -e "$InfoMSG $RunningMSG\n$ErrorMSG $StatusUnknown"
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
  GetStatus
  if [[ $Status == down ]]; then
    echo -e "\n$DoneMSG $StoppedMSG"
    rm "$MyDIR"/.uproxyCTRL.tmp 2>/dev/null
  else
    echo -e "\n$ErrorMSG $NotStoppedMSG"
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
  if [[ $response =~ ^(yes|y)$ ]]; then
      echo -e -n "$InfoMSG $StoppingMSG"
      pkill -x uproxy > /dev/null
      PrintDots 6
      GetStatus
      if [[ $Status == down ]]; then
        echo -e "\n$DoneMSG $StoppedMSG"
        rm "$MyDIR"/.uproxyCTRL.tmp 2>/dev/null
      else
        echo -e "\n$ErrorMSG $NotStoppedMSG"
      fi
  else
    echo -e "$InfoMSG Stopping uproxy aborted."
  fi
fi
if [[ $Status == gone ]]; then
  echo -e "$ErrorMSG $NotFoundMSG"
fi
if [[ $Status == up ]]; then
  echo -e "$InfoMSG $RunningMSG\n$ErrorMSG $StatusUnknown"
fi
}

function DisplayPorts()
{
GetStatus
if [[ $Status == down ]]; then
  echo -e "$ErrorMSG $NotRunningMSG"
fi
if [[ $Status == up1 || $Status == up2 ]]; then
  echo -e "$InfoMSG Uproxy is using the following ${BLUE}$UProxyPortsUsed${NC} ports:"
  for ((i=1;i<=UproxyPortsTotalTEMP;i++)); do
    UProxyClientPort=$(sort -n "$MyDIR"/.uproxyCTRL.tmp | grep -v "^$" | awk '!/^#/{ print $1 }' | head -n $i | tail -n 1)
    if (( UProxyClientPort >= 10000 )); then
      Spaces="   "
    else
      Spaces="    "
    fi
    echo -e "       $UProxyClientPort $Spaces ${GREY}LISTEN${NC}"
  done
  if (( UProxyClients )); then
    for ((i=1;i<=UProxyClients;i++)); do
      UProxyClientPort=$(netstat -an --programs 2>/dev/null | grep -w uproxy | awk '{print $4}' | cut -d ":" -f 2 | sort -rn | head -n "$UProxyClients" | sort -n | head -n $i | tail -n 1)
      if (( UProxyClientPort > UproxyPortsEndTEMP )); then
        PID=$(netstat -an --programs 2>/dev/null | grep -w "$UProxyClientPort" | awk '{print $6}' | cut -d "/" -f 1)
        TargetIP=$(ps aux | grep uproxy | grep "$PID" | awk '{print $13}')
        TargetPort=$(ps aux | grep uproxy | grep "$PID" | awk '{print $14}')
        if (( UProxyClientPort >= 10000 )); then
          Spaces="   "
        else
          Spaces="    "
        fi
        echo -e "       $UProxyClientPort $Spaces ${RED}CLIENT${NC} for target $TargetIP:$TargetPort"
      fi
    done
  fi
fi
if [[ $Status == gone ]]; then
  echo -e "$ErrorMSG $NotFoundMSG"
fi
if [[ $Status == up ]]; then
  echo -e "$ErrorMSG $StatusUnknown"
fi
}

function DisplayHelp()
{
echo -e ""
echo -e " uproxyCTRL v$Version ($DateOfCrime)."
echo -e ""
echo -e " A tool to control uproxy from the command line."
echo -e ""
echo -e " Usage: ./uproxyCTRL.sh (-)[option] (-y)"
echo -e ""
echo -e " Options:"
echo -e " ├─ help            Display this help."
echo -e " ├─ ports           Display all ports uproxy is using."
echo -e " ├─ restart         Restart uproxy."
echo -e " │                  ${ITALIC}(Use a trailing -y to affirm any questions. Caution advised!)${NC}"
echo -e " ├─ start           Start uproxy."
echo -e " ├─ status          Display status of uproxy."
echo -e " └─ stop            Stop uproxy."
echo -e "                    ${ITALIC}(Use a trailing -y to affirm any questions. Caution advised!)${NC}"
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
    "ports" | "-ports"                ) DisplayPorts;;
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
    *                                 ) DisplayNotFound
  esac
fi
