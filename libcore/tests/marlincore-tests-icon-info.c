/*
 * Copyright (C) 2012, ammonkey <am.monkeyd@gmail.com>
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

#include <stdlib.h>
#include <gtk/gtk.h>
#include <glib.h>
#include <gio/gio.h>
#include "marlincore-tests-icon-info.h"

GMainLoop* loop;

static gboolean fatal_handler(const gchar* log_domain,
                              GLogLevelFlags log_level,
                              const gchar* message,
                              gpointer user_data)
{
    return FALSE;
}

static gboolean
show_infos (gpointer data)
{
    marlin_icon_info_infos_caches ();
    //g_message ("pix ref count %u", G_OBJECT (data)->ref_count);
    g_main_loop_quit (loop);

    return FALSE;
}

void marlincore_tests_icon_info (void)
{
    GOFFile* file;

    g_test_log_set_fatal_handler (fatal_handler, NULL);
    /* The URI is valid, the target exists */
    file = gof_file_get_by_uri ("file:///home/kitkat/test/zz/a.png");
    g_assert(file != NULL);
    gof_file_query_update (file);
    g_assert(file->pix == NULL);
    file->flags = 2;
    gof_file_update_icon (file, 128);
    g_assert(file->pix != NULL);
    gof_file_update_icon (file, 32);
    /*gof_file_update_icon (file, 16);*/
    g_message ("pix ref count %u", G_OBJECT (file->pix)->ref_count);
    //g_object_unref (file->pix);
    //g_message ("pix ref count %u", G_OBJECT (file->pix)->ref_count);
    g_object_unref (file->pix);
    //g_clear_object (&file->pix);

    //marlin_icon_info_infos_caches ();

    //g_timeout_add_seconds_full (0, 2, show_infos, file->pix, NULL);
    g_timeout_add_seconds_full (0, 2, show_infos, NULL, NULL);

    loop = g_main_loop_new(NULL, FALSE);
    g_main_loop_run(loop);

#if 0
    g_assert(file != NULL);
    g_assert_cmpstr(g_file_info_get_name (file->info), ==, "share");
    g_assert_cmpint(gof_file_is_symlink(file), ==, FALSE);
#endif

}
