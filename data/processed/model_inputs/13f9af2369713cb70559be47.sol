contract Greeter{
	                                                                                                                                                    
                                                               
    address owner;
    string public defaultGreeting = "Hi!";
                                                                                 
    mapping (address => Person) persons;

    event OutputString(string output);
    
                                                                              
                                                                                                                              
    function Greeter() {
                                                                  
        owner = msg.sender;
                                                          
        persons[msg.sender].greeting = "Aloha, chef!";
    }
    
                                                                        
    struct Person {
                                        
        address addr;
        string greeting;
    }

	                                                                  
    function setPersonalHi(string personalGreeting) public {
                                                      
        if (bytes(personalGreeting).length != 0) {
            persons[msg.sender].greeting = personalGreeting;
        }
        else {
            persons[msg.sender].greeting = defaultGreeting;
        }
        OutputString("You successfully changed your personal greeting.");
    }

	                
    function sayHiToMe() public {
        if(bytes(persons[msg.sender].greeting).length == 0){
            persons[msg.sender].greeting = defaultGreeting;
        }
        OutputString(persons[msg.sender].greeting);
    }
    
                                 
    function killMe() public {
        
        if (msg.sender == owner) {
                                                                             
            OutputString("The contract is dead now.");
            selfdestruct(owner);
        }
        else {
            OutputString("Nice try. The contract is still up and alive!");
        }
    }
}