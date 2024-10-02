.. index:: ! installing

.. _installing-solidity:

###################################
Instalando o Compilador do Solidity
###################################

Controle de Versão
==================

As versões do Solidity seguem o `Controle de Versão Semântico <https://semver.org>`_. Além disso,
lançamentos de nível de patch com a versão principal 0 (ou seja, 0.x.y) não 
conterão mudanças incompatíveis. Isso significa que o código que compila com a versão 0.x.y
pode ser experado para compilar com 0.x.z, onde z > y.

Além dos lançamentos, fornecemos **versões de desenvolvimento nightly** para facilitar
que os desenvolvedores experimentem novos recursos e
feedback antecipado. No ententao, observe que, embora as versões nightly sejam
muito estáveis, elas contêm o código mais recente da branch de desenvolvimento e não
há garantia que sempre irão funcionar. Apesar dos nossos melhores esforços, podem
conter mudanças não documentadas e/ou imcompatíveis que não farão parte de um
lançamento oficial. Elas não são destinadas para uso em produção.

Ao implantar contratos, você deve usar a versão mais recente lançada do Solidity. Isso
é por causa das quebras de compatibilidade, além de novos recursos e correções de bugs, são introduzidas regularmente.
Atualmente, usamos um número de versão 0.x `para indicar esse ritmo de mudança <https://semver.org/#spec-item-4>`_.

Remix
=====

*Recomendamos Remix para pequenos contratos e para aprender rapidamente Solidity.*

`Acesse o Remix online <https://remix.ethereum.org/>`_, você não precisa instalar nada.
Se quiser usá-lo sem conexão com a Internet, acesse
https://github.com/ethereum/remix-live/tree/gh-pages#readme e siga as instruções dessa página.
O Remix é uma opção conveniente para testar versões nightly
sem a necessidade de instalar várias versões do Solidity.

Outras informações nesta página detalham instalar o compilador do Solidity via linha de comando
no seu computador. Escolha um compilador de linha de comando se estiver trabalhando em um contrato maior
ou se precisar de mais opções de compilação.

.. _solcjs:

npm / Node.js
=============

Use o ``npm`` como uma maneira conveniente e portátil de instalar o ``solcjs``, um compilador do Solidity. O
programa `solcjs` possui menos recursos que as formas de acessar o compilador descritas
mais adiante nesta página. A
documentação do :ref:`commandline-compiler` presume que você está usando
o compilador completo ``solc``. O uso do ``solcjs`` é documentado dentro do seu próprio
`repositório <https://github.com/ethereum/solc-js>`_.

Nota: O projeto solc-js é derivado do `solc` em C++
usando Emscripten, o que significa que ambos usam o mesmo código fonte de compilador.
O `solc-js` pode ser usado diretamente em projetos JavaScript (como o Remix).
Por favor, consulte o repositório solc-js para obter instruções.

.. code-block:: bash

    npm install -g solc

.. note::

    O executável de linha de comando é chamado ``solcjs``.

    As opções de linha de comando do ``solcjs`` não são compatíveis com o ``solc`` e ferramentas (como o ``geth``)
    que esperam o comportamento do ``solc`` não irão funcionar com ``solcjs``.

Docker
======

Imagens Docker das compilações do Solidity estão disponíveis utilizando a imagem ``solc`` da organização ``ethereum``.
Use a tag ``stable`` para a versão mais recente lançada, e ``nightly`` para mudanças potencialmente instáveis na branch de ``desenvolvimento``.

A imagem Docker executa o compilador, permitindo que você passe todos os argumentos do compilador para ela.
Por exemplo, o comando abaixo faz o download da versão estável da imagem ``solc`` (se você ainda não a tiver)
e a executa em um novo container, passando o argumento ``--help``.

.. code-block:: bash

    docker run ethereum/solc:stable --help

Você pode especificar versões de builds lançadas na tag. Por exemplo:

.. code-block:: bash

    docker run ethereum/solc:stable --help

Nota

