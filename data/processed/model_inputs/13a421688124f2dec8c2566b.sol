contract Agt {
    using RLP for RLP.RLPItem;
    using RLP for RLP.Iterator;
    using RLP for bytes;
 
    struct BlockHeader {
        uint       prevBlockHash;     
        uint       coinbase;          
        uint       blockNumber;       
                                         
        uint       timestamp;          
        bytes32    extraData;          
    }
 
    function Agt() {}
     
    function parseBlockHeader( bytes rlpHeader ) constant internal returns(BlockHeader) {
        BlockHeader memory header;
        
        var it = rlpHeader.toRLPItem().iterator();        
        uint idx;
        while(it.hasNext()) {
            if( idx == 0 ) header.prevBlockHash = it.next().toUint();
            else if ( idx == 2 ) header.coinbase = it.next().toUint();
            else if ( idx == 8 ) header.blockNumber = it.next().toUint();
            else if ( idx == 11 ) header.timestamp = it.next().toUint();
            else if ( idx == 12 ) header.extraData = bytes32(it.next().toUint());
            else it.next();
            
            idx++;
        }
 
        return header;        
    }
            
                                                
    event VerifyAgt( uint error, uint index );    
    
    struct VerifyAgtData {
        uint rootHash;
        uint rootMin;
        uint rootMax;
        
        uint leafHash;
        uint leafCounter;        
    }

    function verifyAgt( VerifyAgtData data,
                        uint   branchIndex,
                        uint[] countersBranch,
                        uint[] hashesBranch ) constant internal returns(bool) {
                        
        uint currentHash = data.leafHash & 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF;
        
        uint leftCounterMin;
        uint leftCounterMax;        
        uint leftHash;
        
        uint rightCounterMin;
        uint rightCounterMax;        
        uint rightHash;
        
        uint min = data.leafCounter;
        uint max = data.leafCounter;
        
        for( uint i = 0 ; i < countersBranch.length ; i++ ) {
            if( branchIndex & 0x1 > 0 ) {
                leftCounterMin = countersBranch[i] & 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF;
                leftCounterMax = countersBranch[i] >> 128;                
                leftHash    = hashesBranch[i];
                
                rightCounterMin = min;
                rightCounterMax = max;
                rightHash    = currentHash;                
            }
            else {                
                leftCounterMin = min;
                leftCounterMax = max;
                leftHash    = currentHash;
                
                rightCounterMin = countersBranch[i] & 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF;
                rightCounterMax = countersBranch[i] >> 128;                
                rightHash    = hashesBranch[i];                                            
            }
            
            currentHash = uint(sha3(leftCounterMin + (leftCounterMax << 128),
                                    leftHash,
                                    rightCounterMin + (rightCounterMax << 128),
                                    rightHash)) & 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF;
            
            if( (leftCounterMin >= leftCounterMax) || (rightCounterMin >= rightCounterMax) ) {
                if( i > 0 ) {
                                                        
                    VerifyAgt( 0x80000000, i );
                    return false;
                }
                if( leftCounterMin > leftCounterMax ) {
                                                        
                    VerifyAgt( 0x80000001, i );                
                    return false;
                }
                if( rightCounterMin > rightCounterMax ) {
                                                        
                    VerifyAgt( 0x80000002, i );                
                    return false;
                }                
            }
            
            if( leftCounterMax >= rightCounterMin ) {
                VerifyAgt( 0x80000009, i );            
                return false;
            }

            min = leftCounterMin;
            max = rightCounterMax;
            
            branchIndex = branchIndex / 2;
        }

        if( min != data.rootMin ) {
                                                            
            VerifyAgt( 0x80000003, min );                        
            return false;
        }
        if( max != data.rootMax ) {
                                                            
            VerifyAgt( 0x80000004, max );                    
            return false;
        }
        
        if( currentHash != data.rootHash ) {
                                                                              
            VerifyAgt( 0x80000005, currentHash );
            return false;
        }
        
        return true;
    }
    
    function verifyAgtDebugForTesting( uint rootHash,
                                       uint rootMin,
                                       uint rootMax,
                                       uint leafHash,
                                       uint leafCounter,
                                       uint branchIndex,
                                       uint[] countersBranch,
                                       uint[] hashesBranch ) returns(bool) {
                                       
        VerifyAgtData memory data;
        data.rootHash = rootHash;
        data.rootMin = rootMin;
        data.rootMax = rootMax;
        data.leafHash = leafHash;
        data.leafCounter = leafCounter;
        
        return verifyAgt( data, branchIndex, countersBranch, hashesBranch );
    }         
}

