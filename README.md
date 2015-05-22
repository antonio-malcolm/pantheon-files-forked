**This is a forked, modified version of Elementary OS Pantheon Files**

(and probably needs a better name than "pantheon-files-forked")

...with a focus on becoming more platform-agnostic.
...plus, simply, a few changes one guy felt like bringing to it.

If you like it, use it (see: INSTALL.md)!
If you have suggestions, suggest!
If you want to contribute, contribute!

**Cha-cha-cha-changes!**

* All references to, and dependencies upon, Zeitgeist are removed.

* Window decorations are left entirely to the window manager. 
 * This requires use of PCMan's [Gtk3Nocsd](https://github.com/PCMan/gtk3-nocsd "PCMan/gtk3-nocsd")
  * (First order of TODO business is to remove this dependency, as Files should do that all on its own.)
 * Means Files now looks (semi) normal in Openbox - YAY.

* Some portions of code are updated for quality. 
 * Previews work- update #private string? previewer, in /src/View/AbstractDirectoryView.vala, with the CLI call for your previewer.
  * (Second order of TODO business is to make this work from the dconf setting.)

There are a few other changes under the hood. 
Aside from the removal of Zeitgeist from the source, everything should be considered experimental, in-process, and probably somewhat trite and unoriginal, for the time being.
It's being writ by one guy, who is not the original author, but loves the work, and will do his best to improve upon it in a new way.
(And, he's a busy man, and there's lots to do, he thinks...)

~Hallo!


**Begin original README documentation (sort of)**

Files is a simple, powerful and sexy file manager.

Some of its features:
* Full integration with GTK+3 and Granite.
* Built for the Pantheon DE as the main target (<-- not so much, anymore).
* Tab browsing, allowing the restoration of closed tabs.
* Support for extensions written in Vala. Current extensions include:
    - Color tags for files and folders.
    - Dropbox and Ubuntu One integration.

For installation instructions read INSTALL.

Please report comments, suggestions and bugs to:
    https://bugs.launchpad.net/pantheon-files

And join the IRC channel #elementary on irc.freenode.net

For contributing code/translations/documentation to Files read HACKING.

Check for new versions at:
    http://launchpad.net/pantheon-files

For Ubuntu and derivatives, you can get stable builds of Files at:
    https://launchpad.net/~elementary-os/+archive/stable
