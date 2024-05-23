import 'package:flutter/material.dart';
import 'package:english_words/english_words.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => MyAppState(),
      child: Consumer<MyAppState>(
        builder: (context, appState, child) {
          return MaterialApp(
            title: 'Team 1 App',
            theme: ThemeData(
              useMaterial3: true,
              colorScheme: ColorScheme.fromSeed(seedColor: appState.seedColor),
            ),
            home: MyHomePage(),
            debugShowCheckedModeBanner: false,
          );
        },
      ),
    );
  }
}

class MyAppState extends ChangeNotifier {
  var current = WordPair.random();
  var history = <WordPair>[];

  GlobalKey? historyListKey;

  bool showHistory = true;
  Color seedColor = Colors.deepOrange;

  void getNext() {
    history.insert(0, current);
    var animatedList = historyListKey?.currentState as AnimatedListState?;
    animatedList?.insertItem(0);
    current = WordPair.random();
    notifyListeners();
  }

  var favorites = <WordPair>[];

  void toggleFavorite([WordPair? pair]) {
    pair = pair ?? current;
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

  void toggleHistoryVisibility() {
    showHistory = !showHistory;
    notifyListeners();
  }

  void updateSeedColor(Color color) {
    seedColor = color;
    notifyListeners();
  }
}

class MyHomePage extends StatefulWidget {
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  var selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    var colorScheme = Theme.of(context).colorScheme;

    Widget page;
    switch (selectedIndex) {
      case 0:
        page = GeneratorPage();
        break;
      case 1:
        page = FavoritesPage();
        break;
      case 2:
        page = SettingsPage();
        break;
      case 3:
        page = AboutPage();
        break;
      case 4:
        page = ProfilePage();
        break;
      case 5:
        page = ImageListPage();
        break;
      default:
        throw UnimplementedError('no widget for $selectedIndex');
    }

    var mainArea = ColoredBox(
      color: colorScheme.surfaceVariant,
      child: AnimatedSwitcher(
        duration: Duration(milliseconds: 200),
        child: page,
      ),
    );

    return Scaffold(
      appBar: AppBar(
        title: Text('Team 1 App'),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                color: colorScheme.primary,
              ),
              child: Text(
                'Menu',
                style: TextStyle(
                  color: colorScheme.onPrimary,
                  fontSize: 24,
                ),
              ),
            ),
            ListTile(
              leading: Icon(Icons.home),
              title: Text('Home'),
              onTap: () {
                Navigator.pop(context);
                setState(() {
                  selectedIndex = 0;
                });
              },
            ),
            ListTile(
              leading: Icon(Icons.favorite),
              title: Text('Favorites'),
              onTap: () {
                Navigator.pop(context);
                setState(() {
                  selectedIndex = 1;
                });
              },
            ),
            ListTile(
              leading: Icon(Icons.settings),
              title: Text('Settings'),
              onTap: () {
                Navigator.pop(context);
                setState(() {
                  selectedIndex = 2;
                });
              },
            ),
            ListTile(
              leading: Icon(Icons.info),
              title: Text('About'),
              onTap: () {
                Navigator.pop(context);
                setState(() {
                  selectedIndex = 3;
                });
              },
            ),
            ListTile(
              leading: Icon(Icons.person),
              title: Text('Profile'),
              onTap: () {
                Navigator.pop(context);
                setState(() {
                  selectedIndex = 4;
                });
              },
            ),
            ListTile(
              leading: Icon(Icons.image),
              title: Text('Image List'),
              onTap: () {
                Navigator.pop(context);
                setState(() {
                  selectedIndex = 5;
                });
              },
            ),
          ],
        ),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          return mainArea;
        },
      ),
    );
  }
}

class GeneratorPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();
    var pair = appState.current;

    IconData icon;
    if (appState.favorites.contains(pair)) {
      icon = Icons.favorite;
    } else {
      icon = Icons.favorite_border;
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (appState.showHistory)
            Expanded(
              flex: 3,
              child: HistoryListView(),
            ),
          SizedBox(height: 10),
          BigCard(pair: pair),
          SizedBox(height: 10),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              ElevatedButton.icon(
                onPressed: () {
                  appState.toggleFavorite();
                },
                icon: Icon(icon),
                label: Text('Like'),
              ),
              SizedBox(width: 10),
              ElevatedButton(
                onPressed: () {
                  appState.getNext();
                },
                child: Text('Next'),
              ),
            ],
          ),
          Spacer(flex: 2),
        ],
      ),
    );
  }
}

class BigCard extends StatelessWidget {
  const BigCard({
    Key? key,
    required this.pair,
  }) : super(key: key);