Versões específicas do compilador são suportadas como tags da imagem Docker, como `ethereum/solc:0.8.23`. Aqui, usaremos a
tag `stable` em vez de uma versão específica para garantir que os usuários obtenham a versão mais recente por padrão e evitem o problema de
obter uma versão desatualizada.

Para usar a imagem Docker para compilar arquivos Solidity na máquina host, monte uma
pasta local para entrada e saída e especifique o contrato a ser compilado. Por exemplo:

.. code-block:: bash

    docker run -v /local/path:/sources ethereum/solc:stable -o /sources/output --abi --bin /sources/Contract.sol

Você também pode usar a interface JSON padrão (que é recomendada ao usar o compilador com ferramentas).
Ao usar essa interface, não é necessário montar nenhum diretório de forma que o JSON de entrada é
autossuficiente (ou seja, não refere-se a nenhum arquivo externo que precise ser
:ref:`carregado pelo callback de importação <initial-vfs-content-standard-json-with-import-callback>`).

.. code-block:: bash

    docker run ethereum/solc:stable --standard-json < input.json > output.json

Pacotes Linux
=============

Pacotes binários do Solidity estão disponíveis em 
`solidity/releases <https://github.com/ethereum/solidity/releases>`_.

Também temos PPAs para Ubuntu, você pode obter a versão estável
mais recente utilizando os seguintes comandos:

.. code-block:: bash

    sudo add-apt-repository ppa:ethereum/ethereum
    sudo apt-get update
    sudo apt-get install solc

A versão nightly pode ser instalada usando os seguintes comandos:

.. code-block:: bash

    sudo add-apt-repository ppa:ethereum/ethereum
    sudo add-apt-repository ppa:ethereum/ethereum-dev
    sudo apt-get update
    sudo apt-get install solc

Além disso, algumas distribuições Linux oferecem seus próprios pacotes. Esses pacotes não são mantidos
diretamente por nós, mas geralmente são mantidos atualizados pelos respectivos mantenedores de pacotes.

Por exemplo, o Arch Linux tem pacotes para a versão mais recente de desenvolvimento como pacotes AUR: `solidity <https://aur.archlinux.org/packages/solidity>`_
e `solidity-bin <https://aur.archlinux.org/packages/solidity-bin>`_.

.. note::

    Por favor, esteja ciente de que os pacotes `AUR <https://wiki.archlinux.org/title/Arch_User_Repository>`_
    são conteúdos produzidos por usuários e pacotes não oficiais. Tenha cautela ao utilzá-los.

Também existe um `pacote snap <https://snapcraft.io/solc>`_, no entanto, ele está **atualmente sem manutenção**.
Ele é instalável em todas as `distribuições Linux suportadas <https://snapcraft.io/docs/core/install>`_. Para
instalar a versão estável mais recente do solc:

.. code-block:: bash

    sudo snap install solc

Se você quiser ajudar a testar a versão mais recente do Solidity
com as mudanças mais recentes, use o seguinte comando:

.. code-block:: bash

    sudo snap install solc --edge

.. note::

    O pacote ``solc`` snap utiliza confinamento estrito. Esse é o modo mais seguro para pacotes snap,
    mas possui algumas limitações, como acessar apenas arquivos nos diretórios ``/home`` e ``/media``.
    Para mais informações, consulte `Desmistificando o Confinamento do Snap <https://snapcraft.io/blog/demystifying-snap-confinement>`_.


Pacotes macOS
=============

Distribuímos o compilador Solidity através do Homebrew
como uma versão de compilação a partir do código-fonte. Atualmente,
pacotes pré-compilados (bottles) não são suportados.

.. code-block:: bash

    brew update
    brew upgrade
    brew tap ethereum/ethereum
    brew install solidity

Para instalar a versão mais recente do Solidity 0.4.x ou 0.5.x, você pode usar, respectivamente,
os comandos ``brew install solidity@4`` e ``brew install solidity@5``.

Se você precisar de uma versão específica do Solidity, pode instalar uma
fórmula do Homebrew diretamente do GitHub.

Visualize os
`commits de solidity.rb no GitHub <https://github.com/ethereum/homebrew-ethereum/commits/master/solidity.rb>`_.

Copie o hash do commit da versão que você deseja e faça o checkout em sua máquina.

