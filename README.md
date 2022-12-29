1. hybrid-vapoursynth-addon
Adding Vapoursynth and plugins to Hybrid
2. extract the folder to a temporary folder
3. make the build-vapoursynth.sh script executable `chmod +x build-vapoursynth.sh` and run it.
4. When it's finished add:
    ```
    export LD_LIBRARY_PATH=~/opt/vapoursynth/lib
    export PYTHONPATH=~/opt/vapoursynth/lib/python3.6/site-packages
    export PATH="~/opt/vapoursynth/bin:$PATH"
    export PATH="~/.local/bin:$PATH"
    ```
  to your `~/.profile`- and `~/.bashrc` -file, close the terminal and open a new terminal, best use absolute paths.
  
  Side notes:
  * depending on your Python version you need to adjust _pyhton3.6_ accordingly and if you changed the default paths inside the config.txt youe need to adjust them here too.
  * in Ubuntu 20.04 I had to use absolute paths so instead of ~/... I had to use /home/selur/...

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

Note: building RIFE (https://github.com/HomeOfVapourSynthEvolution/VapourSynth-RIFE-ncnn-Vulkan)
requires VULKAN SDK installed
on Ubuntu 18.04:
```
wget -qO - http://packages.lunarg.com/lunarg-signing-key-pub.asc | sudo apt-key add -
sudo wget -qO /etc/apt/sources.list.d/lunarg-vulkan-bionic.list http://packages.lunarg.com/vulkan/lunarg-vulkan-bionic.list
sudo apt update
sudo apt install vulkan-sdk
```
on Ubuntu 20.04:
```
wget -qO - http://packages.lunarg.com/lunarg-signing-key-pub.asc | sudo apt-key add -
sudo wget -qO /etc/apt/sources.list.d/lunarg-vulkan-focal.list http://packages.lunarg.com/vulkan/lunarg-vulkan-focal.list
sudo apt update
sudo apt install vulkan-sdk
```
on Ubuntu 22.04:
```
wget -qO- https://packages.lunarg.com/lunarg-signing-key-pub.asc | sudo tee /etc/apt/trusted.gpg.d/lunarg.asc
sudo wget -qO /etc/apt/sources.list.d/lunarg-vulkan-jammy.list http://packages.lunarg.com/vulkan/lunarg-vulkan-jammy.list
sudo apt update
sudo apt install vulkan-sdk
```
