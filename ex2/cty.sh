#!/bin/bash

if [[ -z ${1} || -z ${2} || -z ${3} ]]
then
	echo "One or more parameters missing" 1>&2
	exit 1
fi

if [[ ! -f ${1} ]]
then
	echo "'${1}': file not found" 1>&2
	exit 1
fi

if [[ ! -r ${1} ]]
then
	echo "'${1}': lack of read permissions" 1>&2
	exit 1
fi

if [[ ${2} != "country" && ${2} != "zones" && ${2} != "distance" ]]
then
	echo "${2}: command not found" 1>&2
	exit 1
fi

if [[ ${2} == "distance" && -z ${4} ]]
then
	echo "${2}: command requires two arguments" 1>&2
	exit 1
fi

fields=$(echo "2,5,6,7,8,10")

function rowResult() {
 	result_exact_sign=$(cat ${1} | cut -d ',' -f ${fields} | egrep -m1 -i "[[:space:],]=${3}(\(+[[:digit:]]*\)+)?(\[+[[:digit:]]*\]+)?[[:space:];,]")

	if [[ ! -z ${result_exact_sign} ]]
	then
		echo ${result_exact_sign}
		return 0
	fi

	sign_length=$(echo ${#3})

	if [[ ${sign_length} -ge 4 ]]
	then
		prefix_four=$(echo ${3} | cut -c1-4)
		result_prefix_four=$(cat ${1} | cut -d ',' -f ${fields} | egrep -m1 -i "^(.*,.*,.*,.*,.*)+[[:space:],]${prefix_four}(\(+[[:digit:]]*\)+)?(\[+[[:digit:]]*\]+)?[[:space:];,]"
)
		if [[ ! -z ${result_prefix_four} ]]
		then
			echo ${result_prefix_four}
			return 0
		fi
	fi

	if [[ ${sign_length} -ge 3 ]]
	then
		prefix_three=$(echo ${3} | cut -c1-3)
		result_prefix_three=$(cat ${1} | cut -d ',' -f ${fields} | egrep -m1 -i "^(.*,.*,.*,.*,.*)+[[:space:],]${prefix_three}(\(+[[:digit:]]*\)+)?(\[+[[:digit:]]*\]+)?[[:space:];,]"
)

		if [[ ! -z ${result_prefix_three} ]]
		then
			echo ${result_prefix_three}
			return 0
		fi
	fi

	if [[ ${sign_length} -ge 2 ]]
	then
		prefix_two=$(echo ${3} | cut -c 1,2)
		result_prefix_two=$(cat ${1} | cut -d ',' -f ${fields} | egrep -m1 -i "^(.*,.*,.*,.*,.*)+[[:space:],]${prefix_two}(\(+[[:digit:]]*\)+)?(\[+[[:digit:]]*\]+)?[[:space:];,]"
)

		if [[ ! -z ${result_prefix_two} ]]
		then
			echo ${result_prefix_two}
			return 0
		fi
	fi

	if [[ ${sign_length} -ge 1 ]]
	then
		prefix_one=$(echo ${3} | cut -c1)
		result_prefix_one=$(cat ${1} | cut -d ',' -f ${fields} | egrep -m1 -i "^(.*,.*,.*,.*,.*)+[[:space:],]${prefix_one}(\(+[[:digit:]]*\)+)?(\[+[[:digit:]]*\]+)?[[:space:];,]"
)
	
		if [[ ! -z ${result_prefix_one} ]]
		then
			echo ${result_prefix_one}
			return 0
		fi
	fi

	return 1
}

if [[ ${2} == "country" ]]
then
	result=$(echo $(rowResult ${1} ${2} ${3}))

	if [[ ! -z ${result} ]]
	then
	 	matched=$(echo ${3} | egrep -io "/+[[:alnum:]]*(([\(\[])+|$)" | tr -d '/' | tr -d '(' | tr -d '[')

	 	if [[ ! -z ${matched} ]]
	 	then
	 		first_result=$(echo ${result} | cut -d ',' -f1)
	 		second_result=$(rowResult ${1} ${2} ${matched} | cut -d ',' -f1)

	 		if [[ ! -z ${second_result} ]]
	 		then
	 			if [[ ${second_result} != ${first_result} ]]
	 			then			
		 			echo "${first_result} (${second_result})"
		 			exit 0
		 		else
					echo ${result} | cut -d ',' -f1
					exit 0		 			
		 		fi
	 		fi
	 	fi
	 	
		echo ${result} | cut -d ',' -f1
		exit 0
	fi

	exit 1
fi

if [[ ${2} == "zones" ]]
then
	result=$(rowResult ${1} ${2} ${3})

	if [[ ! -z ${result} ]]
	then
		ITU=$(echo ${result} | cut -d ',' -f3)
 		WAZ=$(echo ${result} | cut -d ',' -f2)

 		sign=$(echo ${result} | cut -d ',' -f6 | egrep -m1 -i -o "([[:space:],])?=${3}(\(+[[:digit:]]*\)+)?(\[+[[:digit:]]*\]+)?[[:space:];,]")

 		if [[ -z ${sign} ]]
 		then
	 		sign=$(echo ${result} | cut -d ',' -f6 | egrep -m1 -i -o "([[:space:],])?${3}(\(+[[:digit:]]*\)+)?(\[+[[:digit:]]*\]+)?[[:space:];,]")
	 	fi

	 	if [[ ! -z ${sign} ]]
	 	then
	 		if_ITU=$(echo ${sign} | egrep -m1 -i -o "(\[+[[:digit:]]*\]+)?")

	 		if [[ ! -z ${if_ITU} ]]
	 		then
	 			ITU=$(echo ${if_ITU} | tr -d '[' | tr -d ']')
	 		fi

	 		if_WAZ=$(echo ${sign} | egrep -m1 -i -o "(\(+[[:digit:]]*\)+)?")

	 		if [[ ! -z ${if_WAZ} ]]
	 		then
	 			WAZ=$(echo ${if_WAZ} | tr -d '(' | tr -d ')')
	 		fi
	 	fi

 		echo "${ITU} ${WAZ}"
 		exit 0
	fi

	exit 1
fi

if [[ ${2} == "distance" ]]
then
	first_sign=$(echo $(rowResult ${1} ${2} ${3}))
	second_sign=$(echo $(rowResult ${1} ${2} ${4}))

	if [[ ! -z ${first_sign} && ! -z ${second_sign} ]]
	then
		lat1=$(echo ${first_sign} | cut -d ',' -f4)
		lat2=$(echo ${second_sign} | cut -d ',' -f4)
		lon1=$(echo ${first_sign} | cut -d ',' -f5)
		lon2=$(echo ${second_sign} | cut -d ',' -f5)

		rlat1=$(awk -v awklat1=${lat1} 'BEGIN {PI=3.14159265; print awklat1 * PI / 180;}')
		rlat2=$(awk -v awklat2=${lat2} 'BEGIN {PI=3.14159265; print awklat2 * PI / 180;}')
		rlon1=$(awk -v awklon1=${lon1} 'BEGIN {PI=3.14159265; print awklon1 * PI / 180;}')
		rlon2=$(awk -v awklon2=${lon2} 'BEGIN {PI=3.14159265; print awklon2 * PI / 180;}')

		dlat=$(awk -v awklat1=${rlat1} -v awklat2=${rlat2} 'BEGIN {print awklat2 - awklat1;}')
		dlon=$(awk -v awklon1=${rlon1} -v awklon2=${rlon2} 'BEGIN {print awklon2 - awklon1;}')

		calc=$(awk -v awklat1=${rlat1} -v awklat2=${rlat2} -v awkdlat=${dlat} -v awkdlon=${dlon} 'BEGIN {print sin(awkdlat / 2)^2 + cos(awklat1) * cos(awklat2) * sin(awkdlon / 2)^2}')
		calc_second=$(awk -v awkcalc=${calc} 'BEGIN {x = sqrt(awkcalc); y = sqrt(1 - x*x); print 2*atan2(x, y);}')
		result=$(awk -v awkcalc_second=${calc_second} 'BEGIN {r = 6371; printf "%.0f", awkcalc_second * r}')

		echo ${result}
		exit 0
	fi

	exit 1
fi