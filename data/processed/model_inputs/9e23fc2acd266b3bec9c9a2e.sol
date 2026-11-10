contract C2 {
    C1 d = new C1(4);                                                
    function createC1(uint arg) {
        C1 newC1  = new C1(arg);
    }
    
    function createAndEndowC1(uint arg, uint amount) payable {
                                    
        C1 newC1 = (new C1).value(amount)(arg);
    }
}