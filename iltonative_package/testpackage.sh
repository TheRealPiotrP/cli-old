#!/bin/bash

#Ensure running with superuser privileges
current_user=$(whoami)
if [ $current_user != "root" ]; then
	echo "testpackage.sh requires superuser privileges to run"
	exit 1
fi

source ./config.shprops

#Test Utility Functions
test_build_package(){
	./build.sh

	if [ "$?" != "0" ]; then
		echo "Package build failed"
		return 1
	fi
	return 0
}

test_package_installed(){
	dpkg -s "${PACKAGE_NAME}" > /dev/null 2>&1
	return $?
}

echo_red(){
	echo -e "\e[31m$1\e[0m"
}

echo_green(){
	echo -e "\e[32m$1\e[0m"
}

echo_yellow(){
	echo -e "\e[33m$1\e[0m"
}

#Remove the package
remove_package(){
	apt-get remove -y ${PACKAGE_NAME} 
	
}

install_package() {
	if [ -s "./${PACKAGE_NAME}_${PACKAGE_VERSION}-1_amd64.deb" ]; then
		#Package Exists
		dpkg -i ./${PACKAGE_NAME}_${PACKAGE_VERSION}-1_amd64.deb
		return $?
	else
		#Package does not exist
		echo "Cannot install Package, it does not exist."
		return 1
	fi

}

#Test Complete Removal
test_complete_removal(){
	$(test_package_installed)

	if [ "$?" == 0 ]; then
		echo "Package is still installed"
		return 1
	elif [ -d "${INSTALL_ROOT}" ]; then
		echo "${INSTALL_ROOT} still exists"
		return 1
	elif [ -s "/usr/bin/dotnet-compile-native" ]; then
		echo "/usr/bin/dotnet-compile-native still exists"
		return 1
	fi
	return 0
}

# Compare Output to Checked-in LKG output for testdocs.json
test_manpage_generator(){

	python ./build_tools/manpage_generator.py ./build_tools/tests/testdocs.json ./build_tools/tests

	# Output is file "tool1.1"
	# LKG file is "lkgtestman.1"

	difference=$(diff ./build_tools/tests/tool1.1 ./build_tools/tests/lkgtestman.1)

	if [ -z "$difference" ]; then
		return 0
	else
		echo "Bad Manpage Generation"
		echo $difference
		return 1
	fi
	
}


#Baseline Test
test_dotnet-compile-native_exists(){
	hash dotnet-compile-native 2>/dev/null

	if [ "$?" != "0" ]; then
		echo "dotnet-compile-native does not exist on the path"
		return 1
	fi
	return 0
}

test_dotnet-compile-native_hello(){

	cp ${INSTALL_ROOT}/samples/hello.dll /tmp/hello.dll
	
	dotnet-compile-native /tmp/hello.dll /tmp > /dev/null

	output=$(/tmp/hello)

	if [[ "$output" == "Hello"* ]]; then
		return 0
	fi
	
	echo $output
	return 1
}

test_dotnet-compile-native_badassembly(){
	echo "This is a bad assembly" > /tmp/bad.dll

	dotnet-compile-native /tmp/bad.dll /tmp > /dev/null 2>&1

	if [[ "$?" == "0" ]]; then
		echo "dotnet-compile-native did not fail with a bad assembly"
		return 1
	fi

	return 0
}

test_dotnet-compile-native_badoutputdir(){
	echo "This is actually a file" > /tmp/baddir
	cp ${INSTALL_ROOT}/samples/hello.dll /tmp/hello.dll

	dotnet-compile-native /tmp/hello.dll /tmp/baddir

	if [[ "$?" == 0 ]]; then
		echo "dotnet-compile-native did not fail with a bad output directory"
		return 1
	fi

	return 0
}

test_dotnet-compile-native_manpage_exists(){
	man dotnet-compile-native > /dev/null 2>&1

	if [[ "$?" != "0" ]]; then
		echo "man dotnet-compile-native fails"
		return 1
	fi
	return 0
}

test_coreclr_exists(){
	coreclr_root="${INSTALL_ROOT}/coreclr"

	if [ -f "${coreclr_root}/CoreRun" ]; then
		return 0
	else
		echo "CoreRun does not exist in ${coreclr_root}"
		return 1
	fi
}

run_test_function() {
	if [ -z "$1" ]; then
		echo "run_test_function requires a test function name as the first parameter"
		exit 1
	fi
	
	test_command=$1
	echo_yellow "Running test: $test_command ..."
	output=$( $test_command )

	if [ "$?" != 0 ]; then
		echo_red "$test_command failed"
		echo_red "$test_command output: $output"
		exit 1
	else
		echo_green "$test_command succeeded"
		return 0
	fi
}

run_tests(){
	#If the package is already installed remove it, and test that
	$( test_package_installed )

	if [ "$?" == 0 ]; then
		echo_yellow "dotnet package installed, removing first"
		$(remove_package)
		test_complete_removal

		if [ "$?" != 0]; then
			echo_red "Complete removal failed"
			echo_red "Fix removal before re-running tests"
			exit 1
		fi
	fi
	
	echo_yellow "Running Preinstallation Tests"

	run_test_function test_manpage_generator
	
	echo_yellow "Running Build And Install"
	
	run_test_function test_build_package
	run_test_function install_package
	
	echo_yellow "Running PostInstallation Tests"
	
	run_test_function test_coreclr_exists
	run_test_function test_dotnet-compile-native_manpage_exists
	run_test_function test_dotnet-compile-native_exists
	run_test_function test_dotnet-compile-native_hello
	run_test_function test_dotnet-compile-native_badassembly
	run_test_function test_dotnet-compile-native_badoutputdir

	echo_yellow "Running Package Removal"
	
	# Test package removal
	run_test_function remove_package
	run_test_function test_complete_removal
		
}

# Allow for testing specific pieces only
if [ "$1" == "build" ]; then
	run_test_function test_build_package
elif [ "$1" == "install" ]; then
	run_test_function install_package
else
	run_tests
fi

