import gi
import os
import sys
from pathlib import PurePath

gi.require_version("Soup", "2.4")
from gi.repository import GObject, Soup, Gio, GLib

# version check
# assert Soup.get_major_version() == Soup.MAJOR_VERSION
# assert Soup.get_minor_version() == Soup.MINOR_VERSION
# assert Soup.get_micro_version() == Soup.MICRO_VERSION

msg = Soup.Message.new("GET", "https://conda-forge.org")
session = Soup.Session.new()

if os.name == 'nt':
    ca_file = PurePath(os.environ["CONDA_PREFIX"], "Library", "ssl", "cacert.pem")
    try:
        db = Gio.TlsFileDatabase.new(str(ca_file))
    except GLib.Error as e:
        print(f"Could not create TLS database for {str(ca_file)} -> {e.message}")
        sys.exit(1)
    else:
        session.props.tls_database = db
        session.props.ssl_use_system_ca_file = False

session.send_message(msg) # blocks
if msg.props.status_code < 200 or msg.props.status_code >= 300:
    print(f"Found status code: {msg.props.status_code}")
