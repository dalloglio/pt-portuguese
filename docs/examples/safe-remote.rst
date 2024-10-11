.. index:: purchase, remote purchase, escrow

********************
Compra Remota Segura
********************

A compra de bens remotamente atualmente requer múltiplas partes que precisam confiar umas nas outras.
A configuração mais simples envolve um vendedor e um comprador. O comprador deseja receber
um item do vendedor e o vendedor deseja receber alguma compensação, por exemplo, Ether,
em troca. A parte problemática é o envio: não há uma mameira de determinar com
certeza que o item chegou ao comprador.

Existem várias maneiras de resolver esse problema, mas todas apresentam alguma limitação.
No exemplo a seguir, ambas as partes precisam depositar no contrato o dobro do valor do item
como garantia. Assim que isso ocorre, o Ether permanece bloqueado no
contrato até que o comprador confirme que recebeu o item. Depoi disso,
o comprador recebe de volta o valor (metado do depósito) e o vendedor recebe três
vezes o valor (seu depósito mais o valor do item). A ideia por trás
disso é que ambas as partes têm um incentivo para resolver a situação, caso contrário,
seus Ethers serão bloqueados para sempre.

Esse contrato, é claro, não resolve totalmente o problema, mas fornece uma visão geral de como
você pode usar construções semelhantes a uma máquina de estados dentro de um contrato.


.. code-block:: solidity

    // SPDX-License-Identifier: GPL-3.0
    pragma solidity ^0.8.4;
    contract Purchase {
        uint public value;
        address payable public seller;
        address payable public buyer;

        enum State { Created, Locked, Release, Inactive }
        // A variável de estado tem um valor padrão do primeiro membro, `State.created`
        State public state;

        modifier condition(bool condition_) {
            require(condition_);
            _;
        }

        /// Apenas o comprador pode chamar esta função.
        error OnlyBuyer();
        /// Apenas o vendedor pode chamar esta função.
        error OnlySeller();
        /// A função não pode ser chamada no estado atual.
        error InvalidState();
        /// O valor fornecido deve ser par.
        error ValueNotEven();

        modifier onlyBuyer() {
            if (msg.sender != buyer)
                revert OnlyBuyer();
            _;
        }

        modifier onlySeller() {
            if (msg.sender != seller)
                revert OnlySeller();
            _;
        }

        modifier inState(State state_) {
            if (state != state_)
                revert InvalidState();
            _;
        }

        event Aborted();
        event PurchaseConfirmed();
        event ItemReceived();
        event SellerRefunded();

        // Garanta que `msg.value` seja um número par.
        // A divisão irá truncar se for um número impar.
        // Verifica através da multiplicação que não era um número impar.
        constructor() payable {
            seller = payable(msg.sender);
            value = msg.value / 2;
            if ((2 * value) != msg.value)
                revert ValueNotEven();
        }

        /// Aborta a compra e recupera o ether.
        /// Só pode ser chamado pelo vendedor antes
        /// do contrato ser bloqueado.
        function abort()
            external
            onlySeller
            inState(State.Created)
        {
            emit Aborted();
            state = State.Inactive;
            // Usamos `transfer` aqui diretamente. É
            // seguro contra reentrância, porque é a
            // última chamada nesta função e
            // já alteramos o estado.
            seller.transfer(address(this).balance);
        }

        /// Confirma a compra como comprador.
        /// A transação deve incluir `2 * value` ether.
        /// O ether ficará bloquado até que a função `confirmReceived`
        /// seja chamada.
        function confirmPurchase()
            external
            inState(State.Created)
            condition(msg.value == (2 * value))
            payable
        {
            emit PurchaseConfirmed();
            buyer = payable(msg.sender);
            state = State.Locked;
        }

        /// Confirme que você (o comprador) recebeu o item.
        /// Isso liberará o ether bloqueado.
        function confirmReceived()
            external
            onlyBuyer
            inState(State.Locked)
        {
            emit ItemReceived();
            // É importante mudar o estado primeiro, porque
            // caso contrário, os contratos chamados usando `send` abaixo
            // podem chamar novamente aqui.
            state = State.Release;

            buyer.transfer(value);
        }

        /// Essa função reembolsa o vendedor, ou seja,
        /// devolve os fundos bloqueados do vendedor.
        function refundSeller()
            external
            onlySeller
            inState(State.Release)
        {
            emit SellerRefunded();
            // É importante mudar o estado primeiro, porque
            // caso contrário, os contratos chamados usando `send` abaixo
            // podem chamar novamente aqui.
            state = State.Inactive;

            seller.transfer(3 * value);
        }
    }
