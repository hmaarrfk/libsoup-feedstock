#include <libsoup/soup.h>

int main(int argc, char *argv[]) {
  g_debug("Entering main");
  SoupMessage *msg = soup_message_new(SOUP_METHOD_GET, "https://conda-forge.org");
  SoupSession *session = soup_session_new();
  GError *error = NULL;
#ifdef G_OS_WIN32
  gchar *ca_file = g_build_filename(g_getenv("CONDA_PREFIX"), "Library", "ssl", "cacert.pem", NULL);
  GTlsDatabase *db = g_tls_file_database_new(ca_file, &error);
  if (error) {
    g_warning("Could not create TLS database for %s -> %s", ca_file, error->message);
    g_error_free(error);
    return 1;
  }
  else {
    g_object_set(session, "tls-database", db, "ssl-use-system-ca-file", FALSE, NULL);
    g_object_unref(db);
  }
  g_free(ca_file);
#endif
  GBytes *bytes = soup_session_send_and_read(session, msg, NULL, &error); // blocks
  if (error) {
    g_error_free(error);
    return 1;
  }

  g_assert_true(soup_message_get_status(msg) == SOUP_STATUS_OK);
  g_object_unref(msg);
  g_object_unref(session);
  return 0;
}

