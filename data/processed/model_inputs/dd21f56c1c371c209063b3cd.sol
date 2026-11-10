contract mortal {
                                                  
    address owner;

                                                                                        
    function mortal() { owner = msg.sender; }

                                                       
    function kill() { if (msg.sender == owner) suicide(owner); }
}

contract store is mortal {

    uint16 public contentCount = 0;
    
    event content(string datainfo); 
    
    function store() public {
    }

    function add(string datainfo) {
        contentCount++;
        content(datainfo);
    }
}