*************************
Canais de Micropagamentos
*************************

Nessa seção, iremos aprender como construir uma implementação de exemplo
de um canal de pagamento. Isso usa assinaturas criptográficas para fazer
transferências repetidas de Ether entre as mesmas partes de forma segura, instântanea, e
sem taxas de transação. Por example, precisamos entender como
assinar e verificar assinaturas, e configurar o canal de pagamentos.

Criando e verificando assinaturas
=================================

Imagine que Alice deseja enviar Ether para Bob, ou seja,
Alice é a remetente e Bob é o destinatário.

Alice apenas precisa enviar mensagens assinadas criptograficamente
(por exemplo, via e-mail) para Bob e isso é parecido com escrever cheques.

Alice e Bob usam assinaturas para autorizar as transações, o que é possível com contratos inteligentes no Ethereum.
Alice construirá um simples contrato inteligente que deixa ela transmitir Ether, mas ao invés de chamar a função ela mesma
para iniciar um pagamento, ela irá deixar Bob fazer isso, e dessa forma, pagar a taxa da transação.

O contrato vai funcionar da seguinte maneira:

    1. Alice implanta o contrato ``ReceiverPays``, anexando Ether o suficiente para cobrir os pagamentos que serão feitos.
    2. Alice autoriza um pagamento assinando uma mensagem com sua chave privada.
    3. Alice envia uma mensagem assinada criptograficamente para Bob. A mensagem não precisa ser mantida em segredo
       (explicado depois), e o mecanismo para enviar isso não importa.
    4. Bob reinvindica seu pagamento apresentando a mensagem assinada para o contrato inteligente, que verifica a
       autenticidade da mensagem e então libera os fundos.

Criando a assinatura
--------------------

Alice não precisa interagir com a rede Ethereum
para assinar a transação, o processo é completamente offline.
Nesse tutorial, iremos assinar mensagens no navegador
usando `web3.js <https://github.com/web3/web3.js>`_ e
`MetaMask <https://metamask.io>`_, usando o método descrito em `EIP-712 <https://github.com/ethereum/EIPs/pull/712>`_,
como isso fornece um número para outros benefícios seguros.

.. code-block:: javascript

    /// Criar o hash primeira torna as coisas mais fáceis
    var hash = web3.utils.sha3("mensagem para assinar");
    web3.eth.personal.sign(hash, web3.eth.defaultAccount, function () { console.log("Assinado"); });

.. note::
  O ``web3.eth.personal.sign`` pré-adiciona o tamanho da
  mensagem para o dado assinado. Desde que criemos o hash por primeiro, a mensagem
  será sempre exatamente do tamanho de 32 bytes, e portanto, esse tamanho
  prefixado é sempre o mesmo.

O que assinar
-------------

Para um contrato que aborda pagamentos, a mensagem assinada deve incluir:

    1. O endereço do destinatário.
    2. O valor a ser transferido.
    3. Proteção contra ataques repetidos.

Um ataque de replay é quando uma mensagem assinada é reutilizada para reinvindicar
autorização para uma segunda ação. Para evitar ataques de replay,
usamos a mesma técnica como as próprias transações do Ethereum,
um então chamado nonce, que é o número de transações enviadas pela
conta. O contrato inteligente verifica se um nonce e usada múltiplas vezes.

Outro tipo de ataque de replay pode ocorrer quando um dono
implanta um contrato inteligente ``ReceiverPays``, faz 
pagamentos, e então destrói o contrato. Mais tarde, ele decide
o contrato inteligente ``ReceiverPays`` novamente, mas o
novo contrato não conhece os nonces usados na implantação
anterior, então o atacante pode usar as mensagens antigas novamente.

Alice pode proteger contra esse ataque incluindo o
endereco do contrato na mensagem, e apenas mensagens contendo
o próprio endereço do contrato será aceito. Você pode encontrar
um exemplo disso nas primeiras duas linhas do função ``claimPayment()``
do contrato completo no final dessa seção.

