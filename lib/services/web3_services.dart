import 'package:web3dart/web3dart.dart';
import 'package:http/http.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class Web3Service {
  late Web3Client _client;
  late String _rpcUrl;
  late String _contractAddress;
  
  static const String _contractABI = ''' [
    {
      "inputs": [
        {
          "internalType": "uint256",
          "name": "initialSupply",
          "type": "uint256"
        }
      ],
      "stateMutability": "nonpayable",
      "type": "constructor"
    },
    {
      "anonymous": false,
      "inputs": [
        {
          "indexed": true,
          "internalType": "address",
          "name": "owner",
          "type": "address"
        },
        {
          "indexed": true,
          "internalType": "address",
          "name": "spender",
          "type": "address"
        },
        {
          "indexed": false,
          "internalType": "uint256",
          "name": "value",
          "type": "uint256"
        }
      ],
      "name": "Approval",
      "type": "event"
    },
    {
      "anonymous": false,
      "inputs": [
        {
          "indexed": true,
          "internalType": "address",
          "name": "previousOwner",
          "type": "address"
        },
        {
          "indexed": true,
          "internalType": "address",
          "name": "newOwner",
          "type": "address"
        }
      ],
      "name": "OwnershipTransferred",
      "type": "event"
    },
    {
      "anonymous": false,
      "inputs": [
        {
          "indexed": true,
          "internalType": "address",
          "name": "from",
          "type": "address"
        },
        {
          "indexed": true,
          "internalType": "address",
          "name": "to",
          "type": "address"
        },
        {
          "indexed": false,
          "internalType": "uint256",
          "name": "value",
          "type": "uint256"
        }
      ],
      "name": "Transfer",
      "type": "event"
    },
    {
      "inputs": [
        {
          "internalType": "address",
          "name": "owner",
          "type": "address"
        },
        {
          "internalType": "address",
          "name": "spender",
          "type": "address"
        }
      ],
      "name": "allowance",
      "outputs": [
        {
          "internalType": "uint256",
          "name": "",
          "type": "uint256"
        }
      ],
      "stateMutability": "view",
      "type": "function",
      "constant": true
    },
    {
      "inputs": [
        {
          "internalType": "address",
          "name": "spender",
          "type": "address"
        },
        {
          "internalType": "uint256",
          "name": "amount",
          "type": "uint256"
        }
      ],
      "name": "approve",
      "outputs": [
        {
          "internalType": "bool",
          "name": "",
          "type": "bool"
        }
      ],
      "stateMutability": "nonpayable",
      "type": "function"
    },
    {
      "inputs": [
        {
          "internalType": "address",
          "name": "account",
          "type": "address"
        }
      ],
      "name": "balanceOf",
      "outputs": [
        {
          "internalType": "uint256",
          "name": "",
          "type": "uint256"
        }
      ],
      "stateMutability": "view",
      "type": "function",
      "constant": true
    },
    {
      "inputs": [],
      "name": "decimals",
      "outputs": [
        {
          "internalType": "uint8",
          "name": "",
          "type": "uint8"
        }
      ],
      "stateMutability": "view",
      "type": "function",
      "constant": true
    },
    {
      "inputs": [
        {
          "internalType": "address",
          "name": "spender",
          "type": "address"
        },
        {
          "internalType": "uint256",
          "name": "subtractedValue",
          "type": "uint256"
        }
      ],
      "name": "decreaseAllowance",
      "outputs": [
        {
          "internalType": "bool",
          "name": "",
          "type": "bool"
        }
      ],
      "stateMutability": "nonpayable",
      "type": "function"
    },
    {
      "inputs": [
        {
          "internalType": "address",
          "name": "spender",
          "type": "address"
        },
        {
          "internalType": "uint256",
          "name": "addedValue",
          "type": "uint256"
        }
      ],
      "name": "increaseAllowance",
      "outputs": [
        {
          "internalType": "bool",
          "name": "",
          "type": "bool"
        }
      ],
      "stateMutability": "nonpayable",
      "type": "function"
    },
    {
      "inputs": [],
      "name": "name",
      "outputs": [
        {
          "internalType": "string",
          "name": "",
          "type": "string"
        }
      ],
      "stateMutability": "view",
      "type": "function",
      "constant": true
    },
    {
      "inputs": [],
      "name": "owner",
      "outputs": [
        {
          "internalType": "address",
          "name": "",
          "type": "address"
        }
      ],
      "stateMutability": "view",
      "type": "function",
      "constant": true
    },
    {
      "inputs": [],
      "name": "renounceOwnership",
      "outputs": [],
      "stateMutability": "nonpayable",
      "type": "function"
    },
    {
      "inputs": [],
      "name": "symbol",
      "outputs": [
        {
          "internalType": "string",
          "name": "",
          "type": "string"
        }
      ],
      "stateMutability": "view",
      "type": "function",
      "constant": true
    },
    {
      "inputs": [],
      "name": "totalSupply",
      "outputs": [
        {
          "internalType": "uint256",
          "name": "",
          "type": "uint256"
        }
      ],
      "stateMutability": "view",
      "type": "function",
      "constant": true
    },
    {
      "inputs": [
        {
          "internalType": "address",
          "name": "from",
          "type": "address"
        },
        {
          "internalType": "address",
          "name": "to",
          "type": "address"
        },
        {
          "internalType": "uint256",
          "name": "amount",
          "type": "uint256"
        }
      ],
      "name": "transferFrom",
      "outputs": [
        {
          "internalType": "bool",
          "name": "",
          "type": "bool"
        }
      ],
      "stateMutability": "nonpayable",
      "type": "function"
    },
    {
      "inputs": [
        {
          "internalType": "address",
          "name": "newOwner",
          "type": "address"
        }
      ],
      "name": "transferOwnership",
      "outputs": [],
      "stateMutability": "nonpayable",
      "type": "function"
    },
    {
      "inputs": [
        {
          "internalType": "address",
          "name": "to",
          "type": "address"
        },
        {
          "internalType": "uint256",
          "name": "amount",
          "type": "uint256"
        }
      ],
      "name": "mint",
      "outputs": [],
      "stateMutability": "nonpayable",
      "type": "function"
    },
    {
      "inputs": [
        {
          "internalType": "address",
          "name": "to",
          "type": "address"
        },
        {
          "internalType": "uint256",
          "name": "amount",
          "type": "uint256"
        }
      ],
      "name": "transfer",
      "outputs": [
        {
          "internalType": "bool",
          "name": "",
          "type": "bool"
        }
      ],
      "stateMutability": "nonpayable",
      "type": "function"
    },
    {
      "inputs": [
        {
          "internalType": "address",
          "name": "account",
          "type": "address"
        }
      ],
      "name": "getBalance",
      "outputs": [
        {
          "internalType": "uint256",
          "name": "",
          "type": "uint256"
        }
      ],
      "stateMutability": "view",
      "type": "function",
      "constant": true
    }
  ]''';

  Web3Service() {
    _rpcUrl = dotenv.env['ALCHEMY_URL'] ?? 'https://eth-sepolia.g.alchemy.com/v2/JFNsnU50koQ_laIQrcTCP';
    _contractAddress = dotenv.env['CONTRACT_ADDRESS'] ?? '0xF5f97ed40f941416ADd40401CB864c7C08C72E6A';
    _client = Web3Client(_rpcUrl, Client());
  }

  // Tambahkan method untuk validasi address
  bool isValidAddress(String address) {
    try {
      // Cek apakah address memiliki format yang benar
      if (address.isEmpty) return false;
      
      // Hapus whitespace
      address = address.trim();
      
      // Cek apakah dimulai dengan 0x dan panjang 42 karakter
      if (address.startsWith('0x') && address.length == 42) {
        // Coba parse sebagai EthereumAddress
        EthereumAddress.fromHex(address);
        return true;
      }
      
      // Jika tidak dimulai dengan 0x tapi panjang 40 karakter
      if (!address.startsWith('0x') && address.length == 40) {
        // Coba parse dengan menambahkan 0x
        EthereumAddress.fromHex('0x$address');
        return true;
      }
      
      return false;
    } catch (e) {
      return false;
    }
  }

  // Normalize address format
  String normalizeAddress(String address) {
    address = address.trim();
    if (!address.startsWith('0x') && address.length == 40) {
      return '0x$address';
    }
    return address;
  }

  Future<String> getBalance(String address) async {
    try {
      // Validasi dan normalize address
      if (!isValidAddress(address)) {
        throw Exception('Invalid address format');
      }
      
      address = normalizeAddress(address);
      
      final contract = DeployedContract(
        ContractAbi.fromJson(_contractABI, 'SimpleToken'),
        EthereumAddress.fromHex(_contractAddress),
      );

      final balanceFunction = contract.function('balanceOf');
      final result = await _client.call(
        contract: contract,
        function: balanceFunction,
        params: [EthereumAddress.fromHex(address)],
      );

      BigInt balance = result.first;
      return balance.toString();
    } catch (e) {
      throw Exception('Error getting balance: $e');
    }
  }

  Future<String> transferToken(String privateKey, String toAddress, String amount) async {
    try {
      // Validasi private key
      if (privateKey.isEmpty) {
        throw Exception('Private key cannot be empty');
      }
      
      // Validasi dan normalize address
      if (!isValidAddress(toAddress)) {
        throw Exception('Invalid recipient address format. Address should be 40 characters long and optionally prefixed with 0x');
      }
      
      toAddress = normalizeAddress(toAddress);
      
      // Validasi amount
      if (amount.isEmpty) {
        throw Exception('Amount cannot be empty');
      }
      
      BigInt amountBigInt;
      try {
        amountBigInt = BigInt.parse(amount);
      } catch (e) {
        throw Exception('Invalid amount format');
      }
      
      if (amountBigInt <= BigInt.zero) {
        throw Exception('Amount must be greater than 0');
      }

      final credentials = EthPrivateKey.fromHex(privateKey);
      final contract = DeployedContract(
        ContractAbi.fromJson(_contractABI, 'SimpleToken'),
        EthereumAddress.fromHex(_contractAddress),
      );

      final transferFunction = contract.function('transfer');
      final transaction = Transaction.callContract(
        contract: contract,
        function: transferFunction,
        parameters: [
          EthereumAddress.fromHex(toAddress),
          amountBigInt,
        ],
      );

      final result = await _client.sendTransaction(
        credentials,
        transaction,
        chainId: 11155111, // Sepolia chain ID
      );

      return result;
    } catch (e) {
      throw Exception('Error transferring token: $e');
    }
  }

  Future<EthereumAddress> getAddressFromPrivateKey(String privateKey) async {
    try {
      if (privateKey.isEmpty) {
        throw Exception('Private key cannot be empty');
      }
      
      final credentials = EthPrivateKey.fromHex(privateKey);
      return credentials.address;
    } catch (e) {
      throw Exception('Invalid private key: $e');
    }
  }

  // Method tambahan untuk cek ETH balance (native currency)
  Future<String> getEthBalance(String address) async {
    try {
      if (!isValidAddress(address)) {
        throw Exception('Invalid address format');
      }
      
      address = normalizeAddress(address);
      
      final balance = await _client.getBalance(EthereumAddress.fromHex(address));
      return balance.getValueInUnit(EtherUnit.ether).toString();
    } catch (e) {
      throw Exception('Error getting ETH balance: $e');
    }
  }
}