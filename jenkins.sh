#! /bin/bash

chown jenkins:jenkins /var/jenkins_home

add_extra_host() {
	if [ -n "$ADD_HOSTS" ]; then
		OIFS=$IFS
		IFS=$','
	
		for item in $ADD_HOSTS
		do
	  		ip=$(echo $item | awk -F '[/:]' '{print $1}')
	  		host=$(echo $item | awk -F '[/:]' '{print $2}')
	  		printf '%s\t%s\n' $ip $host | tee -a /etc/hosts > /dev/null
		done

	IFS=${OIFS}
	fi	
}


# Copy files from /usr/share/jenkins/ref into /var/jenkins_home
# So the initial JENKINS-HOME is set with expected content. 
# Don't override, as this is just a reference setup, and use from UI 
# can then change this, upgrade plugins, etc.
copy_reference_file() {
	f=${1%/} 
	echo "$f"
    rel=${f:23}
    dir=$(dirname ${f})
    echo " $f -> $rel"    
	if [[ ! -e /var/jenkins_home/${rel} ]] 
	then
		echo "copy $rel to JENKINS_HOME"
		gosu jenkins mkdir -p /var/jenkins_home/${dir:23}
		gosu jenkins cp -r /usr/share/jenkins/ref/${rel} /var/jenkins_home/${rel}; 
	fi; 
}

add_extra_host

export -f copy_reference_file

find /usr/share/jenkins/ref/ -type f -exec bash -c 'copy_reference_file {}' \;


# if `docker run` first argument start with `--` the user is passing jenkins launcher arguments
if [[ $# -lt 1 ]] || [[ "$1" == "--"* ]]; then
   exec gosu jenkins java $JAVA_OPTS -jar /usr/share/jenkins/jenkins.war $JENKINS_OPTS "$@"
fi

# As argument is not jenkins, assume user want to run his own process, for sample a `bash` shell to explore this image
exec gosu jenkins "$@"
