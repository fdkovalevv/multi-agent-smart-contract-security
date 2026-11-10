contract proforma  {
    address public owner;
    
    struct proformaStruct {
        address client;                                   
        string fName;
        string lName;
        string email;
        address company;                                    
        address validator;                                                       
        
        uint pay_step1;                                                                                                        
        uint pay_step2;                                                                                                    
        uint pay_step3;                                                                                    
        uint commission_company;                                                 
        uint client_amount;                                        
        
        bool iscompleted ;                            
        }
        
    struct TransactionStruct
        {                        
                                             
            address client;                                           
            uint client_nounce;                                                                   
        }

                                                                                
                                                                      
     
                                    
    mapping (address => proformaStruct) clients;
                                                                             
    address[] public clientsDatabase; 
     

                                     
    constructor () public {
         owner = msg.sender;
        } 
        
    
    function setClient(address _address, string _fName, string _lName, string _email) public {
       var client = clients[_address];

        client.fName = _fName;
        client.lName = _lName;
        client.email   =_email;
        
        clientsDatabase.push(_address) -1;
    }
    
    
    function getClient() view public returns (address[]) {
        return clientsDatabase ;
    }
    
                                    
    function getAllClients(address cli) view public returns (string, string, string){
        return (clients[cli].fName, clients[cli].lName, clients[cli].email);
    }
    
                       
    function countClients() view public returns (uint){
        return clientsDatabase.length;
    }
    
    
    
        
   
      
                                                  
                               
                                                
     
        
                                                      
                                                      
                                     
                                       
                                            
     
      
      
         
         

                                                       
           function() payable public
        {
        }
        
        
}