Além do mais, ao invés de destruir o contrato chamado ``selfdestruct``,
que está depreciado atualmente, iremos desabilitar as funcionalidades do contrato congelando-às,
resultando na reversão de qualquer chamada após isso tiver sido congelado.

Empacotando argumentos
----------------------

Agora que nós identificamos quais informações incluir na mensagem assinada,
estamos prontos para colocar a mensagem junto, crie um hash, e assine. Para simplicidade,
concatenamos os dados. A biblioteca `ethereumjs-abi <https://github.com/ethereumjs/ethereumjs-abi>`_
fornece uma função chamada ``soliditySHA3`` que imita o comportamento da
funcão ``keccak256`` do Solidity aplicada à argumentos codificados usando ``abi.encodePacked``.
Aqui está uma função JavaScript que cria a assinatura apropriada para o exemplo de ``ReceiverPays``.

.. code-block:: javascript

    // recipient é o endereço que deve ser pago.
    // amount, em wei, especifíca quanto ether deve ser enviado.
    // nonce pode ser qualquer número único para prevenir ataques de replay
    // contractAddress é usado para prevenir ataques de replay entre contratos
    function signPayment(recipient, amount, nonce, contractAddress, callback) {
        var hash = "0x" + abi.soliditySHA3(
            ["address", "uint256", "uint256", "address"],
            [recipient, amount, nonce, contractAddress]
        ).toString("hex");

        web3.eth.personal.sign(hash, web3.eth.defaultAccount, callback);
    }

Recuperando o Signatário da Mensagem no Solidity
---------------------------------------------

De forma geral, assinaturas ECDSA consistem em dois parâmetros,
``r`` e ``s``. As assinaturas no Ethereum incluem um terceiro
parâmetro chamado ``v``, que permite verificar qual
chave privada foi usada para assinar a mensagem e ajudar a identificar
o remetente da transação. O Solidity oferece uma função
embutida chamada :ref:`ecrecover <mathematical-and-cryptographic-functions>` que
aceita uma mensagem junto com os parâmetros ``r``, ``s`` e ``v``,
retornando o endereço que assinou a mensagem.

Extraindo os Parâmetros da Assinatura
-----------------------------------

Assinaturas produzidas pelo web3.js são a concatenação de ``r``,
``s`` e ``v``, portanto, o primeiro passo é separá-los.
Isso pode ser feito no lado do cliente, mas realizar essa separação dentro
do contrato inteligente significa que você só precisa enviar um único parâmetro
de assinatura em vez de três. Dividir um array de byte em
suas partes constituintes é uma tarefa complicada, por isso utilizamos
:doc:`assembly inline <assembly>` para executar essa separação na função ``splitSignature``
(a terceira função no contrato completo no final desta seção).

Calculando o Hash da Mensagem
---------------------------

O contrato inteligente precisa saber exatamente quais parâmetros foram assinados, por isso ele
deve recriar a mensagem a partir desses parâmetros e utilizá-la para verificar a assinatura.
As funções ``prefixed`` e ``recoverSigner`` realizam essa tarefa na função ``claimPayment``.

O contrato completo
-------------------

