// ignore_for_file: unnecessary_breaks

import 'package:english_words/english_words.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(ChangeNotifierProvider(
    create: (context) => MyAppState(),
    child: MyApp(),
  ));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => MyAppState(),
      child: MaterialApp(
        title: 'Namer App',
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(
              seedColor: const Color.fromARGB(255, 197, 188, 14)),
        ),
        home: MyHomePage(),
      ),
    );
  }
}

class MyAppState extends ChangeNotifier {
  WordPair _current = WordPair.random(); // Use a private field for state

  WordPair get current => _current; // Getter for read-only access

  void getNext() {
    _current = WordPair.random();
    notifyListeners();
  }

  List favorites = <WordPair>[];

  // Add methods for favorites management
  bool isFavorite(WordPair pair) => favorites.contains(pair);

  void toggleFavorite(WordPair pair) {
    if (favorites.contains(pair)) {
      favorites.remove(pair);
    } else {
      favorites.add(pair);
    }
    notifyListeners();
  }

  void removeFavorite(WordPair pair) {
    favorites.remove(pair);
    notifyListeners();
  }
}

// ...

class MyHomePage extends StatefulWidget {
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage>
    with SingleTickerProviderStateMixin {
  int selectedIndex = 0;
  final wordHistory = <WordPair>[];

  late AnimationController _controller; // Declare the controller

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this, // Pass `this` as the TickerProvider
      duration: const Duration(milliseconds: 200), // Set animation duration
    );
  }

  @override
  void dispose() {
    _controller.dispose(); // Dispose of the controller on widget disposal
    super.dispose();
  }

  void goToFavoritesPage() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => FavoritesPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<MyAppState>();

    void handleNext() {
      wordHistory.add(appState.current); // Add current word to history
      appState.getNext();

      _controller.forward(); // Start the animation forward
    }

    return LayoutBuilder(builder: (context, constraints) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Namer App'),
          actions: [
            IconButton(
              icon: const Icon(Icons.favorite),
              onPressed: goToFavoritesPage,
            ),
          ],
        ),
        body: Row(
          crossAxisAlignment: CrossAxisAlignment.start, // Align vertically
          children: [
            // NavigationRail (Responsive behavior)
            if (constraints.maxWidth >= 600)
              NavigationRail(
                extended: true,
                destinations: [
                  NavigationRailDestination(
                    icon: const Icon(Icons.home),
                    label: const Text('Home'),
                  ),
                  NavigationRailDestination(
                    icon: const Icon(Icons.favorite),
                    label: const Text('Favorites'),
                  ),
                ],
                selectedIndex: selectedIndex,
                onDestinationSelected: (value) {
                  setState(() {
                    selectedIndex = value;
                  });
                },
              ),
            Expanded(
              child: Stack(
                children: [
                  // Show previous words with decreasing opacity
                  Opacity(
                    opacity: 0.8,
                    child: ListView.builder(
                      itemCount: wordHistory.length,
                      itemBuilder: (context, index) {
                        final wordPair =
                            wordHistory[wordHistory.length - 1 - index];
                        return ListTile(
                          leading: const Icon(Icons.arrow_upward),
                          title: Text(wordPair.asLowerCase),
                        );
                      },
                    ),
                  ),
                  Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        BigCard(pair: appState.current),
                        const SizedBox(height: 10),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            ElevatedButton.icon(
                              onPressed: () =>
                                  appState.toggleFavorite(appState.current),
                              icon: Icon(
                                appState.isFavorite(appState.current)
                                    ? Icons.favorite
                                    : Icons.favorite_border,
                              ),
                              label: const Text('Like'),
                            ),
                            const SizedBox(width: 10),
                            // Wrap the "Next" button with AnimatedOpacity
                            ElevatedButton(
                              onPressed: handleNext,
                              child: const Text('Next'),
                            ),

                            const SizedBox(width: 10),
                          ],
                        ),
                      ],
                    ),
                  ),
                  // Optional: Add a subtle animation for the "Next" button press
                  AnimatedOpacity(
                    opacity:
                        _controller.value, // Use controller's value for opacity
                    duration: const Duration(milliseconds: 200),
                    child: ElevatedButton(
                      onPressed: handleNext,
                      child: const Text('Next'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    });
  }
}

// ...

class BigCard extends StatelessWidget {
  const BigCard({super.key, required this.pair});

  final WordPair pair;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context); // Access the theme
    final style = theme.textTheme.displayMedium!.copyWith(
      color: theme.colorScheme.onPrimary,
      backgroundColor: Color.fromARGB(0, 225, 118, 10),
    );

    return Card(
      color: theme.colorScheme.primary,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Text(
          pair.asLowerCase,
          style: style,
          semanticsLabel: "${pair.first} ${pair.second}",
        ),
      ),
    );
  }
}

class FavoritesPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();

    if (appState.favorites.isEmpty) {
      return Center(
        child: Text('No favorites yet.'),
      );
    }

    return ListView(
      children: [
        Padding(
          padding: const EdgeInsets.all(20),
          child: Text('You have '
              '${appState.favorites.length} favorites:'),
        ),
        for (var pair in appState.favorites)
          ListTile(
            leading: Icon(Icons.favorite),
            title: Text(pair.asLowerCase),
          ),
      ],
    );
  }
}
