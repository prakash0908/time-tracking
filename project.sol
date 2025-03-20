// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract TimeTracking {

    struct Task {
        uint256 id;
        string description;
        uint256 totalTimeSpent;  // Time in seconds
        uint256 startTime;
        bool isActive;
        address owner;
    }

    uint256 public taskCounter;
    mapping(uint256 => Task) public tasks;
    mapping(address => uint256[]) public userTasks;

    event TaskCreated(uint256 taskId, string description, address owner);
    event TaskStarted(uint256 taskId, uint256 startTime);
    event TaskStopped(uint256 taskId, uint256 totalTimeSpent);
    event TaskUpdated(uint256 taskId, string description);

    modifier onlyOwner(uint256 _taskId) {
        require(msg.sender == tasks[_taskId].owner, "Only the owner can update this task");
        _;
    }

    modifier taskExists(uint256 _taskId) {
        require(tasks[_taskId].id != 0, "Task does not exist");
        _;
    }

    modifier taskIsActive(uint256 _taskId) {
        require(tasks[_taskId].isActive == true, "Task is not active");
        _;
    }

    modifier taskIsNotActive(uint256 _taskId) {
        require(tasks[_taskId].isActive == false, "Task is already active");
        _;
    }

    // Create a new task
    function createTask(string memory _description) external {
        taskCounter++;
        uint256 taskId = taskCounter;

        tasks[taskId] = Task({
            id: taskId,
            description: _description,
            totalTimeSpent: 0,
            startTime: 0,
            isActive: false,
            owner: msg.sender
        });

        userTasks[msg.sender].push(taskId);

        emit TaskCreated(taskId, _description, msg.sender);
    }

    // Start a task (start time tracking)
    function startTask(uint256 _taskId) external onlyOwner(_taskId) taskIsNotActive(_taskId) taskExists(_taskId) {
        Task storage task = tasks[_taskId];
        task.startTime = block.timestamp;
        task.isActive = true;

        emit TaskStarted(_taskId, task.startTime);
    }

    // Stop a task (stop time tracking)
    function stopTask(uint256 _taskId) external onlyOwner(_taskId) taskIsActive(_taskId) taskExists(_taskId) {
        Task storage task = tasks[_taskId];
        uint256 timeSpent = block.timestamp - task.startTime;
        task.totalTimeSpent += timeSpent;
        task.isActive = false;

        emit TaskStopped(_taskId, task.totalTimeSpent);
    }

    // Update the description of a task
    function updateTaskDescription(uint256 _taskId, string memory _description) external onlyOwner(_taskId) taskExists(_taskId) {
        tasks[_taskId].description = _description;

        emit TaskUpdated(_taskId, _description);
    }

    // Get details of a task
    function getTaskDetails(uint256 _taskId) external view taskExists(_taskId) returns (Task memory) {
        return tasks[_taskId];
    }

    // Get all tasks of a user
    function getUserTasks(address _user) external view returns (uint256[] memory) {
        return userTasks[_user];
    }
}
