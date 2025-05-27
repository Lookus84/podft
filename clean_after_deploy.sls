#!jinja|yaml|gpg

# Очистка временных файлов
remove_tmp_dirs:
  cmd.run:
    - name: "[ -d /tmp/deploy_apps ] || [ -d /tmp/kubernetes ] && rm -rf /tmp/deploy_apps /tmp/kubernetes || echo 'Директории отсутствуют'"