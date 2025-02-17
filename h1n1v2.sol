/**
 *Submitted for verification at basescan.org on 2025-02-09
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract H1N1 {
    string public name = "H1N1";
    string public symbol = "H1N1";
    uint8 public decimals = 18;
    uint256 public globalSupply = 1 * 10 ** uint256(decimals); // Offre initiale de 1 token
    uint256 public infectionMultiplier = 2; // Facteur exponentiel initial
    uint256 public maxSupply = 1_000_000_000 * 10 ** uint256(decimals); // Limite d'offre totale

    mapping(address => uint256) public balances;
    mapping(address => bool) public hasClaimed; // Suivi des utilisateurs ayant réclamé leur 1er token
    mapping(address => mapping(address => uint256)) public allowances; // Autorisations des tokens

    event Transfer(address indexed from, address indexed to, uint256 value);
    event TokensCreated(uint256 newTokens, address indexed recipient);
    event IntroTokenClaimed(address indexed user);
    event Approval(address indexed owner, address indexed spender, uint256 value);

    constructor() {
        balances[msg.sender] = globalSupply;
    }

    function transfer(address recipient, uint256 amount) public returns (bool) {
        require(recipient != address(0), "Invalid recipient address");
        require(balances[msg.sender] >= amount, "Insufficient balance");

        balances[msg.sender] -= amount;
        balances[recipient] += amount;
        emit Transfer(msg.sender, recipient, amount);

        // Ajustement du ratio pour atteindre maxSupply en environ 1000 transactions
        uint256 newTokens = amount * infectionMultiplier / 1000;
        if (globalSupply + newTokens <= maxSupply) {
            globalSupply += newTokens;
            balances[recipient] += newTokens;
            infectionMultiplier += 1; // Augmente progressivement
            emit TokensCreated(newTokens, recipient);
        }

        return true;
    }

    function balanceOf(address account) public view returns (uint256) {
        return balances[account];
    }

    function totalSupply() public view returns (uint256) {
        return globalSupply;
    }

    // Fonction pour réclamer 1 H1N1 lors de la première interaction
    function claimIntroToken() public {
        require(!hasClaimed[msg.sender], "Already claimed");
        require(globalSupply + 1 * 10 ** uint256(decimals) <= maxSupply, "Max supply reached");

        hasClaimed[msg.sender] = true;
        balances[msg.sender] += 1 * 10 ** uint256(decimals);
        globalSupply += 1 * 10 ** uint256(decimals);
        emit IntroTokenClaimed(msg.sender);
    }

    // Fonction d'approbation permettant à un utilisateur de donner l'autorisation d'utiliser ses tokens
    function approve(address spender, uint256 amount) public returns (bool) {
        allowances[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);
        return true;
    }

    // Vérifier l'autorisation donnée par un propriétaire à un spender
    function allowance(address owner, address spender) public view returns (uint256) {
        return allowances[owner][spender];
    }

    // Fonction de transfert depuis un autre compte si autorisé
    function transferFrom(address sender, address recipient, uint256 amount) public returns (bool) {
        require(allowances[sender][msg.sender] >= amount, "Allowance exceeded");
        require(balances[sender] >= amount, "Insufficient balance");

        balances[sender] -= amount;
        balances[recipient] += amount;
        allowances[sender][msg.sender] -= amount;
        emit Transfer(sender, recipient, amount);
        return true;
    }
}
