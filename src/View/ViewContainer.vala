//
//  ViewContainer.vala
//
//  Authors:
//       Mathijs Henquet <mathijs.henquet@gmail.com>
//       ammonkey <am.monkeyd@gmail.com>
//
//  Copyright (c) 2010 Mathijs Henquet
//
//  This program is free software; you can redistribute it and/or modify
//  it under the terms of the GNU General Public License as published by
//  the Free Software Foundation; either version 3 of the License, or
//  (at your option) any later version.
//
//  This program is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
//  GNU General Public License for more details.
//
//  You should have received a copy of the GNU General Public License
//  along with this program; if not, write to the Free Software
//  Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307 USA
//

using Marlin;

namespace Marlin.View {
    public class ViewContainer : Gtk.Overlay {

        public Gtk.Widget? content_item;
        public bool can_show_folder = true;
        public string label = "";
        public Marlin.View.Window window;
        public GOF.AbstractSlot? view = null;
        public Marlin.ViewMode view_mode = Marlin.ViewMode.INVALID;
        public GLib.File? location {
            get {
                var slot = get_current_slot ();
                return slot != null ? slot.location : null;
            }
        }
        public string uri {
            get {
                var slot = get_current_slot ();
                return slot != null ? slot.uri : null;
            }
        }

        public GOF.AbstractSlot? slot {
            get {
                return get_current_slot ();
            }
        }

        public OverlayBar overlay_statusbar;
        private Browser browser;
        private GLib.List<GLib.File>? selected_locations = null;

        private bool ready = false;

        public signal void tab_name_changed (string tab_name);
        public signal void loading (bool is_loading);
        /* To maintain compatibility with existing plugins */
        public signal void path_changed (File file);

        /* Initial location now set by Window.make_tab after connecting signals */
        public ViewContainer (Marlin.View.Window win, Marlin.ViewMode mode, GLib.File loc) {
            window = win;
            overlay_statusbar = new OverlayBar (win, this);
            browser = new Browser ();

            this.show_all ();

            /* Override background color to support transparency on overlay widgets */
            Gdk.RGBA transparent = {0, 0, 0, 0};
            override_background_color (0, transparent);

            set_events (Gdk.EventMask.ENTER_NOTIFY_MASK | Gdk.EventMask.LEAVE_NOTIFY_MASK);
            connect_signals ();
            change_view_mode (mode, loc);
        }

        ~ViewContainer () {
            debug ("ViewContainer destruct");
        }

        private void connect_signals () {
            path_changed.connect (user_path_change_request);
            window.folder_deleted.connect (on_folder_deleted);
        }

        private void disconnect_signals () {
            path_changed.disconnect (user_path_change_request);
            window.folder_deleted.disconnect (on_folder_deleted);
        }

        private void on_folder_deleted (GLib.File deleted) {
            if (deleted.equal (this.location)) {
                close ();
                window.remove_tab (this);
            }
        }

        public void close () {
            disconnect_signals ();
            view.close ();
        }

        public Gtk.Widget content {
            set {
                if (content_item != null)
                    remove (content_item);
                add (value);
                content_item = value;
                content_item.show_all ();
            }
            get {
                return content_item;
            }
        }

        public string tab_name {
            set {
                label = value;
                tab_name_changed (value);
            }
            get {
                return label;
            }
        }

        public void go_up () {
            if (view.directory.has_parent ())
                user_path_change_request (view.directory.get_parent ());
        }

        public void go_back (int n = 1) {
            string? loc = browser.go_back (n);

            if (loc != null)
                user_path_change_request (File.new_for_commandline_arg (loc));
        }

        public void go_forward (int n = 1) {
            string? loc = browser.go_forward (n);

            if (loc != null)
                user_path_change_request (File.new_for_commandline_arg (loc));
        }


        public void change_view_mode (Marlin.ViewMode mode, GLib.File? loc = null) {
            if (mode != view_mode) {
                if (loc == null) /* Only untrue on container creation */
                    loc = this.location;

                if (view != null) {
                    store_selection ();
                    /* Make sure async loading and thumbnailing are cancelled and signal handlers disconnected */
                    view.cancel ();
                }

                if (mode == Marlin.ViewMode.MILLER_COLUMNS)
                    view = new Miller (loc, this, mode);
                else
                    view = new Slot (loc, this, mode);

                content = view.get_content_box ();

                view_mode = mode;
                overlay_statusbar.showbar = view_mode != Marlin.ViewMode.LIST;
                overlay_statusbar.reset_selection ();

                load_slot_directory (view);
                window.update_top_menu ();
            }
        }

