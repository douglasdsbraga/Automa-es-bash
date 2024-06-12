# compress dir e files
Trata de ser um script de linha de comando focado em automatizar a compressão de uma lista de arquivos ou ou pastas via terminal. 

O caso da qual se recomenda usar ele é no caso de fazer compressão por compressão e, no caso dele, remover a pasta original. A escolha pra compra compressão foi o .tar e com o zgip pra compressão fica entÀo nomeDoArquivo.tar.gz

Lembranod que neste executavel ele leva em consideração o pv ( pipe viwer ) para poder ver o progresso. Para poder instalar, fica assim: 

macOS: Se pv não estiver instalado, você pode instalá-lo usando Homebrew:
brew install pv


Linux: A instalação do pv varia conforme a distribuição. Aqui estão alguns exemplos:

Debian/Ubuntu:
sudo apt-get install pv

Red Hat/CentOS:
sudo yum install pv

Fedora:
sudo dnf install pv

Certo com o arquivo criado e com insatalação do pv feita é necessário tonar o aruqivo executavel e por seguinte dar as devidas permissões. Isto nòa é uma recomendação mas em ultimo caso de a permissão máximo para que econsuga adentrar nas pastas e sub pastas.

-------------------------------------------------------

estrutura de pastas
dsb-projects
L dsb-projeto1
L dsb-projeto2
L dsb-projeto3
L ... 

Antes preciso explicar algumas coisas como o comando tar e pv e seus argumentos

o comando tar ele possui os argumentos:
tar -czvf backup.tar.gz meus_dados/

que deocmpondo fica desta forma: 

- tar: Chama o programa tar.
- -c: Cria um novo arquivo tar.
- -z: Comprime o arquivo tar com gzip.
- -v: Exibe o progresso da operação.
- -f: Especifica o nome do arquivo de saída, que é backup.tar.gz.
- meus_dados/: A pasta cujo conteúdo será arquivado e comprimido.

Para descompactar:

tar -xzvf backup.tar.gz

Neste comando:

-x: Extract (extrair), usado para extrair o conteúdo do arquivo tar.
-z: Descomprime o arquivo usando gzip.
-v: Exibe o progresso da operação.
-f: Especifica o nome do arquivo tar a ser extraído (backup.tar.gz).


O uso do PV ( piupe viwer ) é geralmente considerado mais simples de usar para mostrar uma barra de progresso ao arquivar e comprimir arquivos com tar. O pv é fácil de integrar em pipelines de comandos e fornece uma barra de progresso clara e direta.

tar -cf - pasta/ | pv -s $(du -sb pasta/ | awk '{print $1}') | gzip > arquivo.tar.gz

Explicação:

- **tar -cf - pasta/**: Cria um arquivo tar da pasta e envia a saída para stdout (-).
- **pv -s $(du -sb pasta/ | awk '{print $1}')**: pv lê o tamanho total da pasta e mostra a barra de progresso.
- **gzip > arquivo.tar.gz**: Comprime a saída e salva no arquivo arquivo.tar.gz.


Descomprimindo e Extraindo com pv e tar

Para descomprimir e extrair um arquivo tar.gz com uma barra de progresso, use:

pv arquivo.tar.gz | tar -xzvf -

xplicação:

- **pv arquivo.tar.gz**: pv lê o arquivo comprimido e mostra a barra de progresso.
- **tar -xzvf -**: Extrai o arquivo tar.gz recebido de pv.





Explicando o script

# Verifica se o pv está instalado
if ! command -v pv &> /dev/null; then
    echo "pv não está instalado. Instale-o usando o gerenciador de pacotes da sua distribuição."
    exit 1
fi

# Diretório onde o script está localizado
base_dir="$(pwd)"

# Nome do script
script_name="compress.sh"

# Muda para o diretório base
cd "$base_dir" || exit

# Loop sobre todos os arquivos e diretórios no diretório atual
# lembrando que no caso auqi esta para toda a pasta mas dá para especificar o  prefixo da pasta como no exmeplo acima dsb-*
for item in * ; do 
    # Exibe o item sendo processado
    echo "Processando: $item"

    # Verifica se é um diretório
    if [ -d "$item" ]; then
        # Cria um arquivo tar.gz com o nome do diretório, exceto para o próprio script, arquivos já comprimidos e arquivos que são .tar.gz
        if [ "$item" != "$script_name" ] && [ ! -e "${item}.tar.gz" ] && [[ "$item" != *.tar.gz ]]; then
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
        # Cria um arquivo tar.gz com o nome do arquivo, exceto para o próprio script, arquivos já comprimidos e arquivos que são .tar.gz
        if [ "$item" != "$script_name" ] && [ ! -e "${item}.tar.gz" ] && [[ "$item" != *.tar.gz ]]; then
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

**Pontos importantes**

1. Evita a Compressão do Próprio Script e Arquivos Já Comprimidos
2. Neste script: Adicionamos uma variável script_name para armazenar o nome do script atual (compress.sh). Dentro do loop, verificamos se o item é o próprio script ou se já foi comprimido, usando a condição "$item" != "$script_name" e [ ! -e "${item}.tar.gz" ]. Se o item não for o próprio script e ainda não foi comprimido, o script procede com a compressão normal e depois remove o diretório ou arquivo usando rm -rf "$item" ou rm -f "$item", respectivamente.
3. após a compressão bem-sucedida de um diretório ou arquivo, usamos rm -rf "$item" ou rm -f "$item" para remover o item do sistema de arquivos. Isso garante que o item original seja removido após ser comprimido.
4. Neste script, adicionei uma mensagem dentro do loop for para exibir qual arquivo ou pasta está sendo processado no momento. Isso proporciona uma melhor experiência ao usuário, pois ele pode ver em tempo real o progresso do script.
5. Para evitar a compressão de arquivos que já estão comprimidos (por exemplo, arquivos .tar.gz), podemos adicionar uma verificação adicional no script para ignorar esses arquivos. Neste script, a verificação adicional [[ "$item" != *.tar.gz ]] foi adicionada para ignorar arquivos que já são .tar.gz. Isso garante que esses arquivos não serão comprimidos novamente.  
6. Existe a possibilidade de uma  verificação para usar um array de formatos de compressão em vez de apenas .tar.gz. Isso tornaria o script mais flexível e permitiria que adicionasse ou removesse facilmente outros formatos de compressão conforme necessário.

