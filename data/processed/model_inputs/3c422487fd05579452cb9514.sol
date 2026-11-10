contract OddEven {
    enum Stage {
        FirstCommit,
        SecondCommit,
        FirstReveal,
        SecondReveal,
        Distribution
    }

    struct Player {
        address addr;
        bytes32 commitment;
        uint number;
    }

    Player[2] private players;
    Stage public stage = Stage.FirstCommit;

    function play(bytes32 commitment) public payable {
                                        
        uint playerIndex;
        if(stage == Stage.FirstCommit) playerIndex = 0;
        else if(stage == Stage.SecondCommit) playerIndex = 1;
        else revert("only two players allowed");

                                          
                                           
        require(msg.value == 2 ether, 'msg.value must be 2 eth');

                               
        players[playerIndex] = Player(msg.sender, commitment, 0);

                             
        if(stage == Stage.FirstCommit) stage = Stage.SecondCommit;
        else stage = Stage.FirstReveal;
    }

    function reveal(uint number, bytes32 blindingFactor) public {
                                        
        require(stage == Stage.FirstReveal || stage == Stage.SecondReveal, "wrong stage");

                                
        uint playerIndex;
        if(players[0].addr == msg.sender) playerIndex = 0;
        else if(players[1].addr == msg.sender) playerIndex = 1;
        else revert("unknown player");

                                                       
        require(keccak256(abi.encodePacked(msg.sender, number, blindingFactor)) == players[playerIndex].commitment, "invalid hash");

                                          
        players[playerIndex].number = number;

                             
        if(stage == Stage.FirstReveal) stage = Stage.SecondReveal;
        else stage = Stage.Distribution;
    }

    function distribute() public {
                                             
        require(stage == Stage.Distribution, "wrong stage");

                      
        uint n = players[0].number + players[1].number;

                                           
        players[n%2].addr.call.value(3 ether)("");

                              
        players[(n+1)%2].addr.call.value(1 ether)("");

                          
        delete players;
        stage = Stage.FirstCommit;
    }
}