        public void user_path_change_request (GLib.File loc) {
            loading (true);
            view.user_path_change_request (loc);
        }

        public void new_container_request (GLib.File loc, int flag = 1) {
            switch ((Marlin.OpenFlag)flag) {
                case Marlin.OpenFlag.NEW_TAB:
                    this.window.add_tab (loc, view_mode);
                    break;

                case Marlin.OpenFlag.NEW_WINDOW:
                    this.window.add_window (loc, view_mode);
                    break;

                default:
                    assert_not_reached ();
            }
        }

        public void slot_path_changed (GLib.File loc, bool allow_mode_change = true) {
            /* automagicly enable icon view for icons keypath */
            if (allow_mode_change &&
                get_current_slot ().directory.uri_contain_keypath_icons &&
                view_mode != Marlin.ViewMode.ICON)

                change_view_mode (Marlin.ViewMode.ICON, null);
            else
                set_up_current_slot ();
        }

        private void set_up_current_slot () {
            ready = false;
            load_slot_directory (get_current_slot ());
        }

        public void load_slot_directory (GOF.AbstractSlot? slot) {
            if (slot == null)
                return;

            refresh_slot_info (slot);

            /* Allow time for the window to update before trying to load directory so that
             * the window is displayed more quickly when starting the application in,
             * or switching view to, a folder that contains a large number of files.
             * Also ensures infobars are added correctly by plugins.  Only checking in idle
             * time allows pathbar animation to complete smoothly.

             * Wait until directory is flagged ready to allow time for network folders to be found
             * and accessed.

             * Do not try and load directory that is not flagged 'can load'.
             */
            Idle.add (() => {
                if (!slot.directory.is_ready)
                    return true;

                if (slot.directory.can_load) {
                    slot.directory.load ();
                    plugin_directory_loaded ();
                } else
                     directory_done_loading (slot);

                return false;
            });
        }

        private void plugin_directory_loaded () {
            var slot = get_current_slot ();
            Object[] data = new Object[3];
            data[0] = window;
            /* infobars are added to the view, not the active slot */
            data[1] = view;
            data[2] = slot.directory.file;

            plugins.directory_loaded ((void*) data);
        }

        public void refresh_slot_info (GOF.AbstractSlot aslot) {
            GLib.File loc = aslot.directory.file.location;
            update_tab_name (loc);
            browser.record_uri (loc.get_parse_name ()); /* will ignore null changes */

            window.loading_uri (loc.get_uri ());
            window.update_top_menu ();
            window.update_labels (loc.get_parse_name (), tab_name);
            window.set_can_go_back (browser.get_can_go_back ());
            window.set_can_go_forward (browser.get_can_go_forward ());
        }

        public void update_tab_name (GLib.File loc) {
            string? slot_path = loc.get_path ();
            tab_name = "-----";
            if (slot_path == null) {
                string [] uri_parts = loc.get_uri ().split (Path.DIR_SEPARATOR_S);
                uint index = uri_parts.length - 1;
                string s;
                while (index >= 0) {
                    s = uri_parts [index];
                    if (s.length >= 1) {
                        if (index == 0) {
                            tab_name = Marlin.protocol_to_name (s);
                        } else
                            tab_name = s;
                        break;
                    }
                    index--;
                }
            } else if (slot_path == Environment.get_home_dir ())
                tab_name = _("Home");
            else if (slot_path == "/")
                tab_name = _("File System");
            else {
                try {
                    var info = loc.query_info (FileAttribute.STANDARD_DISPLAY_NAME, FileQueryInfoFlags.NONE);
                    tab_name = info.get_attribute_string (FileAttribute.STANDARD_DISPLAY_NAME);
                }
                catch (GLib.Error e) {
                    warning ("Could not get location display name. %s", e.message);
                    tab_name = loc.get_basename ();
                    can_show_folder = false;
                }
            }

            if (tab_name == "-----")
                tab_name = loc.get_uri ();

            if (Posix.getuid() == 0)
                tab_name = tab_name + " " + _("(as Administrator)");
        }

