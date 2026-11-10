contract Vote {
    VoteFactory public myVoteFactory;

    function Vote() {
                                                                   
        myVoteFactory = VoteFactory(msg.sender);
    }
    
    function () payable {
                                                                                 
        myVoteFactory.vote(this == myVoteFactory.yesContract(), msg.sender);
    }

    function payOut() {
                                                         
        msg.sender.send(this.balance);
    }
}