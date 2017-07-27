
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
    return Splitter.deployed().then(function(instance) {
      contract = instance;
    });
  });

  it('Should be owned by owner', function() {
    return contract.owner({ from: owner })
    .then(function(_owner) {
      assert.strictEqual(_owner, owner, 'Contract is not owned by owner');
    })
  });

  it('Should not accept contribute with value 0', function() {
    return contract.contribute({ from: externalContributor, value: 0 })
    .then(assert.fail)
    .catch(function(error) {
      assert(
        error.message.indexOf('Error: You have to send an amount higher than 0')
      )
    });
  });

  it('Should not accept change of contract state from other person that is not the owner', function() {
    return contract.seeParticipantsAddresses(1, { from: externalContributor })
    .then(assert.fail)
    .catch(function(error) {
      assert(
        error.message.indexOf('Error: You are not the owner of the contract')
      )
    });
  });

  it('Should amount of external contributor goes to the contract totally', async function() {
    let initialContractBalance = await web3.eth.getBalance(contract.address);
    await contract.contribute({ from: externalContributor, value: amountToContribute });

    let finalContractBalance = await web3.eth.getBalance(contract.address);

    //Data expected
    let expectedContractBalance = parseInt(initialContractBalance + amountToContribute);

    assert.equal(finalContractBalance, expectedContractBalance, 'Contribution is not in the contract totally');
  });

  it('Should not accept contribution from the owner if there are not at least 2 participants, the conyribution is returned to the owner', async function() {
    let initialOwnerBalance = await web3.eth.getBalance(owner).toString(10);
    let initialContractBalance = await web3.eth.getBalance(contract.address).toString(10);

    let txn = await contract.contribute({ from: owner, value: amountToContribute });
    
    let gasUsed = txn.receipt.gasUsed;
    let gasPrice = contract.constructor.class_defaults.gasPrice;
    let totalGasCost = gasUsed * gasPrice;

    let finalOwnerBalance = await web3.eth.getBalance(owner).toString(10);
    let finalContractBalance = await web3.eth.getBalance(contract.address).toString(10);

    //Data expected
    let expectedOwnerBalance = initialOwnerBalance - totalGasCost;

    assert.equal(finalContractBalance, initialContractBalance, `Contribution was not returned to the owner, the contract have it`);
    assert.equal(finalOwnerBalance, expectedOwnerBalance, `Contribution was not returned to the owner`);
  });

  it('Should add two participants to the contract, the owner makes a contribution, the contract does not hold the contribution and send the half of it to each participant', async function() {
    let initialNumberOfParticipants = await contract.getParticipantsCount({ from: owner });
    let initialContractBalance = await web3.eth.getBalance(contract.address).toString(10);
    let initialFirstParticipantBalance = await web3.eth.getBalance(addressOfParticipant1).toString(10);
    let initialSecondParticipantBalance = await web3.eth.getBalance(addressOfParticipant2).toString(10);

    await contract.addNewParticipantAccount(addressOfParticipant1);
    await contract.addNewParticipantAccount(addressOfParticipant2);

    await contract.contribute({ from: owner, value: amountToContribute });

    let finalNumberOfParticipants = await contract.getParticipantsCount({ from: owner });
    let finalFirstParticipantBalance = await web3.eth.getBalance(addressOfParticipant1).toString(10);
    let finalSecondParticipantBalance = await web3.eth.getBalance(addressOfParticipant2).toString(10);

    //Data expected
    let amountToEachAddress = amountToContribute / participantsCount;
    let expectedFirstParticipantBalance = initialFirstParticipantBalance - amountToEachAddress;
    let expectedSecondParticipantBalance = initialSecondParticipantBalance - amountToEachAddress;

    assert.equal(finalNumberOfParticipants, parseInt(initialNumberOfParticipants + 2), 'A new participant is not in the contract');
    assert.equal(finalFirstParticipantBalance, expectedFirstParticipantBalance, 'First participant does not receive the half of the contribution');
    assert.equal(finalSecondParticipantBalance, expectedSecondParticipantBalance, 'Second participant does not receive the half of the contribution');
  });

});
