/*
* Copyright (c) 2011-2017 Alecaddd (http://alecaddd.com)
*
* This program is free software; you can redistribute it and/or
* modify it under the terms of the GNU General Public
* License as published by the Free Software Foundation; either
* version 2 of the License, or (at your option) any later version.
*
* This program is distributed in the hope that it will be useful,
* but WITHOUT ANY WARRANTY; without even the implied warranty of
* MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
* General Public License for more details.
*
* You should have received a copy of the GNU General Public
* License along with this program; if not, write to the
* Free Software Foundation, Inc., 51 Franklin Street, Fifth Floor,
* Boston, MA 02110-1301 USA
*
* Authored by: Alessandro "Alecaddd" Castellani <castellani.ale@gmail.com>
*/

namespace Sequeler { 
    public class DataBase : Object {
        public Gda.Connection cnn;
        public string cnc_string { set; get; }
        public string provider { set; get; default = "SQLite"; }
        public string port { set; get; default = "3306"; }

        public void set_constr_data (Gee.HashMap<string, string> data) {
            provider = data["type"] == "MariaDB"? "MySQL" : data["type"];
            port = data["port"] != "" ? data["port"] : port;

            if (provider == "SQLite") {
                cnc_string = provider + "://DB_DIR=" + data["host"] + ";DB_NAME=" + data["name"] + "";
                return;
            }

            cnc_string = provider + "://" + data["username"] + ":" + data["password"] + "@DB_NAME=" + data["name"] + ";HOST=" + data["host"] + ";PORT=" + port;
        }

        public void open () throws Error {
            try {
                cnn = Gda.Connection.open_from_string (null, cnc_string, null, Gda.ConnectionOptions.NONE);
            } catch ( Error e ) {
				throw e;
            }
            if (cnn.is_opened ()) {
                cnn.execution_timer = true;
            }
        }

        public int run_query (string query) throws Error requires (cnn.is_opened ()) {
            return cnn.execute_non_select_command (query);
        }

        public Gda.DataModel? run_select (string query) throws Error requires (cnn.is_opened ()) {
            return cnn.execute_select_command (query);
        }

        public void close () {
            cnn.close ();
        }
    }
}