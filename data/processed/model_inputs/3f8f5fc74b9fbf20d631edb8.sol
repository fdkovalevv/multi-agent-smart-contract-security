contract Survey {
    Devcon2Interface public devcon2Token;

                                                                               
    mapping (bytes32 => bool) public hasResponded;
    
                                               
    uint public surveyEndAt;

                                                     
    string public question;

                                  
    bytes32[] public responseOptions;

                                                                  
    uint public numResponseOptions;

                                                                             
                                 
    mapping (uint => uint) public responseCounts;

                                 
    uint public numResponses;

                                              
    event Response(bytes32 indexed tokenId, uint responseId);

                                        
                                                                       
                                                                                          
                                                    
                                                                                 
    function Survey(address tokenAddress, uint duration, string _question, bytes32[] _responseOptions) {
        devcon2Token = Devcon2Interface(tokenAddress);
        question = _question;
        numResponseOptions = _responseOptions.length;
        for (uint i=0; i < numResponseOptions; i++) {
            responseOptions.push(_responseOptions[i]);
        }
        surveyEndAt = now + duration;
    }

                                  
                                                                               
    function respond(uint responseId) returns (bool) {
                                         
        if (now >= surveyEndAt) return false;

                                   
        if (!devcon2Token.isTokenOwner(msg.sender)) return false;

                                                                        
                                                                               
                                                                        
        var tokenId = devcon2Token.ownedToken(msg.sender);

                                                                             
                 
        if (tokenId == 0x0) throw;

                                                        
        if (hasResponded[tokenId]) return false;

                                       
        if (responseId >= responseOptions.length) return false;

        responseCounts[responseId] += 1;

                            
        Response(tokenId, responseId);

                                                               
        hasResponded[tokenId] = true;

                                         
        numResponses += 1;
    }
}

contract MainnetSurvey is Survey {
    function MainnetSurvey(uint duration, string _question, bytes32[] _responseOptions) Survey(0xabf65a51c7adc3bdef0adf8992884be38072c184, duration, _question, _responseOptions) {
    }
}

contract ETCSurvey is MainnetSurvey {
    function ETCSurvey() MainnetSurvey(
            2 weeks,
            "Do plan to pursue any development or involvement on the Ethereum Classic blockchain",
            _options
        )
    {
        bytes32[] memory _options = new bytes32[](4);
        _options[0] = "No Answer";
        _options[1] = "Yes";
        _options[2] = "No";
        _options[3] = "Undecided";
    }
}