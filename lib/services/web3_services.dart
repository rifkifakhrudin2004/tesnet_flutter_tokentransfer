import 'package:web3dart/web3dart.dart';
import 'package:http/http.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class Web3Service {
  late Web3Client _client;
  late String _rpcUrl;
  late String _contractAddress;
  
  // Keep the existing contract ABI for token operations if needed
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
      if (address.isEmpty) return false;
      address = address.trim();
      
      if (address.startsWith('0x') && address.length == 42) {
        EthereumAddress.fromHex(address);
        return true;
      }
      
      if (!address.startsWith('0x') && address.length == 40) {
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

  // Method untuk transfer ETH Sepolia (native currency) - Version 2
  Future<String> transferETH(String privateKey, String toAddress, String amountInEther) async {
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
      if (amountInEther.isEmpty) {
        throw Exception('Amount cannot be empty');
      }
      
      double amountDouble;
      try {
        amountDouble = double.parse(amountInEther);
      } catch (e) {
        throw Exception('Invalid amount format');
      }
      
      if (amountDouble <= 0) {
        throw Exception('Amount must be greater than 0');
      }

      final credentials = EthPrivateKey.fromHex(privateKey);
      
      // Convert amount dari Ether ke Wei menggunakan BigInt
      // 1 ETH = 10^18 Wei
      final weiPerEth = BigInt.from(10).pow(18);
      final amountInWei = BigInt.from((amountDouble * 1000000000000000000).round());
      
      // Get current gas price dengan penanganan error yang lebih baik
      BigInt gasPriceWei;
      try {
        final gasPrice = await _client.getGasPrice();
        gasPriceWei = gasPrice.getInWei;
      } catch (e) {
        print('Failed to get gas price, using default: $e');
        // Fallback ke 20 Gwei
        gasPriceWei = BigInt.from(20) * BigInt.from(10).pow(9); // 20 Gwei in Wei
      }
      
      // Estimasi gas limit
      BigInt gasLimit;
      try {
        gasLimit = await _client.estimateGas(
          to: EthereumAddress.fromHex(toAddress),
          value: EtherAmount.inWei(amountInWei),
        );
        // Tambahkan buffer 20% untuk safety
        gasLimit = (gasLimit * BigInt.from(120)) ~/ BigInt.from(100);
      } catch (e) {
        print('Failed to estimate gas, using default: $e');
        gasLimit = BigInt.from(21000); // Standard gas limit untuk ETH transfer
      }
      
      // Buat transaction untuk transfer ETH
      final transaction = Transaction(
        to: EthereumAddress.fromHex(toAddress),
        gasPrice: EtherAmount.inWei(gasPriceWei),
        maxGas: gasLimit.toInt(),
        value: EtherAmount.inWei(amountInWei),
      );

      print('Sending transaction:');
      print('To: $toAddress');
      print('Amount: $amountInEther ETH (${amountInWei} Wei)');
      print('Gas Price: ${gasPriceWei} Wei');
      print('Gas Limit: ${gasLimit}');

      final result = await _client.sendTransaction(
        credentials,
        transaction,
        chainId: 11155111, // Sepolia chain ID
      );

      return result;
    } catch (e) {
      print('Full error: $e');
      throw Exception('Error transferring ETH: $e');
    }
  }

  // Method untuk cek ETH balance (native currency)
  Future<String> getEthBalance(String address) async {
    try {
      if (!isValidAddress(address)) {
        throw Exception('Invalid address format');
      }
      
      address = normalizeAddress(address);
      
      final balance = await _client.getBalance(EthereumAddress.fromHex(address));
      return balance.getValueInUnit(EtherUnit.ether).toStringAsFixed(6);
    } catch (e) {
      throw Exception('Error getting ETH balance: $e');
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

  // Method untuk mendapatkan gas price terkini
  Future<EtherAmount> getCurrentGasPrice() async {
    try {
      return await _client.getGasPrice();
    } catch (e) {
      // Fallback ke 20 Gwei jika gagal
      return EtherAmount.inWei(BigInt.from(20000000000));
    }
  }

  // Method untuk estimasi gas limit
  Future<BigInt> estimateGas(String toAddress, String amountInEther) async {
    try {
      final amountInWei = EtherAmount.fromUnitAndValue(EtherUnit.ether, double.parse(amountInEther));
      
      final gasEstimate = await _client.estimateGas(
        to: EthereumAddress.fromHex(normalizeAddress(toAddress)),
        value: amountInWei,
      );
      
      return gasEstimate;
    } catch (e) {
      // Fallback ke standard gas limit untuk ETH transfer
      return BigInt.from(21000);
    }
  }

  // EXISTING TOKEN METHODS (keep these if you still want token functionality)
  
  Future<String> getBalance(String address) async {
    try {
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
      throw Exception('Error getting token balance: $e');
    }
  }

  Future<String> transferToken(String privateKey, String toAddress, String amount) async {
    try {
      if (privateKey.isEmpty) {
        throw Exception('Private key cannot be empty');
      }
      
      if (!isValidAddress(toAddress)) {
        throw Exception('Invalid recipient address format');
      }
      
      toAddress = normalizeAddress(toAddress);
      
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
        chainId: 11155111,
      );

      return result;
    } catch (e) {
      throw Exception('Error transferring token: $e');
    }
  }
}