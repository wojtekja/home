#!/bin/bash 
#
path_chain=/var/lib/rundeck/scheduler/jobs/
path_exec=/var/lib/rundeck/scheduler/execs/
RD_CONF=/home/s5e5nf/rundeck/rd.conf
export RD_CONF

echo "A)Create host file"
echo "B)Prepare the schedule"
echo "C)Execute the schedule"
read INPUT    


        case $INPUT in

          A)


echo "Patching start date: YYYY-MM-DD - IMPORTANT TO KEEP THIS FORMAT!"
read date_for_dir

if [ -d "$path_chain/$date_for_dir" ]; then
echo "directory exist.... exiting"
exit 4
fi
mkdir -p $path_chain/$date_for_dir; touch $path_chain/$date_for_dir/hosts
echo " Please insert hosts with detailed time to execution to (HOSTNAME START HOUR): ${path_chain}${date_for_dir}/hosts"
exit 0

        ;;
        B)

echo " choose the date for submit defined AC "

ls $path_chain
read data_selected_display

data=$data_selected_display

echo " clean folder before start"
sleep 1
rm -rf $path_chain/$data_selected_display/2019-*
rm -rf $path_exec/$data_selected_display/2019-*
sleep 1
echo " removed old jobd from the selected date"
rd jobs list -p Patching | sed '/^[[:space:]]*$/d' | grep -v "#" |awk {'print $2'} | grep $data_selected_display | tee temp/temp_list_jobs
for i in `cat temp/temp_list_jobs`; do echo rd jobs purge -J $i -p Patching -y ;done | /bin/bash 
sleep 1
echo "create job folders.." 
sleep 1
awk -v adata="${data}" '{print "mkdir -p ""jobs/"adata"/"adata"T"$2}' $path_chain/$data_selected_display/hosts |sort|uniq|/bin/bash
sleep 1
echo "done"
sleep 1
echo "create hostname files.."
sleep 1
awk -v adata="${data}" '{print "touch ""jobs/"adata"/"adata"T"$2"/"$1}' $path_chain/$data_selected_display/hosts|/bin/bash 
echo "done"
sleep 1
echo "setup the jobs.."
sleep 1
mkdir -p $path_exec/$data_selected_display
for i in `ls -d jobs/$data_selected_display/*/ | tr "/" " " | awk {'print $3'}`; do name=$i filter=`ls jobs/$data_selected_display/$i` ./yaml_generator.sh job_template.yaml > execs/$data_selected_display/$i.yaml ;done
echo "done"
echo "run the jobs.."
sleep 1

for i in `ls $path_exec/$data_selected_display |grep yaml`; do rd jobs load -F yaml -f $path_exec/$data_selected_display/$i -p Patching;done


echo "the jobs are scheduled now.. please setup execution to schedule the jobs.."



        ;;
        C)

echo "Select date:"
ls $path_chain
read data_selected_display

echo "searching defined jobs.."
echo " "
rd jobs list -p Patching | sed '/^[[:space:]]*$/d' | grep -v "#" |awk {'print $2'} | grep $data_selected_display | tee temp/temp_list_jobs 

echo "execute the jobs?"

read -r -p " Are you sure? [y/N] " response
case $response in
        [yY][eE][sS]|[yY])

        for i in `cat temp/temp_list_jobs`; do echo rd run -j $i --at $i":00+0200" -p Patching ;done |/bin/bash





        echo done
exit 4
        ;;
esac
;;

          *)    continue
                ;;
        esac

