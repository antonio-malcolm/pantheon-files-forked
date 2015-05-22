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

 Authors : Jeremy Wootten <jeremy@elementary.org>
*/

namespace Marlin {
    public class SingleLineEditableLabel : AbstractEditableLabel {

        protected Gtk.Entry textview;

        public SingleLineEditableLabel () {}

        public override Gtk.Widget create_editable_widget () {
            textview = new Gtk.Entry ();
            return textview as Gtk.Widget;
        }

        public override Gtk.Widget get_real_editable () {
            return textview;
        }

        public override void set_text (string text) {
            textview.set_text (text);
            original_name = text;
        }


        public override void set_justify (Gtk.Justification jtype) {
            switch (jtype) {
                case Gtk.Justification.LEFT:
                    textview.set_alignment (0.0f);
                    break;

                case Gtk.Justification.CENTER:
                    textview.set_alignment (0.5f);
                    break;

                case Gtk.Justification.RIGHT:
                    textview.set_alignment (1.0f);
                    break;

                default:
                    textview.set_alignment (0.5f);
                    break;
            }
        }

        public override string get_text () {
            return textview.get_text ();
        }

        /** Gtk.Editable interface */

        public override void select_region (int start_pos, int end_pos) {
            textview.grab_focus ();
            textview.select_region (start_pos, end_pos);
        }

        public override void do_delete_text (int start_pos, int end_pos) {
            textview.delete_text (start_pos, end_pos);
        }

        public override void do_insert_text (string new_text, int new_text_length, ref int position) {
            textview.insert_text (new_text, new_text_length, ref position);
        }

        public override string get_chars (int start_pos, int end_pos) {
            return textview.get_chars (start_pos, end_pos);
        }

        public override int get_position () {
            return textview.get_position ();
        }

        public override bool get_selection_bounds (out int start_pos, out int end_pos) {
            int start, end;
            bool result = textview.get_selection_bounds (out start, out end);
            start_pos = start;
            end_pos = end;
            return result;
        }

        public override void set_position (int position) {
            textview.set_position (position);
        }

        public override void set_size_request (int width, int height) {
            textview.set_size_request (width, height);
        }
    }
}
