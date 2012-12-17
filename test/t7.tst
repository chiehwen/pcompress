#
# Test crypto
#
echo "#################################################"
echo "# Pipe mode Crypto tests"
echo "#################################################"

rm -f *.pz
rm -f *.1

for algo in lzfx adapt2
do
	for tf in comb_d.dat
	do
		for feat in "-e" "-e -L" "-D -e" "-D -EE -L -e" "-e -S CRC64"
		do
			for seg in 2m 5m
			do
				echo "sillypassword" > /tmp/pwf
				cmd="cat ${tf} | ../../pcompress -c${algo} -p -l3 -s${seg} $feat -w /tmp/pwf > ${tf}.pz"
				echo "Running $cmd"
				eval $cmd
				if [ $? -ne 0 ]
				then
					echo "FATAL: Compression errored."
					exit 1
				fi

				pw=`cat /tmp/pwf`
				if [ "$pw" = "sillypassword" ]
				then
					echo "FATAL: Password file /tmp/pwf not zeroed!"
					exit 1
				fi

				echo "sillypassword" > /tmp/pwf
				cmd="../../pcompress -d -w /tmp/pwf ${tf}.pz ${tf}.1"
				echo "Running $cmd"
				eval $cmd
				if [ $? -ne 0 ]
				then
					echo "FATAL: Decompression errored."
					exit 1
				fi

				diff ${tf} ${tf}.1 > /dev/null
				if [ $? -ne 0 ]
				then
					echo "FATAL: Decompression was not correct"
					exit 1
				fi

				pw=`cat /tmp/pwf`
				if [ "$pw" = "sillypassword" ]
				then
					echo "FATAL: Password file /tmp/pwf not zeroed!"
					exit 1
				fi
				rm -f ${tf}.pz ${tf}.1
			done
		done
	done
done

rm -f /tmp/pwf

echo "#################################################"
echo ""
