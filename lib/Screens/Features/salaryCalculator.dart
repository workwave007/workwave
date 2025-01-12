import 'package:flutter/material.dart';
import 'package:intl/intl.dart';



class SalaryInputScreen extends StatefulWidget {
  @override
  _SalaryInputScreenState createState() => _SalaryInputScreenState();
}

class _SalaryInputScreenState extends State<SalaryInputScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _ctcController = TextEditingController();
  final TextEditingController _basePayController = TextEditingController();
  String? _selectedTaxRegime;

  void _calculateTakeHomeSalary() {
    if (!_formKey.currentState!.validate()) return;

    final double ctc = double.parse(_ctcController.text);
    final double basePay = double.parse(_basePayController.text);

    // Deductions
    final double employerPf = basePay * 0.12;
    final double gratuity = basePay * 0.0481;
    final double grossSalary = ctc - (employerPf + gratuity);

    // Taxable income
    final double standardDeduction = 50000;
    final double professionalTax = 2500;
    final double taxableIncome = grossSalary - standardDeduction;

    // Income tax calculation
    double incomeTax = 0.0;
    if (_selectedTaxRegime == 'New Tax Regime') {
      if (taxableIncome <= 300000) {
        incomeTax = 0.0;
      } else if (taxableIncome <= 600000) {
        incomeTax = (taxableIncome - 300000) * 0.05;
      } else if (taxableIncome <= 900000) {
        incomeTax = (300000 * 0.05) + (taxableIncome - 600000) * 0.10;
      } else if (taxableIncome <= 1200000) {
        incomeTax = (300000 * 0.05) + (300000 * 0.10) + (taxableIncome - 900000) * 0.15;
      } else if (taxableIncome <= 1500000) {
        incomeTax = (300000 * 0.05) + (300000 * 0.10) + (300000 * 0.15) + (taxableIncome - 1200000) * 0.20;
      } else {
        incomeTax = (300000 * 0.05) + (300000 * 0.10) + (300000 * 0.15) + (300000 * 0.20) + (taxableIncome - 1500000) * 0.30;
      }
    } else if (_selectedTaxRegime == 'Old Tax Regime') {
      if (taxableIncome <= 250000) {
        incomeTax = 0.0;
      } else if (taxableIncome <= 500000) {
        incomeTax = (taxableIncome - 250000) * 0.05;
      } else if (taxableIncome <= 1000000) {
        incomeTax = (250000 * 0.05) + (taxableIncome - 500000) * 0.20;
      } else {
        incomeTax = (250000 * 0.05) + (500000 * 0.20) + (taxableIncome - 1000000) * 0.30;
      }
    }

    // Final calculations
    final double employeePf = basePay * 0.12;
    final double deductions = employeePf + professionalTax + incomeTax;
    final double annualTakeHomeSalary = grossSalary - deductions;
    final double monthlyTakeHomeSalary = annualTakeHomeSalary / 12;

    // Navigate to result screen
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ResultScreen(
          annualTakeHome: annualTakeHomeSalary,
          monthlyTakeHome: monthlyTakeHomeSalary,
          grossSalary: grossSalary,
          incomeTax: incomeTax,
          professionalTax: professionalTax,
          employeePf: employeePf, ctc: ctc, baseSalary: basePay,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blueAccent, Colors.lightBlue.shade200],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: SingleChildScrollView(
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'Take-Home Salary Calculator',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: 20),
                    _buildInputField(
                      controller: _ctcController,
                      label: 'Enter your CTC (₹)',
                      hintText: 'e.g., 600000',
                      validator: (value) =>
                          value!.isEmpty ? 'Please enter your CTC' : null,
                    ),
                    SizedBox(height: 20),
                    _buildInputField(
                      controller: _basePayController,
                      label: 'Enter your Base Pay (₹)',
                      hintText: 'e.g., 300000',
                      validator: (value) =>
                          value!.isEmpty ? 'Please enter your Base Pay' : null,
                    ),
                    SizedBox(height: 20),
                    _buildDropdownField(),
                    SizedBox(height: 30),
                    ElevatedButton(
                      onPressed: _calculateTakeHomeSalary,
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 16), backgroundColor: Colors.blue.shade700,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        elevation: 5,
                      ),
                      child: Text(
                        'Calculate Take-Home Salary',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
  Widget _buildInputField({
    required TextEditingController controller,
    required String label,
    required String hintText,
    required String? Function(String?) validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: TextInputType.number,
      validator: validator,
      style: TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Colors.white70),
        hintText: hintText,
        hintStyle: TextStyle(color: Colors.white30),
        filled: true,
        fillColor: Colors.blue.shade600.withOpacity(0.6),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide.none,
        ),
        contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      ),
    );
  }

  Widget _buildDropdownField() {
    return DropdownButtonFormField<String>(
      value: _selectedTaxRegime,
      items: [
        DropdownMenuItem(
          value: 'New Tax Regime',
          child: Text('New Tax Regime'),
        ),
        DropdownMenuItem(
          value: 'Old Tax Regime',
          child: Text('Old Tax Regime'),
        ),
      ],
      onChanged: (value) => setState(() {
        _selectedTaxRegime = value!;
      }),
      validator: (value) =>
          value == null ? 'Please select a tax regime' : null,
      decoration: InputDecoration(
        labelText: 'Select Tax Regime',
        labelStyle: TextStyle(color: Colors.white70),
        filled: true,
        fillColor: Colors.blue.shade600.withOpacity(0.6),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide.none,
        ),
        contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      ),
      dropdownColor: Colors.blue.shade600,
      style: TextStyle(color: Colors.white),
    );
  }
}