.. code-block:: solidity
    :force:

    // SPDX-License-Identifier: GPL-3.0
    pragma solidity >=0.7.0 <0.9.0;

    contract Owned {
        address payable owner;
        constructor() {
            owner = payable(msg.sender);
        }
    }

    contract Freezable is Owned {
        bool private _frozen = false;

        modifier notFrozen() {
            require(!_frozen, "Contract Inativo.");
            _;
        }

        function freeze() internal {
            if (msg.sender == owner)
                _frozen = true;
        }
    }

    contract ReceiverPays is Freezable {
        mapping(uint256 => bool) usedNonces;

        constructor() payable {}

        function claimPayment(uint256 amount, uint256 nonce, bytes memory signature)
            external
            notFrozen
        {
            require(!usedNonces[nonce]);
            usedNonces[nonce] = true;

            // isso recria a mensagem que foi assinada no cliente
            bytes32 message = prefixed(keccak256(abi.encodePacked(msg.sender, amount, nonce, this)));
            require(recoverSigner(message, signature) == owner);
            payable(msg.sender).transfer(amount);
        }

        // congelar o contrato e recuperar os fundos do restantes.
        function shutdown()
            external
            notFrozen
        {
            require(msg.sender == owner);
            freeze();
            payable(msg.sender).transfer(address(this).balance);
        }

        /// metódos de assinatura.
        function splitSignature(bytes memory sig)
            internal
            pure
            returns (uint8 v, bytes32 r, bytes32 s)
        {
            require(sig.length == 65);

            assembly {
                // primeiros 32 bytes, depois do prefixo de comprimento.
                r := mload(add(sig, 32))
                // segundos 32 bytes.
                s := mload(add(sig, 64))
                // byte final (primeiro byte dos próximos 32 bytes).
                v := byte(0, mload(add(sig, 96)))
            }

            return (v, r, s);
        }

        function recoverSigner(bytes32 message, bytes memory sig)
            internal
            pure
            returns (address)
        {
            (uint8 v, bytes32 r, bytes32 s) = splitSignature(sig);
            return ecrecover(message, v, r, s);
        }

        /// cria um hash prefixado para imitar o comportamento de eth_sign.
        function prefixed(bytes32 hash) internal pure returns (bytes32) {
            return keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", hash));
        }
    }


Escrevendo um Canal de Pagamento Simples
========================================

Alice agora constrói uma implementação simples, mas completa, de um canal
de pagamento. Os canais de pagamento usam assinaturas criptográficas para fazer
transferências repetidas de Ether de forma segura, instantânea e sem taxas de transação.

O que é um Canal de Pagamento?
------------------------------

Os canais de pagamento permitem que os participantes façam transferências repetidas de Ether
sem usar transações. Isso significa que você pode evitar os atrasos e
taxas associados às transações. Vamos explorar um canal de pagamento
unidirecional simples entre duas partes (Alice e Bob). Envolve três etapas:

    1. Alice financia um contrato inteligente com Ether. Isso "abre" o canal de pagamento.
    2. Alice assina mensagens que especificam quanto desse Ether é devido para o destinatário. Esta etapa é repetida para cada pagamento.
    3. Bob "fecha" o canal de pagamento, retirando sua parte do Ether e enviando o restante de volta ao remetente.

.. note::
  Apenas as etapas 1 e 3 exigem transações Ethereum, a etapa 2 significa que o remetente
  transmite uma mensagem criptograficamente assinada para o destinatário via métodos
  off-chain (por exemplo, e-mail). Isso significa que apenas duas transações são necessárias para suportar
  qualquer número de transferências.

Bob tem a garantia de receber seus fundos porque o contrato inteligente deposita o
Ether e honra uma mensagem assinada válida. O contrato inteligente também impõe um
tempo limite, então Alice tem a garantia de eventualmente recuperar seus fundos mesmo se o
destinatário se recusar a fechar o canal. Cabe aos participantes de um canal de
pagamento decidir quanto tempo mantê-lo aberto. Para uma transação com curto tempo de duração,
como cibercafé por cada minuto de acesso à rede, o canal
de pagamento pode ser mantido aberto por um tempo limitado. Por outro lado, para um
pagamento recorrente, como pagar a um funcionário um salário por hora, o canal de pagamento
pode ser mantido aberto por vários meses ou anos.

Abrindo um Canal de Pagamento
-----------------------------

Para abrir um canal de pagamento, Alice implanta o contrato inteligente, anexando
o Ether a ser depositado e especificando o destinatário pretendido e uma
duração máxima para o canal existir. Essa é a função
``SimplePaymentChannel`` no contrato, no final desta seção.

Fazendo Pagamentos
------------------

Alice faz pagamentos enviando mensagens assinadas para Bob.
Esta etapa é realizada inteiramente fora da rede Ethereum.
As mensagens são assinadas criptograficamente pelo remetente e então transmitidas diretamente para o distinatário.