  final WordPair pair;
  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);
    var style = theme.textTheme.displayMedium!.copyWith(
      color: theme.colorScheme.onPrimary,
    );

    return Card(
      color: theme.colorScheme.primary,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: AnimatedSize(
          duration: Duration(milliseconds: 200),
          child: MergeSemantics(
            child: Wrap(
              children: [
                Text(
                  pair.first,
                  style: style.copyWith(fontWeight: FontWeight.w200),
                ),
                Text(
                  pair.second,
                  style: style.copyWith(fontWeight: FontWeight.bold),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class FavoritesPage extends StatefulWidget {
  @override
  _FavoritesPageState createState() => _FavoritesPageState();
}

class _FavoritesPageState extends State<FavoritesPage> {
  TextEditingController _searchController = TextEditingController();
  late List<WordPair> filteredFavorites;

  bool _sortAscending = true;

  @override
  void initState() {
    super.initState();
    filteredFavorites = context.read<MyAppState>().favorites;
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    final searchTerm = _searchController.text.toLowerCase();
    final allFavorites = context.read<MyAppState>().favorites;

    setState(() {
      filteredFavorites = allFavorites.where((pair) {
        final pairText = pair.asLowerCase;
        return pairText.contains(searchTerm);
      }).toList();
    });
  }

  void _toggleSortOrder() {
    setState(() {
      _sortAscending = !_sortAscending;
      filteredFavorites.sort((a, b) => _sortAscending
          ? a.asLowerCase.compareTo(b.asLowerCase)
          : b.asLowerCase.compareTo(a.asLowerCase));
    });
  }

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);
    var appState = context.watch<MyAppState>();

    if (appState.favorites.isEmpty) {
      return Center(
        child: Text('No favorites yet.'),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    labelText: 'Search favorites',
                    prefixIcon: Icon(Icons.search),
                  ),
                ),
              ),
              IconButton(
                icon: Icon(
                  _sortAscending ? Icons.sort : Icons.sort_by_alpha,
                  semanticLabel: 'Sort',
                ),
                onPressed: _toggleSortOrder,
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Text(
            'You have ${filteredFavorites.length} favorites:',
          ),
        ),
        Expanded(
          child: GridView.builder(
            gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
              maxCrossAxisExtent: 400,
              childAspectRatio: 400 / 80,
            ),
            itemCount: filteredFavorites.length,
            itemBuilder: (context, index) {
              var pair = filteredFavorites[index];
              return ListTile(
                leading: IconButton(
                  icon: Icon(Icons.delete_outline, semanticLabel: 'Delete'),
                  color: theme.colorScheme.primary,
                  onPressed: () {
                    appState.removeFavorite(pair);
                  },
                ),
                title: Text(
                  pair.asLowerCase,
                  semanticsLabel: pair.asPascalCase,
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class SettingsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();
    var theme = Theme.of(context);

    return ListView(
      padding: EdgeInsets.all(20),
      children: [
        SwitchListTile(
          title: Text('Show History'),
          value: appState.showHistory,
          onChanged: (value) {
            appState.toggleHistoryVisibility();
          },
        ),
        ListTile(
          title: Text('Change Theme Color'),
          trailing: Icon(Icons.color_lens),
          onTap: () async {
            var color = await showDialog(
              context: context,
              builder: (context) =>
                  ThemeColorPicker(selectedColor: appState.seedColor),
            );
            if (color != null) {
              appState.updateSeedColor(color);
            }
          },
        ),
      ],
    );
  }
}

class ThemeColorPicker extends StatelessWidget {
  final Color selectedColor;

  ThemeColorPicker({required this.selectedColor});

  @override
  Widget build(BuildContext context) {
    return SimpleDialog(
      title: Text('Select Theme Color'),
      children: [
        ColorOption(Colors.deepOrange, selectedColor),
        ColorOption(Colors.blue, selectedColor),
        ColorOption(Colors.green, selectedColor),
        ColorOption(Colors.purple, selectedColor),
      ],
    );
  }
}

class ColorOption extends StatelessWidget {
  final Color color;
  final Color selectedColor;

  ColorOption(this.color, this.selectedColor);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(
        Icons.circle,
        color: color,
      ),
      title: Text(color.toString().split('(0xff')[1].split(')')[0]),
      onTap: () {
        Navigator.of(context).pop(color);
      },
      selected: color == selectedColor,
      trailing: color == selectedColor ? Icon(Icons.check) : null,
    );
  }
}

class AboutPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'About Team 1 App',
            style: Theme.of(context).textTheme.headline5,
          ),
          SizedBox(height: 20),
          Text(
            'This application generates random word pairs for your amusement. '
            'You can like your favorite word pairs and view them in the Favorites section.',
          ),
          SizedBox(height: 20),
          Text(
            'Developed by Team 1 Bootcamp Flutter TIF Polije PSDKU Nganjuk.',
            style: Theme.of(context).textTheme.bodyText2,
          ),
        ],
      ),
    );
  }
}

class ProfilePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);

    return Padding(
      padding: EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Profile',
            style: theme.textTheme.headline5,
          ),
          SizedBox(height: 20),
          ListTile(
            leading: Icon(Icons.person),
            title: Text('Username: tomdelonge'),
          ),
          ListTile(
            leading: Icon(Icons.email),
            title: Text('Email: tom182@email.com'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => EditProfilePage()),
              );
            },
            child: Text('Edit Profile'),
          ),
        ],
      ),
    );
  }
}

