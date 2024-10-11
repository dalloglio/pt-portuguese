.. index:: auction;blind, auction;open, blind auction, open auction

***************
Leilão às Cegas
***************

Nesta seção, mostraremos como é fácil criar um contrato de leilão
completamente às cegas no Ethereum. Começaremos com um leilão aberto, onde
todos podem ver os lances feitos, e então estenderemos esse contrato para um
leilão às cegas, onde não é possível ver o lance real até que o período de
lances termine.

.. _simple_auction:

Leilão Aberto Simpres
========================

A ideia geral do seguinte contrato de leilão simples é que todos podem
enviar seus lances durante um período de lances. Os lances já incluem o envio de uma compensação,
por exemplo, Ether, para garantir o comprometimento dos licitantes com seus lances. Se um lance mais alto for
feito, o licitante anterior com o maior lance recebe seu Ether de volta. Após o término do
período de lances, o contrato deve ser chamado manualmente para que o beneficiário
receba seu Ether - contratos não podem se ativar sozinhos.

.. code-block:: solidity

    // SPDX-License-Identifier: GPL-3.0
    pragma solidity ^0.8.4;
    contract SimpleAuction {
        // Parâmetros do leilão. Os tempos são definidos como
        // timestamps absolutos em unix (segundos desde 01/01/1970)
        // ou períodos de tempo em segundos.
        address payable public beneficiary;
        uint public auctionEndTime;

        // Estado atual do leilão.
        address public highestBidder;
        uint public highestBid;

        // Saques permitidos de lances anteriores
        mapping(address => uint) pendingReturns;

        // Definido como `true` no final, não permite nenhuma alteração.
        // Por padrão, é inicializado como `false`.
        bool ended;

        // Eventos que serão emitidos em caso de alterações.
        event HighestBidIncreased(address bidder, uint amount);
        event AuctionEnded(address winner, uint amount);

        // Erros que descrevem falhas.

        // Os comentários com três barras são conhecidos como comentários natspec
        // Eles serão exibidos quando o usuário
        // for solicitado a confirmar uma transação ou
        // quando um erro for exibido.

        /// O leilão já terminou.
        error AuctionAlreadyEnded();
        /// Já existe um lance maior ou igual.
        error BidNotHighEnough(uint highestBid);
        /// O leilão ainda não terminou.
        error AuctionNotYetEnded();
        /// A função `auctionEnd` já foi chamada.
        error AuctionEndAlreadyCalled();

        /// Cria um leilão simples com `biddingTime`
        /// segundos de tempo de lance em nome do
        /// endereço do beneficiário `beneficiaryAddress`.
        constructor(
            uint biddingTime,
            address payable beneficiaryAddress
        ) {
            beneficiary = beneficiaryAddress;
            auctionEndTime = block.timestamp + biddingTime;
        }

        /// Faça uma oferta no leilão com o valor enviado
        /// junto com esta transação.
        /// O valor será reembolsado apenas se o
        /// leilão não for ganho.
        function bid() external payable {
            // Nenhum argumento é necessário, todas
            // as informações já fazem parte da
            // transação. A palavra-chave payable
            // é necessária para que a função
            // possa receber Ether.

            // Reverte a chamada se o período de
            // lances já tiver terminado.
            if (block.timestamp > auctionEndTime)
                revert AuctionAlreadyEnded();

            // Se o lance não for maior, envie o
            // Ether de volta (a instrução revert
            // reverterá todas as alterações na
            // execução desta função incluindo
            // o recebimento do Ether).
            if (msg.value <= highestBid)
                revert BidNotHighEnough(highestBid);

            if (highestBid != 0) {
                // Enviar o Ether de volta simplesmente usando
                // highestBidder.send(highestBid) é um risco de segurança,
                // porque pode executar um contrato não confiável.
                // É sempre mais seguro deixar que os destinatários
                // retirem seu Ether por conta própria.
                pendingReturns[highestBidder] += highestBid;
            }
            highestBidder = msg.sender;
            highestBid = msg.value;
            emit HighestBidIncreased(msg.sender, msg.value);
        }

        /// Retire um lance que foi superado.
        function withdraw() external returns (bool) {
            uint amount = pendingReturns[msg.sender];
            if (amount > 0) {
                // É importante definir isso para zero porque o destinatário
                // pode chamar essa função novamente como parte da chamada de recebimento
                // antes que o `send` retorne.
                pendingReturns[msg.sender] = 0;

                // msg.sender não é do tipo `address payable` e deve ser
                // explicitamente convertidi usando `payable(msg.sender)` para poder
                // usar a função membro `send()`.
                if (!payable(msg.sender).send(amount)) {
                    // Não há necessidade de chamar throw aqui, basta redefinir o valor devido
                    pendingReturns[msg.sender] = amount;
                    return false;
                }
            }
            return true;
        }

        /// Finaliza o leilão e envia o maior lance
        /// para o beneficiário.
        function auctionEnd() external {
            // É uma boa diretriz estruturar funções que interagem
            // com outros contratos (ou seja, que chamam funções ou enviam Ether)
            // em três fases:
            // 1. verificação de condições
            // 2. execução de ações (potencialmente alternando condições)
            // 3. interação com outros contratos
            // Se essas fases misturadas, o outro contrato pode chamar
            // de volta o contrato atual e modificar o estado ou causar
            // efeitos (pagamento em Ether) a serem executados várias vezes.
            // Se funções chamadas internamente incluírem interação com contratos
            // externos, elas também devem ser consideradas interação com
            // contratos externos.

            // 1. Condições
            if (block.timestamp < auctionEndTime)
                revert AuctionNotYetEnded();
            if (ended)
                revert AuctionEndAlreadyCalled();

            // 2. Efeitos
            ended = true;
            emit AuctionEnded(highestBidder, highestBid);

            // 3. Interação
            beneficiary.transfer(highestBid);
        }
    }

