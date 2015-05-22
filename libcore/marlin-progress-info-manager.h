/*
 * Copyright (C) 2011 Red Hat, Inc.
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
 * Author: Cosimo Cecchi <cosimoc@redhat.com>
 */

#ifndef __MARLIN_PROGRESS_INFO_MANAGER_H__
#define __MARLIN_PROGRESS_INFO_MANAGER_H__

#include <glib-object.h>

#include <marlin-progress-info.h>

#define MARLIN_TYPE_PROGRESS_INFO_MANAGER marlin_progress_info_manager_get_type()
#define MARLIN_PROGRESS_INFO_MANAGER(obj) \
    (G_TYPE_CHECK_INSTANCE_CAST ((obj), MARLIN_TYPE_PROGRESS_INFO_MANAGER, MarlinProgressInfoManager))
#define MARLIN_PROGRESS_INFO_MANAGER_CLASS(klass) \
    (G_TYPE_CHECK_CLASS_CAST ((klass), MARLIN_TYPE_PROGRESS_INFO_MANAGER, MarlinProgressInfoManagerClass))
#define MARLIN_IS_PROGRESS_INFO_MANAGER(obj) \
    (G_TYPE_CHECK_INSTANCE_TYPE ((obj), MARLIN_TYPE_PROGRESS_INFO_MANAGER))
#define MARLIN_IS_PROGRESS_INFO_MANAGER_CLASS(klass) \
    (G_TYPE_CHECK_CLASS_TYPE ((klass), MARLIN_TYPE_PROGRESS_INFO_MANAGER))
#define MARLIN_PROGRESS_INFO_MANAGER_GET_CLASS(obj) \
    (G_TYPE_INSTANCE_GET_CLASS ((obj), MARLIN_TYPE_PROGRESS_INFO_MANAGER, MarlinProgressInfoManagerClass))

typedef struct _MarlinProgressInfoManager MarlinProgressInfoManager;
typedef struct _MarlinProgressInfoManagerClass MarlinProgressInfoManagerClass;
typedef struct _MarlinProgressInfoManagerPriv MarlinProgressInfoManagerPriv;

struct _MarlinProgressInfoManager {
    GObject parent;

    /* private */
    MarlinProgressInfoManagerPriv *priv;
};

struct _MarlinProgressInfoManagerClass {
    GObjectClass parent_class;
};

GType marlin_progress_info_manager_get_type (void);

MarlinProgressInfoManager* marlin_progress_info_manager_new (void);

void marlin_progress_info_manager_add_new_info (MarlinProgressInfoManager *self,
						  MarlinProgressInfo *info);
GList *marlin_progress_info_manager_get_all_infos (MarlinProgressInfoManager *self);

G_END_DECLS

#endif /* __MARLIN_PROGRESS_INFO_MANAGER_H__ */
