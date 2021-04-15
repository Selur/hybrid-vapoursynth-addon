1. hybrid-vapoursynth-addon
Adding Vapoursynth and plugins to Hybrid
2. extract the folder to a temporary folder
3. make the build-vapoursynth.sh script executable `chmod +x build-vapoursynth.sh` and run it.
4. When it's finished add:
    ```
    export LD_LIBRARY_PATH=/usr/local/lib
    export PYTHONPATH=~/opt/vapoursynth/lib/python3.6/site-packages
    export PATH="~/opt/vapoursynth/bin:$PATH"
    ```
to your `~/.profile`- and `~/.bashrc` -file, close the terminal and open a new terminal.
( Note: depending on your Python version you need to adjust _pyhton3.6_ accordingly and if you changed the default paths inside the config.txt youe need to adjust them here too)

5. Calling `vspipe --version` should output something like:
    ```
    VapourSynth Video Processing Library
    Copyright (c) 2012-2020 Fredrik Mellbin
    Core R49
    API R3.6
    Options: -
    ```
6. reboot your system.
(`vspipe --version` should now work without having to enter the export calls)
7. make the build-plugins.sh executable `chmod +x build-plugins.sh` and run it (this will take quite a while).

Now Hybrid will be able to use Vapoursynth.