Leilão às Cegas
===============

O leilão aberto anterior é estendido para um leilão às cegas a seguir. A
vantagem de um leilão às cegas é que não há pressão de tempo no final do fim
do período de lances. Criar um leilão às cegas em uma plataforma de computação
transparente pode parecer uma contradição, mas a criptografia vem para ajudar a resolver 
esse problema.

Durante o **período de lances**, um participante não envia seu lance diretamente, mas
apenas uma versão hasheada (codificada) dele. Como é considerado praticamente
impossível encontrar dois valores (suficientemente longos) que gerem o msmo valor de hash,
o participante se compromete ao lance dessa forma. Após o fim do período de lances, os participantes precisam revelar seus lances: Eles enviam seus valores de forma não criptografada, e
o contrato verifica se o valor do hash é o mesmo fornecido durante
o período de lances.

Outro desafio é como tornar o leilão **vinculado e cego** ao mesmo
tempo: A única maneira de prevenir que o participante simplesmente não envie o Ether após
ganhar o leilão é para fazer com que ele envie junto com o lance. Como as transferências
de valor não podem ser ocultadas no Ethereum, qualquer pessoa pode ver o valor enviado.

O contrato a seguir resolve esse problema aceitando qualquer valor que seja
maior que o lance mais alto. Como isso só pode ser verificado durante
a fase de revelação, alguns lances podem ser **inválidos**, e isso é intencional (o contrato
até fornece um sinalizador explícito para realizar lances inválidos com transferências 
de valor elevado): participantees poder confundir a concorrência fazendo vários lances autos ou baixos inválidos.

