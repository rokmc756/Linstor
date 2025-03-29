for i in `seq 1 6`
do

    nc -vz 192.168.1.17$i 22
    # ssh-keyscan 192.168.2.7$i

    ssh-keyscan 192.168.1.17$i >/dev/null 2>&1

done