        public void directory_done_loading (GOF.AbstractSlot slot) {
            loading (false);
            can_show_folder = true;

            if (slot.directory.permission_denied) {
                content = new Granite.Widgets.Welcome (_("This does not belong to you."),
                                                           _("You don't have permission to view this folder."));
                can_show_folder = false;
            } else if (!slot.directory.can_load) {
                content = new Granite.Widgets.Welcome (_("Unable to mount folder."),
                                                           _("The server for this folder could not be located."));
                can_show_folder = false;
            } else if (!slot.directory.file.exists) {
                    content = new DirectoryNotFound (slot.directory, this);
                    can_show_folder = false;
            } else if (selected_locations != null) {
                    view.select_glib_files (selected_locations, null);
                    selected_locations = null;
            } else if (slot.directory.selected_file != null) {
                if (slot.directory.selected_file.query_exists ())
                    focus_location_if_in_current_directory (slot.directory.selected_file);
                else {
                    content = new Granite.Widgets.Welcome (_("File not found."),
                                                           _("The file selected no longer exists."));
                    can_show_folder = false;
                }
                slot.directory.selected_file = null;
            }

            if (can_show_folder) {
                ready = true;
                content = view.get_content_box ();
            }
        }

        private void store_selection () {
            unowned GLib.List<unowned GOF.File> selected_files = view.get_selected_files ();
            selected_locations = null;

            if (selected_files.length () >= 1) {

                selected_files.@foreach ((file) => {
                    selected_locations.prepend (GLib.File.new_for_uri (file.uri));
                });
            }
        }

        public unowned GOF.AbstractSlot? get_current_slot () {
           return view != null ? view.get_current_slot () : null;
        }

        public void set_active_state (bool is_active) {
            var aslot = get_current_slot ();
            if (aslot != null)
                aslot.set_active_state (is_active);
        }

        public void focus_location (GLib.File? file,
                                    bool select_in_current_only = false,
                                    bool unselect_others = false) {

            if (unselect_others || file == null) {
                get_current_slot ().set_all_selected (false);
                selected_locations = null;
            }

            if (file == null || location.equal (file))
                return;

            var filetype = file.query_file_type (0);
            if (filetype == FileType.UNKNOWN)
                return;

            GLib.File? loc = null;
            File? parent = file.get_parent ();
            if (parent != null && location.equal (file.get_parent ())) {
                if (select_in_current_only || file.query_file_type (0) != FileType.DIRECTORY) {
                   var list = new List<File> ();
                    list.prepend (file);
                    get_current_slot ().select_glib_files (list, file);
                } else
                    loc = file;
            } else if (!select_in_current_only) {
                if (filetype == FileType.DIRECTORY)
                    loc = file;
                else if (parent != null) {
                    loc = parent;
                    selected_locations.prepend (file);
                }
            }

            if (loc != null)
                user_path_change_request (loc);
        }

        public void focus_location_if_in_current_directory (GLib.File? file,
                                                            bool unselect_others = false) {

            focus_location (file, true, unselect_others);
        }

        public string get_root_uri () {
            string path = "";
            if (view != null)
                path = view.get_root_uri () ?? "";

            return path;
        }

        public string get_tip_uri () {
            string path = "";
            if (view != null)
                path = view.get_tip_uri () ?? "";

            return path;
        }

        public void reload (bool propagate = true) {
            /* Allow time for the signal to propagate and the tab label to redraw */
            Idle.add (() => {
                var slot = get_current_slot ();
                if (slot == null)
                    return false;

                slot.reload ();
                load_slot_directory (slot);
                /* For remote folders, make sure any other windows showing the same folder are
                 * also refreshed. Prevent infinite loop with propagate - when called from application,
                 * propagate will be false.
                 */
                if (propagate)
                    ((Marlin.Application)(window.application)).tab_reloaded (window, slot.location);

                return false;
            });
        }

        public Gee.List<string> get_go_back_path_list () {
            assert (browser != null);
            return browser.go_back_list ();
        }

        public Gee.List<string> get_go_forward_path_list () {
            assert (browser != null);
            return browser.go_forward_list ();
        }

        public new void grab_focus () {
            if (can_show_folder && view != null)
                view.grab_focus ();
            else
                content.grab_focus ();
        }
    }
}
