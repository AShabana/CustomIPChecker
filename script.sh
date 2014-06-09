#!/bin/bash

# Each field contain #T.D may require review from you

print_usage()
{
        echo -e "Usage :\n\t$0 [-r] source_directory distination_directory"
        exit 1
}
exe()
{
if [ ! -x $file ] && [ ! -d $file ]
then
        mkdir -p "$cwd/$dst_dir/$(dirname $file)"
        IPs=`egrep '([[:digit:]]{1,3}\.){3}' $file`
        sed  's/172\.\(1[6-9]\|2[0-9]\|3[0-1]\)\.[[:digit:]\{1,3\}]\.[[:digit:]\{1,3\}]/private-IP-address/g; s/192\.168\.[[:digit:]\{1,3\}]\.[[:digit:]\{1,3\}]/private-IP-address/g ; s/10\.[[:digit:]]\{1,3\}\.[[:digit:]]\{1,3\}\.[[:digit:]]\{1,3\}/private-IP-address/g;' $file > "$cwd/$dst_dir/$file"
        for ip in $IPs
        do
                        res=`nslookup $ip`
                        if [ $? -ne 0 ]
                        then
                                        IP[$ip]=$ip
                        else
                                        t=`echo $res | grep -o "name = .*" | cut -d" " -f3`
                                        IP[$ip]=$t
                        fi
        pat="sed -i 's/$ip/${IP[$ip]}/g'  $cwd/$dst_dir/$file"
        eval $pat
        done
        diff $file $cwd/$dst_dir/$file > $cwd/$dst_dir/$file.report
    echo -e  "$file Content\n==============\n"
    cat $cwd/$dst_dir/$file
    echo -e "Report for $file Content\n================\n"
    cat $cwd/$dst_dir/$file.report


fi
}
# Check cmd args
if  [ $# -gt 3 ] || [ $# -lt 2 ]
then
        print_usage
fi
if [ "$1" = "-r" ]
then
        RFlag="-R"
elif [ -d "$1" ] && [ $# -eq 2 ]
then
        src_dir=$1
else
        print_usage
fi
if [ -d "$2" ] && [ $# -eq 2 ]
then
        dst_dir=$2
elif [ -d "$2" ] && [ $# -eq 3 ]
then
        src_dir=$2
        if [ -d "$3" ] ;then dst_dir=$3 ; fi
fi
#main
# do logic and save at temp dir ( Remove private IP with const. and resolvable ip with name )
RFlag=""
cwd=`pwd`
if [ ${dst_dir:0:1} == "/" ]
then
        cwd=""
fi
declare -A IP

if [ "$RFlag" = "-R" ] # Use recurse
then
                cd $src_dir
                for file in `find .`
                do
                                        exe file
                                done
else  # Without recurse
                cd $src_dir
                for file in `ls`
                do
                                        exe file
                done
fi
# get diff between original and temp file and put to reports dir
exit 0


