#!/bin/bash

source /usr/share/dotnet-compile-native/config/config.shprops

corerun=${INSTALL_ROOT}/coreclr/corerun
il_to_cpp=${INSTALL_ROOT}/native/ILToCpp/ILToCPP.exe

c_libs="${INSTALL_ROOT}/native/sharedlibs/libSystem.Native.a ${INSTALL_ROOT}/native/sharedlibs/libclrgc.a"
c_includes="-I${INSTALL_ROOT}/native/inc -I${INSTALL_ROOT}/native/inc/GC -I${INSTALL_ROOT}/native/inc/GC/env ${INSTALL_ROOT}/native/inc/lxstubs.cpp ${INSTALL_ROOT}/native/inc/main.cpp"
c_flags="-g -lstdc++ -lrt -Wno-invalid-offsetof"

il_to_cpp_args="-r ${INSTALL_ROOT}/native/lib/Unix/*.dll -r ${INSTALL_ROOT}/native/lib/*.dll -llvm"

output_directory=$(pwd)

print_usage(){
		echo "dotnet-native-compile {path to il assembly}"
}

il_to_cpp(){
	if [ -z "$1" ] || [ ! -f "$1" ]; then
		echo "Error: Invalid il assembly path"
		echo "$1"
		exit 1
	fi

	il_assembly_file="$1"
	il_assembly_filename=$(basename "$il_assembly_file" .dll)

	intermediate_cpp_file=/tmp/${il_assembly_filename}.cpp
	rm -f $intermediate_cpp_file

	full_command="$corerun $il_to_cpp $il_to_cpp_args -out $intermediate_cpp_file $il_assembly_file"
	$full_command > /dev/null

	echo $intermediate_cpp_file
}

cpp_to_native(){
	if [ -z "$1" ] || [ ! -f "$1" ]; then
		echo "Error: Invalid cpp file"
		echo "$1"
		exit 1
	fi

	cpp_file="$1"
	cpp_filename=$(basename "$cpp_filename" .cpp)

	output_file=$output_directory/${cpp_filename}
	rm -f $output_file

	cp ${INSTALL_ROOT}/inc/stubs.cpp /tmp/stubs.cpp
	full_command="clang-3.5 $c_flags $c_includes $intermediate_cpp_file $c_libs -o $output_file"

	$full_command > /dev/null
	chmod u+rwx $output_file

	echo $output_file
}

if [ -z "$1" ] || [ ! -f "$1" ]; then
	print_usage
	exit 1
fi

echo "Converting $1 to native"

tmp_cpp_file=$(il_to_cpp "$1")
output_executable=$(cpp_to_native "$tmp_cpp_file")

echo "Native Output: $output_executable"