
var Splitter = artifacts.require("./Splitter.sol");

contract('Splitter', function(accounts) {

  var contract;
  var owner = accounts[0];
  var amountEvenContributed = 10;
  var amountOddContributed = 11;
  var depositor = accounts[1];
  var addressOfApplicantOne = accounts[2];
  var addressOfApplicantTwo = accounts[3];
  var notCurrentApplicantAddress = accounts[4];

  beforeEach(function () {
    return Splitter.new({ from: owner })
    .then(function(instance) {
      contract = instance;
    });
  });

  it('Should not accept contribute with value 0', async function() {
    return contract.depositFunds(addressOfApplicantOne, addressOfApplicantTwo, { from: depositor, value: 0 })
    .then(assert.fail)
    .catch(function(error) {
      assert(
        error.message.indexOf('invalid JUMP')
      )
    });
  });

  it('Should not accept change of contract state from other person that is not the owner', function() {
    return contract.setContractState(true, { from: depositor })
    .then(assert.fail)
    .catch(function(error) {
      assert(
        error.message.indexOf('invalid JUMP')
      )
    });
  });

  it('Should not accept any interaction with the contract if its dead', async function() {
    await contract.setContractState(true, { from: owner });

    return contract.depositFunds(addressOfApplicantOne, addressOfApplicantTwo, { from: depositor, value: amountEvenContributed })
    .then(assert.fail)
    .catch(function(error) {
      assert(
        error.message.indexOf('invalid JUMP')
      )
    })
    .then(function(error) {
      return contract.withdrawFunds({ from: addressOfApplicantOne })
      .then(assert.fail)
      .catch(function(error) {
        assert(
          error.message.indexOf('invalid JUMP')
        )
      })
    });
  });

  it('Should reject a withdrawal if the requester is not a current participant of the contract', async function() {
    await contract.depositFunds(addressOfApplicantOne, addressOfApplicantTwo, { from: depositor, value: amountEvenContributed });

    return contract.withdrawFunds({ from: notCurrentApplicantAddress })
    .then(assert.fail)
    .catch(function(error) {
      assert(
        error.message.indexOf('invalid JUMP')
      )
    })
  });

  it('Should send the half of the amount deposited for each current applicant of the contract', async function() {
    let initialApplicantOneBalance = await web3.eth.getBalance(addressOfApplicantOne);
    let initialApplicantTwoBalance = await web3.eth.getBalance(addressOfApplicantTwo);

    let depositTxn = await contract.depositFunds(addressOfApplicantOne, addressOfApplicantTwo, { from: depositor, value: amountEvenContributed });
    let txnAmountDeposited = depositTxn.logs[0].args.amountDeposited;

    // Manage numbers if they are too big
    let expectedAmountForEachOne = web3.toBigNumber(txnAmountDeposited).div(2);
    // Withdraw funds
    let withdrawOneTxn = await contract.withdrawFunds({ from: addressOfApplicantOne });
    let withdrawTwoTxn = await contract.withdrawFunds({ from: addressOfApplicantTwo });
    let transactionReceipt = web3.eth.getTransaction(withdrawOneTxn.tx);

    //Calculate transaction gas
    let gasUsedTxn = web3.toBigNumber(withdrawOneTxn.receipt.gasUsed);
    let gasPrice = web3.toBigNumber(transactionReceipt.gasPrice);
    let totalTxnGas = gasPrice.times(gasUsedTxn);

    let finalFirstApplicantBalance = await web3.eth.getBalance(addressOfApplicantOne).toString(10);
    let finalSecondApplicantBalance = await web3.eth.getBalance(addressOfApplicantTwo).toString(10);

    let expectedFirstApplicantBalance = web3.toBigNumber(initialApplicantOneBalance).plus(expectedAmountForEachOne).minus(totalTxnGas);
    let expectedSecondApplicantBalance = web3.toBigNumber(initialApplicantTwoBalance).plus(expectedAmountForEachOne).minus(totalTxnGas);

    assert.equal(finalFirstApplicantBalance, expectedFirstApplicantBalance.toString(10), 'First applicant does not receive the half of the funds');
    assert.equal(finalSecondApplicantBalance, expectedSecondApplicantBalance.toString(10), 'Second applicant does not receive the half of the funds');
  });

  it('Should refund the remainder to the depositor if the value of the funds sent is an odd value', async function() {
    let initialDepositorBalance = await web3.eth.getBalance(depositor);

    let depositTxn = await contract.depositFunds(addressOfApplicantOne, addressOfApplicantTwo, { from: depositor, value: amountOddContributed });
    let txnAmountDeposited = web3.toBigNumber(depositTxn.logs[0].args.amountDeposited);
    let expectedAmountToRefund = web3.toBigNumber(depositTxn.logs[0].args.amountRefund);
    let transactionReceipt = web3.eth.getTransaction(depositTxn.tx);

    //Calculate transaction gas
    let gasUsedTxn = web3.toBigNumber(depositTxn.receipt.gasUsed);
    let gasPrice = web3.toBigNumber(transactionReceipt.gasPrice);
    let totalTxnGas = gasPrice.times(gasUsedTxn);

    let finalDepositorBalance = await web3.eth.getBalance(depositor).toString(10);

    let expectedDepositorBalance = web3.toBigNumber(initialDepositorBalance).minus(amountOddContributed).minus(totalTxnGas).plus(expectedAmountToRefund);

    assert.equal(finalDepositorBalance, expectedDepositorBalance.toString(10), 'First applicant does not receive the half of the funds');
  });

});
