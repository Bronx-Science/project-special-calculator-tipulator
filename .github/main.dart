import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (context) => TipCalculatorModel(),
      child: TipCalculatorApp(),
    ),
  );
} //just the main method. it runs the app nothing interesting

class TipCalculatorApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: TipCalculatorScreen(),
    );
  }
  //makes it so when you open the app 
  //the first thing you see if the calulcation screen
  //also got rid of the debug banner on the top right
} 

class TipCalculatorScreen extends StatefulWidget {
  @override
  TipCalculatorScreenState createState() => TipCalculatorScreenState();
  //this is the Calculation screen widget, it makes the screen.
  //it calls the TipCalculatorScreenState which changes the state of
  //the screen in other words how the screen looks
} 

class TipCalculatorScreenState extends State<TipCalculatorScreen> {
  //this class changes the state of the calculation screen
  //I mentioned earlier
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
    final List<Widget> screens = [
      CalculatorWidget(context: context),
      HistoryScreen(),
    ];

    return Scaffold( 
      //color of the background
      backgroundColor: const Color.fromARGB(255, 73, 111, 180),
      appBar: AppBar(
        //color of the appbar
        backgroundColor: const Color.fromARGB(255, 54, 52, 52),
        title: const Text("Tip Calculator"),
      ),
      body: screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        //color of the navigation bar
        backgroundColor: const Color.fromARGB(255, 54, 52, 52),
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            //creates a calculation tab icon for navigation
            icon: Icon(Icons.table_view),
            label: 'Calculator',
          ),
          BottomNavigationBarItem(
            //creates a history tab icon for navigation
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
  //creates a model of a calculation. each model has it's own bill amount
  //and tip percentage chosen by the user. 
  //everytime a calculation happens a model is created
  double billAmount = 0.00;
  double tipPercentage = 0.15;
  List<String> history = [];

  void calculateTip() {
    //creates necessary variables used in tip calculations and displays
    final tipAmount = billAmount * tipPercentage;
    final totalAmount = billAmount + tipAmount;
    final formattedBill = billAmount.toStringAsFixed(2);
    final formattedTip = tipAmount.toStringAsFixed(2);
    final formattedTotal = totalAmount.toStringAsFixed(2);

    final historyEntry =
    //formatting how the history will look like for each calculation
        '\$$formattedBill With ${tipPercentage * 100}% Tip\nTip: \$$formattedTip    Total: \$$formattedTotal';
    history.insert(0, historyEntry);

    notifyListeners();
  }
}

class CalculatorWidget extends StatefulWidget {
  //the heart of the calculator functionality and UI
  final billAmountController = TextEditingController(); //keeps track of the Bill Amount
  final customTipController = TextEditingController(); //keeps track of the custom tip amount
  final BuildContext context;

  CalculatorWidget({Key? key, required this.context}) : super(key: key);

  @override
  _CalculatorWidgetState createState() => _CalculatorWidgetState();
}

class _CalculatorWidgetState extends State<CalculatorWidget> {
  bool isCustomTipMode = false; //determines if the number inputted is
                                //for bill amount or custom tip
  double customTip = 0.0; //store custom tip
  double originalBillAmount = 0.0; //store the original bill amount

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
      originalBillAmount = enteredBillAmount; //store the original bill amount
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
    //creates the number buttons
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
    //creates the percentage buttons. same as previous buildbutton
    //class but changes color of percentage buttons
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
    //builds the custom tip button and apply button
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
        ? originalBillAmount + tipAmount
        : model.billAmount + tipAmount;
    final formattedTip = tipAmount.toStringAsFixed(2);
    final formattedTotal = totalAmount.toStringAsFixed(2);

    return SingleChildScrollView(
      //builds UI displaying bill amount, total, and tip 
      //as well as custom tip when it is clicked
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
          //building number pads
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
  //cretes the history screen by taking data from the calculation tab
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