class EditProfilePage extends StatefulWidget {
  @override
  _EditProfilePageState createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController _usernameController = TextEditingController();
  TextEditingController _emailController = TextEditingController();

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Profile'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Edit Username:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              TextFormField(
                controller: _usernameController,
                decoration: InputDecoration(hintText: 'Enter new username'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a valid username';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20),
              Text(
                'Edit Email:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              TextFormField(
                controller: _emailController,
                decoration: InputDecoration(hintText: 'Enter new email'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a valid email address';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    // Implement logic to update username and email
                    String newUsername = _usernameController.text;
                    String newEmail = _emailController.text;
                    // Simpan perubahan profil dan kembali ke halaman sebelumnya
                    Navigator.of(context).pop();
                  }
                },
                child: Text('Save Changes'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class HistoryListView extends StatefulWidget {
  const HistoryListView({Key? key}) : super(key: key);

  @override
  State<HistoryListView> createState() => _HistoryListViewState();
}

class _HistoryListViewState extends State<HistoryListView> {
  final _key = GlobalKey();

  static const Gradient _maskingGradient = LinearGradient(
    colors: [Colors.transparent, Colors.black],
    stops: [0.0, 0.5],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<MyAppState>();
    appState.historyListKey = _key;

    return ShaderMask(
      shaderCallback: (bounds) => _maskingGradient.createShader(bounds),
      blendMode: BlendMode.dstIn,
      child: AnimatedList(
        key: _key,
        reverse: true,
        padding: EdgeInsets.only(top: 100),
        initialItemCount: appState.history.length,
        itemBuilder: (context, index, animation) {
          final pair = appState.history[index];
          return SizeTransition(
            sizeFactor: animation,
            child: Center(
              child: TextButton.icon(
                onPressed: () {
                  appState.toggleFavorite(pair);
                },
                icon: appState.favorites.contains(pair)
                    ? Icon(Icons.favorite, size: 12)
                    : SizedBox(),
                label: Text(
                  pair.asLowerCase,
                  semanticsLabel: pair.asPascalCase,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class ImageItem {
  final String title;
  final String imageUrl;

  ImageItem({required this.title, required this.imageUrl});
}

class ImageListPage extends StatelessWidget {
  final List<ImageItem> imageItems = [
    ImageItem(
        title: 'Image 1',
        imageUrl:
            'https://ew.com/thmb/3caakBmef-ZzbinYMN9JM2XAjJ4=/1500x0/filters:no_upscale():max_bytes(150000):strip_icc():format(webp)/tom-delonge-032224-3bf0e79696a3486b8d96f220f4c3ec04.jpg'),
    ImageItem(
        title: 'Image 2',
        imageUrl:
            'https://hardrockfm.com/wp-content/uploads/2022/06/attachment-billie_joe_armstrong_green_day_live_2022-640x426.jpeg'),
    ImageItem(
        title: 'Image 3',
        imageUrl:
            'https://www.rollingstone.com/wp-content/uploads/2023/09/Deryck-Whibley-Hospitalized.jpg'),
    ImageItem(
        title: 'Image 4',
        imageUrl:
            'https://www.timesonline.com/gcdn/presto/2023/09/02/NBCT/c2da11b2-0edf-4888-a603-6eea8eb9745e-simple_plan_singer_2.jpg'),
    ImageItem(
        title: 'Image 5',
        imageUrl:
            'https://images.kerrangcdn.com/images/2020/12/Ben-Barlow-Neck-Deep-solo-portrait-2020-credit-Tom-Barnes.jpg'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Image List'),
      ),
      body: ListView.builder(
        itemCount: imageItems.length,
        itemBuilder: (context, index) {
          final item = imageItems[index];
          return ListTile(
            title: Text(item.title),
            leading: CircleAvatar(
              backgroundImage: NetworkImage(item.imageUrl),
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ImageDetailPage(item)),
              );
            },
          );
        },
      ),
    );
  }
}

class ImageDetailPage extends StatelessWidget {
  final ImageItem imageItem;

  ImageDetailPage(this.imageItem);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Image Detail'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment:
              MainAxisAlignment.start, // Ubah menjadi MainAxisAlignment.start
          crossAxisAlignment:
              CrossAxisAlignment.center, // Tetapkan alignment ke tengah
          children: [
            Padding(
              padding: EdgeInsets.only(top: 20), // Tambahkan padding ke atas
              child: Container(
                width: 200, // Atur lebar gambar
                height: 200, // Atur tinggi gambar
                decoration: BoxDecoration(
                  borderRadius:
                      BorderRadius.circular(12), // Tambahkan border radius
                  image: DecorationImage(
                    image: NetworkImage(imageItem.imageUrl),
                    fit: BoxFit
                        .cover, // Agar gambar mengisi container dengan baik
                  ),
                ),
              ),
            ),
            SizedBox(height: 20),
            Text(
              imageItem.title,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}
