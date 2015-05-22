/*
 * Copyright (C) 2011, Lucas Baudin <xapantu@gmail.com>
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
 * You should have received a copy of the GNU General Public License
 * along with this program; if not, write to the Free Software
 * Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.
 *
 */

#include <gio/gio.h>
#include <gtk/gtk.h>
#include <glib.h>
#include "marlincore-tests-gof.h"
#include "marlincore-tests-file.h"
#include "marlincore-tests-icon-info.h"
#include "pantheon-files-core.h"

int main (int argc, char* argv[])
{
    //g_test_init (&argc, &argv, NULL);
    g_type_init ();
    gtk_test_init (&argc, &argv);

    g_test_add_func("/marlin/goffile", marlincore_tests_file);
    g_test_add_func("/marlin/goffile", marlincore_tests_goffile);
    //g_test_add_func("/marlin/gof", marlin_location_bar_tests);
    /* only used for local tests with local files */
    //g_test_add_func ("/marlin/icon_info", marlincore_tests_icon_info);

    return g_test_run();
}
