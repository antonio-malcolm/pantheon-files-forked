/*
 * Copyright (c) 2011 Lucas Baudin <xapantu@gmail.com>
 *
 * Marlin is free software; you can redistribute it and/or
 * modify it under the terms of the GNU General Public License as
 * published by the Free Software Foundation; either version 2 of the
 * License, or (at your option) any later version.
 *
 * Marlin is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 * General Public License for more details.
 *
 * You should have received a copy of the GNU General Public
 * License along with this program; see the file COPYING.  If not,
 * write to the Free Software Foundation, Inc., 59 Temple Place - Suite 330,
 * Boston, MA 02111-1307, USA.
 *
 */

namespace Marlin.View
{

    public static int show_dialog (string message, Gtk.MessageType type, Gtk.ButtonsType buttons) {
        var dialog = new Gtk.MessageDialog (null, Gtk.DialogFlags.MODAL,
                                            type, buttons, "%s", message);

        dialog.set_position (Gtk.WindowPosition.MOUSE);
        var response = dialog.run ();
        dialog.destroy ();
        return response;
    }

    public class DirectoryNotFound : Granite.Widgets.Welcome {
        public GOF.Directory.Async dir_saved;
        public ViewContainer ctab;

        public DirectoryNotFound(GOF.Directory.Async dir, ViewContainer tab) {
            base (_("This folder does not exist."), _("The folder \"%s\" can't be found.").printf (dir.location.get_basename ()));

            append ("folder-new", _("Create"), _("Create the folder \"%s\"").printf (dir.location.get_basename ()));

            dir_saved = dir;
            ctab = tab;

            this.activated.connect ((index) => {
                bool success = false;

                try {
                    success = dir.location.make_directory_with_parents (null);
                } catch (Error e) {
                    if (e is IOError.EXISTS)
                        success = true;
                    else
                        show_dialog (_("Failed to create the folder\n\n%s").printf (e.message),
                                     Gtk.MessageType.ERROR, Gtk.ButtonsType.CLOSE);
                }

                if (success)
                    ctab.user_path_change_request (dir_saved.location);
            });

            show_all ();
        }
    }
}
