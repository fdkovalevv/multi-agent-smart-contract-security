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