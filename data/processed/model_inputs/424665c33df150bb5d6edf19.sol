contract Ownable {
  address public owner;


     
                                                                                         
             
     
  function Ownable() public {
    owner = msg.sender;
  }


     
                                                               
     
  modifier onlyOwner() {
    require(msg.sender == owner);
    _;
  }


     
                                                                                     
                                                          
     
  function transferOwnership(address newOwner) public onlyOwner {
    if (newOwner != address(0)) {
      owner = newOwner;
    }
  }

}

contract MonsterCreatorInterface is Ownable {

    uint8 public lockedMonsterStatsCount = 0;
    uint nonce = 0;

    function rand(uint8 min, uint8 max) public returns (uint8) {
        nonce++;
        uint8 result = (uint8(sha3(block.blockhash(block.number-1), nonce ))%max);
        
        if (result < min)
        {
            result = result+min;
        }
        return result;
    }
    
    


    function shinyRand(uint16 min, uint16 max) public returns (uint16) {
        nonce++;
        uint16 result = (uint16(sha3(block.blockhash(block.number-1), nonce ))%max);
        
        if (result < min)
        {
            result = result+min;
        }
        return result;
    }
    
    
    
    mapping(uint256 => uint8[8]) public baseStats;

    function addBaseStats(uint256 _mId, uint8[8] data) external onlyOwner {
                                       
                                                                
                                                                    
        require(data[0] > 0);
        require(baseStats[_mId][0] == 0);
        baseStats[_mId] = data;
    }
    
    function _addBaseStats(uint256 _mId, uint8[8] data) internal {
        
        
        baseStats[_mId] = data;
        lockedMonsterStatsCount++;
    }


    


    
    function MonsterCreatorInterface() public {
        
                                                                             
        _addBaseStats(1, [45, 49, 49, 65, 65, 45, 12, 4]);
        _addBaseStats(2, [60, 62, 63, 80, 80, 60, 12, 4]);
        _addBaseStats(3, [80, 82, 83, 100, 100, 80, 12, 4]);
        _addBaseStats(4, [39, 52, 43, 60, 50, 65, 10, 6]);
        _addBaseStats(5, [58, 64, 58, 80, 65, 80, 10, 6]);
        _addBaseStats(6, [78, 84, 78, 109, 85, 100, 10, 6]);
        _addBaseStats(7, [44, 48, 65, 50, 64, 43, 11, 14]);
        _addBaseStats(8, [59, 63, 80, 65, 80, 58, 11, 14]);
        _addBaseStats(9, [79, 83, 100, 85, 105, 78, 11, 14]);
        _addBaseStats(10, [40, 35, 30, 20, 20, 50, 7, 4]);
        
        _addBaseStats(149, [55, 50, 45, 135, 95, 120, 8, 14]);
        _addBaseStats(150, [91, 134, 95, 100, 100, 80, 2, 5]);
        _addBaseStats(151, [100, 100, 100, 100, 100, 100, 5, 19]);
    }
    
                                                                                   
                                          
    function getMonsterStats( uint256 _mID) external constant returns(uint8[8] stats) {
           stats[0] = baseStats[_mID][0];
           stats[1] = baseStats[_mID][1];
           stats[2] = baseStats[_mID][2];
           stats[3] = baseStats[_mID][3];
           stats[4] = baseStats[_mID][4];
           stats[5] = baseStats[_mID][5];
           stats[6] = baseStats[_mID][6];
           stats[7] = baseStats[_mID][7];
           
          

        }

                                                     
        function getMonsterIVs() external returns(uint8[7] ivs) {

            bool shiny = false;

            uint16 chance = shinyRand(1, 8192);

            if (chance == 42) {
                shiny = true;
            }

                                         
                                                      
            if (shiny == true) {
                ivs[0] = uint8(rand(10, 31));
                ivs[1] = uint8(rand(10, 31));
                ivs[2] = uint8(rand(10, 31));
                ivs[3] = uint8(rand(10, 31));
                ivs[4] = uint8(rand(10, 31));
                ivs[5] = uint8(rand(10, 31));
                ivs[6] = 1;
                
            } else {
                ivs[0] = uint8(rand(0, 31));
                ivs[1] = uint8(rand(0, 31));
                ivs[2] = uint8(rand(0, 31));
                ivs[3] = uint8(rand(0, 31));
                ivs[4] = uint8(rand(0, 31));
                ivs[5] = uint8(rand(0, 31));
                ivs[6] = 0;
            }

            

        }


                                                                                                    
                                                                           
        function getGen0IVs() external returns (uint8[7] ivs) {
            
            bool shiny = false;

            uint16 chance = shinyRand(1, 4096);

            if (chance == 42) {
                shiny = true;
            }
            
            if (shiny) {
                 ivs[0] = uint8(rand(15, 31));
                ivs[1] = uint8(rand(15, 31));
                ivs[2] = uint8(rand(15, 31));
                ivs[3] = uint8(rand(15, 31));
                ivs[4] = uint8(rand(15, 31));
                ivs[5] = uint8(rand(15, 31));
                ivs[6] = 1;
                
            } else {
                ivs[0] = uint8(rand(10, 31));
                ivs[1] = uint8(rand(10, 31));
                ivs[2] = uint8(rand(10, 31));
                ivs[3] = uint8(rand(10, 31));
                ivs[4] = uint8(rand(10, 31));
                ivs[5] = uint8(rand(10, 31));
                ivs[6] = 0;
            }
            
        }
        
        function withdrawBalance() external onlyOwner {
       
        uint256 balance = this.balance;
       
       
        owner.transfer(balance);
        
    }
}