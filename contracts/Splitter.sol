// Splitter Contract Practice

pragma solidity ^0.4.6;

contract Splitter {
  address public owner;
  uint    public participantsCount;
  bool    public contractDead;
  
  struct ParticipantStruct {
    address participantAddress;
  }
  
  ParticipantStruct[] public participantStructs;
  
  event LogContractState(address contractAddress, bool isContractDead);
  event LogParticipantsCount(uint newParticipantsCount);
  event LogAccountBalance(address ownerAddress, uint accountBalance);
  event LogOwnerBalance(address ownerAddress, uint ownerAccountBalance);
  
  function Splitter() {
    owner = msg.sender;
  }
  
  function contribute()
    public payable
    returns(bool successTransaction)
  {
    if(contractDead) throw;
    if(msg.value == 0) throw;
    if(msg.sender != owner) {
      LogContractState(this, contractDead);
      return true;
    }
    
    participantsCount = participantStructs.length;
    if(participantsCount < 2) {
      if(!owner.send(msg.value)) throw;
      LogOwnerBalance(owner, owner.balance);
      return false;
    }
    
    for(uint i = 0; i<2; i++){
      if(!participantStructs[i].participantAddress.send(msg.value/participantsCount)) throw;
      LogAccountBalance(participantStructs[i].participantAddress, participantStructs[i].participantAddress.balance);
    }
    return true;
  }
  
  function seeParticipantsAddresses(uint indexOfParticipant) constant returns (address participantAddress) {
    if(contractDead) throw;
    return participantStructs[indexOfParticipant].participantAddress;
  }
  
  function getParticipantsCount() public constant returns(uint actualParticipantsCount) {
    if(contractDead) throw;
    
    participantsCount = participantStructs.length;
    LogParticipantsCount(participantsCount);
    return participantsCount;
  }
  
  function addNewParticipantAccount(address newParticipantAddress) 
    public 
    returns(bool participantAdded) 
  {
    if(contractDead) throw;
    if(msg.sender != owner) throw;
    
    ParticipantStruct memory newParticipant;
    newParticipant.participantAddress = newParticipantAddress;
    participantStructs.push(newParticipant);
    return true;
  }
  
  function setContractState(bool stateOfContract) public returns(bool isContractAlive) {
    if(msg.sender != owner) throw;
    contractDead = stateOfContract;
    LogContractState(this, contractDead);
    if(contractDead) return false;
    else return true;
  }
}