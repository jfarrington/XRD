Build Trims 8/22/13
J.farrington

**Verify that all commands shown reflect your environment

Install Grace:
-Download the latest version of grace (grace-5.1.23) onto /usr/local/
-Go into grace-5.1.23/ and 
--$ sudo ./configure
--$ sudo make
--$ sudo make install
-Make a symbolic link from /usr/local/grace/bin/xmgrace to usr/local/bin/xmgrace

Build Trims:

(Part1)
-Modify Makefile to reflect your environment
-install minpack-dev
--$ sudo apt-get install minpack-dev
-$ sudo make
-The ezcaSetMonitor function has a new definition which requires an extra value, count. I modified testfit.c to add this value and set it up to 0.
-It compiles with a bunch of warnings,ignore them. Creates tescfit.o and libfit.so
-Define some paths to ezca library so that the compiler can link to it:
--Method1:Add path to the compiler library path definition
---Go to /etc/ld.so.conf.d
---Add a file (i.e newlib.conf) with the path to libezca.so (/opt/epics/extensions/lib/linux-x86)
--Method2:Use symbolic link on default compiler library 
---Go to /usr/local/lib
---$ ln -s /opt/epics/extensions/lib/linux-x86/libezca.so libezca.so

(Part2)
-Go to /usr/lib/
--$ sudo ln -s /opt/epics_dev/IOC/STRIP_DET/SYDOR_XRD_uC5282/SydorXRD_Start/trims/libfit.so libfit.so
--$ sudo ln -s /opt/epics/extensions/lib/linux-x86/libezca.so libezca.so
-
-Go to the trims directory
-Edit build.txt to reflect your environment
--$source build.txt
-Run Trims
$./trims
..Done!

