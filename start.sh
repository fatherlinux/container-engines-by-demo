#!/usr/bin/env sh

# Author: Scott McCarty <scott.mccarty@gmail.com>
# Twitter: @fatherlinux
# Date: 03/15/2020
# Description: Demonstrate how a container engine works by mounting storage,
# constructing the config.json and passing to runc
 
# Setting up some colors for helping read the demo output.
# Comment out any of the below to turn off that color.
bold=$(tput bold)
cyan=$(tput setaf 6)
reset=$(tput sgr0)

read_color() {
    read -p "${bold}$1${reset}"
}

echo_color() {
    echo "${cyan}$1${reset}"
}

setup() {
	echo_color "Setting up"
}

intro() {
    read -p "Demonstrate how a container engine works by mounting storage, constructing the config.json and passing to runc"
    echo
}

demo_one() {
	echo
	echo_color "We are going to start a container as root, using both Podman and Docker to see if we can tell them apart."
	echo
	read_color "sudo podman run -id localhost/bash2"
	sudo podman run -id localhost/bash2
	echo
	read_color "sudo docker run -id localhost/bash2"
	sudo docker run -id localhost/bash2

	echo
	echo_color "Now, let's take a look at the processes we created. Notice, that they look identical, they are basically impossible to tall apart."
	echo
	read_color "ps -efZ | grep bash2 | grep -v grep"
	ps -efZ | grep bash2 | grep -v grep

	# Clean up those containers
	sudo podman kill -a > /dev/null 2>&1
	sudo podman rm -a > /dev/null 2>&1
	sudo docker kill `docker ps --no-trunc -q` > /dev/null 2>&1
	sudo docker rm `docker ps --no-trunc -a -q` > /dev/null 2>&1

	echo
	echo_color "Now, lets start a container as a regular user, using Podman and Docker to see if we can tell them apart."
	echo
	read_color "podman run -id localhost/bash2"
	podman run -id localhost/bash2
	echo
	read_color "docker run -id localhost/bash2"
	docker run -id localhost/bash2

	echo
	echo_color "Now, let's take a look at the processes we created. Notice, that they look identical, they are basically impossible to tall apart."
	echo
	read_color "ps -efZ | grep bash2 | grep -v grep"
	ps -efZ | grep bash2 | grep -v grep

	# Clean up those containers
	podman kill -a > /dev/null 2>&1
	podman rm -a > /dev/null 2>&1
	docker kill `docker ps --no-trunc -q` > /dev/null 2>&1
	docker rm `docker ps --no-trunc -a -q` > /dev/null 2>&1

	echo
	read_color "Go back to the presentation..."
}

demo_two() {
	echo
	echo_color "Podman is a great teaching tool. It lets us break the container creation down into a very granular proces. In this demo, we are going to complete the first step in creating a container. This step creates the meta data representation of the container in /var/lib/containers"
	echo
	read_color "sudo podman create -it registry.access.redhat.com/ubi8/ubi"
	CONTAINER_LABEL=`sudo podman create -it registry.access.redhat.com/ubi8/ubi`
	echo $CONTAINER_LABEL

	echo
	echo_color "Notice the state of the container:"
	echo
	read_color "sudo podman ps -a"
	sudo podman ps -a

	echo
	read_color "Go back to the presentation..."
}

demo_three() {
	echo
	echo_color "The meta data has been created, now let's have podman create the copy-on-write layer for our new container."
	echo
	read_color "sudo podman mount $CONTAINER_LABEL"
	CONTAINER_MOUNT_POINT=`sudo podman mount $CONTAINER_LABEL`
	echo $CONTAINER_MOUNT_POINT

	echo
	echo_color "Take a look at the contents of the mount point. It's the root filesystem (rootfs) of an operating system. It's all of the layers of the container image overlayed, with one copy-on-write layer on top."
	echo
	read_color "sudo ls -al $CONTAINER_MOUNT_POINT"
	sudo ls -al $CONTAINER_MOUNT_POINT

	echo
	echo_color "Now, let's add a file so that we can see it when we eventually start the container"
	echo
	read_color "sudo touch $CONTAINER_MOUNT_POINT/etc/testfile"
	sudo touch $CONTAINER_MOUNT_POINT/etc/testfile
	echo
	read_color "sudo ls -al $CONTAINER_MOUNT_POINT/etc/"
	sudo ls -al $CONTAINER_MOUNT_POINT/etc/

	echo
	echo_color "Notice the state of the container:"
	echo
	read_color "sudo podman ps -a"
	sudo podman ps -a

	echo
	read_color "Go back to the presentation..."
}

