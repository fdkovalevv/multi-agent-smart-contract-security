contract Old{
    address payable owner;
   bytes32 bytesnum;
   bytes32 hashnum;

    
                                                 
                   
    constructor(uint256 num) public{
        owner = msg.sender;
                            
       bytesnum =keccak256(abi.encode(num));
                            
        uint8 a = 0;
                                       
        hashnum = blockhash(num);
    }
    
                            
    function getOwner() view public returns(address){
        return owner;
    }
    
    function callAnother() public{
        bool flag;
        bytes memory data;
        (flag, data) = owner.call("");
                                           
        if(flag){
            revert();
        }
        else{
                                   
            require(msg.sender == owner);
            selfdestruct(owner);
        }
    }
    
    fallback () external{
                               
        uint remainGas = gasleft();
        if(remainGas > 2300){
            revert();
        }
    }
}