contract WeightedSubmission {
    function WeightedSubmission(){}
    
    struct SingleSubmissionData {
        uint128 numShares;
        uint128 submissionValue;
        uint128 totalPreviousSubmissionValue;
        uint128 min;
        uint128 max;
        uint128 augRoot;
    }
    
    struct SubmissionMetaData {
        uint64  numPendingSubmissions;
        uint32  readyForVerification;                      
        uint32  lastSubmissionBlockNumber;
        uint128 totalSubmissionValue;
        uint128 difficulty;
        uint128 lastCounter;
        
        uint    submissionSeed;
        
    }
    
    mapping(address=>SubmissionMetaData) submissionsMetaData;
    
                                      
    mapping(address=>mapping(uint=>SingleSubmissionData)) submissionsData;
    
    event SubmitClaim( address indexed sender, uint error, uint errorInfo );
    function submitClaim( uint numShares, uint difficulty, uint min, uint max, uint augRoot, bool lastClaimBeforeVerification ) {
        SubmissionMetaData memory metaData = submissionsMetaData[msg.sender];
        
        if( metaData.lastCounter >= min ) {
                                                    
            SubmitClaim( msg.sender, 0x81000001, metaData.lastCounter ); 
            return;        
        }
        
        if( metaData.readyForVerification > 0 ) {
                                                           
            SubmitClaim( msg.sender, 0x81000002, 0 ); 
            return;
        }
        
        if( metaData.numPendingSubmissions > 0 ) {
            if( metaData.difficulty != difficulty ) {
                                                                  
                SubmitClaim( msg.sender, 0x81000003, metaData.difficulty ); 
                return;            
            }
        }
        
        SingleSubmissionData memory submissionData;
        
        submissionData.numShares = uint64(numShares);
        uint blockDifficulty;
        if( block.difficulty == 0 ) {
                                                   
            blockDifficulty = (900000000 * (metaData.numPendingSubmissions+1)); 
        }
        else {
            blockDifficulty = block.difficulty;
        }
        
        submissionData.submissionValue = uint128((uint(numShares * difficulty) * (5 ether)) / blockDifficulty);
        
        submissionData.totalPreviousSubmissionValue = metaData.totalSubmissionValue;
        submissionData.min = uint128(min);
        submissionData.max = uint128(max);
        submissionData.augRoot = uint128(augRoot);
        
        (submissionsData[msg.sender])[metaData.numPendingSubmissions] = submissionData;
        
                           
        metaData.numPendingSubmissions++;
        metaData.lastSubmissionBlockNumber = uint32(block.number);
        metaData.difficulty = uint128(difficulty);
        metaData.lastCounter = uint128(max);
        metaData.readyForVerification = lastClaimBeforeVerification ? uint32(1) : uint32(0);

        uint128 temp128;
        
        
        temp128 = metaData.totalSubmissionValue; 

        metaData.totalSubmissionValue += submissionData.submissionValue;
        
        if( temp128 > metaData.totalSubmissionValue ) {
                                      
                                                                                   
                                                         
                                                                     
            SubmitClaim( msg.sender, 0x81000005, 0 ); 
            return;                                
        }
                
        
        submissionsMetaData[msg.sender] = metaData;
        
                           
        SubmitClaim( msg.sender, 0, numShares * difficulty );
    }

    function getClaimSeed(address sender) constant returns(uint){
        SubmissionMetaData memory metaData = submissionsMetaData[sender];
        if( metaData.readyForVerification == 0 ) return 0;
        
        if( metaData.submissionSeed != 0 ) return metaData.submissionSeed; 
        
        uint lastBlockNumber = uint(metaData.lastSubmissionBlockNumber);
        
        if( block.number > lastBlockNumber + 200 ) return 0;
        if( block.number <= lastBlockNumber + 15 ) return 0;
                
        return uint(block.blockhash(lastBlockNumber + 10));
    }
    
    event StoreClaimSeed( address indexed sender, uint error, uint errorInfo );
    function storeClaimSeed( address miner ) {
                                                                       
        uint seed = getClaimSeed( miner );
        if( seed != 0 ) {
            submissionsMetaData[miner].submissionSeed = seed;
            StoreClaimSeed( msg.sender, 0, uint(miner) );
            return;
        }
        
               
        SubmissionMetaData memory metaData = submissionsMetaData[miner];
        uint lastBlockNumber = uint(metaData.lastSubmissionBlockNumber);
                
        if( metaData.readyForVerification == 0 ) {
                                                       
            StoreClaimSeed( msg.sender, 0x8000000, uint(miner) );
        }
        else if( block.number > lastBlockNumber + 200 ) {
                                                       
            StoreClaimSeed( msg.sender, 0x8000001, uint(miner) );
        }
        else if( block.number <= lastBlockNumber + 15 ) {
                                                    
            StoreClaimSeed( msg.sender, 0x8000002, uint(miner) );
        }
        else {
                            
            StoreClaimSeed( msg.sender, 0x8000003, uint(miner) );
        }
    }

    function verifySubmissionIndex( address sender, uint seed, uint submissionNumber, uint shareIndex ) constant returns(bool) {
        if( seed == 0 ) return false;
    
        uint totalValue = uint(submissionsMetaData[sender].totalSubmissionValue);
        uint numPendingSubmissions = uint(submissionsMetaData[sender].numPendingSubmissions);

        SingleSubmissionData memory submissionData = (submissionsData[sender])[submissionNumber];        
        
        if( submissionNumber >= numPendingSubmissions ) return false;
        
        uint seed1 = seed & 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF;
        uint seed2 = seed / (2**128);
        
        uint selectedValue = seed1 % totalValue;
        if( uint(submissionData.totalPreviousSubmissionValue) >= selectedValue ) return false;
        if( uint(submissionData.totalPreviousSubmissionValue + submissionData.submissionValue) < selectedValue ) return false;  

        uint expectedShareshareIndex = (seed2 % uint(submissionData.numShares));
        if( expectedShareshareIndex != shareIndex ) return false;
        
        return true;
    }
    
    function calculateSubmissionIndex( address sender, uint seed ) constant returns(uint[2]) {
                                                                                 
        uint seed1 = seed & 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF;
        uint seed2 = seed / (2**128);

        uint totalValue = uint(submissionsMetaData[sender].totalSubmissionValue);
        uint numPendingSubmissions = uint(submissionsMetaData[sender].numPendingSubmissions);

        uint selectedValue = seed1 % totalValue;
        
        SingleSubmissionData memory submissionData;        
        
        for( uint submissionInd = 0 ; submissionInd < numPendingSubmissions ; submissionInd++ ) {
            submissionData = (submissionsData[sender])[submissionInd];        
            if( uint(submissionData.totalPreviousSubmissionValue + submissionData.submissionValue) >= selectedValue ) break;  
        }
        
                           
        if( submissionInd == numPendingSubmissions ) return [uint(0xFFFFFFFFFFFFFFFF),0xFFFFFFFFFFFFFFFF];

        uint shareIndex = seed2 % uint(submissionData.numShares); 
        
        return [submissionInd, shareIndex];
    }
    
                                              
    function closeSubmission( address sender ) internal {
        SubmissionMetaData memory metaData = submissionsMetaData[sender];
        metaData.numPendingSubmissions = 0;
        metaData.totalSubmissionValue = 0;
        metaData.readyForVerification = 0;
        metaData.submissionSeed = 0;
        
                                         
                                                                                          
                                        
        
        submissionsMetaData[sender] = metaData;
    }
    
    struct SubmissionDataForClaimVerification {
        uint lastCounter;
        uint shareDifficulty;
        uint totalSubmissionValue;
        uint min;
        uint max;
        uint augMerkle;
        
        bool indicesAreValid;
        bool readyForVerification;
    }
    
    function getClaimData( address sender, uint submissionIndex, uint shareIndex, uint seed )
                           constant internal returns(SubmissionDataForClaimVerification){
                           
        SubmissionDataForClaimVerification memory output;

        SubmissionMetaData memory metaData = submissionsMetaData[sender];
        
        output.lastCounter = uint(metaData.lastCounter);
        output.shareDifficulty = uint(metaData.difficulty);
        output.totalSubmissionValue = metaData.totalSubmissionValue;
        

        SingleSubmissionData memory submissionData = (submissionsData[sender])[submissionIndex];
        
        output.min = uint(submissionData.min);
        output.max = uint(submissionData.max);
        output.augMerkle = uint(submissionData.augRoot);
        
        output.indicesAreValid = verifySubmissionIndex( sender, seed, submissionIndex, shareIndex );
        output.readyForVerification = (metaData.readyForVerification > 0);
        
        return output; 
    }
    
    function debugGetNumPendingSubmissions( address sender ) constant returns(uint) {
        return uint(submissionsMetaData[sender].numPendingSubmissions);
    }
    
    event DebugResetSubmissions( address indexed sender, uint error, uint errorInfo );
    function debugResetSubmissions( ) {
                                             
                                                       
        closeSubmission(msg.sender);
        DebugResetSubmissions( msg.sender, 0, 0 );
    }    
}

