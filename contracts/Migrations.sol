// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;

contract ProductVerification {
    address public admin;
    mapping(address => bool) public users;
    mapping(uint => string) public products; // Store products by their ID
    uint public productCount;

    // Events to log actions
    event ProductAdded(uint productId, string productName);
    event UserAdded(address user);
    event UserRemoved(address user);

    constructor() {
        admin = msg.sender; // Admin is the contract deployer
        productCount = 0; // Initialize product count
    }

    // Modifier to restrict actions to the admin
    modifier onlyAdmin() {
        require(msg.sender == admin, "Only admin can perform this action");
        _;
    }

    // Add a new user (only admin can add users)
    function addUser(address userAddress) public onlyAdmin {
        users[userAddress] = true;
        emit UserAdded(userAddress);
    }

    // Remove a user (only admin can remove users)
    function removeUser(address userAddress) public onlyAdmin {
        users[userAddress] = false;
        emit UserRemoved(userAddress);
    }

    // Check if the address is a registered user
    function isUser(address userAddress) public view returns (bool) {
        return users[userAddress];
    }

    // Admin can add products
    function addProduct(string memory productName) public onlyAdmin {
        productCount++;
        products[productCount] = productName;
        emit ProductAdded(productCount, productName);
    }

    // Admin can view products by ID
    function viewProduct(uint productId) public view returns (string memory) {
        return products[productId];
    }
}
