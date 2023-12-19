SET PATH=%QUARTUS_ROOTDIR_18_1%\bin64;%PATH%
hdlmake
make mrproper
make analyze_elaborate
@pause
