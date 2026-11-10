contract ConstructHuntStart {
    
  struct Participant {
      address participantAddress;
      string name;
      string message;
  }
  
  mapping(address => Participant) public ParticipantList;
  address owner;
  string owner_name;
    
  function ConstructHuntStart() {
      owner = msg.sender;
      owner_name = "Hudson Jameson (a.k.a Souptacular)";
  }
  
  function getContractInfo() constant returns (string) {
      return "Visit WEBSITE for more info.";
  }
  
  function joinTheHunt (string inputName, string shoutOut) returns (string){
      ParticipantList[msg.sender] = Participant(msg.sender, inputName, shoutOut);
      return "Success!";
  }
  
  function getParticipantData (address inputAddy) constant returns (string, string) {
      Participant participantData = ParticipantList[inputAddy];
      return (participantData.name, participantData.message);
  }
  
}