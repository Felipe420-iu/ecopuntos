[1mdiff --git a/create_superadmin.py b/create_superadmin.py[m
[1mindex 46146ec..92e821b 100644[m
[1m--- a/create_superadmin.py[m
[1m+++ b/create_superadmin.py[m
[36m@@ -92,8 +92,13 @@[m [mdef get_env_or_input(varname, prompt_text, hide=False):[m
 [m
     if val:[m
         return val[m
[32m+[m[32m    # If running in a non-interactive environment (no TTY), do not prompt[m
     if hide:[m
[32m+[m[32m        if not sys.stdin.isatty():[m
[32m+[m[32m            return None[m
         return getpass.getpass(prompt_text + ': ')[m
[32m+[m[32m    if not sys.stdin.isatty():[m
[32m+[m[32m        return None[m
     return input(prompt_text + ': ')[m
 [m
 [m
[1mdiff --git a/start.sh b/start.sh[m
[1mindex bbbff68..4e301ca 100644[m
[1m--- a/start.sh[m
[1m+++ b/start.sh[m
[36m@@ -7,8 +7,17 @@[m [mecho "Collecting static files..."[m
 python manage.py collectstatic --noinput || echo "collectstatic failed, continuing..."[m
 [m
 echo "Ensuring superuser exists (create_superadmin)..."[m
[31m-# create_superadmin.py reads DJANGO_SUPERUSER_* env vars; --use-railway will prefer RAILWAY_DATABASE_URL/DATABASE_URL[m
[31m-python create_superadmin.py --use-railway --migrate || echo "create_superadmin failed or skipped, continuing..."[m
[32m+[m[32m## build command with optional username/email args (password should stay in env vars)[m
[32m+[m[32mCREATE_CMD=(python create_superadmin.py --use-railway --migrate)[m
[32m+[m[32mif [ -n "${DJANGO_SUPERUSER_USERNAME:-}" ]; then[m
[32m+[m[32m  CREATE_CMD+=(--username "${DJANGO_SUPERUSER_USERNAME}")[m
[32m+[m[32mfi[m
[32m+[m[32mif [ -n "${DJANGO_SUPERUSER_EMAIL:-}" ]; then[m
[32m+[m[32m  CREATE_CMD+=(--email "${DJANGO_SUPERUSER_EMAIL}")[m
[32m+[m[32mfi[m
[32m+[m
[32m+[m[32m# Execute command (password must be in env var DJANGO_SUPERUSER_PASSWORD in Railway)[m
[32m+[m[32m"${CREATE_CMD[@]}" || echo "create_superadmin failed or skipped, continuing..."[m
 [m
 echo "Starting Gunicorn..."[m
 exec gunicorn proyecto2023.wsgi:application \[m
