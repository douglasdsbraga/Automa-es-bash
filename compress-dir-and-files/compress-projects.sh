#!/bin/bash

# Verifica se o pv está instalado
if ! command -v pv &> /dev/null; then
    echo "pv não está instalado. Instale-o usando o gerenciador de pacotes da sua distribuição."
    exit 1
fi

# Diretório onde o script está localizado
base_dir="$(pwd)"

# Nome do script
script_name="compress-projects.sh"

# Lista de formatos de compressão a serem ignorados
ignored_formats=("*.tar.gz" "*.zip" "*.rar")  # Adicione outros formatos conforme necessário

# Muda para o diretório base
cd "$base_dir" || exit

# Loop sobre todos os arquivos e diretórios no diretório atual
for item in * ; do
    # Exibe o item sendo processado
    echo "Processando: $item"

    # Verifica se é um diretório
    if [ -d "$item" ]; then
        # Cria um arquivo tar.gz com o nome do diretório, exceto para o próprio script e arquivos já comprimidos
        if [ "$item" != "$script_name" ] && [ ! -e "${item}.tar.gz" ]; then
            tar -cf - "$item" | pv -s $(du -sb "$item" | awk '{print $1}') | gzip > "${item}.tar.gz"
            echo "Arquivo ${item}.tar.gz criado com sucesso."
            # Remover diretório após compressão
            rm -rf "$item"
            echo "Diretório ${item} removido."
        else
            echo "Pulando a compressão de ${item}."
        fi
    # Verifica se é um arquivo
    elif [ -f "$item" ]; then
        # Verifica se o arquivo corresponde a um formato de compressão a ser ignorado
        ignore_file=false
        for format in "${ignored_formats[@]}"; do
            if [[ "$item" == $format ]]; then
                ignore_file=true
                break
            fi
        done

        # Cria um arquivo tar.gz com o nome do arquivo, exceto para o próprio script e arquivos já comprimidos
        if [ "$item" != "$script_name" ] && [ ! -e "${item}.tar.gz" ] && [ "$ignore_file" = false ]; then
            tar -czvf "${item}.tar.gz" "$item"
            echo "Arquivo ${item}.tar.gz criado com sucesso."
            # Remover arquivo após compressão
            rm -f "$item"
            echo "Arquivo ${item} removido."
        else
            echo "Pulando a compressão de ${item}."
        fi
    else
        echo "$item não é um diretório ou arquivo."
    fi
done