class ResultScreen extends StatelessWidget {
  final double ctc;
  final double baseSalary;
  final double annualTakeHome;
  final double monthlyTakeHome;
  final double grossSalary;
  final double incomeTax;
  final double professionalTax;
  final double employeePf;

  ResultScreen({
    required this.ctc,
    required this.baseSalary,
    required this.annualTakeHome,
    required this.monthlyTakeHome,
    required this.grossSalary,
    required this.incomeTax,
    required this.professionalTax,
    required this.employeePf,
  });

  String formatCurrency(double value) {
    return NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: 2)
        .format(value);
  }
  

  @override
  Widget build(BuildContext context) {
    double totalDeductions =
        incomeTax + professionalTax + employeePf; // Total deductions
    double deductionPercentage =
        (totalDeductions / grossSalary) * 100; // Deduction percentage

    return Scaffold(
      appBar: AppBar(title: Text('Salary Breakdown')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Salary Breakdown',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.purple,
                        ),
                      ),
                      SizedBox(height: 20),
                      _buildBreakdownRow('CTC', formatCurrency(ctc)),
                      _buildBreakdownRow('Base Salary', formatCurrency(baseSalary)),
                      Divider(),
                      _buildBreakdownRow('Gross Salary', formatCurrency(grossSalary)),
                      Divider(),
                      _buildBreakdownRow(
                        'Income Tax',
                        '- ${formatCurrency(incomeTax)}',
                      ),
                      _buildBreakdownRow(
                        'Professional Tax',
                        '- ${formatCurrency(professionalTax)}',
                      ),
                      _buildBreakdownRow(
                        'Employee PF',
                        '- ${formatCurrency(employeePf)}',
                      ),
                      Divider(thickness: 1.5),
                      _buildBreakdownRow(
                        'Total Deductions',
                        '- ${formatCurrency(totalDeductions)}',
                        isBold: true,
                      ),
                      SizedBox(height: 10),
                      Text(
                        'Percentage of Salary Deducted: ${deductionPercentage.toStringAsFixed(2)}%',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.redAccent,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            SizedBox(height: 20),
            Card(
              color: Colors.purple,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 6,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      'Monthly Take-Home Salary ',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white70,
                      ),
                    ),
                    SizedBox(height: 10),
                    Text(
                      formatCurrency(monthlyTakeHome),
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: 10),
                    Text(
                      'Annual Take-Home Salary: ${formatCurrency(annualTakeHome)}',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Back'),
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: 12),
                textStyle: TextStyle(fontSize: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBreakdownRow(String label, String value, {bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 16,
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}