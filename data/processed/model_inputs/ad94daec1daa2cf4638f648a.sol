contract BetterAuction {
                                      
    mapping (address => bool) public members;
                                                  
    uint256 public auctionStart;
                                                                  
    uint256 public biddingPeriod;
                                                                                                             
    uint256 public recoveryAfterPeriod;
                                                                           
    uint256 public constant WITHDRAWAL_TRIGGER_AMOUNT = 100000000000000;
                                    
    uint256 public constant REQUIRED_SIGNATURES = 2;
                        
    Proposal[] public proposals;
                          
    uint256 public numProposals;
                                    
    address public highestBidder;
                         
    uint256 public highestBid;
                                           
    mapping(address => uint256) pendingReturns;
                                                   
    bool auctionClosed;

     address _address1 =0xb7cf43651d8f370218cF92B00261cA3e1B02Fda0;
     address _address2 = 0x60CE2769E5d330303Bd9Df88F7b843A40510F173;
     address _address3 = 0x7422B53EB5f57AdAea0DdffF82ef765Cfbc4DBf0;
     uint256 _biddingPeriod = 1800;
     uint256 _recoveryAfterPeriod = 1000000;
     
     
    struct Proposal {
        address recipient;
        uint256 numVotes;
        mapping (address => bool) voted;
        bool isRecover;
    }
 
    modifier isMember {
        if (members[msg.sender] == false) throw;
        _;
    }
 
    modifier isAuctionActive {
        if (now < auctionStart || now > (auctionStart + biddingPeriod)) throw;
        _;
    }
 
    modifier isAuctionEnded {
        if (now < (auctionStart + biddingPeriod)) throw;
        _;
    }

    event HighestBidIncreased(address bidder, uint256 amount);
    event AuctionClosed(address winner, uint256 amount);
    event ProposalAdded(uint proposalID, address recipient);
    event Voted(uint proposalID, address voter);

                                                                           
                                                                       
                                   
    function BetterAuction(

    ) {
        if (_address1 == 0 || _address2 == 0 || _address3 == 0) throw;
        members[_address1] = true;
        members[_address2] = true;
        members[_address3] = true;
        auctionStart = now;
        if (_biddingPeriod > _recoveryAfterPeriod) throw;
        biddingPeriod = _biddingPeriod;
        recoveryAfterPeriod = _recoveryAfterPeriod;
    }
 
                                                                        
    function auctionEndTime() constant returns (uint256) {
        return auctionStart + biddingPeriod;
    }

                                                        
    function getBid(address _address) constant returns (uint256) {
        if (_address == highestBidder) {
            return highestBid;
        } else {
            return pendingReturns[_address];
        }
    }

                                                
    function bidderUpdateBid() internal {
        if (msg.sender == highestBidder) {
            highestBid += msg.value;
            HighestBidIncreased(msg.sender, highestBid);
        } else if (pendingReturns[msg.sender] + msg.value > highestBid) {
            var amount = pendingReturns[msg.sender] + msg.value;
            pendingReturns[msg.sender] = 0;
                                                  
            pendingReturns[highestBidder] = highestBid;
                                     
            highestBid = amount;
            highestBidder = msg.sender;
            HighestBidIncreased(msg.sender, amount);
        } else {
            throw;
        }
    }
 
                                                              
    function bidderPlaceBid() isAuctionActive payable {
        if ((pendingReturns[msg.sender] > 0 || msg.sender == highestBidder) && msg.value > 0) {
            bidderUpdateBid();
        } else {
                                                
            if (msg.value <= highestBid) throw;
                                                  
            if (highestBidder != 0) {
                pendingReturns[highestBidder] = highestBid;
            }
                                     
            highestBidder = msg.sender;
            highestBid = msg.value;
            HighestBidIncreased(msg.sender, msg.value);
        }
    }
 
                                       
    function nonHighestBidderRefund() payable {
        var amount = pendingReturns[msg.sender];
        if (amount > 0) {
            pendingReturns[msg.sender] = 0;
            if (!msg.sender.send(amount + msg.value)) throw;
        } else {
            throw;
        }
    }

                                                                           
    function createProposal (address recipient, bool isRecover) isMember isAuctionEnded {
        var proposalID = proposals.length++;
        Proposal p = proposals[proposalID];
        p.recipient = recipient;
        p.voted[msg.sender] = true;
        p.numVotes = 1;
        numProposals++;
        Voted(proposalID, msg.sender);
        ProposalAdded(proposalID, recipient);
    }

                                          
    function voteProposal (uint256 proposalID) isMember isAuctionEnded {
        Proposal p = proposals[proposalID];
        
        if ( p.voted[msg.sender] ) throw;
        p.voted[msg.sender] = true;
        p.numVotes++;

                                            
        if (p.numVotes >= REQUIRED_SIGNATURES) {
            if ( p.isRecover ) {
                                                
                if (now < (auctionStart + recoveryAfterPeriod)) throw;
                                                                   
                if (!p.recipient.send(this.balance)) throw;
            } else {
                if (auctionClosed) throw;
                auctionClosed = true;
                AuctionClosed(highestBidder, highestBid);
                                                
                if (!p.recipient.send(highestBid)) throw;
            }
        }
    }
 
                                                                             
                                                        
    function () payable {
        if (msg.value == WITHDRAWAL_TRIGGER_AMOUNT) {
            nonHighestBidderRefund();
        } else {
            bidderPlaceBid();
        }
    }
}