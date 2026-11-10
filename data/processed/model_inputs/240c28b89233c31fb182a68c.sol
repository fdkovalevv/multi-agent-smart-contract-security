contract RaceFTW {
    
                    
    string disclaimer = "Copyright (c) 2016 \"The owner of this contract\" \nPermission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the \"Software\"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:\n\nThe above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.\n\nTHE SOFTWARE IS PROVIDED \"AS IS\", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.";
    
    function getDisclaimer() returns (string) {
        return disclaimer;
    }
    
    address lastContributor;
    uint fixedContribution = 10 finney;
    
    uint raceEnds = 0;
    
                                                                              
    uint RACE_LENGTH = 555555;
    
    event LastContributorChanged(address newWinner);
    
    function RaceFTW () {
        raceEnds = block.number + RACE_LENGTH;
    }
    
    function getRaceEndBlock() returns (uint) {
        return raceEnds;
    }
    
    function getCurrentWinner() returns (address) {
        return lastContributor;
    }
    
    function () {
                                  
        if (block.number > raceEnds) {
            throw;
        }
                                                     
        if (msg.value != fixedContribution) {
            throw;
        }
                               
        if (lastContributor != msg.sender) {
            LastContributorChanged(msg.sender);
        }
        
                                     
        lastContributor = msg.sender;
    }
    
    
    function claimReward() {
                                        
        if (msg.sender != lastContributor) {
            throw;
        }
                                        
        if (block.number < raceEnds) {
            throw;
        }
        if (this.balance > 0) {
            lastContributor.send(this.balance);
        }
    }
}