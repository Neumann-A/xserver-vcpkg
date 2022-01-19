# xserver-vcpkg
Building xserver and x-org tools using vcpkg


#executing xserver:
./Xming.exe -listen tcp -ac +iglx +extension GLX +extension XINERAMA +extension RENDER +extension RANDR +extension DAMAGE +extension DPMS +extension COMPOSITE +extension DOUBLE-BUFFER -compositewm -hostintitle -keyhook -wgl  -screen 0 @2 -logfile mytest5.log 

# manual vcpkg command:
./vcpkg.exe install --triplet=x64-windows --overlay-ports=../ports/libs/ --overlay-ports=../ports/apps/ --allow-unsupported <portname> 
./vcpkg.exe install --triplet=x64-windows --overlay-ports=../ports/libs/ --overlay-ports=../ports/apps/ --allow-unsupported --editable <portname> 


./vcpkg.exe depend-info --triplet=x64-windows --overlay-ports=../ports/libs/ --overlay-ports=../ports/apps/ <portname>