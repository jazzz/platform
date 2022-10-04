// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

import '@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol';
import './interfaces/IOwnable.sol';

contract ChainJetRunner is OwnableUpgradeable {
    struct Task {
        address addr;
        address owner;
    }

    mapping(address => Task) public tasks;
    mapping(address => uint256) public balances;
    mapping(address => bool) public whitelist; // whitelisted network operators
    uint256 public gasOverhead = 42840;

    event TaskEnabled(address indexed task, address indexed owner);
    event TaskDisabled(address indexed task);
    event Deposit(address indexed sender, uint256 amount);
    event Withdraw(address indexed sender, uint256 amount);
    event Run(address indexed task, uint256 etherUsed);
    event SetWhitelist(address indexed operator, bool status);

    modifier onlyWhitelisted() {
        require(whitelist[msg.sender], 'onlyWhitelisted: caller is not whitelisted');
        _;
    }

    function initialize() external initializer {
        whitelist[msg.sender] = true;
        __Ownable_init();
    }

    function enableTask(address _task) external payable {
        require(IOwnable(_task).owner() == msg.sender, 'enableTask: caller is not the owner');
        require(tasks[_task].addr == address(0), 'enableTask: task already enabled');
        if (msg.value > 0) {
            balances[msg.sender] += msg.value;
            emit Deposit(msg.sender, msg.value);
        }
        require(balances[msg.sender] > 0, 'enableTask: no balance');
        tasks[_task] = Task({addr: _task, owner: msg.sender});
        emit TaskEnabled(_task, msg.sender);
    }

    function disableTask(address _task) external {
        require(tasks[_task].addr != address(0), 'disableTask: task not enabled');
        require(tasks[_task].owner == msg.sender, 'disableTask: caller is not the owner');
        delete tasks[_task];
        emit TaskDisabled(_task);
    }

    function deposit() external payable {
        balances[msg.sender] += msg.value;
        emit Deposit(msg.sender, msg.value);
    }

    function withdraw(uint256 _amount) external {
        require(balances[msg.sender] >= _amount, 'withdraw: insufficient balance');
        balances[msg.sender] -= _amount;
        payable(msg.sender).transfer(_amount);
        emit Withdraw(msg.sender, _amount);
    }

    function run(address _task, bytes memory _data)
        external
        onlyWhitelisted
        returns (bool success, bytes memory returndata)
    {
        uint256 startGas = gasleft();
        Task memory task = tasks[_task];
        require(task.addr != address(0), 'run: task not enabled');
        (success, returndata) = _task.call(_data);
        uint256 etherUsed = (gasOverhead + (startGas - gasleft())) * tx.gasprice;
        require(balances[task.owner] >= etherUsed, 'run: insufficient balance');
        balances[task.owner] -= etherUsed;
        payable(msg.sender).transfer(etherUsed);
        emit Run(_task, etherUsed);
        return (success, returndata);
    }

    function setWhitelist(address _addr, bool _whitelisted) external onlyOwner {
        whitelist[_addr] = _whitelisted;
        emit SetWhitelist(_addr, _whitelisted);
    }

    function setGasOverhead(uint256 _gasOverhead) external onlyOwner {
        gasOverhead = _gasOverhead;
    }
}
