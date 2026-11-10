contract Old{
    address owner;
   bytes32 bytesnum;
   bytes32 hashnum;

    
                                                 
                   
    function Old(uint256 num){
        owner = msg.sender;
                            
       bytesnum =sha3(num);
                            
        var a = 0;
                                       
        hashnum = block.blockhash(num);
    }
    
                            
    function getOwner() constant returns(address){
        return owner;
    }
    
    function callAnother(){
                                           
        if(owner.callcode("")){
            throw;
        }
        else{
                                   
            require(msg.sender == owner);
            suicide(owner);
        }
    }
    
    function () external{
                               
        if(msg.gas > 2300){
            throw;
        }
    }
}