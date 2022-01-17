# xserver-vcpkg
Building xserver and x-org tools using vcpkg


# manual vcpkg command:
./vcpkg.exe install --triplet=x64-windows --overlay-ports=../ports/libs/ --overlay-ports=../ports/apps/ --allow-unsupported <portname> 
./vcpkg.exe install --triplet=x64-windows --overlay-ports=../ports/libs/ --overlay-ports=../ports/apps/ --allow-unsupported --editable <portname> 