import 'package:flutter/material.dart';
import '../models/category.dart';
import '../models/meal.dart';
import '../services/api_service.dart';
import '../widgets/category_chip.dart';
import '../widgets/recipe_card.dart';
import 'detail_page.dart';

class RecipeHomePage extends StatefulWidget {
  const RecipeHomePage({super.key});

  @override
  State<RecipeHomePage> createState() => _RecipeHomePageState();
}

class _RecipeHomePageState extends State<RecipeHomePage> {
  final ScrollController _categoryScrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();

  List<Category> categories = [];
  List<Meal> meals = [];
  String activeCategory = 'All';
  bool isLoading = true;

  bool showRightArrow = true;
  bool showLeftArrow = false;
  bool showHintRight = false;
  bool showHintLeft = false;

  @override
  void initState() {
    super.initState();
    _fetchInitialData();

    _categoryScrollController.addListener(() {
      if (!_categoryScrollController.hasClients) return;
      final maxScroll = _categoryScrollController.position.maxScrollExtent;
      final offset = _categoryScrollController.offset;

      setState(() {
        showLeftArrow = offset > 50;
        showRightArrow = offset < maxScroll - 50;
      });
    });
  }

  Future<void> _fetchInitialData() async {
    categories = await ApiService.fetchCategories();
    meals = await ApiService.searchMeals();
    setState(() {
      isLoading = false;
      showHintRight = true;
    });

    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) setState(() => showHintRight = false);
    });
  }

  void _onSelectCategory(String category) async {
    FocusScope.of(context).unfocus(); // Tutup keyboard
    _searchController.clear(); // Reset pencarian jika pilih kategori

    setState(() {
      activeCategory = category;
      isLoading = true;
    });

    meals = await ApiService.searchMeals(category: category == 'All' ? null : category);
    setState(() => isLoading = false);
  }

  Future<void> _onSearch(String query) async {
    setState(() {
      isLoading = true;
      activeCategory = 'All';
    });

    meals = await ApiService.searchMeals(query: query.isEmpty ? null : query);
    setState(() => isLoading = false);
  }

  @override
  void dispose() {
    _categoryScrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const mainGreen = Color(0xFF02462E);
    const accentYellow = Color(0xFFFEC700);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'EasyCooking',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
          ),
        ),
        centerTitle: true,
        backgroundColor: mainGreen,
      ),
      body: CustomScrollView(
        slivers: [
          // 🔍 Search Bar
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
              child: TextField(
                controller: _searchController,
                onSubmitted: _onSearch,
                textInputAction: TextInputAction.search,
                decoration: InputDecoration(
                  hintText: 'Search recipes...',
                  prefixIcon: const Icon(Icons.search, color: mainGreen),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear, color: mainGreen),
                          onPressed: () {
                            _searchController.clear();
                            _onSearch('');
                          },
                        )
                      : null,
                  filled: true,
                  fillColor: Colors.grey[100],
                  contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: BorderSide.none,
                  ),
                ),
                onChanged: (value) {
                  setState(() {}); // Update suffixIcon visibility
                },
              ),
            ),
          ),

          // 🍴 Category Title
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: const Text(
                'Categories',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: mainGreen,
                ),
              ),
            ),
          ),

          // 🔄 Category Scroll + Panah + Tulisan Geser
          SliverToBoxAdapter(
            child: Stack(
              children: [
                SizedBox(
                  height: 95,
                  child: isLoading && categories.isEmpty
                      ? const Center(
                          child: CircularProgressIndicator(color: mainGreen),
                        )
                      : SingleChildScrollView(
                          controller: _categoryScrollController,
                          scrollDirection: Axis.horizontal,
                          physics: const BouncingScrollPhysics(),
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          child: Row(
                            children: [
                              CategoryChip(
                                name: 'All',
                                imageUrl: null,
                                selected: activeCategory == 'All',
                                onTap: () => _onSelectCategory('All'),
                                activeColor: accentYellow,
                                textColor: mainGreen,
                              ),
                              ...categories.map(
                                (cat) => CategoryChip(
                                  name: cat.strCategory,
                                  imageUrl: cat.strCategoryThumb,
                                  selected: activeCategory == cat.strCategory,
                                  onTap: () => _onSelectCategory(cat.strCategory),
                                  activeColor: accentYellow,
                                  textColor: mainGreen,
                                ),
                              ),
                              const SizedBox(width: 80),
                            ],
                          ),
                        ),
                ),

                // ⬅️ Panah Kiri
                if (showLeftArrow)
                  Positioned(
                    left: 8,
                    top: 25,
                    child: GestureDetector(
                      onTap: () {
                        _categoryScrollController.animateTo(
                          _categoryScrollController.offset - 200,
                          duration: const Duration(milliseconds: 400),
                          curve: Curves.easeOut,
                        );
                        setState(() => showHintLeft = true);
                        Future.delayed(const Duration(seconds: 2),
                            () => setState(() => showHintLeft = false));
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 250),
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.9),
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: const [
                            BoxShadow(
                              color: Colors.black12,
                              blurRadius: 4,
                              offset: Offset(2, 2),
                            )
                          ],
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.arrow_back_ios, size: 14, color: mainGreen),
                            const SizedBox(width: 4),
                            AnimatedOpacity(
                              opacity: showHintLeft ? 1 : 0,
                              duration: const Duration(milliseconds: 300),
                              child: const Text(
                                'Geser',
                                style: TextStyle(
                                  color: mainGreen,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                // ➡️ Panah Kanan
                if (showRightArrow)
                  Positioned(
                    right: 8,
                    top: 25,
                    child: GestureDetector(
                      onTap: () {
                        _categoryScrollController.animateTo(
                          _categoryScrollController.offset + 200,
                          duration: const Duration(milliseconds: 400),
                          curve: Curves.easeOut,
                        );
                        setState(() => showHintRight = true);
                        Future.delayed(const Duration(seconds: 2),
                            () => setState(() => showHintRight = false));
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 250),
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.9),
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: const [
                            BoxShadow(
                              color: Colors.black12,
                              blurRadius: 4,
                              offset: Offset(2, 2),
                            )
                          ],
                        ),
                        child: Row(
                          children: [
                            AnimatedOpacity(
                              opacity: showHintRight ? 1 : 0,
                              duration: const Duration(milliseconds: 300),
                              child: const Text(
                                'Geser',
                                style: TextStyle(
                                  color: mainGreen,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                            const SizedBox(width: 4),
                            const Icon(Icons.arrow_forward_ios, size: 14, color: mainGreen),
                          ],
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),

          // 🍲 Recipes List
          isLoading
              ? const SliverFillRemaining(
                  child: Center(child: CircularProgressIndicator(color: mainGreen)),
                )
              : meals.isEmpty
                  ? const SliverFillRemaining(
                      child: Center(
                        child: Text(
                          'No recipes found 😢',
                          style: TextStyle(color: mainGreen, fontSize: 16),
                        ),
                      ),
                    )
                  : SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, i) {
                          final m = meals[i];
                          return Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            child: RecipeCard(
                              meal: m,
                              onTap: () async {
                                final full = await ApiService.fetchMealDetail(m.idMeal!);
                                if (full != null && context.mounted) {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => RecipeDetailPage(meal: full),
                                    ),
                                  );
                                }
                              },
                              color: mainGreen,
                              accentColor: accentYellow,
                            ),
                          );
                        },
                        childCount: meals.length,
                      ),
                    ),
        ],
      ),
    );
  }
}
