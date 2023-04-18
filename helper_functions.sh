GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m' # No Color

function echog(){
   echo -e "${RED}${STEP_INDEX}${NC} : ${GREEN}$1${NC}"
}
function echor(){
   echo -e "${RED}${STEP_INDEX}${NC} : ${RED}$1${NC}"
}
function cleanup_alvr(){
   echog "Cleaning up ALVR"
   for vrp in vrdashboard vrcompositor vrserver vrmonitor vrwebhelper vrstartup alvr_dashboard; do
     pkill -f $vrp
   done
   sleep 3
   for vrp in vrdashboard vrcompositor vrserver vrmonitor vrwebhelper vrstartup alvr_dashboard; do
     pkill -f -9 $vrp
   done
}
