contract DepositGovernanceFactory {
    
    function newDepositGovernance(uint _depositSize, address _poiContract, address _looperContract) returns (address) {
        return new DepositGovernance(_depositSize, _poiContract, _looperContract);
    }
    
}