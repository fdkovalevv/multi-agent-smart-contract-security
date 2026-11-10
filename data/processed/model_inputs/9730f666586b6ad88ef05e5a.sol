interface Game {
    event GameStarted(uint betAmount);
    event NewPlayerAdded(uint numPlayers, uint prizeAmount);
    event GameFinished(address winner);

    function () public payable;                                                                               
    function getPrizeAmount() public constant returns (uint);                                           
    function getNumWinners() public constant returns(uint, uint);
    function getPlayers() public constant returns(address[]);                                     
    function getWinners() public view returns(address[] memory players,
                                                uint[] memory prizes);                                              
    function getStat() public constant returns(uint, uint, uint);                           

    function calcaultePrizes() public returns (uint[]);

    function finish() public;                                                    

    function revoke() public;                                                               
                                                                                        
}

contract BaseUnilotGame is Game {
    enum State {
        ACTIVE,
        ENDED,
        REVOKING,
        REVOKED,
        MOVED
    }

    event PrizeResultCalculated(uint size, uint[] prizes);

    State state;
    address administrator;
    uint bet;

    mapping (address => TicketLib.Ticket) internal tickets;
    address[] internal ticketIndex;

    UnilotPrizeCalculator calculator;

               
    modifier onlyAdministrator() {
        require(msg.sender == administrator);
        _;
    }

    modifier onlyPlayer() {
        require(msg.sender != administrator);
        _;
    }

    modifier validBet() {
        require(msg.value == bet);
        _;
    }

    modifier activeGame() {
        require(state == State.ACTIVE);
        _;
    }

    modifier inactiveGame() {
        require(state != State.ACTIVE);
        _;
    }

    modifier finishedGame() {
        require(state == State.ENDED);
        _;
    }

                     

    function getState()
        public
        view
        returns(State)
    {
        return state;
    }

    function getBet()
        public
        view
        returns (uint)
    {
        return bet;
    }

    function getPlayers()
        public
        constant
        returns(address[])
    {
        return ticketIndex;
    }

    function getPlayerDetails(address player)
        public
        view
        inactiveGame
        returns (uint, uint, uint)
    {
        TicketLib.Ticket memory ticket = tickets[player];

        return (ticket.block_number, ticket.block_time, ticket.prize);
    }

    function getNumWinners()
        public
        constant
        returns (uint, uint)
    {
        var(numWinners, numFixedAmountWinners) = calculator.getNumWinners(ticketIndex.length);

        return (numWinners, numFixedAmountWinners);
    }

    function getPrizeAmount()
        public
        constant
        returns (uint result)
    {
        uint totalAmount = this.balance;

        if ( state == State.ENDED ) {
            totalAmount = bet * ticketIndex.length;
        }

        result = calculator.getPrizeAmount(totalAmount);

        return result;
    }

    function getStat()
        public
        constant
        returns ( uint, uint, uint )
    {
        var (numWinners, numFixedAmountWinners) = getNumWinners();
        return (ticketIndex.length, getPrizeAmount(), uint(numWinners + numFixedAmountWinners));
    }

    function calcaultePrizes()
        public
        returns(uint[] memory result)
    {
        var(numWinners, numFixedAmountWinners) = getNumWinners();
        uint16 totalNumWinners = uint16( numWinners + numFixedAmountWinners );
        result = new uint[]( totalNumWinners );


        uint[50] memory prizes = calculator.calcaultePrizes(
        bet, ticketIndex.length);

        for (uint16 i = 0; i < totalNumWinners; i++) {
            result[i] = prizes[i];
        }

        return result;
    }

    function revoke()
        public
        onlyAdministrator
        activeGame
    {
        for (uint24 i = 0; i < ticketIndex.length; i++) {
            ticketIndex[i].transfer(bet);
        }

        state = State.REVOKED;
    }
}

contract UnilotTailEther is BaseUnilotGame {

    uint64 winnerIndex;

                    
    function UnilotTailEther(uint betAmount, address calculatorContractAddress)
        public
    {
        state = State.ACTIVE;
        administrator = msg.sender;
        bet = betAmount;

        calculator = UnilotPrizeCalculator(calculatorContractAddress);

        GameStarted(betAmount);
    }

    function getWinners()
        public
        view
        finishedGame
        returns(address[] memory players, uint[] memory prizes)
    {
        var(numWinners, numFixedAmountWinners) = getNumWinners();
        uint totalNumWinners = numWinners + numFixedAmountWinners;

        players = new address[](totalNumWinners);
        prizes = new uint[](totalNumWinners);

        uint index;

        for (uint i = 0; i < totalNumWinners; i++) {
            if ( i > winnerIndex ) {
                index = ( ( players.length ) - ( i - winnerIndex ) );
            } else {
                index = ( winnerIndex - i );
            }

            players[i] = ticketIndex[index];
            prizes[i] = tickets[players[i]].prize;
        }

        return (players, prizes);
    }

    function ()
        public
        payable
        validBet
        onlyPlayer
    {
        require(tickets[msg.sender].block_number == 0);
        require(ticketIndex.length <= 1000);

        tickets[msg.sender].block_number = uint40(block.number);
        tickets[msg.sender].block_time   = uint32(block.timestamp);

        ticketIndex.push(msg.sender);

        NewPlayerAdded(ticketIndex.length, getPrizeAmount());
    }

    function finish()
        public
        onlyAdministrator
        activeGame
    {
        uint64 max_votes;
        uint64[] memory num_votes = new uint64[](ticketIndex.length);

        for (uint i = 0; i < ticketIndex.length; i++) {
            TicketLib.Ticket memory ticket = tickets[ticketIndex[i]];
            uint64 vote = uint64( ( ( ticket.block_number * ticket.block_time ) + uint( ticketIndex[i]) ) % ticketIndex.length );

            num_votes[vote] += 1;

            if ( num_votes[vote] > max_votes ) {
                max_votes = num_votes[vote];
                winnerIndex = vote;
            }
        }

        uint[] memory prizes = calcaultePrizes();

        uint lastId = winnerIndex;

        for ( i = 0; i < prizes.length; i++ ) {
            tickets[ticketIndex[lastId]].prize = prizes[i];
            ticketIndex[lastId].transfer(prizes[i]);

            if ( lastId <= 0 ) {
                lastId = ticketIndex.length;
            }

            lastId -= 1;
        }

        administrator.transfer(this.balance);

        state = State.ENDED;

        GameFinished(ticketIndex[winnerIndex]);
    }
}