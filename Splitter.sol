// Splitter Contract Practice

pragma solidity ^0.4.6;

contract Splitter {
  address public owner;
  uint    public contractBalance;
  uint    public participantsCount;
  bool    public killSwitch = false;
  
  struct ParticipantStruct {
    address participantAddress;
    uint    participantAccountBalance;
  }
  
  ParticipantStruct[] public participantStructs;
  
  event LogContractBalance(uint contractBalanceAmount);
  event LogAccountBalance(string nameOfOwner, address ownerAddress, uint accountBalance);
  
  function Splitter() 
  {
    owner = msg.sender;
  }
  
  function seeContractBalance() 
    constant 
    returns(uint contractBalanceAmount)
  {
    LogContractBalance(this.balance);
    return this.balance;
  }
  
  function receiveContribution()
    public payable
    returns(string msgOfSuccessTransaction)
  {
    if(msg.value == 0) throw;
    if(msg.sender != owner) {
      contractBalance = this.balance + msg.value;
      return ('Your contribution goes to the contract, thanks');
    }
    
    participantsCount = participantStructs.length;
    if(participantsCount < 2)  return ('You have not set yet the participants of this contract');
    
    for(uint i = 0; i<participantsCount; i++){
      if(!participantStructs[i].participantAddress.send(msg.value/2)) throw;
    }
    return ('Your participants receive your contribution, thanks');
  }
  
  function seeAccountsBalances(uint _numberOfAccount) 
    constant 
    returns(string nameOfOwner, address ownerAddress, uint accountBalance) 
  {
    if(_numberOfAccount > 2 || _numberOfAccount <= 0) throw;
    participantsCount = participantStructs.length;
    
    if(_numberOfAccount == 1) {
      nameOfOwner = 'Owner';
      ownerAddress = owner;
      accountBalance = owner.balance;
    } else {
      nameOfOwner = 'Participant';
      ownerAddress = participantStructs[_numberOfAccount-1].participantAddress;
      accountBalance = participantStructs[_numberOfAccount-1].participantAccountBalance;
    }
    
    LogAccountBalance(nameOfOwner, ownerAddress, accountBalance);
    return (nameOfOwner, ownerAddress, accountBalance);
  }
  
  function setNewParticipantAccount(address _newParticipantAddress, uint _positionOfParticipant) 
    public 
    returns(bool success) 
  {
    if(msg.sender != owner) throw;
    if(_positionOfParticipant > 2 || _positionOfParticipant <= 0) throw;
    participantsCount = participantStructs.length;
    ParticipantStruct memory newParticipant;
    newParticipant.participantAddress = _newParticipantAddress;
    newParticipant.participantAccountBalance = 0;
    
    if(participantsCount < 2) {
      participantStructs.push(newParticipant);
    } else {
      participantStructs[_positionOfParticipant-1] = newParticipant;
    }
    
    return true;
  }
  
  function setKillSwitch(bool _stateOfContract)
    public 
    returns(string stateOfContract) 
  {
    if(msg.sender != owner) throw;
    killSwitch = _stateOfContract;
    if(!killSwitch) return 'Contract is dead now';
    else return 'Contract come alive again';
  }
}