.. code-block:: solidity
    :force:

    // SPDX-License-Identifier: GPL-3.0
    pragma solidity ^0.8.4;
    contract BlindAuction {
        struct Bid {
            bytes32 blindedBid;
            uint deposit;
        }

        address payable public beneficiary;
        uint public biddingEnd;
        uint public revealEnd;
        bool public ended;

        mapping(address => Bid[]) public bids;

        address public highestBidder;
        uint public highestBid;

        // Retiradas permitidas de lances anteriores
        mapping(address => uint) pendingReturns;

        event AuctionEnded(address winner, uint highestBid);

        // Erros que descrevem falhas.

        /// A função foi chamada muito cedo.
        /// Tente novamente em `time`.
        error TooEarly(uint time);
        /// A função foi chamada muito tarde.
        /// Não pode ser chamado após `time`.
        error TooLate(uint time);
        /// A função auctionEnd já foi chamada.
        error AuctionEndAlreadyCalled();

        // Modificadores são uma forma conveniente de validar entradas para
        // funções. `onlyBefore` é aplicado a `bid` abaixo:
        // O novo corpo da função é o corpo do modificador onde
        // `_` é substituído pelo corpo antigo da função.
        modifier onlyBefore(uint time) {
            if (block.timestamp >= time) revert TooLate(time);
            _;
        }
        modifier onlyAfter(uint time) {
            if (block.timestamp <= time) revert TooEarly(time);
            _;
        }

        constructor(
            uint biddingTime,
            uint revealTime,
            address payable beneficiaryAddress
        ) {
            beneficiary = beneficiaryAddress;
            biddingEnd = block.timestamp + biddingTime;
            revealEnd = biddingEnd + revealTime;
        }

        /// Faça um lance oculto com `blindedBid` =
        /// keccak256(abi.encodePacked(value, fake, secret)).
        /// O ether enviado só é reembolsado se o lance for corretamente
        /// revelado na fase de revelação. O lance é valído se o
        /// ether enviado junto com o lance é pelo menos "value" e
        /// "fake" não for verdadeiro. Definir "fake" como verdadeiro e enviar
        /// um valor diferente são maneiras de ocultar o lance real, mas
        /// ainda assim fazer o depósito necessário. O mesmo endereço pode
        /// colocar multiplos lances.
        function bid(bytes32 blindedBid)
            external
            payable
            onlyBefore(biddingEnd)
        {
            bids[msg.sender].push(Bid({
                blindedBid: blindedBid,
                deposit: msg.value
            }));
        }

        /// Revele seus lances ocultos. Você irá obter um reembolso para todos
        /// os lances inválidos corretamente ocultos e para todos os lances, exceto pelo
        /// maior de todos.
        function reveal(
            uint[] calldata values,
            bool[] calldata fakes,
            bytes32[] calldata secrets
        )
            external
            onlyAfter(biddingEnd)
            onlyBefore(revealEnd)
        {
            uint length = bids[msg.sender].length;
            require(values.length == length);
            require(fakes.length == length);
            require(secrets.length == length);

            uint refund;
            for (uint i = 0; i < length; i++) {
                Bid storage bidToCheck = bids[msg.sender][i];
                (uint value, bool fake, bytes32 secret) =
                        (values[i], fakes[i], secrets[i]);
                if (bidToCheck.blindedBid != keccak256(abi.encodePacked(value, fake, secret))) {
                    // O lance não foi realmente revelado
                    // Não reembolsar o depósito.
                    continue;
                }
                refund += bidToCheck.deposit;
                if (!fake && bidToCheck.deposit >= value) {
                    if (placeBid(msg.sender, value))
                        refund -= value;
                }
                // Tornar impossível para o remetente reivindicar
                // o mesmo depósito novamente.
                bidToCheck.blindedBid = bytes32(0);
            }
            payable(msg.sender).transfer(refund);
        }

        /// Retirar um lance que foi superado.
        function withdraw() external {
            uint amount = pendingReturns[msg.sender];
            if (amount > 0) {
                // É importante definir isso como zero por que o destinatário
                // pode chamar essa função novamente como parte da chamada de recebimento
                // antes que `transfer` retorne (veja a remark acima sobre
                // condições -> efeitos -> interação).
                pendingReturns[msg.sender] = 0;

                payable(msg.sender).transfer(amount);
            }
        }

        /// Encerra o leilão e envia o maior lance
        /// ao beneficiário.
        function auctionEnd()
            external
            onlyAfter(revealEnd)
        {
            if (ended) revert AuctionEndAlreadyCalled();
            emit AuctionEnded(highestBidder, highestBid);
            ended = true;
            beneficiary.transfer(highestBid);
        }

        // Essa é uma função "interna" o que significa que só
        // pode ser chamada a partir do próprio contrato (ou a partir de
        // contratos derivados).
        function placeBid(address bidder, uint value) internal
                returns (bool success)
        {
            if (value <= highestBid) {
                return false;
            }
            if (highestBidder != address(0)) {
                // Refund the previously highest bidder.
                pendingReturns[highestBidder] += highestBid;
            }
            highestBid = value;
            highestBidder = bidder;
            return true;
        }
    }
