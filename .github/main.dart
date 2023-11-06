import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (context) => TipCalculatorModel(),
      child: TipCalculatorApp(),
    ),
  );
}

class TipCalculatorApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: TipCalculatorScreen(),
    );
  }
}

class TipCalculatorScreen extends StatefulWidget {
  @override
  _TipCalculatorScreenState createState() => _TipCalculatorScreenState();
}

class _TipCalculatorScreenState extends State<TipCalculatorScreen> {
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> _screens = [
      CalculatorWidget(context: context),
      HistoryScreen(),
    ];

    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 73, 111, 180),
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 54, 52, 52),
        title: const Text("Tip Calculator"),
      ),
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: const Color.fromARGB(255, 54, 52, 52),
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.table_view),
            label: 'Calculator',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history),
            label: 'History',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        onTap: _onItemTapped,
      ),
    );
  }
}

class TipCalculatorModel with ChangeNotifier {
  double billAmount = 0.00;
  double tipPercentage = 0.15;
  List<String> history = [];

  void calculateTip() {
    final tipAmount = billAmount * tipPercentage;
    final totalAmount = billAmount + tipAmount;
    final formattedBill = billAmount.toStringAsFixed(2);
    final formattedTip = tipAmount.toStringAsFixed(2);
    final formattedTotal = totalAmount.toStringAsFixed(2);

    final historyEntry =
        '\$$formattedBill With ${tipPercentage * 100}% Tip\nTip: \$$formattedTip    Total: \$$formattedTotal';
    history.insert(0, historyEntry);

    notifyListeners();
  }
}

class CalculatorWidget extends StatefulWidget {
  final billAmountController = TextEditingController();
  final customTipController = TextEditingController();
  final BuildContext context;

  CalculatorWidget({Key? key, required this.context}) : super(key: key);

  @override
  _CalculatorWidgetState createState() => _CalculatorWidgetState();
}

class _CalculatorWidgetState extends State<CalculatorWidget> {
  bool isCustomTipMode = false;
  double customTip = 0.0;
  double originalBillAmount = 0.0; // Store the original bill amount

  @override
  void initState() {
    super.initState();
    widget.billAmountController.addListener(updateBillAmount);
  }

  void updateBillAmount() {
    final enteredBillAmount =
        double.tryParse(widget.billAmountController.text) ?? 0.00;
    final model =
        Provider.of<TipCalculatorModel>(widget.context, listen: false);

    if (!isCustomTipMode) {
      originalBillAmount = enteredBillAmount; // Store the original bill amount
      model.billAmount = enteredBillAmount;
    }
  }

  void toggleCustomTipMode() {
    setState(() {
      isCustomTipMode = !isCustomTipMode;
    });
  }

  void applyCustomTip() {
    customTip = double.tryParse(widget.customTipController.text) ?? 0.0;
    final model =
        Provider.of<TipCalculatorModel>(widget.context, listen: false);
    model.tipPercentage = customTip / 100;
    model.calculateTip();
    toggleCustomTipMode();
    widget.customTipController.text = "";
  }

  ElevatedButton buildNumberButton(String label, Function() onPressed) {
    return ElevatedButton(
      onPressed: () {
        if (isCustomTipMode && label == ("C")) {
          widget.customTipController.text = " ";
        } else if (isCustomTipMode) {
          widget.customTipController.text += label;
        } else {
          onPressed();
        }
      },
      style: ButtonStyle(
        backgroundColor: MaterialStateProperty.all(
          const Color.fromARGB(255, 54, 52, 52),
        ),
        fixedSize: MaterialStateProperty.all(const Size(80, 80)),
      ),
      child: Text(
        label,
        style: const TextStyle(fontSize: 20, color: Colors.white),
      ),
    );
  }

  ElevatedButton buildPercentageButton(String label, Function() onPressed) {
    return ElevatedButton(
      onPressed: () {
        if (isCustomTipMode && label == ("C")) {
          widget.customTipController.text = " ";
        } else if (isCustomTipMode) {
          widget.customTipController.text += label;
        } else {
          onPressed();
        }
      },
      style: ButtonStyle(
        backgroundColor: MaterialStateProperty.all(
          const Color.fromARGB(255, 38, 63, 123),
        ),
        fixedSize: MaterialStateProperty.all(const Size(80, 80)),
      ),
      child: Text(
        label,
        style: const TextStyle(fontSize: 20, color: Colors.white),
      ),
    );
  }

