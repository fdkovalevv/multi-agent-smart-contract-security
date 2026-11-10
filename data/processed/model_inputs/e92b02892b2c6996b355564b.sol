contract TrustBet {
    address     public owner;       
    bool        public stop      = false;        
    uint8       public winTeam   = 3;                             
    uint256     public stopWithdrawBlock = 0;        
    mapping(uint8 => mapping(address=>uint256)) public stakes;      
    uint256[3] public teamStakes;        
    
                  
    modifier owned {
        require(owner == msg.sender);
        _;
    }

               
    constructor () public {
        owner = msg.sender;
    }

                 
    function stopBet() public owned {
        stop = true;
    }

                                                  
    function lottery(uint8 team) public owned {
                           
        require(stop && team < 3);
              
        winTeam = team;
                                    
        stopWithdrawBlock = block.number + 130000;
    }

                                        
    function bet(uint8 team) public payable {
                      
        require(!stop && team < 3 && msg.value >= 0.01 ether);
                
        stakes[team][msg.sender] += msg.value;
                
        teamStakes[team] += msg.value;
    }

          
    function withdraw() public returns (uint256) {
                              
        require(stopWithdrawBlock>=block.number && stakes[winTeam][msg.sender]>0);
              
        uint256 myStake = stakes[winTeam][msg.sender];
                                        
        stakes[winTeam][msg.sender] = 0;
              
        uint256 win = myStake * (teamStakes[0] + teamStakes[1] + teamStakes[2]) / teamStakes[winTeam];
                        
        uint256 amount = win - win * 1 / 100;
                     
        assert(amount > 0);
                
        if(address(this).balance > amount){
            msg.sender.transfer(amount);
            return amount;
        }
        return 0;
    }

          
    function commission() public {
                                  
        require(winTeam < 3 && stopWithdrawBlock<block.number && address(this).balance>0);
        owner.transfer(address(this).balance);
    }
}