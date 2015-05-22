**Requirements**

* Vala >= 0.16
* Granite >= 0.3.0
* Gtk+ >= 3.0.3
* GLib >= 2.32
* Gio >= 2.0
* Gee >= 1.0
* Pango >= 1.1.2
* Sqlite 3
* Libnotify >= 0.7.2
* Gail >= 3.0
* LibDBus-GLib
* GConf 2
* PCMan's [gtk3-nocsd](https://github.com/PCMan/gtk3-nocsd "PCMan/gtk3-nocsd"), if you want window manager decorations


To get all of the dependencies under a Debian-based distribution, run:

````
# apt-get build-dep pantheon-files
```


**Optional**

* Unity (libunity-dev) >= 4.0.0 (For Unity launcher support).


**To build pantheon-files**

```
mkdir build && cd build
cmake .. -DCMAKE_INSTALL_PREFIX=/usr/local
make
```

To install it:

```
# make install
```
    
To debug it:

```
cmake .. -DCMAKE_BUILD_TYPE=Debug
```

To install only libcore and libwidgets use the following command:

```
cmake .. -DLIB_ONLY=true
```


**To activate window decorations via the window manager, using gtk3-nocsd**

To execute from a command:

```
env LD_PRELOAD="/<PATH TO>/gtk3-nocsd.so" pantheon-files
```

In pantheon-files.desktop, replace the Exec= line with:

```
Exec=env LD_PRELOAD="/<PATH TO>/gtk3-nocsd.so" pantheon-files %U
```
