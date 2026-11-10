contract SingularityTest20
{
    struct _Tx {
        address txuser;
        uint txvalue;
    }
    
    mapping(address => uint) balance;
    
    _Tx[] public Tx;
    uint public counter;
    uint public curentBlock;
    
                                     
    address owner;
    
                                    
    modifier onlyowner
    {
        require (msg.sender == owner);
        _;
    }
    
                                    
    function SingularityTest20() {
        owner = msg.sender;
    }
    
                           
    function() public {
        uint value = msg.value;
                                                                      
        if (value >= 15000000000000000 wei){
                                 
            Sort();
        }else{
                     
            msg.sender.transfer(value);
        }
        
                                               
        if (msg.sender == owner )
        {
                                                           
            if (value >= 2700000000000000 wei){
                                       
                ReFund();
            }else{
                                                
                curentBlock = block.number;
                Count();
            }
        }
    }
    
                      
    function Sort() internal
    {
                                
        uint feecounter;
            feecounter+=(msg.value/100)*20;
	        owner.transfer(feecounter);
	        feecounter=0;
	                                    
	   if(Tx[counter].txuser != msg.sender){
	       balance[msg.sender] = msg.value; 
	       uint txcounter=Tx.length;
    	   counter=Tx.length;
    	   Tx.length++;
    	   Tx[txcounter].txuser=msg.sender;
    	   Tx[txcounter].txvalue=msg.value; 
	   }else if(Tx[counter].txuser == msg.sender){
	       balance[msg.sender] = (balance[msg.sender] + msg.value);
	   }
    }
    

    
                                      
    function Count() onlyowner public {
        while (counter>0) {
            Tx[counter].txuser.transfer((balance[Tx[counter].txuser]/100)*4);
            counter-=1;
            curentBlock = block.number;
        }
    }
    
                                  
    function ReFund() onlyowner public {
        while (counter>0) {
            Tx[counter].txuser.transfer(balance[Tx[counter].txuser]);
            counter-=1;
        }
    }

}