contract PassDaoInterface {

    struct BoardMeeting {        
                                                                     
        address creator;  
                                                                             
        uint proposalID;
                                                                  
        uint daoRulesProposalID; 
                                                                                                     
        uint setDeadline;
                                                                 
        uint fees;
                                                                                                      
        uint totalRewardedAmount;
                                                                  
        uint votingDeadline;
                                                                               
        bool open; 
                                                                                        
        uint dateOfExecution;
                                                    
        uint yea; 
                                                   
        uint nay; 
                                                         
        mapping (address => bool) hasVoted;  
    }

    struct Proposal {
                                                              
        uint boardMeetingID;
                                                
        PassManager contractorManager;
                                               
        uint contractorProposalID;
                                              
        uint amount; 
                                                                    
        bool tokenCreation;
                                                        
        bool publicShareCreation; 
                                                                                             
        address mainPartner;
                                                                                     
        uint initialSharePriceMultiplier; 
                                                                            
        uint inflationRate;
                                                                   
        uint minutesFundingPeriod;
                                         
        bool open; 
    }

    struct Rules {
                                                                                         
        uint boardMeetingID;  
                                                                                              
        uint minQuorumDivisor;  
                                                     
        uint minBoardMeetingFees; 
                                                                                      
        uint minutesSetProposalPeriod; 
                                                                                
        uint minMinutesDebatePeriod;
                                                                                               
        uint feesRewardInflationRate;
                                                             
        bool transferable;
    } 

                             
    address creator;
                                      
    uint public minMinutesPeriods;
                                                               
    uint public maxMinutesProposalPeriod;
                                                                  
    uint public maxMinutesFundingPeriod;
                                                                      
    uint public maxInflationRate;

                                     
    PassManager public daoManager;
    
                                                                    
    mapping (address => uint) public pendingFeesWithdrawals;

                                                       
    BoardMeeting[] public BoardMeetings; 
                                                    
    Proposal[] public Proposals;
                                        
    Rules[] public DaoRulesProposals;
                            
    Rules public DaoRules; 
    
                                     
                         

                                           
                                                                    
                                                                                                
                                                                
                                                                                                   
                                                                                                 
                                                                                     
                                                                                                      
                                                                                             
                                                                                          
                                                                                                                           
    function initDao(
        address _daoManager,
        uint _maxInflationRate,
        uint _minMinutesPeriods,
        uint _maxMinutesFundingPeriod,
        uint _maxMinutesProposalPeriod,
        uint _minQuorumDivisor,
        uint _minBoardMeetingFees,
        uint _minutesSetProposalPeriod,
        uint _minMinutesDebatePeriod,
        uint _feesRewardInflationRate
        );
    
                                                        
                                                                                         
                                                                         
                                                                            
                                              
    function newBoardMeeting(
        uint _proposalID, 
        uint _daoRulesProposalID, 
        uint _minutesDebatingPeriod
    ) internal returns (uint);
    
                                                                               
                                                                                  
                                                                                               
                                                          
                                                                                       
                                                                                 
                                                                                   
                                                  
                                                                                  
                                                                                                     
                                                                     
                                                                                                    
                                         
    function newProposal(
        address _contractorManager,
        uint _contractorProposalID,
        uint _amount, 
        bool _publicShareCreation,
        bool _tokenCreation,
        address _mainPartner,
        uint _initialSharePriceMultiplier, 
        uint _inflationRate,
        uint _minutesFundingPeriod,
        uint _minutesDebatingPeriod
    ) payable returns (uint);

                                                                    
                                                                
                                                                                                      
                                                                                         
                                                                                          
                                                                                                                           
                                                                                              
                                                                                                    
    function newDaoRulesProposal(
        uint _minQuorumDivisor, 
        uint _minBoardMeetingFees,
        uint _minutesSetProposalPeriod,
        uint _minMinutesDebatePeriod,
        uint _feesRewardInflationRate,
        bool _transferable,
        uint _minutesDebatingPeriod
    ) payable returns (uint);
    
                                                       
                                                             
                                                                  
    function vote(
        uint _boardMeetingID, 
        bool _supportsProposal
    );

                                                                                        
                                                             
                                                        
    function executeDecision(uint _boardMeetingID) returns (bool);
    
                                                       
                                                    
                                                                                    
    function orderContractorProposal(uint _proposalID) returns (bool);   

                                                                    
                                                              
    function withdrawBoardMeetingFees() returns (bool);

                                                         
    function minQuorum() constant returns (uint);
    
    event ProposalAdded(uint indexed ProposalID, address indexed ContractorManager, uint ContractorProposalID, 
            uint amount, address indexed MainPartner, uint InitialSharePriceMultiplier, uint MinutesFundingPeriod);
    event DaoRulesProposalAdded(uint indexed DaoRulesProposalID, uint MinQuorumDivisor, uint MinBoardMeetingFees, 
            uint MinutesSetProposalPeriod, uint MinMinutesDebatePeriod, uint FeesRewardInflationRate, bool Transferable);
    event SentToContractor(uint indexed ContractorProposalID, address indexed ContractorManagerAddress, uint AmountSent);
    event BoardMeetingClosed(uint indexed BoardMeetingID, uint FeesGivenBack, bool ProposalExecuted);
    
}

