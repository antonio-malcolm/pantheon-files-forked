/*
 Copyright (C) 2014 elementary Developers

 This program is free software: you can redistribute it and/or modify it
 under the terms of the GNU Lesser General Public License version 3, as published
 by the Free Software Foundation.

 This program is distributed in the hope that it will be useful, but
 WITHOUT ANY WARRANTY; without even the implied warranties of
 MERCHANTABILITY, SATISFACTORY QUALITY, or FITNESS FOR A PARTICULAR
 PURPOSE. See the GNU General Public License for more details.

 You should have received a copy of the GNU General Public License along
 with this program. If not, see <http://www.gnu.org/licenses/>.

 Authors :
*/

namespace FM {
    /* Implement common features of ColumnView and ListView */
    public abstract class AbstractTreeView : AbstractDirectoryView {
        const int ICON_XPAD = 6;

        protected Gtk.TreeView tree;
        protected Gtk.TreeViewColumn name_column;

        public AbstractTreeView (Marlin.View.Slot _slot) {
            base (_slot);
        }

        ~AbstractTreeView () {
            debug ("ATV destruct");
        }

        protected virtual void create_and_set_up_name_column () {
            name_column = new Gtk.TreeViewColumn ();
            name_column.set_sort_column_id (FM.ListModel.ColumnID.FILENAME);
            name_column.set_expand (true);
            name_column.set_resizable (true);

            name_renderer = new Marlin.TextRenderer (Marlin.ViewMode.LIST);
            set_up_name_renderer ();

            set_up_icon_renderer ();

            name_column.pack_start (icon_renderer, false);
            name_column.set_attributes (icon_renderer,
                                        "file", FM.ListModel.ColumnID.FILE_COLUMN);

            name_column.pack_start (name_renderer, true);
            name_column.set_attributes (name_renderer,
                                        "text", FM.ListModel.ColumnID.FILENAME,
                                        "file", FM.ListModel.ColumnID.FILE_COLUMN,
                                        "background", FM.ListModel.ColumnID.COLOR);

            tree.append_column (name_column);
        }

        protected void set_up_icon_renderer () {
            icon_renderer.set_property ("follow-state",  true);
            icon_renderer.xpad = ICON_XPAD;
        }

        protected void set_up_view () {
            connect_tree_signals ();
        }

        protected override void set_up_name_renderer () {
            base.set_up_name_renderer ();
            name_renderer.@set ("wrap-width", -1);
            name_renderer.@set ("zoom-level", Marlin.ZoomLevel.NORMAL);
            name_renderer.@set ("ellipsize-set", true);
            name_renderer.@set ("ellipsize", Pango.EllipsizeMode.END);
            name_renderer.xalign = 0.0f;
            name_renderer.yalign = 0.5f; 
        }

        protected void connect_tree_signals () {
            tree.get_selection ().changed.connect (on_view_selection_changed);

            tree.realize.connect ((w) => {
                tree.grab_focus ();
                tree.columns_autosize ();
            });
        }

        protected override Gtk.Widget? create_view () {
            tree = new Gtk.TreeView ();
            tree.set_model (model);
            tree.set_headers_visible (false);
            tree.set_rules_hint (true);
            tree.get_selection ().set_mode (Gtk.SelectionMode.MULTIPLE);
            tree.set_rubber_banding (true);

            create_and_set_up_name_column ();
            set_up_view ();

            return tree as Gtk.Widget;
        }

        public override void change_zoom_level () {
            if (tree != null) {
                base.change_zoom_level ();
                tree.columns_autosize ();
            }
        }

        public override GLib.List<Gtk.TreePath> get_selected_paths () {
            return tree.get_selection ().get_selected_rows (null);
        }

        public override void highlight_path (Gtk.TreePath? path) {
            tree.set_drag_dest_row (path, Gtk.TreeViewDropPosition.INTO_OR_AFTER);
        }

        public override Gtk.TreePath? get_path_at_pos (int x, int y) {
            Gtk.TreePath? path = null;

            if (x >= 0 && y >= 0 && tree.get_dest_row_at_pos (x, y, out path, null))
                return path;
            else
                return null;
        }

        public override void select_all () {
            tree.get_selection ().select_all ();
        }

        public override void unselect_all () {
            tree.get_selection ().unselect_all ();
        }

        public override void select_path (Gtk.TreePath? path) {
            if (path != null) {
                debug ("select path %s", path.to_string ());
                tree.get_selection ().select_path (path);
            }
        }
        public override void unselect_path (Gtk.TreePath? path) {
            if (path != null)
                tree.get_selection ().unselect_path (path);
        }

