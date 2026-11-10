contract RES { 

                                       
    string public name;
    string public symbol;
    uint8 public decimals;
    
    uint totalSupply;
    
                                                 
    mapping (address => uint256) public balanceOf;
    
                                                                                  
    event Transfer(address indexed from, address indexed to, uint256 value);
    
                                                             

    function RES() {
        name = "RES";     
        symbol = "RES";
        decimals = 16;
    }

    function buy() public payable {
      balanceOf[msg.sender] = msg.value;
      totalSupply += msg.value;
    }  

}

contract SwarmRedistribution is RES {
        
    struct dividendPathway {
      address from;
      uint amount;
      uint timeStamp;
    }

    mapping(address => dividendPathway[]) public dividendPathways;
    
    mapping(address => bool) public isHuman;

    uint taxRate;
    uint exchangeRate;

    struct Node {
      address node;
      address parent;
      uint indexCount;
    }
    
                               
    Node[] public swarmTree;
    
    mapping(address => uint) nodeIndex;
    mapping(uint => uint[]) indices;
    
    uint humanCount;

    event Swarm(address indexed leaf, address indexed node, uint256 share);

    function SwarmRedistribution() {
      
                                        
    taxRate = 20;
    exchangeRate = 60;
    }

    function sell(uint256 _value) public {
      if(balanceOf[msg.sender] < _value) throw;
      uint256 exchangeTax = _value * exchangeRate / 1000;
      balanceOf[msg.sender] -= _value;

        if(swarmRedistribution(msg.sender, exchangeTax) == true) {
          if (!msg.sender.send(_value - exchangeTax))
            throw;
          totalSupply -= (_value - exchangeTax);
        }
        else {
                          
          if (!msg.sender.send(_value))
            throw;
          totalSupply -= _value;
          
        }
    }  

                    
    function transfer(address _to, uint256 _value) {
                                                                
        if (balanceOf[msg.sender] < _value) throw;
        if (balanceOf[_to] + _value < balanceOf[_to]) throw;
        
                           
        uint256 taxCollected = _value * taxRate / 1000;

                                           
        balanceOf[msg.sender] -= _value;
        balanceOf[_to] += _value - taxCollected;
        
        if(swarmRedistribution(_to, taxCollected) == true) {
        }
        else {
                          
          balanceOf[msg.sender] += taxCollected;
        }

                                         
        dividendPathways[_to].push(dividendPathway({
                                        from: msg.sender, 
                                        amount:  _value,
                                        timeStamp: now
                                      }));

                                                                    
        Transfer(msg.sender, _to, _value);
    }

    function swarmRedistribution(address _to, uint256 _taxCollected) internal returns (bool) {
        if(dividendPathways[_to].length != 0){
           iterateThroughSwarm(_to, _to, now);
           if(swarmTree.length != 0) {
            return doSwarm(_to, _taxCollected);
           }
        }
        else return false;
      }
    
    function iterateThroughSwarm(address _leaf, address _node, uint _timeStamp) internal {
      if(dividendPathways[_node].length != 0) {
        for(uint i = 0; i < dividendPathways[_node].length; i++) {
            uint timeStamp = dividendPathways[_node][i].timeStamp;
          if(timeStamp < _timeStamp) {
            
            bool human = isHuman[_node];
            
            if(human) humanCount++;
            
            if(nodeIndex[_node] == 0) {
            
            Node memory node = Node({
                        node: dividendPathways[_node][i].from, 
                        parent: _node,
                        indexCount: 1
                      });
            nodeIndex[_node] = swarmTree.length;          
            indices[nodeIndex[_node]].push(i);          
            }
            else {
              indices[nodeIndex[_node]].push(i);
              swarmTree[nodeIndex[_node]].indexCount++;
            }
            
            if(node.node != _leaf || node.node != _node) {
              swarmTree.push(node);
              iterateThroughSwarm(_leaf, node.node, timeStamp);
            }
          }
        }
      }
    }

    function doSwarm(address _leaf, uint256 _taxCollected) internal returns (bool) {
      
      bool noHumans = false;
      if(humanCount == 0) noHumans = true;

      uint256 share = _taxCollected / humanCount;

      for(uint i = 0; i < swarmTree.length; i++) {
        
        address node = swarmTree[i].node;
        address parent = swarmTree[i].parent;
        bool human = isHuman[node];

        if(human) balanceOf[swarmTree[i].node] += share;

        for(uint k = 0; k < swarmTree[i].indexCount; k++) {
          uint index = indices[nodeIndex[node]][i];
          
          if(dividendPathways[parent][index].amount - _taxCollected > 0) {
            dividendPathways[parent][index].amount -= _taxCollected; 
            break;
          }
          else removeDividendPathway(parent, index);
        }
        
                                                                 
        if(human) Swarm(_leaf, swarmTree[i].node, share);
        delete indices[nodeIndex[node]];
        delete nodeIndex[node];
      }
      delete swarmTree;
      delete humanCount;

      if(noHumans) return false;
      return true;
    }
    
    function removeDividendPathway(address node, uint index) internal {
                delete dividendPathways[node][index];
                for (uint i = index; i < dividendPathways[node].length - 1; i++) {
                        dividendPathways[node][i] = dividendPathways[node][i + 1];
                }
                dividendPathways[node].length--;
        }

}