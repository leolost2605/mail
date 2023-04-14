// -*- Mode: vala; indent-tabs-mode: nil; tab-width: 4 -*-
/*-
 * Copyright (c) 2017 elementary LLC. (https://elementary.io)
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 *
 * Authored by: Corentin Noël <corentin@elementary.io>
 */

public class Mail.Backend.Account : GLib.Object {
    public Camel.Service service { get; construct; }

    public Account (Camel.Service service) {
        Object (service: service);
    }

    construct {
        unowned var network_manager = GLib.NetworkMonitor.get_default ();
        network_manager.network_changed.connect (() => {
            manage_connection.begin (network_manager.network_available);
        });
    }

    public async void manage_connection (bool online) {
        var offlinestore = (Camel.OfflineStore)service;

        if (online) {
            try {
                yield offlinestore.set_online (true, GLib.Priority.DEFAULT, null);
                yield offlinestore.synchronize (false, GLib.Priority.DEFAULT, null);
            } catch (Error e) {
                critical (e.message);
            }
            return;
        }

        try {
            yield offlinestore.set_online (false, GLib.Priority.DEFAULT, null);
        } catch (Error e) {
            critical (e.message);
        }
    }

    public static uint hash (Mail.Backend.Account account) {
        return GLib.str_hash (account.service.uid);
    }
    public bool equal (Mail.Backend.Account account2) {
        return hash (this) == hash (account2);
    }
}