        public override bool path_is_selected (Gtk.TreePath? path) {
            if (path != null)
                return tree.get_selection ().path_is_selected (path);
            else
                return false;
        }

        public override bool get_visible_range (out Gtk.TreePath? start_path,
                                                out Gtk.TreePath? end_path) {
            start_path = null;
            end_path = null;
            return tree.get_visible_range (out start_path, out end_path);
        }

        public override void sync_selection () {
            /* Not implemented - needed? No current bug reports. */
        }

        protected override void update_selected_files () {
            selected_files = null;

            tree.get_selection ().selected_foreach ((model, path, iter) => {
                GOF.File? file; /* can be null if click on blank row in list view */
                model.@get (iter, FM.ListModel.ColumnID.FILE_COLUMN, out file, -1);
                if (file != null)
                    selected_files.prepend (file);
            });

            selected_files.reverse ();
        }

        protected override bool view_has_focus () {
            return tree.has_focus;
        }

        protected override uint get_event_position_info (Gdk.EventButton event,
                                                         out Gtk.TreePath? path,
                                                         bool rubberband = false) {
            unowned Gtk.TreePath? p = null;
            unowned Gtk.TreeViewColumn? c = null;
            uint zone;
            int cx, cy, depth;
            path = null;

            if (event.window != tree.get_bin_window ())
                return ClickZone.INVALID;

            bool on_blank = tree.is_blank_at_pos ((int)event.x, (int)event.y, out p, out c, out cx, out cy);
            path = p;
            depth = p != null ? p.get_depth () : 0;
            zone = (p != null ? ClickZone.BLANK_PATH : ClickZone.BLANK_NO_PATH);

            if (c != null && c == name_column) {
                int? x_offset, width;
                c.cell_get_position (icon_renderer, out x_offset, out width);
                int expander_width = (tree.show_expanders ? 10 : 0) * (depth +1);
                expander_width += ICON_XPAD;

                if (cx > expander_width ) {
                    if (cx <= x_offset + width + expander_width) {
                        if (helpers_shown &&
                            ((cx -x_offset - expander_width) <= 18) &&
                            (cy <=18))

                            zone = ClickZone.HELPER;
                        else
                            zone = ClickZone.ICON;

                    } else if (!on_blank &&
                               cy < icon_size &&
                               cx < x_offset + width - 6) /* stop edges of row appearing as name */

                        zone = ClickZone.NAME;
                    else {
                        c.cell_get_position (name_renderer, out x_offset, out width);

                        if (right_margin_unselects_all && cx >= x_offset + width - 6)
                            zone = ClickZone.INVALID; /* Cause unselect all to occur on right margin */
                    }
                } else
                    zone = ClickZone.EXPANDER;
            } else if (c != name_column)
                zone = ClickZone.INVALID; /* Cause unselect all to occur on other columns*/

            return zone;
        }

        protected override void scroll_to_cell (Gtk.TreePath? path, bool scroll_to_top) {
            if (tree == null || path == null || slot.directory.permission_denied)
                return;

            tree.scroll_to_cell (path, name_column, scroll_to_top, 0.0f, 0.0f);
        }
        protected override void set_cursor_on_cell (Gtk.TreePath path,
                                                    Gtk.CellRenderer renderer,
                                                    bool start_editing,
                                                    bool scroll_to_top) {
            scroll_to_cell (path, scroll_to_top);
            tree.set_cursor_on_cell (path, name_column, renderer, start_editing);
        }

        public override void set_cursor (Gtk.TreePath? path,
                                         bool start_editing,
                                         bool select,
                                         bool scroll_to_top) {
            if (path == null)
                return;

            Gtk.TreeSelection selection = tree.get_selection ();

            if (!select)
                selection.changed.disconnect (on_view_selection_changed);

            set_cursor_on_cell (path, name_renderer, start_editing, scroll_to_top);

            if (!select)
                selection.changed.connect (on_view_selection_changed);
        }

        public override Gtk.TreePath? get_path_at_cursor () {
            Gtk.TreePath? path;
            tree.get_cursor (out path, null);
            return path;
        }

        /* These two functions accelerate the loading of Views especially for large folders
         * Views are not displayed until fully loaded */
        protected override void freeze_tree () {
            tree.freeze_child_notify ();
            tree_frozen = true;
        }

        protected override void thaw_tree () {
            if (tree_frozen) {
                tree.thaw_child_notify ();
                tree_frozen = false;
            }
        }
    }
}
