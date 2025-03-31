for i in `seq 6 9`
do

    nc -vz 192.168.1.8$i 22
    # ssh-keyscan 192.168.2.7$i

    ssh-keyscan 192.168.1.8$i >/dev/null 2>&1

done

