contract NoOpenWallet {
    
      
                   
                     
                     
       
    mapping(address => uint256) public wallets;    

    function createAnAccount() public{
        wallets[msg.sender] = 0;
                                                
    }
    
      
                                                                                    
                                                        
                                         
       

    function deposit() public payable {
        require(wallets[msg.sender] + msg.value > wallets[msg.sender]);
        wallets[msg.sender] += msg.value;
    }

    function withdraw(uint _value) public {
        require(wallets[msg.sender] >= _value);
        msg.sender.transfer(_value);
    }
}