Cada mensagem inclui as seguintes informações:

    * O endereço do contrato inteligente, utilizado para prevenir ataques de repetição entre contratos.
    * A quantia total de Ether que é devida ao destinatário até agora.

Um canal de pagamento é fechado apenas uma vez, no final de uma série de transferências.
Por isso, apenas uma das mensagens enviadas é restagada. É por isso que
cada mensagem especifíca a quantia total cumulativa de Ether devida, em vez da
quantia do micropagamento individual. O destinatário naturalmente escolherá
resgatar a mensagem mais recente por que é aquela com o maior total.
O nonce por mensagem não é mais necessário, porque o contrato inteligente honra
apenas uma única mensagem. O endereço do contrato inteligente ainda é usado
para evitar uma mensagem destinada a um canal de pagamento seja usada para um canal diferente.

Aqui está o código JavaScript modificado para assinar criptograficamente uma mensagem da seção anterior:

.. code-block:: javascript

    function constructPaymentMessage(contractAddress, amount) {
        return abi.soliditySHA3(
            ["address", "uint256"],
            [contractAddress, amount]
        );
    }

    function signMessage(message, callback) {
        web3.eth.personal.sign(
            "0x" + message.toString("hex"),
            web3.eth.defaultAccount,
            callback
        );
    }

    // contractAddress é usado para evitar ataques de repetição entre contratos.
    // quantidade, em wei, especifica quanto Ether deve ser enviado.

    function signPayment(contractAddress, amount, callback) {
        var message = constructPaymentMessage(contractAddress, amount);
        signMessage(message, callback);
    }


Closing the Payment Channel
---------------------------

When Bob is ready to receive his funds, it is time to
close the payment channel by calling a ``close`` function on the smart contract.
Closing the channel pays the recipient the Ether they are owed and
deactivates the contract by freezing it, sending any remaining Ether back to Alice. To
close the channel, Bob needs to provide a message signed by Alice.

The smart contract must verify that the message contains a valid signature from the sender.
The process for doing this verification is the same as the process the recipient uses.
The Solidity functions ``isValidSignature`` and ``recoverSigner`` work just like their
JavaScript counterparts in the previous section, with the latter function borrowed from the ``ReceiverPays`` contract.

Only the payment channel recipient can call the ``close`` function,
who naturally passes the most recent payment message because that message
carries the highest total owed. If the sender were allowed to call this function,
they could provide a message with a lower amount and cheat the recipient out of what they are owed.

The function verifies the signed message matches the given parameters.
If everything checks out, the recipient is sent their portion of the Ether,
and the sender is sent the remaining funds via a ``transfer``.
You can see the ``close`` function in the full contract.

Channel Expiration
-------------------

Bob can close the payment channel at any time, but if they fail to do so,
Alice needs a way to recover her escrowed funds. An *expiration* time was set
at the time of contract deployment. Once that time is reached, Alice can call
``claimTimeout`` to recover her funds. You can see the ``claimTimeout`` function in the full contract.

After this function is called, Bob can no longer receive any Ether,
so it is important that Bob closes the channel before the expiration is reached.

The full contract
-----------------

