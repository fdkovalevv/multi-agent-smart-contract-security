contract ProofOfIndividuality {
    
        address ResilienceContract;

        struct Human {
            string name;
            address account;
            address simulatePathwayFromMe;
        }
        
        Human[] public Humans;
        mapping(address => uint) public HumansIndex;
        
        mapping(address => bool) public POI;
        
        function ProofOfIndividuality() {
            Humans.length++;
            Humans[0] = Human({
                name: '', 
                account: 0,
                simulatePathwayFromMe: 0
            });        
        }
        
        function setPOI(bool hasPOI) internal {
            POI[msg.sender] = hasPOI;
        }
        
        function addYourself(string _name) public {
            if(HumansIndex[msg.sender] != 0) throw;

            HumansIndex[msg.sender] = Humans.length;
            
            address simulatePathwayFromMe = new simulatePathwayFromX(ResilienceContract);
            
            Humans.push(Human({
                name: _name, 
                account: msg.sender,
                simulatePathwayFromMe: simulatePathwayFromMe
            }));
            
            setPOI(true);
        }

        function removeYourself() public {
            uint index = HumansIndex[msg.sender];
            HumansIndex[msg.sender] = 0;
            delete Humans[index];
            for (uint i = index; i < Humans.length - 1; i++) {
                Humans[i] = Humans[i + 1];
                HumansIndex[Humans[i].account] = i;
            }
            Humans.length--;
            setPOI(false);
        }
        
        function verifyPOI(address _POIholder) external returns (bool isHuman) { 
            return POI[_POIholder];
        }
        
        function setResilienceContract(address _ResilienceContract) {
            if(ResilienceContract != 0) throw;
            ResilienceContract = _ResilienceContract;
        }
        
}