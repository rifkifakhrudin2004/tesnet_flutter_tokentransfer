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
  
  String _balance = '0';
  String _currentAddress = '';
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Token Transfer'),
        backgroundColor: Colors.blue,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
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
            Card(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Text(
                      'Token Balance: $_balance STK',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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
            Card(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Text(
                      'Transfer Tokens',
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
                        labelText: 'Amount (STK)',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.monetization_on),
                      ),
                      keyboardType: TextInputType.number,
                    ),
                    SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _isLoading ? null : _transferToken,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        padding: EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: _isLoading 
                        ? CircularProgressIndicator() 
                        : Text('Transfer Tokens'),
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
      final balance = await _web3Service.getBalance(address.hex);
      setState(() => _balance = balance);
      
      _showSuccess('Balance updated successfully');
    } catch (e) {
      _showError('Error checking balance: ${e.toString()}');
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
      
      _showSuccess('Transfer successful!\nTransaction Hash: $result');
      
      // Clear form
      _toAddressController.clear();
      _amountController.clear();
      
      // Refresh balance
      await _checkBalance();
    } catch (e) {
      _showError('Transfer failed: ${e.toString()}');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
      ),
    );
  }
}