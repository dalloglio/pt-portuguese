Solidity
========

Solidity é uma linguagem de alto nível, orientada à objetos para implementação de contratos inteligentes.
Contratos inteligentes são programas que controlam o comportamento de contas dentro da rede Ethereum.

Solidity é uma `linguagem de chaves <https://en.wikipedia.org/wiki/List_of_programming_languages_by_type#Curly-bracket_languages>`_ projetada para ser executada na Máquina Virtual Ethereum (EVM).
Ela é influenciada por C++, Python, e JavaScript.
Você pode encontrar mais detalhes sobre as linguagens que inspiraram o Solidity na seção de :doc:`influências da linguagem <language-influences>`.

Solidity é uma linguagem de tipagem estática, que suporta herança, bibliotecas e tipos complexos definidos pelo usuário, entre outras funcionalidades.

Com Solidity, você pode criar contratos para usos como votação, crowdfunding, leilões secretos e carteiras multi-assinatura.

Ao implantar contratos, você deve usar a versão mais recente do Solidity.
Além de casos excepcionais, somente a versão mais recente recebe
`correções de segurança <https://github.com/ethereum/solidity/security/policy#supported-versions>`_.
Além disso, mudanças incompatíveis e novos recursos são introduzidas regularmente.
Atualmente, usamos um número de versão 0.y.z `para indicar esse ritmo rápido de mudanças <https://semver.org/#spec-item-4>`_.

.. warning::

  Solidity lançou recentemente a versão 0.8.x, que introduziu muitas mudanças incompatíveis.
  Certifique-se de ler :doc:`a lista completa <080-breaking-changes>`.

Idéias para melhorar o Solidity ou está documentação são sempre bem-vindas.
Leia nosso :doc:`guia de contribuição <contributing>` para mais detalhes.

.. Hint::

  Você pode baixar esta documentação em PDF, HTML ou Epub
  clicando no menu suspenso de versões no canto inferior esquerdo e selecionando o formato de download preferido.


Começando
---------------

**1. Compreender os conceitos Básicos de Contratos Inteligentes**

Se você é novo no conceito de contratos inteligentes, recomendamos começar explorando a seção "Introdução aos Contratos Inteligentes", que abrange os seguintes tópicos:

* :ref:`Um exemplo simples de contrato inteligente <simple-smart-contract>` escrito em Solidity.
* :ref:`Conceitos Básicos de Blockchain <blockchain-basics>`.
* :ref:`A Maquina Virtual Ethereum <the-ethereum-virtual-machine>`.

**2. Conheça o Solidity**

Uma vez que você esteja familiarizado com os conceitos básicos, recomendamos que leia as seções :doc:`"Solidity por Exemplo" <solidity-by-example>`
e "Descrição da Linguagem" para compreender os conceitos fundamentais da linguagem.

**3. Instale o Compilador Solidity**

Há várias maneiras de instalar o compilador do Solidity,
basta escolher a opção que você prefere e seguir os passos descritos na :ref:`página de instalação <installing-solidity>`.

.. hint::
  Você pode testar exemplos de código diretamente no seu navegador com o
  `IDE Remix <https://remix.ethereum.org>`_.
  Remix é um IDE baseado em navegador que permite escrever, implantar e administrar contratos inteligentes Solidity,
  sem a necessidade de instalar o Solidity localmente.

.. warning::
    Como os humanos escrevem software, ele pode conter erros.
    Portanto, você deve seguir as melhores práticas de desenvolvimento de software ao escrever seus contratos inteligentes.
    Isto inclui revisão de código, testes, auditorias e provas de correção.
    Usuários de contratos inteligentes às vezes tem mais confiança no código do que seus autores,
    e blockchains e contratos inteligentes tem seus próprios problemas únicos para se atentar,
    portanto, antes de trabalhar o código em produção, certifique-se de ler a seção de :ref:`security_considerations`.

**4. Aprenda mais**

Se você quer aprender mais sobre construir aplicações descentralizadas na Ethereum,
os `Recursos para Desenvolvedores Ethereum <https://ethereum.org/en/developers/>`_ podem ajudar com mais documentação geral sobre Ethereum,
além de uma ampla seleção de tutoriais, ferramentas e frameworks de desenvolvimento.

Se você tiver alguma dúvida, pode tentar buscar respostas ou perguntar no
`Ethereum StackExchange <https://ethereum.stackexchange.com/>`_,
ou no nosso `canal do Gitter <https://gitter.im/ethereum/solidity>`_.

.. _translations:

Traduções
------------

Contribuidores da comunidade ajudam a traduzir esta documentação para vários idiomas.
Observe que essas traduções podem ter diferentes graus de completude e atualização.
A versão em Inglês serve como referência.

Você pode alternar entre os idiomas clicando no menu suspenso no canto inferior esquerdo
e selecionando o idioma desejado.

* `Chinês <https://docs.soliditylang.org/zh/latest/>`_
* `Francês <https://docs.soliditylang.org/fr/latest/>`_
* `Indonésio <https://github.com/solidity-docs/id-indonesian>`_
* `Japonês <https://github.com/solidity-docs/ja-japanese>`_
* `Coreano <https://github.com/solidity-docs/ko-korean>`_
* `Persa <https://github.com/solidity-docs/fa-persian>`_
* `Russo <https://github.com/solidity-docs/ru-russian>`_
* `Espanhol <https://github.com/solidity-docs/es-spanish>`_
* `Turco <https://docs.soliditylang.org/tr/latest/>`_

.. note::

   Criamos uma organização no GitHub e fluxo de trabalho de tradução para ajudar a agilizar os esforços da comunidade.
   Por favor, consulte o guia de tradução na `organização solidity-docs <https://github.com/solidity-docs>`_
   para obter informações sobre como inicar um novo idioma ou contribuir para as traduções da comunidade.

Conteúdos
========

:ref:`Indice de Palavras-chave <genindex>`, :ref:`Página de Pesquisa <search>`

.. toctree::
   :maxdepth: 2
   :caption: Básicos

   introduction-to-smart-contracts.rst
   solidity-by-example.rst
   installing-solidity.rst

.. toctree::
   :maxdepth: 2
   :caption: Descrição da Linguagem

   layout-of-source-files.rst
   structure-of-a-contract.rst
   types.rst
   units-and-global-variables.rst
   control-structures.rst
   contracts.rst
   assembly.rst
   cheatsheet.rst
   grammar.rst

.. toctree::
   :maxdepth: 2
   :caption: Compilador

   using-the-compiler.rst
   analysing-compilation-output.rst
   ir-breaking-changes.rst

.. toctree::
   :maxdepth: 2
   :caption: Internals

   internals/layout_in_storage.rst
   internals/layout_in_memory.rst
   internals/layout_in_calldata.rst
   internals/variable_cleanup.rst
   internals/source_mappings.rst
   internals/optimizer.rst
   metadata.rst
   abi-spec.rst

.. toctree::
   :maxdepth: 2
   :caption: Conteúdo de Aviso

   security-considerations.rst
   bugs.rst
   050-breaking-changes.rst
   060-breaking-changes.rst
   070-breaking-changes.rst
   080-breaking-changes.rst

.. toctree::
   :maxdepth: 2
   :caption: Material Adicional

   natspec-format.rst
   smtchecker.rst
   yul.rst
   path-resolution.rst

.. toctree::
   :maxdepth: 2
   :caption: Recursos

   style-guide.rst
   common-patterns.rst
   resources.rst
   contributing.rst
   language-influences.rst
   brand-guide.rst
