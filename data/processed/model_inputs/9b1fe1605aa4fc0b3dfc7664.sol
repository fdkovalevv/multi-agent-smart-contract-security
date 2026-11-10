contract MarchMadness {
    struct Submission {
        bytes32 commitment;
        bytes8 bracket;
        uint8 score;
        bool collectedWinnings;
        bool collectedEntryFee;
    }

    event SubmissionAccepted(address account);
    event NewWinner(address winner, uint8 score);
    event TournamentOver();

    FederatedOracleBytes8 resultsOracle;

	mapping(address => Submission) submissions;

                                       
    uint public winnings;

                                                 
    uint public numWinners;

                                                                  
    uint64 private scoringMask;

                                             
    uint public entryFee;

                                               
    uint public scoringDuration;

                                                     
    uint public tournamentStartTime;

                                                                                                  
                                                                            
    uint public noContestTime;

                                                
    uint public contestOverTime;

                                                            
    bytes8 public results;

                                                   
    uint8 public winningScore;

                                                
    uint32 public maxSubmissions;

                                              
    uint32 public numSubmissions;

                                                                                         
    string public tournamentDataIPFSHash;

	function MarchMadness(
        uint entryFee_,
        uint tournamentStartTime_,
        uint noContestTime_,
        uint scoringDuration_,
        uint32 maxSubmissions_,
        string tournamentDataIPFSHash_,
        address oracleAddress
    ) {
		entryFee = entryFee_;
        tournamentStartTime = tournamentStartTime_;
        scoringDuration = scoringDuration_;
        noContestTime = noContestTime_;
        maxSubmissions = maxSubmissions_;
        tournamentDataIPFSHash = tournamentDataIPFSHash_;
        resultsOracle = FederatedOracleBytes8(oracleAddress);
	}

    function submitBracket(bytes32 commitment) payable {
        if (msg.value != entryFee) {
            throw;
        }
        if (now >= tournamentStartTime) {
            throw;
        }
        if (numSubmissions >= maxSubmissions) {
            throw;
        }

        var submission = submissions[msg.sender];
        if (submission.commitment != 0) {
            throw;
        }

        submission.commitment = commitment;
        numSubmissions++;
        SubmissionAccepted(msg.sender);
    }

    function startScoring() returns (bool) {
        if (results != 0) {
            return false;
        }
        if (now < tournamentStartTime) {
            return false;
        }
        if (now > noContestTime) {
            return false;
        }

        bytes8 oracleValue = resultsOracle.finalValue();
        if (oracleValue == 0) {
            return false;
        }

        results = oracleValue;
        scoringMask = ByteBracket.getScoringMask(results);
        contestOverTime = now + scoringDuration;
        TournamentOver();
        return true;
    }

    function revealBracket(bytes8 bracket, bytes16 salt) returns (bool) {
        var submission = submissions[msg.sender];
        if (sha3(msg.sender, bracket, salt) != submission.commitment) {
            return false;
        }

        submission.bracket = bracket;
        return true;
    }

    function scoreBracket(address account) returns (bool) {
        if (results == 0) {
            return false;
        }
        if (now >= contestOverTime) {
            return false;
        }

        var submission = submissions[account];
        if (submission.bracket == 0) {
            return false;
        }
        if (submission.score != 0) {
            return false;
        }

        submission.score = ByteBracket.getBracketScore(submission.bracket, results, scoringMask);

        if (submission.score > winningScore) {
            winningScore = submission.score;
            numWinners = 0;
        }
        if (submission.score == winningScore) {
            numWinners++;
            winnings = this.balance / numWinners;
            NewWinner(account, submission.score);
        }

        return true;
    }

    function collectWinnings() returns (bool) {
        if (now < contestOverTime) {
            return false;
        }

        var submission = submissions[msg.sender];
        if (submission.score != winningScore) {
            return false;
        }
        if (submission.collectedWinnings) {
            return false;
        }

        submission.collectedWinnings = true;

        if (!msg.sender.send(winnings)) {
            throw;
        }

        return true;
    }

    function collectEntryFee() returns (bool) {
        if (now < noContestTime) {
            return false;
        }
        if (results != 0) {
            return false;
        }

        var submission = submissions[msg.sender];
        if (submission.commitment == 0) {
            return false;
        }
        if (submission.collectedEntryFee) {
            return false;
        }

        submission.collectedEntryFee = true;

        if (!msg.sender.send(entryFee)) {
            throw;
        }

        return true;
    }

    function getBracketScore(bytes8 bracket) constant returns (uint8) {
        if (results == 0) {
            throw;
        }
        return ByteBracket.getBracketScore(bracket, results, scoringMask);
    }

    function getBracket(address account) constant returns (bytes8) {
        return submissions[account].bracket;
    }

    function getScore(address account) constant returns (uint8) {
        return submissions[account].score;
    }

    function getCommitment(address account) constant returns (bytes32) {
        return submissions[account].commitment;
    }

    function hasCollectedWinnings(address account) constant returns (bool) {
        return submissions[account].collectedWinnings;
    }
}