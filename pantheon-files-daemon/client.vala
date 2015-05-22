[DBus (name = "org.elementary.pantheonfiles.db")]
interface Demo : Object {
    public abstract bool   	showTable	(string table) 	throws IOError;
    public abstract int 	getColor 	(string uri) 	throws IOError;
    public abstract bool 	setColor 	(string uri, int color) 	throws IOError;
    public abstract bool 	deleteEntry	(string uri)	throws IOError;
    public abstract bool	clearDB		()				throws IOError;
}

void main () {
    try {
        Demo demo = Bus.get_proxy_sync (BusType.SESSION, "org.elementary.pantheonfiles.db",
                                        "/org/elementary/pantheonfiles/db");
        
		demo.showTable ("tags");

    } catch (IOError e) {
        stderr.printf ("%s\n", e.message);
    }
}