  ElevatedButton buildCustomButton() {
    if (isCustomTipMode) {
      return ElevatedButton(
        onPressed: applyCustomTip,
        style: ButtonStyle(
          backgroundColor: MaterialStateProperty.all(
            const Color.fromARGB(255, 54, 52, 52),
          ),
          fixedSize: MaterialStateProperty.all(const Size(80, 80)),
        ),
        child: const Text(
          'Apply',
          style: TextStyle(fontSize: 12, color: Colors.white),
        ),
      );
    } else {
      return ElevatedButton(
        onPressed: toggleCustomTipMode,
        style: ButtonStyle(
          backgroundColor: MaterialStateProperty.all(
            Color.fromARGB(255, 38, 63, 123),
          ),
          fixedSize: MaterialStateProperty.all(const Size(80, 80)),
        ),
        child: const Text(
          'Custom',
          style: TextStyle(fontSize: 12, color: Colors.white),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final model = Provider.of<TipCalculatorModel>(context);
    final tipAmount =
        isCustomTipMode ? customTip : model.billAmount * model.tipPercentage;
    final totalAmount = isCustomTipMode
        ? originalBillAmount + tipAmount // Use the original bill amount
        : model.billAmount + tipAmount;
    final formattedTip = tipAmount.toStringAsFixed(2);
    final formattedTotal = totalAmount.toStringAsFixed(2);

    return SingleChildScrollView(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          const SizedBox(height: 20),
          Align(
            child: TextFormField(
              controller: widget.billAmountController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Bill Amount',
              ),
            ),
          ),
          if (isCustomTipMode)
            Align(
              child: TextFormField(
                controller: widget.customTipController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Custom Tip %',
                ),
              ),
            ),
          const SizedBox(height: 50),
          Align(
            child: Container(
              margin: const EdgeInsets.all(10),
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                border: Border.all(
                  color: const Color.fromARGB(255, 54, 52, 52),
                ),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                'Total: \$$formattedTotal',
                style: const TextStyle(fontSize: 24),
              ),
            ),
          ),
          Align(
            child: Container(
              margin: const EdgeInsets.all(10),
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                border: Border.all(
                  color: const Color.fromARGB(255, 54, 52, 52),
                ),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                'Tip: \$$formattedTip',
                style: const TextStyle(fontSize: 24),
              ),
            ),
          ),
          const SizedBox(height: 80),
          // Move the number pad rows below the display rows
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              buildNumberButton("7", () {
                widget.billAmountController.text += "7";
              }),
              buildNumberButton("8", () {
                widget.billAmountController.text += "8";
              }),
              buildNumberButton("9", () {
                widget.billAmountController.text += "9";
              }),
              buildCustomButton(),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              buildNumberButton("4", () {
                widget.billAmountController.text += "4";
              }),
              buildNumberButton("5", () {
                widget.billAmountController.text += "5";
              }),
              buildNumberButton("6", () {
                widget.billAmountController.text += "6";
              }),
              buildPercentageButton("15%", () {
                model.tipPercentage = 0.15;
                model.calculateTip();
              }),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              buildNumberButton("1", () {
                widget.billAmountController.text += "1";
              }),
              buildNumberButton("2", () {
                widget.billAmountController.text += "2";
              }),
              buildNumberButton("3", () {
                widget.billAmountController.text += "3";
              }),
              buildPercentageButton("18%", () {
                model.tipPercentage = 0.18;
                model.calculateTip();
              }),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              buildNumberButton(".", () {
                widget.billAmountController.text += ".";
              }),
              buildNumberButton("0", () {
                widget.billAmountController.text += "0";
              }),
              buildNumberButton("C", () {
                widget.billAmountController.text = "";
                widget.customTipController.text = "";
              }),
              buildPercentageButton("20%", () {
                model.tipPercentage = 0.20;
                model.calculateTip();
              }),
            ],
          ),
        ],
      ),
    );
  }
}

class HistoryScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final model = Provider.of<TipCalculatorModel>(context);

    return ListView.builder(
      itemCount: model.history.length,
      itemBuilder: (context, index) {
        return ListTile(
          title: Text(model.history[index]),
          trailing: IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () {
              model.history.removeAt(index);
              model.notifyListeners();
            },
          ),
        );
      },
    );
  }
}