.. code-block:: solidity
    :force:

    // SPDX-License-Identifier: GPL-3.0
    pragma solidity >=0.7.0 <0.9.0;

    contract Frozeable {
        bool private _frozen = false;

        modifier notFrozen() {
            require(!_frozen, "Inactive Contract.");
            _;
        }

        function freeze() internal {
            _frozen = true;
        }
    }

    contract SimplePaymentChannel is Frozeable {
        address payable public sender;    // The account sending payments.
        address payable public recipient; // The account receiving the payments.
        uint256 public expiration;        // Timeout in case the recipient never closes.

        constructor (address payable recipientAddress, uint256 duration)
            payable
        {
            sender = payable(msg.sender);
            recipient = recipientAddress;
            expiration = block.timestamp + duration;
        }

        /// the recipient can close the channel at any time by presenting a
        /// signed amount from the sender. the recipient will be sent that amount,
        /// and the remainder will go back to the sender
        function close(uint256 amount, bytes memory signature)
            external
            notFrozen
        {
            require(msg.sender == recipient);
            require(isValidSignature(amount, signature));

            recipient.transfer(amount);
            freeze();
            sender.transfer(address(this).balance);
        }

        /// the sender can extend the expiration at any time
        function extend(uint256 newExpiration)
            external
            notFrozen
        {
            require(msg.sender == sender);
            require(newExpiration > expiration);

            expiration = newExpiration;
        }

        /// if the timeout is reached without the recipient closing the channel,
        /// then the Ether is released back to the sender.
        function claimTimeout()
            external
            notFrozen
        {
            require(block.timestamp >= expiration);
            freeze();
            sender.transfer(address(this).balance);
        }

        function isValidSignature(uint256 amount, bytes memory signature)
            internal
            view
            returns (bool)
        {
            bytes32 message = prefixed(keccak256(abi.encodePacked(this, amount)));
            // check that the signature is from the payment sender
            return recoverSigner(message, signature) == sender;
        }

        /// All functions below this are just taken from the chapter
        /// 'creating and verifying signatures' chapter.
        function splitSignature(bytes memory sig)
            internal
            pure
            returns (uint8 v, bytes32 r, bytes32 s)
        {
            require(sig.length == 65);

            assembly {
                // first 32 bytes, after the length prefix
                r := mload(add(sig, 32))
                // second 32 bytes
                s := mload(add(sig, 64))
                // final byte (first byte of the next 32 bytes)
                v := byte(0, mload(add(sig, 96)))
            }
            return (v, r, s);
        }

        function recoverSigner(bytes32 message, bytes memory sig)
            internal
            pure
            returns (address)
        {
            (uint8 v, bytes32 r, bytes32 s) = splitSignature(sig);
            return ecrecover(message, v, r, s);
        }

        /// builds a prefixed hash to mimic the behavior of eth_sign.
        function prefixed(bytes32 hash) internal pure returns (bytes32) {
            return keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", hash));
        }
    }


.. note::
  The function ``splitSignature`` does not use all security
  checks. A real implementation should use a more rigorously tested library,
  such as openzeppelin's `version  <https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/utils/cryptography/ECDSA.sol>`_ of this code.

Verifying Payments
------------------

Unlike in the previous section, messages in a payment channel aren't
redeemed right away. The recipient keeps track of the latest message and
redeems it when it's time to close the payment channel. This means it's
critical that the recipient perform their own verification of each message.
Otherwise there is no guarantee that the recipient will be able to get paid
in the end.

The recipient should verify each message using the following process:

    1. Verify that the contract address in the message matches the payment channel.
    2. Verify that the new total is the expected amount.
    3. Verify that the new total does not exceed the amount of Ether escrowed.
    4. Verify that the signature is valid and comes from the payment channel sender.

We'll use the `ethereumjs-util <https://github.com/ethereumjs/ethereumjs-util>`_
library to write this verification. The final step can be done a number of ways,
and we use JavaScript. The following code borrows the ``constructPaymentMessage`` function from the signing **JavaScript code** above:

.. code-block:: javascript

    // this mimics the prefixing behavior of the eth_sign JSON-RPC method.
    function prefixed(hash) {
        return ethereumjs.ABI.soliditySHA3(
            ["string", "bytes32"],
            ["\x19Ethereum Signed Message:\n32", hash]
        );
    }

    function recoverSigner(message, signature) {
        var split = ethereumjs.Util.fromRpcSig(signature);
        var publicKey = ethereumjs.Util.ecrecover(message, split.v, split.r, split.s);
        var signer = ethereumjs.Util.pubToAddress(publicKey).toString("hex");
        return signer;
    }

    function isValidSignature(contractAddress, amount, signature, expectedSigner) {
        var message = prefixed(constructPaymentMessage(contractAddress, amount));
        var signer = recoverSigner(message, signature);
        return signer.toLowerCase() ==
            ethereumjs.Util.stripHexPrefix(expectedSigner).toLowerCase();
    }