demo_four() {
	echo
	echo_color "Podman has a really cool feature to generate the config.json that is created by all container engines (Podman, Docker, CRI-O). We're going to use this command to create it and look at it. First let's checkout what is already created for the container:"
	echo
	read_color "sudo ls -alh /var/lib/containers/storage/overlay-containers/$CONTAINER_LABEL/userdata/"
	sudo ls -alh /var/lib/containers/storage/overlay-containers/$CONTAINER_LABEL/userdata/

	echo
	echo_color "Now, let's generate the config.json:"
	echo
	read_color "sudo podman init $CONTAINER_LABEL"
	sudo podman init $CONTAINER_LABEL

	echo
	echo_color "Notice that the config.json file is now there, along with a couple of other files:"
	echo
	read_color "sudo ls -alh /var/lib/containers/storage/overlay-containers/$CONTAINER_LABEL/userdata/"
	sudo ls -alh /var/lib/containers/storage/overlay-containers/$CONTAINER_LABEL/userdata/

	echo
	echo_color "Take a quick look at it. Notice all of the diffrent sections and pieces of metadata that conform to the OCI runtime start:"
	echo
	read_color "sudo cat /var/lib/containers/storage/overlay-containers/$CONTAINER_LABEL/userdata/config.json | jq ."
	sudo cat /var/lib/containers/storage/overlay-containers/$CONTAINER_LABEL/userdata/config.json | jq .

	echo
	echo_color "Notice the state of the container:"
	echo
	read_color "sudo podman ps -a"
	sudo podman ps -a

	echo
	read_color "Go back to the presentation..."
}

demo_five() {
	echo
	echo_color "The meta-date represetnation of the container has been created, the storage mounted, and the config.json file has been generated. Now, all that's left to do is hand the OCI compliant config.json file off to runc. This is simple to do with the start command:"
	echo
	read_color "sudo podman start $CONTAINER_LABEL"
	sudo podman start $CONTAINER_LABEL

	echo
	echo_color "We now have a fully functioning, running container. Take a look:"
	echo
	read_color "sudo podman ps"
	sudo podman ps

	echo
	read_color "Go back to the presentation..."
}

demo_six() {
	echo
	echo_color "Now, it's time to stop the container in a few different steps. Each step will help understand what the container engine is doing. First let's kill the running container and see what happens:"
	echo
	read_color "sudo podman kill $CONTAINER_LABEL"
	sudo podman kill $CONTAINER_LABEL

	echo
	echo_color "Notice the state of the container. The meta-data for the container still exists:"
	echo
	read_color "sudo podman ps -a"
	sudo podman ps -a

	echo
	echo_color "Take a look at the contents of the mount point. It's The copy-on-write layer hasn't been removed. It's still there:"
	echo
	read_color "sudo ls -al $CONTAINER_MOUNT_POINT"
	sudo ls -al $CONTAINER_MOUNT_POINT

	echo
	echo_color "Finally, notice that the config.json file is still there, along with the other files. Nothing has been deleted yet. We could totally restart the container, and the exact same process, with the exact same data would be running again:"
	echo
	read_color "sudo ls -alh /var/lib/containers/storage/overlay-containers/$CONTAINER_LABEL/userdata/"
	sudo ls -alh /var/lib/containers/storage/overlay-containers/$CONTAINER_LABEL/userdata/

	echo
	read_color "Go back to the presentation..."

	echo
	echo_color "Now, let's remove the container. This will get rid of everything except for -v bind mounts."
	echo
	read_color "sudo podman rm $CONTAINER_LABEL"
	sudo podman rm $CONTAINER_LABEL

	echo
	echo_color "Notice the state of the container. Everything is gone:"
	echo
	read_color "sudo podman ps -a"
	sudo podman ps -a

	echo
	echo_color "Also, notice that everything in /var/lib/containers/storage/overlay-containers/$CONTAINER_LABEL/ is gone"
	echo
	read_color "sudo ls -alh /var/lib/containers/storage/overlay-containers/$CONTAINER_LABEL/"
	sudo ls -alh /var/lib/containers/storage/overlay-containers/$CONTAINER_LABEL/

	echo
	echo_color "But, note that this only deleted the copy-on-write layer for the container. All of the read-only layers which came from the container image are still there:"
	echo
	read_color "sudo podman images | grep ubi8"
	sudo podman images | grep ubi8

	echo
	read_color "Go back to the presentation..."

	echo
	echo_color "Now, for good measure, lets delete the read-only layers too:"
	echo
	read_color "sudo podman rmi registry.access.redhat.com/ubi8/ubi"
	sudo podman rmi registry.access.redhat.com/ubi8/ubi

	echo
	read_color "Now, all of the images are gone - read-only and copy-on-write. This should open your mind to a new way o fthinking about containers. Go back to the presentation..."

}

pause() {
    echo
    read -p "Enter to continue"
    clear
}

presentation() {
    echo
    read -p "Go back to the presetnation..."
    clear
}

clean_images_and_containers() {
	echo
	echo_color "Now, let's clean up the containers and pods"
	echo
	read_color "podman kill -a;podman rm -a;podman pod kill -a;podman pod rm -a"
	podman kill -a;podman rm -a;podman pod kill -a;podman pod rm -a
	echo
	read_color "sudo podman kill -a;sudo podman rm -a;sudo podman pod kill -a;sudo podman pod rm -a"
	sudo podman kill -a;sudo podman rm -a;sudo podman pod kill -a;sudo podman pod rm -a
	echo
	read_color "docker kill \`docker ps --no-trunc -q\`"
	docker kill `docker ps --no-trunc -q`
	echo
	read_color "docker rm \`docker ps --no-trunc -a -q\`"
	docker rm `docker ps --no-trunc -a -q`
}

setup
intro
demo_one
demo_two
demo_three
demo_four
demo_five
demo_six
clean_images_and_containers

echo
read -p "End of Demo!!!"
echo
echo "Thank you!"

