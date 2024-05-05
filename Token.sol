// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
  /*
  @openzeppelin/contracts/token/ERC20/ERC20.sol: ERC20 contract from the OpenZeppelin library containing basic ERC-20 token functions.
  @openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol: ERC20Burnable extension that adds token burning functionality.
  @openzeppelin/contracts/access/Ownable.sol: Ownable contract to manage the owner of the contract.
  */
contract Token2 is ERC20, ERC20Burnable, Ownable {
  // Total Supply
  uint256 private constant _totalSupply = 500000000 * 10 ** 18;

  /* Control point of tokenPause
  (Indicates with a bool value whether token transactions have been stopped or not.)
  */
  bool private _paused = false;
  /* Roles for role-based access control
  (A mapping that stores what roles each address has.)
  */
enum Role { OWNER, ADMIN, USER }
  /* Roles for role-based access control
  (function assigns the administrator role to the first owner.)
  */
  mapping(address => Role) private _roles;

  // Events

  event TokenBurned(address burner, uint256 amount);
  event TokenPaused(address pauser);
  event TokenUnpaused(address unpauser);
  event RoleGranted(address recipient, Role role);
  event RoleRevoked(address recipient, Role role);
  /*
  Token Burning Function:

    The line function burn(uint256 amount) public override defines a function called burn. This functionality is inherited by ERC20Burnable.
    require(!_paused, "The contract is currently paused"); line ensures that token transactions are not stopped.
    super.burn(amount); line calls ERC20Burnable's burn function to burn the tokens.
    emit TokenBurned(msg.sender, amount); line broadcasts an event when a token is burned.

 Token Pause Function:

    function pause() public onlyAdmin line defines a function called pause. This function is only accessible by administrators.
    require(!_paused, "The contract has already been paused"); line ensures that token transactions are not already stopped.
    _paused = true; line sets the _paused variable to true to stop token transactions.
    emit TokenPaused(msg.sender); The line broadcasts an event when token transactions are stopped.

 Token Unpause Function:

    function unpause() public onlyAdmin line defines a function called unpause. This function is only accessible by administrators.
    require(_paused, "Contract is already running"); line ensures that token transactions have already been stopped.
    _paused = false; line sets the _paused variable to false to restart token operations.
    emit TokenUnpaused(msg.sender); line emits an event when token transactions are restarted.
  */

  // Constructor
  constructor(address initialOwner) ERC20("BToken", "B") Ownable(initialOwner) {
    _mint(initialOwner, _totalSupply);
    grantRole(initialOwner, Role.ADMIN);
  }

  uint256 public constant MAX_TRANSFER_AMOUNT = 100000 * 10 ** 18;




  // tokenBurn
  function burn(uint256 amount) public override {
    require(!_paused, "The contract is currently suspended");
    super.burn(amount);
    emit TokenBurned(msg.sender, amount);
  }

  // tokenPause
  function pause() public onlyAdmin {
    require(!_paused, "The contract has already been suspended");
    _paused = true;
    emit TokenPaused(msg.sender);
  }

  // tokenResume
  function unpause() public onlyAdmin {
    require(_paused, "The contract is already running");
    _paused = false;
    emit TokenUnpaused(msg.sender);
  }

  // Role Based System

  modifier onlyAdmin() {
    require(hasRole(Role.ADMIN, msg.sender), "Authorized access required");
    _;
  }

  // Role Grant

  function grantRole(address recipient, Role role) public onlyAdmin {
    require(!hasRole(role, recipient), "The recipient is already assigned this role");
    _roles[recipient] = role;
    emit RoleGranted(recipient, role);
  }

  // Role Revoke
  function revokeRole(address recipient, Role role) public onlyAdmin {
    require(hasRole(role, recipient), "The user is not assigned this role");
    _roles[recipient] = Role.OWNER; // Reset role to OWNER
    emit RoleRevoked(recipient, role);
  }

  // Role Control
  function hasRole(Role role, address account) public view returns (bool) {
    return _roles[account] == role;
  }

  //function _beforeTokenTransfer(address from, address to, uint256 amount) internal virtual override {
    // Transfer to zero address is blocked
   // require(to != address(0), "Recipient address cannot be zero");

    // Transfer from zero address is blocked
   // require(from != address(0), "Sender address cannot be zero");

    // Confirm token transfer
    // super._beforeTokenTransfer(from, to, amount);
/*
    if (!hasRole(msg.sender, Role.ADMIN)) {
            require(amount <= 1000 * 10 ** 18, "max 10");
}
*/
  }
