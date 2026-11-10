contract Greeter{
	                                                                                                                                                    
                                                               
    Person owner;
    string public defaultGreeting = "Hi!";
                                                                                 
    mapping (address => Person) persons;

                                                                              
                                                                                                                              
    function Greeter() {
                                                                  
        owner = persons[msg.sender];
                                                                    
        owner.addr = msg.sender;
        owner.greeting = "Aloha, chef!";
    }
    
                                                                        
    struct Person {
                                        
        address addr;
        string greeting;
    }

	                                                                  
    function setPersonalHi(string personalGreeting) public returns (string) {
                                                      
        if (bytes(personalGreeting).length != 0) {
            persons[msg.sender].greeting = personalGreeting;
        }
        else {
            persons[msg.sender].greeting = defaultGreeting;
        }
        return "You successfully changed your personal greeting";
    }

	                
    function sayHiToMe() public returns (string) {
        if(bytes(persons[msg.sender].greeting).length == 0){
            persons[msg.sender].greeting = defaultGreeting;
        }
        return persons[msg.sender].greeting;
    }
    
                                 
    function killMe() public returns (string) {
        
        if (msg.sender == owner.addr) {
                                                                             
            selfdestruct(owner.addr);
        }
        else {
            return "Nice try. The contract is still up and alive!";
        }
    }
}