.. code-block:: bash

    git clone https://github.com/ethereum/homebrew-ethereum.git
    cd homebrew-ethereum
    git checkout <o-hash-do-commit-vem-aqui>

Instale usando o ``brew``:

.. code-block:: bash

    brew unlink solidity
    # por exemplo: Instala 0.4.8
    brew install solidity.rb

Binários Estáticos
==================

Mantemos um repositório contendo compilações estáticas de versões passadas e atuais do compilador para todas
as plataforma suportadas em `solc-bin`_. Este também é o local onde você pode encontrar as compilações nightly.

O Repositório não é apenas um caminho rápido e fácil para usuários finais para obterem binários prontos para uso
imediato, mas também é projetado para ser amigável a ferramentas de terceiros:

- O conteúdo é espelhado em https://binaries.soliditylang.org onde pode ser facilmente baixado via
  HTTPS, sem qualquer autenticação, limite de taxa ou necessidade de usar git.
- O conteúdo é servido com cabeçalhos `Content-Type` corretos e configuração de CORS flexível, de forma que
  possa ser carregado diretamente pelas ferramentas rodando no navegador.
- Os binários não requerem instalação ou descompactação (com exceção das compilações mais antigas para Windows
  que vêm com as DLLs necessárias).
- Nos empenhamos em manter um alto nível de compatibilidade retroativa. Arquivos, uma vez adicionados, não são removidos ou movidos
  sem fornecer um link simbólico/redirecionamento para a localização enterior. Eles também nunca são modificados
  e devem sempre corresponder ao checksum original. A única exceção seria para arquivos corrompidos 
  inutilizáveis que poderiam causar mais danos se deixados como estão.
- Os arquivos são servidos ambos via HTTP e HTTPS. Desde que você obtenha a lista de arquivos de maneira segura
  (via git, HTTPS, IPFS ou apenas mantê-la em cache localmente) e verifique os hashes dos binários
  após o download, não é necessário usar HTTPS para os próprios binários.

Os mesmos binários estão em muitos casos disponíveis na `página de lançamentos do Solidity no GitHub`_. A
diferença é que nós geralmente não atualizamos versões antigas na página de lançamentos no GitHub. Isso significa
que nós não renomeamos os arquivos se o padrão de nomenclatura mudar e não adicionamos compilações para plataformas
que não eram suportadas no momento do lançamento. Isso só ocorre no repositório ``solc-bin``.

O repositório ``solc-bin`` contém vários diretórios de nível superior, cada um representando uma única plataforma.
Cada diretório inclui um arquivo ``list.json`` que lista os binários disponíveis. Por exemplo, em
``emscripten-wasm32/list.json``, você vai encontrar a seguinte informação sobre a versão 0.7.4:

.. code-block:: json

    {
      "path": "solc-emscripten-wasm32-v0.7.4+commit.3f05b770.js",
      "version": "0.7.4",
      "build": "commit.3f05b770",
      "longVersion": "0.7.4+commit.3f05b770",
      "keccak256": "0x300330ecd127756b824aa13e843cb1f43c473cb22eaf3750d5fb9c99279af8c3",
      "sha256": "0x2b55ed5fec4d9625b6c7b3ab1abd2b7fb7dd2a9c68543bf0323db2c7e2d55af2",
      "urls": [
        "dweb:/ipfs/QmTLs5MuLEWXQkths41HiACoXDiH8zxyqBHGFDRSzVE5CS"
      ]
    }

Isso significa que:

- Você pode encontrar o binário no mesmo diretório sob o nome
  `solc-emscripten-wasm32-v0.7.4+commit.3f05b770.js <https://github.com/ethereum/solc-bin/blob/gh-pages/emscripten-wasm32/solc-emscripten-wasm32-v0.7.4+commit.3f05b770.js>`_.
  Note que o arquivo poderia ser um link simbólico, e você vai precisar resolver isso você mesmo se você não estiver usando
  git para baixar isso ou seu sistema de arquivos não suporta links simbólicos.