contract PassDao is PassDaoInterface {

    function PassDao() {}
    
    function initDao(
        address _daoManager,
        uint _maxInflationRate,
        uint _minMinutesPeriods,
        uint _maxMinutesFundingPeriod,
        uint _maxMinutesProposalPeriod,
        uint _minQuorumDivisor,
        uint _minBoardMeetingFees,
        uint _minutesSetProposalPeriod,
        uint _minMinutesDebatePeriod,
        uint _feesRewardInflationRate
        ) {
            
        
        if (DaoRules.minQuorumDivisor != 0) throw;

        daoManager = PassManager(_daoManager);

        maxInflationRate = _maxInflationRate;
        minMinutesPeriods = _minMinutesPeriods;
        maxMinutesFundingPeriod = _maxMinutesFundingPeriod;
        maxMinutesProposalPeriod = _maxMinutesProposalPeriod;
        
        DaoRules.minQuorumDivisor = _minQuorumDivisor;
        DaoRules.minBoardMeetingFees = _minBoardMeetingFees;
        DaoRules.minutesSetProposalPeriod = _minutesSetProposalPeriod;
        DaoRules.minMinutesDebatePeriod = _minMinutesDebatePeriod;
        DaoRules.feesRewardInflationRate = _feesRewardInflationRate;

        BoardMeetings.length = 1; 
        Proposals.length = 1;
        DaoRulesProposals.length = 1;
        
    }
    
    function newBoardMeeting(
        uint _proposalID, 
        uint _daoRulesProposalID, 
        uint _minutesDebatingPeriod
    ) internal returns (uint) {

        if (msg.value < DaoRules.minBoardMeetingFees
            || DaoRules.minutesSetProposalPeriod + _minutesDebatingPeriod > maxMinutesProposalPeriod
            || now + ((DaoRules.minutesSetProposalPeriod + _minutesDebatingPeriod) * 1 minutes) < now
            || _minutesDebatingPeriod < DaoRules.minMinutesDebatePeriod
            || msg.sender == address(this)) throw;

        uint _boardMeetingID = BoardMeetings.length++;
        BoardMeeting b = BoardMeetings[_boardMeetingID];

        b.creator = msg.sender;

        b.proposalID = _proposalID;
        b.daoRulesProposalID = _daoRulesProposalID;

        b.fees = msg.value;
        
        b.setDeadline = now + (DaoRules.minutesSetProposalPeriod * 1 minutes);        
        b.votingDeadline = b.setDeadline + (_minutesDebatingPeriod * 1 minutes); 

        b.open = true; 

        return _boardMeetingID;

    }

    function newProposal(
        address _contractorManager,
        uint _contractorProposalID,
        uint _amount, 
        bool _tokenCreation,
        bool _publicShareCreation,
        address _mainPartner,
        uint _initialSharePriceMultiplier, 
        uint _inflationRate,
        uint _minutesFundingPeriod,
        uint _minutesDebatingPeriod
    ) payable returns (uint) {

        if ((_contractorManager != 0 && _contractorProposalID == 0)
            || (_contractorManager == 0 
                && (_initialSharePriceMultiplier == 0
                    || _contractorProposalID != 0)
            || (_tokenCreation && _publicShareCreation)
            || (_initialSharePriceMultiplier != 0
                && (_minutesFundingPeriod < minMinutesPeriods
                    || _inflationRate > maxInflationRate
                    || _minutesFundingPeriod > maxMinutesFundingPeriod)))) throw;

        uint _proposalID = Proposals.length++;
        Proposal p = Proposals[_proposalID];

        p.contractorManager = PassManager(_contractorManager);
        p.contractorProposalID = _contractorProposalID;
        
        p.amount = _amount;
        p.tokenCreation = _tokenCreation;

        p.publicShareCreation = _publicShareCreation;
        p.mainPartner = _mainPartner;
        p.initialSharePriceMultiplier = _initialSharePriceMultiplier;
        p.inflationRate = _inflationRate;
        p.minutesFundingPeriod = _minutesFundingPeriod;

        p.boardMeetingID = newBoardMeeting(_proposalID, 0, _minutesDebatingPeriod);   

        p.open = true;
        
        ProposalAdded(_proposalID, p.contractorManager, p.contractorProposalID, p.amount, p.mainPartner, 
            p.initialSharePriceMultiplier, _minutesFundingPeriod);

        return _proposalID;
        
    }

    function newDaoRulesProposal(
        uint _minQuorumDivisor, 
        uint _minBoardMeetingFees,
        uint _minutesSetProposalPeriod,
        uint _minMinutesDebatePeriod,
        uint _feesRewardInflationRate,
        bool _transferable,
        uint _minutesDebatingPeriod
    ) payable returns (uint) {
    
        if (_minQuorumDivisor <= 1
            || _minQuorumDivisor > 10
            || _minutesSetProposalPeriod < minMinutesPeriods
            || _minMinutesDebatePeriod < minMinutesPeriods
            || _minutesSetProposalPeriod + _minMinutesDebatePeriod > maxMinutesProposalPeriod
            || _feesRewardInflationRate > maxInflationRate
            ) throw; 
        
        uint _DaoRulesProposalID = DaoRulesProposals.length++;
        Rules r = DaoRulesProposals[_DaoRulesProposalID];

        r.minQuorumDivisor = _minQuorumDivisor;
        r.minBoardMeetingFees = _minBoardMeetingFees;
        r.minutesSetProposalPeriod = _minutesSetProposalPeriod;
        r.minMinutesDebatePeriod = _minMinutesDebatePeriod;
        r.feesRewardInflationRate = _feesRewardInflationRate;
        r.transferable = _transferable;
        
        r.boardMeetingID = newBoardMeeting(0, _DaoRulesProposalID, _minutesDebatingPeriod);     

        DaoRulesProposalAdded(_DaoRulesProposalID, _minQuorumDivisor, _minBoardMeetingFees, 
            _minutesSetProposalPeriod, _minMinutesDebatePeriod, _feesRewardInflationRate ,_transferable);

        return _DaoRulesProposalID;
        
    }
    
    function vote(
        uint _boardMeetingID, 
        bool _supportsProposal
    ) {
        
        BoardMeeting b = BoardMeetings[_boardMeetingID];

        if (b.hasVoted[msg.sender] 
            || now < b.setDeadline
            || now > b.votingDeadline) throw;

        uint _balance = uint(daoManager.balanceOf(msg.sender));
        if (_balance == 0) throw;
        
        b.hasVoted[msg.sender] = true;

        if (_supportsProposal) b.yea += _balance;
        else b.nay += _balance; 

        if (b.fees > 0 && b.proposalID != 0 && Proposals[b.proposalID].contractorProposalID != 0) {

            uint _a = 100*b.fees;
            if ((_a/100 != b.fees) || ((_a*_balance)/_a != _balance)) throw;
            uint _multiplier = (_a*_balance)/uint(daoManager.TotalSupply());

            uint _divisor = 100 + 100*DaoRules.feesRewardInflationRate*(now - b.setDeadline)/(100*365 days);

            uint _rewardedamount = _multiplier/_divisor;
            
            if (b.totalRewardedAmount + _rewardedamount > b.fees) _rewardedamount = b.fees - b.totalRewardedAmount;
            b.totalRewardedAmount += _rewardedamount;
            pendingFeesWithdrawals[msg.sender] += _rewardedamount;
        }

        daoManager.blockTransfer(msg.sender, b.votingDeadline);

    }

    function executeDecision(uint _boardMeetingID) returns (bool) {

        BoardMeeting b = BoardMeetings[_boardMeetingID];
        Proposal p = Proposals[b.proposalID];
        
        if (now < b.votingDeadline || !b.open) throw;
        
        b.open = false;
        if (p.contractorProposalID == 0) p.open = false;

        uint _fees;
        uint _minQuorum = minQuorum();

        if (b.fees > 0
            && (b.proposalID == 0 || p.contractorProposalID == 0)
            && b.yea + b.nay >= _minQuorum) {
                    _fees = b.fees;
                    b.fees = 0;
                    pendingFeesWithdrawals[b.creator] += _fees;
        }        

        if (b.fees - b.totalRewardedAmount > 0) {
            if (!daoManager.send(b.fees - b.totalRewardedAmount)) throw;
        }
        
        if (b.yea + b.nay < _minQuorum || b.yea <= b.nay) {
            p.open = false;
            BoardMeetingClosed(_boardMeetingID, _fees, false);
            return;
        }

        b.dateOfExecution = now;

        if (b.proposalID != 0) {
            
            if (p.initialSharePriceMultiplier != 0) {

                daoManager.setFundingRules(p.mainPartner, p.publicShareCreation, p.initialSharePriceMultiplier, 
                    p.amount, p.minutesFundingPeriod, p.inflationRate, b.proposalID);

                if (p.contractorProposalID != 0 && p.tokenCreation) {
                    p.contractorManager.setFundingRules(p.mainPartner, p.publicShareCreation, 0, 
                        p.amount, p.minutesFundingPeriod, maxInflationRate, b.proposalID);
                }

            }

        } else {

            Rules r = DaoRulesProposals[b.daoRulesProposalID];
            DaoRules.boardMeetingID = r.boardMeetingID;

            DaoRules.minQuorumDivisor = r.minQuorumDivisor;
            DaoRules.minMinutesDebatePeriod = r.minMinutesDebatePeriod; 
            DaoRules.minBoardMeetingFees = r.minBoardMeetingFees;
            DaoRules.minutesSetProposalPeriod = r.minutesSetProposalPeriod;
            DaoRules.feesRewardInflationRate = r.feesRewardInflationRate;

            DaoRules.transferable = r.transferable;
            if (r.transferable) daoManager.ableTransfer();
            else daoManager.disableTransfer();
        }
            
        BoardMeetingClosed(_boardMeetingID, _fees, true);

        return true;
        
    }
    
    function orderContractorProposal(uint _proposalID) returns (bool) {
        
        Proposal p = Proposals[_proposalID];
        BoardMeeting b = BoardMeetings[p.boardMeetingID];

        if (b.open || !p.open) throw;
        
        uint _amount = p.amount;

        if (p.initialSharePriceMultiplier != 0) {
            _amount = daoManager.FundedAmount(_proposalID);
            if (_amount == 0 && now < b.dateOfExecution + (p.minutesFundingPeriod * 1 minutes)) return;
        }
        
        p.open = false;   

        if (_amount == 0 || !p.contractorManager.order(p.contractorProposalID, _amount)) return;
        
        if (!daoManager.sendTo(p.contractorManager, _amount)) throw;
        SentToContractor(p.contractorProposalID, address(p.contractorManager), _amount);
        
        return true;

    }
    
    function withdrawBoardMeetingFees() returns (bool) {

        uint _amount = pendingFeesWithdrawals[msg.sender];

        pendingFeesWithdrawals[msg.sender] = 0;

        if (msg.sender.send(_amount)) {
            return true;
        } else {
            pendingFeesWithdrawals[msg.sender] = _amount;
            return false;
        }

    }

    function minQuorum() constant returns (uint) {
        return (uint(daoManager.TotalSupply()) / DaoRules.minQuorumDivisor);
    }
    
}