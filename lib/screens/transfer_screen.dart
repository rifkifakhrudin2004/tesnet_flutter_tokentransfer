import 'package:flutter/material.dart';
import 'package:web3dart/web3dart.dart';
import 'package:token_transfer_flutter/services/web3_services.dart';

class TransferScreen extends StatefulWidget {
  @override
  _TransferScreenState createState() => _TransferScreenState();
}

class _TransferScreenState extends State<TransferScreen> {
  final Web3Service _web3Service = Web3Service();
  final TextEditingController _toAddressController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _privateKeyController = TextEditingController();
  
  String _ethBalance = '0';
  String _tokenBalance = '0';
  String _currentAddress = '';
  bool _isLoading = false;
  bool _isTransferringETH = true; 

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Crypto Transfer'),
        backgroundColor: Colors.blue,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Private Key Section
            Card(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    TextField(
                      controller: _privateKeyController,
                      decoration: InputDecoration(
                        labelText: 'Private Key',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.key),
                      ),
                      obscureText: true,
                      onChanged: (value) => _updateAddress(),
                    ),
                    SizedBox(height: 16),
                    if (_currentAddress.isNotEmpty)
                      Container(
                        padding: EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          'Current Address: $_currentAddress',
                          style: TextStyle(fontSize: 12, fontFamily: 'monospace'),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            
            SizedBox(height: 16),
            
            // Balance Section
            Card(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Text(
                      'Account Balance',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: Container(
                            padding: EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.blue[50],
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.blue[200]!),
                            ),
                            child: Column(
                              children: [
                                Text('ETH Balance', style: TextStyle(fontWeight: FontWeight.bold)),
                                Text('$_ethBalance ETH', style: TextStyle(fontSize: 16)),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(width: 16),
                        Expanded(
                          child: Container(
                            padding: EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.green[50],
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.green[200]!),
                            ),
                            child: Column(
                              children: [
                                Text('Token Balance', style: TextStyle(fontWeight: FontWeight.bold)),
                                Text('$_tokenBalance STK', style: TextStyle(fontSize: 16)),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _isLoading ? null : _checkBalance,
                      child: _isLoading 
                        ? CircularProgressIndicator() 
                        : Text('Check Balance'),
                    ),
                  ],
                ),
              ),
            ),
            
            SizedBox(height: 16),
            
            // Transfer Type Toggle
            Card(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Text(
                      'Transfer Type',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () => setState(() => _isTransferringETH = true),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _isTransferringETH ? Colors.blue : Colors.grey[300],
                              foregroundColor: _isTransferringETH ? Colors.white : Colors.black,
                            ),
                            child: Text('Transfer ETH'),
                          ),
                        ),
                        SizedBox(width: 16),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () => setState(() => _isTransferringETH = false),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: !_isTransferringETH ? Colors.green : Colors.grey[300],
                              foregroundColor: !_isTransferringETH ? Colors.white : Colors.black,
                            ),
                            child: Text('Transfer Token'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            
            SizedBox(height: 16),
            
            // Transfer Section
            Card(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Text(
                      _isTransferringETH ? 'Transfer ETH Sepolia' : 'Transfer Tokens',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 16),
                    TextField(
                      controller: _toAddressController,
                      decoration: InputDecoration(
                        labelText: 'To Address',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.account_balance_wallet),
                      ),
                    ),
                    SizedBox(height: 16),
                    TextField(
                      controller: _amountController,
                      decoration: InputDecoration(
                        labelText: _isTransferringETH ? 'Amount (ETH)' : 'Amount (STK)',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.monetization_on),
                        helperText: _isTransferringETH 
                          ? 'Enter amount in ETH (e.g., 0.01)' 
                          : 'Enter amount in tokens',
                      ),
                      keyboardType: TextInputType.numberWithOptions(decimal: true),
                    ),
                    SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _isLoading ? null : (_isTransferringETH ? _transferETH : _transferToken),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _isTransferringETH ? Colors.blue : Colors.green,
                        padding: EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: _isLoading 
                        ? CircularProgressIndicator() 
                        : Text(_isTransferringETH ? 'Transfer ETH' : 'Transfer Tokens'),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _updateAddress() {
    try {
      if (_privateKeyController.text.isNotEmpty) {
        _web3Service.getAddressFromPrivateKey(_privateKeyController.text).then((address) {
          setState(() {
            _currentAddress = address.hex;
          });
        }).catchError((error) {
          setState(() {
            _currentAddress = '';
          });
        });
      }
    } catch (e) {
      setState(() {
        _currentAddress = '';
      });
    }
  }

  Future<void> _checkBalance() async {
    if (_privateKeyController.text.isEmpty) {
      _showError('Please enter private key');
      return;
    }

    setState(() => _isLoading = true);
    try {
      final address = await _web3Service.getAddressFromPrivateKey(_privateKeyController.text);
      
      // Get ETH balance
      final ethBalance = await _web3Service.getEthBalance(address.hex);
      
      // Get Token balance
      final tokenBalance = await _web3Service.getBalance(address.hex);
      
      setState(() {
        _ethBalance = ethBalance;
        _tokenBalance = tokenBalance;
      });
      
      _showSuccess('Balance updated successfully');
    } catch (e) {
      _showError('Error checking balance: ${e.toString()}');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _transferETH() async {
    if (_privateKeyController.text.isEmpty) {
      _showError('Please enter private key');
      return;
    }
    
    if (_toAddressController.text.isEmpty) {
      _showError('Please enter recipient address');
      return;
    }
    
    if (_amountController.text.isEmpty) {
      _showError('Please enter amount');
      return;
    }

    // Validasi amount untuk ETH
    double amount;
    try {
      amount = double.parse(_amountController.text);
      if (amount <= 0) {
        _showError('Amount must be greater than 0');
        return;
      }
    } catch (e) {
      _showError('Invalid amount format');
      return;
    }

    setState(() => _isLoading = true);
    try {
      final result = await _web3Service.transferETH(
        _privateKeyController.text,
        _toAddressController.text,
        _amountController.text,
      );
      
      _showSuccess('ETH Transfer successful!\nTransaction Hash: $result');
      
      // Clear form
      _toAddressController.clear();
      _amountController.clear();
      
      // Refresh balance
      await _checkBalance();
    } catch (e) {
      _showError('ETH Transfer failed: ${e.toString()}');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _transferToken() async {
    if (_privateKeyController.text.isEmpty) {
      _showError('Please enter private key');
      return;
    }
    
    if (_toAddressController.text.isEmpty) {
      _showError('Please enter recipient address');
      return;
    }
    
    if (_amountController.text.isEmpty) {
      _showError('Please enter amount');
      return;
    }

    setState(() => _isLoading = true);
    try {
      final result = await _web3Service.transferToken(
        _privateKeyController.text,
        _toAddressController.text,
        _amountController.text,
      );
      
      _showSuccess('Token Transfer successful!\nTransaction Hash: $result');
      
      // Clear form
      _toAddressController.clear();
      _amountController.clear();
      
      // Refresh balance
      await _checkBalance();
    } catch (e) {
      _showError('Token Transfer failed: ${e.toString()}');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: Duration(seconds: 5),
      ),
    );
  }

  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        duration: Duration(seconds: 5),
      ),
    );
  }
}