- O binário também está espelhado em https://binaries.soliditylang.org/emscripten-wasm32/solc-emscripten-wasm32-v0.7.4+commit.3f05b770.js.
  Neste caso, o git não é necessário e links simbólicos são resolvidos de forma transparente, seja servindo uma cópia
  do arquivo ou retornando um redirecionamento HTTP.
- O arquivo também está disponível no IPFS em `QmTLs5MuLEWXQkths41HiACoXDiH8zxyqBHGFDRSzVE5CS`_.
  Tenha cuidado que a ordem dos itens na matriz de ``urls`` não seja predeterminada ou garantida e os usuários
  não deveriam confiar nisso.
- Você pode verificar a integridade do binário comparando seu hash keccak256 com
  ``0x300330ecd127756b824aa13e843cb1f43c473cb22eaf3750d5fb9c99279af8c3``. O hash pode ser calculado
  na linha de comando usando a utilidade ``keccak256sum`` fornecida por `sha3sum`_ ou pela `função keccak256()
  do ethereumjs-util`_ no JavaScript.
- Você também pode verificar a integridade do binário ao comparar seu hash sha256 com
  ``0x2b55ed5fec4d9625b6c7b3ab1abd2b7fb7dd2a9c68543bf0323db2c7e2d55af2``.

.. warning::

   Devido à forte exigência de compatibilidade retroativa, o repositório contém alguns elementos legados,
   mas você deve evitar usar eles quando escrever novas ferramentas:

   - Utilize ``emscripten-wasm32/`` (com um fallback para ``emscripten-asmjs/``) ao invés de ``bin/`` se
     você quiser a melhor performance. Desde a versão 0.6.1, fornecíamos apenas binários asm.js.
     A partir da versão 0.6.2, passamos a usar `compilações de WebAssembly`_ que oferecem desempenho muito melhor. Nós temos
     re-compilado as versões antigas para wasm, mas os arquivos asm.js originais permanecem em ``bin/``.
     Os novos foram colocados em um diretório separado para evitar conflitos de nomes.
   - Utilize ``emscripten-asmjs/`` e ``emscripten-wasm32/`` ao invés dos diretório ``bin/`` e ``wasm/``
     se você quiser ter certeza se você está baixando um binário wasm ou um asm.js.
   - Utilize ``list.json`` ao invés de ``list.js`` e ``list.txt``. O formato da lista JSON contém toda
     a informação dos antigos e mais.
   - Use https://binaries.soliditylang.org em vez de https://solc-bin.ethereum.org. Para manter as coisas
     simples, movemos quase tudo relacionado ao compilador sob o novo domínio ``soliditylang.org``
     e isso aplica-se ao ``solc-bin`` também. Embora o novo domínio seja recomendado, o antigo
     é ainda totalmente suportado e garantido para apontar para o mesmo local.

.. warning::

    Os binário estão também disponíveis em https://ethereum.github.io/solc-bin/, mas essa página
    parou de ser atualizada logo após o lançamento da versão 0.7.2. Não receberá novos lançamentos
    ou compilações nightly para nenhuma plataforma, e não serve a nova estrutura de diretórios, incluindo
    compilações não emscripten.

    Se você estiver usando essa página, mude para https://binaries.soliditylang.org, que é uma substituição
    direta. Isso nos permite fazer alterações na hospedagem de subjacente de forma transparente,
    minimizando interrupções. Diferente do domínio ``ethereum.github.io``, que nós não temos qualquer controle
    sobre, ``binaries.soliditylang.org`` é garantido funcionar e manter a mesma estrutura de URL
    em um longo prazo.

.. _IPFS: https://ipfs.io
.. _solc-bin: https://github.com/ethereum/solc-bin/
.. _página de lançamentos do Solidity no GitHub: https://github.com/ethereum/solidity/releases
.. _sha3sum: https://github.com/maandree/sha3sum
.. _função keccak256() do ethereumjs-util: https://github.com/ethereumjs/ethereumjs-util/blob/master/docs/modules/_hash_.md#const-keccak256
.. _compilações de WebAssembly: https://emscripten.org/docs/compiling/WebAssembly.html
.. _QmTLs5MuLEWXQkths41HiACoXDiH8zxyqBHGFDRSzVE5CS: https://gateway.ipfs.io/ipfs/QmTLs5MuLEWXQkths41HiACoXDiH8zxyqBHGFDRSzVE5CS

