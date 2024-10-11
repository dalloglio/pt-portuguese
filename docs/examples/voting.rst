.. index:: voting, ballot

.. _voting:

*******
Votação
*******

O seguinte contrato é bastante complexo, mas demonstra
muitos recursos do Solidity. Ele implementa um contrato de
votação. Claro, os principais problemas da votação
eletrônica são como atribuir direitos de voto às
pessoas corretas e como prevenir manipulação. Não iremos
resolver todos os problemas aqui, mas pelo menos iremos mostrar
como a votação delegada pode ser realizada de forma que a contagem de votos
seja **automática e completamente transparente** ao
mesmo tempo.

A idéia é criar um contrato por cédula,
fornecendo um nome curto para cada opção.
Em seguida, o criador do contrato que atua como
presidente, dará o direito de votar para cada
endereço individualmente.

As pessoas por trás dos endereços pode então optar por
votar elas mesmas ou delegar seu
voto a uma pessoa em quem confiam.

Ao final do período de votação, a função ``winningProposal()``
irá retornar a proposta com o maior número
de votos.

.. code-block:: solidity

    // SPDX-License-Identifier: GPL-3.0
    pragma solidity >=0.7.0 <0.9.0;
    /// @title Votação com delegação.
    contract Ballot {
        // Isso declara um novo tipo complexo que será
        // usado por variáveis posteriormente.
        // Ele representará um único eleitor.
        struct Voter {
            uint weight; // peso acumulado pela delegação
            bool voted;  // se true, essa pessoa já votou
            address delegate; // pessoa para quem foi delegada
            uint vote;   // índice da proposta votada
        }

        // Este é um tipo para uma única proposta.
        struct Proposal {
            bytes32 name;   // nome curto (até 32 bytes)
            uint voteCount; // número de votos acumulados
        }

        address public chairperson;

        // Isso declara uma variável de estado que
        // armazena uma struct `Voter` para cada endereço possível.
        mapping(address => Voter) public voters;

        // Um array com tamanho dinâmico de structs `Proposal`.
        Proposal[] public proposals;

        /// Cria uma nova votação para escolher uma das `proposalNames`.
        constructor(bytes32[] memory proposalNames) {
            chairperson = msg.sender;
            voters[chairperson].weight = 1;

            // Para cada um dos nomes de propostas fornecidos,
            // cria um novo objeto de proposta e o adiciona
            // ao final do array.
            for (uint i = 0; i < proposalNames.length; i++) {
                // `Proposal({...})` cria um objeto temporário
                // de Proposal e `proposals.push(...)`
                // adiciona ao final de `proposals`.
                proposals.push(Proposal({
                    name: proposalNames[i],
                    voteCount: 0
                }));
            }
        }

        // Dá ao `voter` o direito de votar nesta votação.
        // Só pode ser chamado pelo `chairperson`.
        function giveRightToVote(address voter) external {
            // Se o primeiro argumento de `require` for avaliado
            // como `false`, a execução é interrompida e todas as
            // mudanças no estado e nos saldos do Ether
            // são revertidas.
            // Isso costumava consumir todo o gas em versões antigas do EVM, mas
            // não é mais assim.
            // É frequentemente uma boa prática usar `require` para verificar se
            // as funções são chamadas corretamente.
            // Como segundo argumento, voc6e também pode fornecer uma
            // explicação sobre o que deu errado.
            require(
                msg.sender == chairperson,
                "Apenas o presidente pode dar direito de votar."
            );
            require(
                !voters[voter].voted,
                "O eleitor já votou."
            );
            require(voters[voter].weight == 0);
            voters[voter].weight = 1;
        }

        /// Delega seu voto para o eleitor `to`.
        function delegate(address to) external {
            // atribui a referência
            Voter storage sender = voters[msg.sender];
            require(sender.weight != 0, "Você não tem direito de votar.");
            require(!sender.voted, "Você já votou.");

            require(to != msg.sender, "Auto-delegação não é permitida.");

            // Encaminha a delegação enquanto
            // `to` também tiver delegado.
            // Em geral, tais loops são muito perigosos,
            // por que, se rodarem por muito tempo, podem
            // precisar de mais gas do que está disponível em um bloco.
            // Nesse caso, a delegação não será executada,
            // mas em outras situações, esses loops podem
            // fazer com que um contrato fique completamente "travado".
            while (voters[to].delegate != address(0)) {
                to = voters[to].delegate;

                // Encontramos um loop na delegação, não permitido.
                require(to != msg.sender, "Encontrado loop na delegação.");
            }

            Voter storage delegate_ = voters[to];

            // Eleitores não podem delegar para contas que não podem votar.
            require(delegate_.weight >= 1);

            // Desde que `sender` é uma referência, isso
            // modifica `voters[msg.sender]`.
            sender.voted = true;
            sender.delegate = to;

            if (delegate_.voted) {
                // Se o delegado já votou,
                // adiciona diretamente ao número de votos
                proposals[delegate_.vote].voteCount += sender.weight;
            } else {
                // Se o delegado não votou ainda,
                // adicionar ao peso dele.
                delegate_.weight += sender.weight;
            }
        }

        /// Dê seu voto (incluindo votos delegados a você)
        /// à proposta `proposals[proposal].name`.
        function vote(uint proposal) external {
            Voter storage sender = voters[msg.sender];
            require(sender.weight != 0, "Não tem direito de votar.");
            require(!sender.voted, "Já votou.");
            sender.voted = true;
            sender.vote = proposal;

            // Se `proposal` está fora do tamanho do array,
            // isso irá lançar erro automaticamente e reverter todas
            // as mudanças.
            proposals[proposal].voteCount += sender.weight;
        }

        /// @dev Calcula a proposta vencedora considerando todos
        /// os votos anteriores.
        function winningProposal() public view
                returns (uint winningProposal_)
        {
            uint winningVoteCount = 0;
            for (uint p = 0; p < proposals.length; p++) {
                if (proposals[p].voteCount > winningVoteCount) {
                    winningVoteCount = proposals[p].voteCount;
                    winningProposal_ = p;
                }
            }
        }

        // Chama a função winningProposal() para obter o índice
        // do vencedor contido no array de propostas e, em seguida,
        // retorna o nome do vencedor.
        function winnerName() external view
                returns (bytes32 winnerName_)
        {
            winnerName_ = proposals[winningProposal()].name;
        }
    }


Possíveis Melhorias
===================

Atualmente, muitas transações são necessárias para
atribuir os direitos de voto a todos os participantes.
Além disso, se duas ou mais propostas tiverem o mesmo
número de votos, a função ``winningProposal()`` não é capaz
de registrar um empate. Você consegue pensar em uma maeira de corrigir esses problemas?