contract ProofOfIndividuality {
    
        address ResilienceContract;

        struct Human {
            string name;
            address account;
        }
        
        Human[] public Humans;
        mapping(address => uint) public HumansIndex;
        
        mapping(address => bool) public POI;
        
        function ProofOfIndividuality() {
            Humans.length++;
            Humans[0] = Human({
                name: '', 
                account: 0
            });        
        }
        
        function setPOI(address account, bool hasPOI) internal {
            POI[account] = hasPOI;
        }
        
        function addYourself(string _name) public {

            address simulatePathwayFromMe = new simulatePathwayFromX(ResilienceContract);
            
            HumansIndex[simulatePathwayFromMe] = Humans.length;

            Humans.push(Human({
                name: _name, 
                account: simulatePathwayFromMe
            }));
            
            setPOI(simulatePathwayFromMe, true);
        }
        
        function verifyPOI(address _POIholder) external returns (bool isHuman) { 
            return POI[_POIholder];
        }
        
        function setResilienceContract(address _ResilienceContract) {
            if(ResilienceContract != 0) throw;
            ResilienceContract = _ResilienceContract;
        }
        
}