.. _building-from-source:

Compilando a partir do código-fonte
===================================
Pré-requisitos - Todos os Sistemas Operacionais
-----------------------------------------------

A seguir, as dependências para todas as compilações do Solidity:

+-------------------------------------+--------------------------------------------------------------+
| Software                            | Notas                                                        |
+=====================================+==============================================================+
| `CMake`_ (versão 3.21.3+ no         | Gerador de arquivos de compilação multiplataforma            |
| Windows, 3.13+ em outros sistemas)  |                                                              |
+-------------------------------------+--------------------------------------------------------------+
| `Boost`_ (versão 1.77+ no           | Bibliotecas C++.                                             |
| Windows, 1.67+ em outros sistemas)  |                                                              |
+-------------------------------------+--------------------------------------------------------------+
| `Git`_                              | Ferramenta de linha de comando para recuperar o código-fonte |
+-------------------------------------+--------------------------------------------------------------+
| `z3`_ (versão 4.8.16+, Opcional)    | Para uso com o verificador SMT.                              |
+-------------------------------------+--------------------------------------------------------------+

.. _Git: https://git-scm.com/download
.. _Boost: https://www.boost.org
.. _CMake: https://cmake.org/download/
.. _z3: https://github.com/Z3Prover/z3

.. note::
    Versões do Solidity anteriores à 0.5.10 podem falhar ao vincular corretamente versões do Boost 1.70+.
    Uma solução possível é renomear temporariamente o ``<diretório de instalação do Boost>/lib/cmake/Boost-1.70.0``
    antes de executar o comando cmake para configurar o Solidity.
    
    A partir da versão 0.5.0, a vinculação com o Boost 1.70+ deve funcionar sem intervenção manual.

.. note::
    A configuração de compilação padrão exige uma versão específica do Z3 (a mais recente no momento em que
    o código foi atualizado pela última vez). Mudanças introduzidas entre versões do Z3 geralmente resultam em resultados ligeiramente diferentes
    (mas ainda válidos) sendo retornados. Nossos testes SMT não levam em conta essas diferenças e
    provavelmente falharão com uma versão diferente daquela para a qual foram escritos. Isso não significa
    que uma compilação usando uma versão diferente esteja com defeito. Se você passar a opção ``-DSTRICT_Z3_VERSION=OFF``
    para o CMake, pode compilar com qualquer versão que atenda ao requisito fornecido na tabela acima.
    No entanto, se você fizer isso, lembre-se de passar a opção ``--no-smt`` para  o script``scripts/tests.sh``
    para pular os testes SMT.

.. note::
    Por padrão, a compilação é realizada no *modo pedante*, que habilita avisos extras e instrui o
    compilador a tratar todos os avisos como erros.
    Isso obriga os desenvolvedores a corrigir os avisos à medida que surgem, evitando que se acumulem "para serem corrigidos posteriormente".
    Se você estiver interessado apenas em criar uma compilação de lançamento e não tem a intenção de modificar o código-fonte para lidar com esses avisos, pode passar a opção ``-DPEDANTIC=OFF`` para o CMake para desativar esse modo.
    Isso não é recomendado para usos gerais, mas pode ser necessário quando utilizando uma cadeia de ferramentas que não
    estamos testando ou tentanto compilar uma versão antiga das ferramentas mais recentes.
    Se você encontrar tais avisos, considere
    `reportá-los <https://github.com/ethereum/solidity/issues/new>`_.

Versões Mínimas do Compilador
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Os seguintes compiladores C++ e suas versões mínimas podem compilar o código-fonte do Solidity:

- `GCC <https://gcc.gnu.org>`_, versão 8+
- `Clang <https://clang.llvm.org/>`_, versão 7+
- `MSVC <https://visualstudio.microsoft.com/vs/>`_, versão 2019+

Pré-requisitos - macOS
----------------------