contract SmartPool is Agt, WeightedSubmission {    
    string  public version = "0.1.1";
    
    Ethash  public ethashContract; 
    address public withdrawalAddress;
    mapping(address=>bool) public owners; 
    
    bool public newVersionReleased = false;
        
    struct MinerData {
        bytes32        minerId;
        address        paymentAddress;
    }

    mapping(address=>MinerData) minersData;
    mapping(bytes32=>bool)      public existingIds;        
    
    bool public whiteListEnabled;
    bool public blackListEnabled;
    mapping(address=>bool) whiteList;
    mapping(address=>bool) blackList;    
    
    function SmartPool( address[] _owners,
                        Ethash _ethashContract,
                        address _withdrawalAddress,
                        bool _whiteListEnabeled,
                        bool _blackListEnabled ) payable {
                        
        for( uint i = 0 ; i < _owners.length ; i++ ) {
            owners[_owners[0]] = true; 
            owners[_owners[1]] = true;
            owners[_owners[2]] = true;
        }
        
        ethashContract = _ethashContract;
        withdrawalAddress = _withdrawalAddress;
        
        whiteListEnabled = _whiteListEnabeled;
        blackListEnabled = _blackListEnabled;               
    }
    
    function declareNewerVersion() {
        if( ! owners[msg.sender] ) throw;
        
        newVersionReleased = true;
        
                                                      
    }
    
    event Withdraw( address indexed sender, uint error, uint errorInfo );
    function withdraw( uint amount ) {
        if( ! owners[msg.sender] ) {
                                       
            Withdraw( msg.sender, 0x80000000, amount );
            return;
        }
        
        if( ! withdrawalAddress.send( amount ) ) throw;
        
        Withdraw( msg.sender, 0, amount );            
    }
    
    function to62Encoding( uint id, uint numChars ) constant returns(bytes32) {
        if( id >= (26+26+10)**numChars ) throw;
        uint result = 0;
        for( uint i = 0 ; i < numChars ; i++ ) {
            uint b = id % (26+26+10);
            uint8 char;
            if( b < 10 ) {
                char = uint8(b + 0x30);               
            }
            else if( b < 26 + 10 ) {
                char = uint8(b + 0x61 - 10);             
            }
            else {
                char = uint8(b + 0x41 - 26 - 10);                       
            }
            
            result = (result * 256) + char;
            id /= (26+26+10);
        }

        return bytes32(result);
    }
        
    event Register( address indexed sender, uint error, uint errorInfo );    
    function register( address paymentAddress ) {
        address minerAddress = msg.sender;
        
                   
        uint id = uint(minerAddress) % (26+26+10)**11;        
        bytes32 minerId = to62Encoding(id,11);
        
        if( existingIds[minersData[minerAddress].minerId] ) {
                                         
            Register( msg.sender, 0x80000000, uint(minerId) ); 
            return;
        }
        
        if( paymentAddress == address(0) ) {
                                   
            Register( msg.sender, 0x80000001, uint(paymentAddress) ); 
            return;
        }
        
        if( whiteListEnabled ) {
            if( ! whiteList[ msg.sender ] ) {
                                          
                Register( msg.sender, 0x80000002, uint(minerId) );
                return;                 
            }
        }
        
        if( blackListEnabled ) {
            if( blackList[ msg.sender ] ) {
                                      
                Register( msg.sender, 0x80000003, uint(minerId) );
                return;                 
            }        
        }
        
        
        
                                     
                                                 
                                                               
        minersData[minerAddress].paymentAddress = paymentAddress;        
        minersData[minerAddress].minerId = minerId;
        existingIds[minersData[minerAddress].minerId] = true;
        
                                 
        Register( msg.sender, 0, 0 ); 
    }

    function canRegister(address sender) constant returns(bool) {
        uint id = uint(sender) % (26+26+10)**11;
        bytes32 expectedId = to62Encoding(id,11);
        
        if( whiteListEnabled ) {
            if( ! whiteList[ sender ] ) return false; 
        }
        if( blackListEnabled ) {
            if( blackList[ sender ] ) return false;        
        }
        
        return ! existingIds[expectedId];
    }
    
    function isRegistered(address sender) constant returns(bool) {
        return minersData[sender].paymentAddress != address(0);
    }
    
    function getMinerId(address sender) constant returns(bytes32) {
        return minersData[sender].minerId;
    }

    event UpdateWhiteList( address indexed miner, uint error, uint errorInfo, bool add );
    event UpdateBlackList( address indexed miner, uint error, uint errorInfo, bool add );    

    function unRegister( address miner ) internal {
        minersData[miner].paymentAddress = address(0);
        existingIds[minersData[miner].minerId] = false;            
    }
    
    function updateWhiteList( address miner, bool add ) {
        if( ! owners[ msg.sender ] ) {
                                         
            UpdateWhiteList( msg.sender, 0x80000000, 0, add );
            return;
        }
        if( ! whiteListEnabled ) {
                                         
            UpdateWhiteList( msg.sender, 0x80000001, 0, add );        
            return;
        }
        
        whiteList[ miner ] = add;
        if( ! add && isRegistered( miner ) ) {
                         
            unRegister( miner );
        }
        
        UpdateWhiteList( msg.sender, 0, uint(miner), add );
    }

    function updateBlackList( address miner, bool add ) {
        if( ! owners[ msg.sender ] ) {
                                         
            UpdateBlackList( msg.sender, 0x80000000, 0, add );
            return;
        }
        if( ! blackListEnabled ) {
                                         
            UpdateBlackList( msg.sender, 0x80000001, 0, add );        
            return;
        }
        
        blackList[ miner ] = add;
        if( add && isRegistered( miner ) ) {
                         
            unRegister( miner );
        }
        
        UpdateBlackList( msg.sender, 0, uint(miner), add );
    }
    
    event DisableBlackListForever( address indexed sender, uint error, uint errorInfo );    
    function disableBlackListForever() {
        if( ! owners[ msg.sender ] ) {
                                         
            DisableBlackListForever( msg.sender, 0x80000000, 0 );
            return;
        }
        
        blackListEnabled = false;
        
        DisableBlackListForever( msg.sender, 0, 0 );        
    }

    event DisableWhiteListForever( address indexed sender, uint error, uint errorInfo );
    function disableWhiteListForever() {
        if( ! owners[ msg.sender ] ) {
                                         
            DisableWhiteListForever( msg.sender, 0x80000000, 0 );
            return;
        }
        
        whiteListEnabled = false;
        
        DisableWhiteListForever( msg.sender, 0, 0 );            
    }
    
    event VerifyExtraData( address indexed sender, uint error, uint errorInfo );    
    function verifyExtraData( bytes32 extraData, bytes32 minerId, uint difficulty ) constant internal returns(bool) {
        uint i;
                     
        for( i = 0 ; i < 11 ; i++ ) {
            if( extraData[10+i] != minerId[21+i] ) {
                                                                             
                VerifyExtraData( msg.sender, 0x83000000, uint(minerId) );         
                return false;            
            }
        }
        
                             
        bytes32 encodedDiff = to62Encoding(difficulty,11);
        for( i = 0 ; i < 11 ; i++ ) {
            if(extraData[i+21] != encodedDiff[21+i]) {
                                                                                                  
                VerifyExtraData( msg.sender, 0x83000001, uint(encodedDiff) );
                return false;            
            }  
        }
                
        return true;            
    }    
    
    event VerifyClaim( address indexed sender, uint error, uint errorInfo );
    
        
    function verifyClaim( bytes rlpHeader,
                          uint  nonce,
                          uint  submissionIndex,
                          uint  shareIndex,
                          uint[] dataSetLookup,
                          uint[] witnessForLookup,
                          uint[] augCountersBranch,
                          uint[] augHashesBranch ) {

        if( ! isRegistered(msg.sender) ) {
                                      
            VerifyClaim( msg.sender, 0x8400000c, 0 );
            return;         
        }

        SubmissionDataForClaimVerification memory submissionData = getClaimData( msg.sender,
            submissionIndex, shareIndex, getClaimSeed( msg.sender ) ); 
                              
        if( ! submissionData.readyForVerification ) {
                                                           
            VerifyClaim( msg.sender, 0x84000003, 0 );            
            return;
        }
        
        BlockHeader memory header = parseBlockHeader(rlpHeader);

                           
        if( ! verifyExtraData( header.extraData,
                               minersData[ msg.sender ].minerId,
                               submissionData.shareDifficulty ) ) {
                                                                               
            VerifyClaim( msg.sender, 0x84000004, uint(header.extraData) );            
            return;                               
        }
        
                              
        if( header.coinbase != uint(this) ) {
                                                                            
            VerifyClaim( msg.sender, 0x84000005, uint(header.coinbase) );            
            return;
        }
         
        
                        
        uint counter = header.timestamp * (2 ** 64) + nonce;
        if( counter < submissionData.min ) {
                                                               
            VerifyClaim( msg.sender, 0x84000007, counter );            
            return;                         
        }
        if( counter > submissionData.max ) {
                                                               
            VerifyClaim( msg.sender, 0x84000008, counter );            
            return;                         
        }
        
                     
        uint leafHash = uint(sha3(rlpHeader));
        VerifyAgtData memory agtData;
        agtData.rootHash = submissionData.augMerkle;
        agtData.rootMin = submissionData.min;
        agtData.rootMax = submissionData.max;
        agtData.leafHash = leafHash;
        agtData.leafCounter = counter;
                

        if( ! verifyAgt( agtData,
                         shareIndex,
                         augCountersBranch,
                         augHashesBranch ) ) {
                                              
            VerifyClaim( msg.sender, 0x84000009, 0 );            
            return;
        }
                          
        
          
                                                   
                                                                             
                                                                             
                                                                                                      
                           
           


                        
        uint ethash = ethashContract.hashimoto( bytes32(leafHash),
                                                bytes8(nonce),
                                                dataSetLookup,
                                                witnessForLookup,
                                                header.blockNumber / 30000 );
        if( ethash > ((2**256-1)/submissionData.shareDifficulty )) {
            if( ethash == 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFE ) {
                                                                                 
                VerifyClaim( msg.sender, 0x8400000a, header.blockNumber / 30000 );                                        
            }
            else {
                                                                
                VerifyClaim( msg.sender, 0x8400000b, ethash );
            }            
            return;        
        }
        
        if( getClaimSeed(msg.sender) == 0 ) {
                                               
            VerifyClaim( msg.sender, 0x84000001, 0 );
            return;        
        }
        
        if( ! submissionData.indicesAreValid ) {
                                                                                                       
            VerifyClaim( msg.sender, 0x84000002, 0 );
            return;                
        } 
        
                                                                                    
        if( ! doPayment(submissionData.totalSubmissionValue,
                        minersData[ msg.sender ].paymentAddress) ) {
                                                       
            return;
        }
        
        closeSubmission( msg.sender );
                                                        
        
        
        VerifyClaim( msg.sender, 0, 0 );                        
        
        
        return;
    }    
    

                   
    uint public uncleRate = 500;      
                   
    uint public poolFees = 0;


    event IncomingFunds( address sender, uint amountInWei );
    function() payable {
        IncomingFunds( msg.sender, msg.value );
    }

    event SetUnlceRateAndFees( address indexed sender, uint error, uint errorInfo );
    function setUnlceRateAndFees( uint _uncleRate, uint _poolFees ) {
        if( ! owners[msg.sender] ) {
                                             
            SetUnlceRateAndFees( msg.sender, 0x80000000, 0 );
            return;
        }
        
        uncleRate = _uncleRate;
        poolFees = _poolFees;
        
        SetUnlceRateAndFees( msg.sender, 0, 0 );
    }
        
    event DoPayment( address indexed sender, address paymentAddress, uint valueInWei );
    function doPayment( uint submissionValue,
                        address paymentAddress ) internal returns(bool) {

        uint payment = submissionValue;
                                       
        
                                                 
                                 
        payment = (payment * (4*10000 - uncleRate)) / (4*10000);
        
               
        payment = (payment * (10000 - poolFees)) / 10000;

        if( payment > this.balance ){
                                                                                                                     
            VerifyClaim( msg.sender, 0x84000000, payment );        
            return false;
        }
                
        if( ! paymentAddress.send( payment ) ) throw;
        
        DoPayment( msg.sender, paymentAddress, payment ); 
        
        return true;
    }
    
    function getPoolETHBalance( ) constant returns(uint) {
                                     
        return this.balance;
    }

    event GetShareIndexDebugForTestRPCSubmissionIndex( uint index );    
    event GetShareIndexDebugForTestRPCShareIndex( uint index );
     
    function getShareIndexDebugForTestRPC( address sender ) {
        uint seed = getClaimSeed( sender );
        uint[2] memory result = calculateSubmissionIndex( sender, seed );
        
        GetShareIndexDebugForTestRPCSubmissionIndex( result[0] );
        GetShareIndexDebugForTestRPCShareIndex( result[1] );        
            
    }        
}