
var Splitter = artifacts.require("./Splitter.sol");

contract('Splitter', function(accounts) {

  var contract;
  var owner = accounts[0];
  var amountToContribute = 10;
  var participantsCount = 2;
  var externalContributor = accounts[1];
  var addressOfParticipant1 = accounts[2];
  var addressOfParticipant2 = accounts[3];

  beforeEach(function () {
    return Splitter.new({ from: owner })
    .then(function(instance) {
      contract = instance;
    });
  });

  it('Should not accept contribute with value 0', async function() {
    return contract.contribute({ from: externalContributor, value: 0 })
    .then(assert.fail)
    .catch(function(error) {
      assert(
        error.message.indexOf('invalid JUMP')
      )
    });
  });

  it('Should not accept change of contract state from other person that is not the owner', function() {
    return contract.setContractState(true, { from: externalContributor })
    .then(assert.fail)
    .catch(function(error) {
      assert(
        error.message.indexOf('invalid JUMP')
      )
    });
  });

  it('Should amount of external contributor goes to the contract totally', async function() {
    let initialContractBalance = await web3.eth.getBalance(contract.address);
    let txn = await contract.contribute({ from: externalContributor, value: amountToContribute });
    console.log(txn);

    let finalContractBalance = await web3.eth.getBalance(contract.address);

    //Data expected
    let expectedContractBalance = parseInt(initialContractBalance + amountToContribute);

    assert.equal(finalContractBalance, expectedContractBalance, 'Contribution is not in the contract totally');
  });

  it('Should not accept contribution from the owner if there are not at least 2 participants', async function() {
    return contract.contribute({ from: owner, value: amountToContribute })
    .then(assert.fail)
    .catch(function(error) {
      assert(
        error.message.indexOf('invalid JUMP')
      )
    });
  });

  it('Should add two participants to the contract, the owner makes a contribution, the contract does not hold the contribution and send the half of it to each participant', async function() {
    let initialContractBalance = await web3.eth.getBalance(contract.address).toString(10);
    let initialFirstParticipantBalance = await web3.eth.getBalance(addressOfParticipant1).toString(10);
    let initialSecondParticipantBalance = await web3.eth.getBalance(addressOfParticipant2).toString(10);

    await contract.addTwoParticipantsAccounts(addressOfParticipant1, addressOfParticipant2);
    await contract.contribute({ from: owner, value: amountToContribute });

    let finalFirstParticipantBalance = await web3.eth.getBalance(addressOfParticipant1).toString(10);
    let finalSecondParticipantBalance = await web3.eth.getBalance(addressOfParticipant2).toString(10);

    //Data expected
    let participantsEstablished = await contract.participantsEstablished({ from: owner });
    let amountToEachAddress = amountToContribute / participantsCount;
    let expectedFirstParticipantBalance = initialFirstParticipantBalance - amountToEachAddress;
    let expectedSecondParticipantBalance = initialSecondParticipantBalance - amountToEachAddress;

    assert.equal(participantsEstablished, true, 'Participants are not established');
    assert.equal(finalFirstParticipantBalance, expectedFirstParticipantBalance, 'First participant does not receive the half of the contribution');
    assert.equal(finalSecondParticipantBalance, expectedSecondParticipantBalance, 'Second participant does not receive the half of the contribution');
  });

});