Para compilações no macOS, certifique-se de que a versão mais recente do
`Xcode está instalada <https://developer.apple.com/xcode/resources/>`_.
O Xcode contém o `compilador C++ Clang <https://en.wikipedia.org/wiki/Clang>`_, a
`IDE do Xcode <https://en.wikipedia.org/wiki/Xcode>`_ e outras ferramentas de desenvolvimento
da Apple que são necessárias para compilar aplicativos C++ no OS X.
Se você estiver instalando o Xcode pela primeira vez ou acabou de instalar uma nova
versão, então você terá que aceitar a licença antes de você poder
realizar compilações via linha de comando:

.. code-block:: bash

    sudo xcodebuild -license accept

Nosso script de compilação para o OS X usa `o Homebrew <https://brew.sh>`_,
gerenciador de pacotes para instalar dependências externas.
Veja como `desinstalar o Homebrew
<https://docs.brew.sh/FAQ#how-do-i-uninstall-homebrew>`_,
se você quiser começar novamente do zero.

Pré-requisitos - Windows
------------------------

Você precisa instalar as seguintes dependências para compilações do Solidity no Windows:

+-----------------------------------+-----------------------------------------------+
| Software                          | Notas                                         |
+===================================+===============================================+
| `Visual Studio 2019 Build Tools`_ | compilador C++.                               |
+-----------------------------------+-----------------------------------------------+
| `Visual Studio 2019`_ (Opcional)  | compilador C++ e ambiente de desenvolvimento. |
+-----------------------------------+-----------------------------------------------+
| `Boost`_ (versão 1.77+)           | bibliotecas C++.                              |
+-----------------------------------+-----------------------------------------------+

Se você já tem uma IDE e precisa apenas do compilador e bibliotecas,
pode instalar o Visual Studio 2019 Build Tools.

O Visual Studio 2019 fornece tanto a IDE quanto o compilador e bibliotecas necessárias.
Portanto, se você ainda não tem uma IDE e prefere desenvolver em Solidity, Visual Studio 2019
pode ser uma opção para configurar tudo facilmente.

Veja a lista de componentes que deve ser instalada
no Visual Studio 2019 Build Tools ou Visual Studio 2019:

* Recursos principais do Visual Studio C++
* Conjunto de ferramentas VC++ 2019 v141 (x86,x64)
* Windows Universal CRT SDK
* Windows 8.1 SDK
* Suporte ao C++/CLI

.. _Visual Studio 2019: https://www.visualstudio.com/vs/
.. _Visual Studio 2019 Build Tools: https://visualstudio.microsoft.com/vs/older-downloads/#visual-studio-2019-and-other-products

Temos um script auxiliar que você pode usar para instalar todos as dependências externas necessárias:

.. code-block:: bat

    scripts\install_deps.ps1

Isso vai instalar o ``boost`` e o ``cmake`` no diretório ``deps``.

Clonar o Repositório
-------------------

Para clonar o código fonte, execute o seguinte comando:

.. code-block:: bash

    git clone --recursive https://github.com/ethereum/solidity.git
    cd solidity

Se você deseja ajudar com a desenvolver o Solidity,
você deve fazer um fork do Solidity e adicionar fork pessoal como um repositório remoto:

.. code-block:: bash

    git remote add personal git@github.com:[username]/solidity.git

.. note::
    Esse método vai resultar em uma compilação pré-lançamento, levando a, por exemplo, uma flag
    sendo definida em cada bytecode produzido por esse compilador.
    Se você quiser re-construir um compilador Solidity já lançada, então
    use o tarball de origem na página de lançamentos do GitHub:

    https://github.com/ethereum/solidity/releases/download/v0.X.Y/solidity_0.X.Y.tar.gz

    (não o "código fonte" fornecido pelo GitHub).

Compilação pela Linha de Comando
------------------------------

**Certifique-se de instalar as Dependências Externas (veja acima) antes de compilar.**

O projeto do Solidity usa o CMake para configurar a compilação.
Você pode querer instalar o `ccache`_ para acelerar compilações repetidas.
O CMake irá reconhecê-lo automaticamente.
Compilar o Solidity é bem similiar no Linux, macOS e outros Unix:

.. _ccache: https://ccache.dev/

.. code-block:: bash

    mkdir build
    cd build
    cmake .. && make

ou ainda mais fácil no Linux e macOS, você pode executar:

.. code-block:: bash

    #nota: isso vai instalar os binários solc e soltest em usr/local/bin
    ./scripts/build.sh

.. warning::

    As compilações para BSD devem funcionar, mas não foram testadas pela equipe do Solidity.

E para Windows:

.. code-block:: bash

    mkdir build
    cd build
    cmake -G "Visual Studio 16 2019" ..

Caso você queira usar a versão do Boost instalada pelo ``scripts\install_deps.ps1``, você também vai
precisar passar os argumentos ``-DBoost_DIR="deps\boost\lib\cmake\Boost-*"`` e ``-DCMAKE_MSVC_RUNTIME_LIBRARY=MultiThreaded``
na chamada do ``cmake``.

Isso deve resultar na criação do arquivo **solidity.sln** no diretório de compilação.
Dando um clique duplo nesse arquivo, o Visual Studio deve ser iniciado. Sugerimos compilar na
configuração de **release**, mas todas as outras também funcionam.

Como alternativa, você pode compilar para Windows na linha de comando, assim:

.. code-block:: bash

    cmake --build . --config Release

Opções do CMake
===============

Se você estiver interessado em quais opções do CMake estão disponíveis, execute o comando ``cmake .. -LH``.

.. _smt_solvers_build:

Solvers SMT
-----------
O Solidity pode ser compilado com o solver Z3 SMT e fará isso por padrão se
ele for encontrado no sistema. Z3 pode ser desabilitado através de uma opção do ``cmake``.

*Nota: Em alguns casos, isso também pode ser uma solução alternativa para falhas na compilação.*

Dentro da pasta de compilação você pode desabilitar o Z3, já que ele é habilitado por padrão:

.. code-block:: bash

    # desabilita o solver SMT Z3.
    cmake .. -DUSE_Z3=OFF

.. note::

    O Solidity pode opcionalmente usar outros solvers, como ``cvc5`` e ``Eldarica``,
    mas a presença deles é verificada apenas em tempo de execução, eles não são necessários para a conclusão da compilação.

A String de Versão em Detalhes
==============================

A string de versão do Solidity contêm quatro partes:

- o número da versão
- a tag de pré-lançamento, normalmente definido como ``develop.YYYY.MM.DD`` ou ``nightly.YYYY.MM.DD``
- o commit no formato ``commit.GITHASH``
- a plataforma, que contém um número arbitrário de itens, contendo detalhes sobre a plataforma e o compilador

Se houver modificações locais, o commit irá ser sufixado com ``.mod ``.

Essas partes são combinadas conforme exigidas pelo SemVer, onde a tag de pré-lançamento do Solidity equivale ao pré-lançamento da SemVer
e o commit e a plataforma do Solidity combinados formam os metadados da compilação do SemVer.

Exemplo da versão de lançamento: ``0.4.8+commit.60cc1668.Emscripten.clang``.

Exemplo da versão de pré-lançamento: ``0.4.9-nightly.2017.1.17+commit.6ecb4aa3.Emscripten.clang``.

Informações Importantes Sobre Versionamento
==========================================

Após o lançamento de uma versão, o nível de patch é incrementado, pois assumimos que apenas
alterações de nível de patch seguem. Quando mudanças são incorporadas, a versão deve ser incrementada de acordo
com o SemVer e a gravidade da mudança. Finalmente, um lançamento é sempre feito com a versão
da compilação nightly atual, mas sem o especificador ``prerelease``.

Exemplo:

1. A versão 0.4.0 é lançada.
2. A partir de agora, a compilição nightly tem a versão 0.4.1.
3. Mudanças que não quebram a compatibilidade são introduzidas --> não há alteração na versão.
4. Uma mudança que quebra a compatibilidade é introduzida --> a versão é incrementada para 0.5.0.
5. A versão 0.5.0 é lançada.

Esse comportamento funciona bem com a :ref:`versão pragma <version_pragma>`.
